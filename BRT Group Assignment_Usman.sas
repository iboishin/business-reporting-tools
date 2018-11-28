libname grp'C:\Users\mmajid1\Documents\GitHub\BusinessReportingTools\Group_assignment';

*Merge Flights and Planes tables;
PROC SQL;
CREATE TABLE grp.Flights_Planes as
	SELECT *
	FROM group.Flights as f, group.Planes as p
	WHERE f.tailnum = a.tailnum;
QUIT;

*Evaluating Reasons of delays while comparing planes with flights;
proc sql;
CREATE TABLE grp.Planes_delay as
	SELECT p.manufacturer as Manufacturer, p.model as Model, ROUND(AVG(f.dep_delay),0.1) as Dep_Arr_Delay, ROUND(AVG(f.arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(f.dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(f.arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(f.dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(f.arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(f.distance),0.1) as Avg_Distance, ROUND(AVG(f.air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM grp.Flights as f, grp.Planes as p
	WHERE f.tailnum = p.tailnum
	GROUP BY p.manufacturer, p.model;
QUIT;

*Delays during different months over a year;

proc sql;
create table grp.flightdelay_overyear as
SELECT month, ROUND(AVG(dep_delay),0.1) as Dep_Arr_Delay, ROUND(AVG(arr_delay),0.1) as Avg_Arr_Delay,
		   ROUND(MAX(dep_delay),0.1) as Max_Dep_Delay, ROUND(MAX(arr_delay),0.1) as Max_Arr_Delay,
		   ROUND(MIN(dep_delay),0.1) as Min_Dep_Delay, ROUND(MIN(arr_delay),0.1) as Min_Arr_Delay,
		   ROUND(AVG(distance),0.1) as Avg_Distance, ROUND(AVG(air_time),0.1) as Avg_Air_Time, count(*) as Nr_Flights
	FROM grp.Flights 
	GROUP BY month;
QUIT; 
