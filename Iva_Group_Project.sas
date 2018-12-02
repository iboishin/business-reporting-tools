libname group 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment';

*import databases;

DATA group.airlines;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\airlines.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs carrier $ airline_name :$27.;
run;

DATA group.airports;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\airports.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs faa $ name :$60. lat lon alt tz dst $ tzone :$20.;
run;

DATA group.flights;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\flights.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs year month day dep_time sched_dep_time dep_delay arr_time sched_arr_time arr_delay carrier $ flight tailnum $
		origin $ dest $ air_time distance hour minute time_hour $19.;
	IF arr_delay = . THEN arr_delay = arr_time - arr_delay;
	IF air_time = . THEN air_time = arr_time - dep_time;
run;

*attempt to fix NA values;
DATA group.flights;
	SET group.flight;
	IF arr_delay = . THEN arr_delay = arr_time - arr_delay;
	IF air_time = . THEN air_time = arr_time - dep_time;
run;

PROC SQL OUTOBS=10;
	SELECT *
	FROM group.flights
	WHERE arr_delay = .;
QUIT;

DATA group.planes;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\planes.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs tailnum $ year_man type :$38. manufacturer :$50. model :$20. engines seats speed engine :$13.;
run;

*remove speed? less than 30 obs on over 3000 total;
PROC SQL;
	SELECT *
	FROM group.planes
	WHERE speed is not missing;
QUIT;

DATA group.weather;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\weather.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs origin $ year month day hour temp dewp humid wind_dir wind_speed wind_gust precip pressure visib time_hour $19.;
run;

*only airports table not in basetable;
PROC SQL;
CREATE TABLE group.Basetable as
	SELECT *
	FROM group.Flights as f LEFT JOIN group.Airlines as al
		ON f.carrier = al.carrier
		LEFT JOIN group.Airports as air
		ON f.dest = air.faa
		LEFT JOIN group.Planes as p
		ON f.tailnum = p.tailnum
		LEFT JOIN group.Weather as w
		ON f.origin = w.origin AND f.time_hour = w.time_hour
	ORDER BY obs;
QUIT;

PROC SQL;
ALTER TABLE group.basetable
DROP speed, faa;
QUIT;

*some airports don't exist in airport table;
PROC SQL;
SELECT *
FROM group.airports
WHERE faa = 'BQN';
QUIT;

*some tailnumbers don't have info on the plane table;
PROC SQL;
SELECT *
FROM group.planes
WHERE tailnum = 'N3ALAA';
QUIT;

*from Fabian;
*Create a new table Airlines_delay with different stats for dep and arr delay per airline;
PROC SQL;
CREATE TABLE group.Airlines_delay as
	SELECT carrier, airline_name as Airline, ROUND(AVG(dep_delay),0.1) as Dep_Arr_Delay, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.Basetable
	GROUP BY 1, 2;
QUIT;

*Create new tables Origin_delay and Dest_delay with different stats for dep and arr delay per airport;
PROC SQL;
CREATE TABLE group.Origin_delay as
	SELECT origin, ROUND(AVG(dep_delay),0.1) as Avg_Dep_Delay, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.Flights
	GROUP BY origin;
QUIT;

PROC SQL;
CREATE TABLE group.Dest_delay as
	SELECT dest, ROUND(AVG(dep_delay),0.1) as Dep_Arr_Delay, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.Flights
	GROUP BY dest;
QUIT;

*From Usman;
*Evaluating Reasons of delays while comparing planes with flights;
PROC SQL;
CREATE TABLE group.Planes_delay as
	SELECT manufacturer as Manufacturer, model as Model, ROUND(AVG(dep_delay),0.1) as Dep_Arr_Delay, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.basetable
	GROUP BY 1, 2;
QUIT;

*Delays during different months over a year;
PROC SQL;
create table group.flightdelay_overyear as
SELECT month, ROUND(AVG(dep_delay),0.1) as Dep_Arr_Delay, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.Flights 
	GROUP BY month;
QUIT; 
