libname group 'C:\Users\iboishin\Documents\GitHub\business-reporting-tools';

*import databases;

DATA group.airlines;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\airlines.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs carrier $ airline_name :$27.;
run;

DATA group.airports;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\airports.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs faa $ name :$60. lat lon alt tz dst $ tzone :$20.;
run;

*originally, there were 9430 missing values for arr_delay and for air_time;
*with this if-statement, we took that number down to 8713 (2.5% of total flights);

DATA group.flights;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\flights.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs year month day dep_time sched_dep_time dep_delay arr_time sched_arr_time arr_delay carrier $ flight tailnum $
		origin $ dest $ air_time distance hour_sched_dep minute_sched_dep time_hour $19.;
	IF arr_delay = . THEN arr_delay = arr_time - sched_arr_time;
run;

*check the number of missing arr_delay values;
*PROC SQL;
*SELECT count(*)
FROM group.flights
WHERE arr_delay = .;
*QUIT;

DATA group.planes;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\planes.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs tailnum $ year_man type :$38. manufacturer :$50. model :$20. engines seats speed engine :$13.;
run;

DATA group.weather;
	INFILE 'C:\Users\iboishin\Documents\GitHub\BusinessReportingTools\Group_assignment\weather.csv' DLM=',' DSD FIRSTOBS=2;
	INPUT obs origin $ year month day hour temp dewp humid wind_dir wind_speed wind_gust precip pressure visib time_hour $19.;
run;

PROC SQL;
CREATE TABLE group.Basetable as
	SELECT *, f.distance / (f.air_time/60) as Mi_per_hr
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

*avg delay based on flight route;
*interesting as aggregate?;
PROC SQL;
CREATE TABLE group.delay_flight_route as
SELECT carrier,flight, avg(dep_delay) as avg_dep_delay, avg(arr_delay) as avg_arr_delay, count(*) as no_flights
FROM group.basetable
GROUP BY 1, 2
ORDER BY 3 DESC, 4 DESC;
QUIT;

*speed was only present in 963 instances (0.3% of all cases);
*available data is insignificant to we removed it to save on memory when importing the data into Tableau;
PROC SQL;
SELECT count(*)
FROM group.basetable
WHERE speed ^= .;
QUIT;

PROC SQL;
SELECT DISTINCT Engine, Speed, count(engine)
FROM group.basetable
GROUP BY 1, 2;
QUIT;

*faa is simply a duplicate value so we removed to save on storage;
PROC SQL;
ALTER TABLE group.basetable
DROP speed, faa;
QUIT;

*explore missing values in basetable;
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

*code for Tableau charts;
PROC SQL;
CREATE TABLE group.delay_by_dep_time as
SELECT Hour_sched_dep, avg(arr_delay) as avg_arr_delay, avg(dep_delay) as avg_dep_delay, count(*) as no_obs
FROM group.basetable
GROUP BY 1;
QUIT;

PROC SQL;
CREATE TABLE group.delay_by_wind as
SELECT wind_speed, avg(arr_delay) as avg_arr_delay, avg(dep_delay) as avg_dep_delay, count(*) as no_obs
FROM group.basetable
GROUP BY 1;
QUIT;

PROC SQL;
CREATE TABLE group.delay_by_month as
SELECT month, avg(arr_delay) as avg_arr_delay, avg(dep_delay) as avg_dep_delay, count(*) as no_obs
FROM group.basetable
GROUP BY 1;
QUIT;

PROC SQL;
CREATE TABLE group.delay_spread_by_airline as
SELECT airline_name, arr_delay, dep_delay
FROM group.basetable;
QUIT;

PROC SQL;
CREATE TABLE group.delay_by_airline as
SELECT airline_name, avg(arr_delay) as avg_arr_delay, avg(dep_delay) as avg_dep_delay, count(*) as no_obs
FROM group.basetable
GROUP BY 1;
QUIT;

PROC SQL;
CREATE TABLE group.delay_by_destination as
SELECT lat, lon, name as airport_name, avg(arr_delay) as avg_arr_delay, avg(dep_delay) as avg_dep_delay, count(*) as no_obs
FROM group.basetable
GROUP BY 1, 2, 3;
QUIT;

PROC SQL;
CREATE TABLE group.delay_by_origin as
SELECT Origin as airport_name, arr_delay, dep_delay
FROM group.basetable;
QUIT;

*some summary tables, which were not used in tableau but were useful in the data exploration process;
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
	SELECT origin, ROUND(AVG(dep_delay),0.1) as Avg_Dep_Delay, ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(AVG(distance),0.1) as Avg_Distance, count(*) as Nr_Flights
	FROM group.Flights
	GROUP BY origin;
QUIT;

PROC SQL;
CREATE TABLE group.Dest_delay as
	SELECT dest, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay, ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.Flights
	GROUP BY dest;
QUIT;

*Evaluating Reasons of delays while comparing planes with flights;
PROC SQL;
CREATE TABLE group.Planes_delay as
	SELECT manufacturer as Manufacturer, model as Model, ROUND(AVG(dep_delay),0.1) as Avg_Dep_Delay, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.basetable
	GROUP BY 1, 2;
QUIT;

*Delays during different months over a year;
PROC SQL;
create table group.flight_delay_overyear as
SELECT month, ROUND(AVG(dep_delay),0.1) as Dep_Arr_Delay, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.Flights 
	GROUP BY month;
QUIT; 
