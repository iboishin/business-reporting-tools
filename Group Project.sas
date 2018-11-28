LIBNAME group "C:\Users\fgalicojustitz\Desktop\SQL-Tableau\Group Project\Data";

*Merge Flights and Airlines tables;
PROC SQL;
CREATE TABLE group.Flights_Airlines as
	SELECT *
	FROM group.Flights as f, group.Airlines as a
	WHERE f.carrier = a.carrier;
QUIT;

*Create a new table Airlines_delay with different stats for dep and arr delay per airline;
PROC SQL;
CREATE TABLE group.Airlines_delay as
	SELECT a.carrier, a.name as Airline, ROUND(AVG(f.dep_delay),0.1) as Dep_Arr_Delay, ROUND(AVG(f.arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(f.dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(f.arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(f.dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(f.arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(f.distance),0.1) as Avg_Distance, ROUND(AVG(f.air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM group.Flights as f, group.Airlines as a
	WHERE f.carrier = a.carrier
	GROUP BY a.carrier, Airline;
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
