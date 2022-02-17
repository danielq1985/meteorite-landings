/*
Explore
-How many records
-Date Range
-Group/count names, nametype, recclass, etc

Clean 
-NULLS
-Duplicates
-Add Boolean Column: 'Location' and 'No Location' -This will help when filtering and plotting
-Add 'Pounds' Columns converting grams
-Add Column 'Class': classification in plain english

Create Windows
-YTD Count

Prep for Tableau
-Create View
	-Name
	-Id
	-Recclass
	-Classification (in plain english)
	-Mass (grams)
	-Mass (pounds)
	-Fall
	-Year
	-Lat
	-Long
	-geolocation
	-Location 
	-YTD Count

Resources
https://en.wikipedia.org/wiki/Meteorite_classification --Classification Table 
*/

-------------------------------------------------------------------
--Explore

use [nasa-meteor]

SELECT *
FROM Meteorite_Landings;

--How many rows?
SELECT COUNT(*)
FROM Meteorite_Landings; --45716

--Date range
SELECT MIN(year) min_year, 
		MAX(year) max_year
FROM Meteorite_Landings; --860 to 2101
						 --Assuming both of these dates are predictions

--Distinct counts for names, name types, classes, mass, fall, and year
SELECT COUNT(DISTINCT name) names,
	   COUNT(DISTINCT name) name_types,
	   COUNT(DISTINCT recclass) recclass,
	   COUNT(DISTINCT mass_g) mass_g,
	   COUNT(DISTINCT fall) fall,
	   COUNT(DISTINCT year) year
FROM Meteorite_Landings; --45716, 45716, 454, 12576, 2, 265

--recclass groups
SELECT recclass, COUNT(*)
FROM Meteorite_Landings
GROUP BY recclass
ORDER BY 2 DESC; --454 diff classifications
			     --Looks like notation techniques differ throughout the years (example: H5, H~5),
				 --would like to create another columm that simplifies the classification

--fall groups
SELECT fall, COUNT(*)
FROM Meteorite_Landings
GROUP BY fall
ORDER BY 2 DESC; --44609 Found, 1107 Fell

------------------------------------------------------------------
--Clean

--Any NULL values, how many per column?
SELECT SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) name_nulls,
	   SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) id_nulls,
	   SUM(CASE WHEN nametype IS NULL THEN 1 ELSE 0 END) nametype_nulls,
	   SUM(CASE WHEN recclass IS NULL THEN 1 ELSE 0 END) recclass_nulls,
	   SUM(CASE WHEN mass_g IS NULL THEN 1 ELSE 0 END) mass_g_nulls,
	   SUM(CASE WHEN fall IS NULL THEN 1 ELSE 0 END) fall_nulls,
	   SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) year_nulls,
	   SUM(CASE WHEN reclat IS NULL THEN 1 ELSE 0 END) reclat_nulls,
	   SUM(CASE WHEN reclong IS NULL THEN 1 ELSE 0 END) reclong_nulls,
	   SUM(CASE WHEN GeoLocation IS NULL THEN 1 ELSE 0 END) geolocation_nulls
FROM Meteorite_Landings; --131 mass_g, 291 year - will drop, 7315 for lat long and geolocation 
						 
--Any duplicates?
SELECT name,
	   id,
	   nametype,
	   recclass,
	   mass_g,
	   fall,
	   year, 
	   reclat, 
	   reclong, 
	   GeoLocation,
	   COUNT(*)
FROM Meteorite_Landings
GROUP BY name,
		id,
		nametype,
		recclass,
		mass_g,
		fall,
		year, 
		reclat, 
		reclong, 
		GeoLocation
HAVING COUNT(*) > 1; --No duplicates

--Add 'location' and 'no location column
SELECT *,
	   CASE WHEN reclat IS NULL THEN 'no location' 
			WHEN reclong IS NULL THEN 'no location' 
			WHEN GeoLocation IS NULL THEN 'no location'
			ELSE 'location' END AS location
FROM Meteorite_Landings; --will use in final view 

--Add 'Pounds' Columns converting grams
SELECT *, 
	   mass_g * 0.00220462 lbs
FROM Meteorite_Landings
WHERE mass_g IS NOT NULL
ORDER BY lbs DESC; --Heavist was 132277.2 lbs (Hoba)

/*
-Simplify classification
--Main groups/subgroups:
-Stony meteorites
	-Chondrites
	-Achondrites
-Stony-iron meteorites 
	-Pallasite
	-Mesosiderite
-Iron meteorites
	-Magmatic 
	-Non-magmatic
*/
SELECT *
FROM Meteorite_Landings

;WITH t1 AS
(
SELECT *,
--Stony
	--Chondrite
	CASE 
		 WHEN recclass LIKE 'H%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'L%' THEN 'Stony-Chondrite' 
		 WHEN recclass LIKE 'LL%' THEN 'Stony-Chondrite' 
		 WHEN recclass LIKE 'E%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'E%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'EH%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'EL%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CI%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CM%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CV%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CR%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CO%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CO%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CK%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CB%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'CH%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'K%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'R%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'C%' THEN 'Stony-Chondrite'
		 WHEN recclass LIKE 'OC%' THEN 'Stony-Chondrite'
	--Achondrite
		WHEN recclass LIKE 'Acapulcoite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Lodranite %' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Winonaite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Howardite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Eucrite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Diogenite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Angrite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Aubrite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Ureilite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Brachinite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Shergottites%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Nakhlites%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Chassignites%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Achondrite%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Achondrite-ung%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Martian%' THEN 'Stony-Achondrite'
		WHEN recclass LIKE 'Impact%' THEN 'Stony-Achondrite'
--Stony Iron
		WHEN recclass LIKE 'Mesosiderite%' THEN 'StonyIron-Mesosiderite'
		WHEN recclass LIKE 'Pallasite%' THEN 'StonyIron-Pallasite'
--Stony Unclassified
		WHEN recclass LIKE 'Stone-uncl%' THEN 'Stony-Unclassified'
		WHEN recclass LIKE 'Stone-ung%' THEN 'Stony-Unclassified'
--Iron
	--Magmatic
		WHEN recclass LIKE '%IC%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IIAB%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IIC%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IID%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IIF%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IIG%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IIIAB%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IIIE%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IIIF%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IVA%' THEN 'Iron-Magmatic'
		WHEN recclass LIKE '%IVB%' THEN 'Iron-Magmatic'
	--Non-Magmatic
		WHEN recclass LIKE '%IAB%' THEN 'Iron-Non-Magmatic'
		WHEN recclass LIKE '%IIE%' THEN 'Iron-Non-Magmatic'
--Iron Unclassified
		WHEN recclass LIKE 'Iron' THEN 'Iron-Unclassified'
		WHEN recclass LIKE 'Iron, ungrouped' THEN 'Iron-Unclassified'
		WHEN recclass LIKE 'Iron?' THEN 'Iron-Unclassified'
	ELSE 'Unknown' END class
FROM Meteorite_Landings)

SELECT class, COUNT(*)
FROM t1
GROUP BY class
ORDER BY 2 DESC;

--------------------------------------------------------------------------

--Create Window:
--YTD Count

SELECT *,
	COUNT(name) OVER (PARTITION BY year) landings_year
FROM Meteorite_Landings
WHERE year IS NOT NULL
ORDER BY year ASC;

---------------------------------------------------------------------------

/*
-Create View
	-Name
	-Id
	-Recclass
	-Subclass
	-Classification (in plain english)
	-Mass (grams)
	-Mass (pounds)
	-Fall
	-Year
	-Lat
	-Long
	-geolocation
	-Location 
	-YTD Count
*/

CREATE VIEW MeteoriteLandings AS

WITH t1 AS 

(SELECT name,
	   id,
	   recclass,
	   CASE 
--Stony
	   --Chondrite
			WHEN recclass LIKE 'H%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'L%' THEN 'Stony-Chondrite' 
			WHEN recclass LIKE 'LL%' THEN 'Stony-Chondrite' 
			WHEN recclass LIKE 'E%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'E%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'EH%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'EL%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CI%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CM%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CV%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CR%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CO%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CO%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CK%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CB%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'CH%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'K%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'R%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'C%' THEN 'Stony-Chondrite'
			WHEN recclass LIKE 'OC%' THEN 'Stony-Chondrite'
	    --Achondrite
			WHEN recclass LIKE 'Acapulcoite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Lodranite %' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Winonaite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Howardite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Eucrite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Diogenite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Angrite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Aubrite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Ureilite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Brachinite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Shergottites%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Nakhlites%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Chassignites%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Achondrite%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Achondrite-ung%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Martian%' THEN 'Stony-Achondrite'
			WHEN recclass LIKE 'Impact%' THEN 'Stony-Achondrite'
--Stony Iron
			WHEN recclass LIKE 'Mesosiderite%' THEN 'StonyIron-Mesosiderite'
			WHEN recclass LIKE 'Pallasite%' THEN 'StonyIron-Pallasite'
--Stony Unclassified
			WHEN recclass LIKE 'Stone-uncl%' THEN 'Stony-Unclassified'
			WHEN recclass LIKE 'Stone-ung%' THEN 'Stony-Unclassified'
--Iron
		--Magmatic
			WHEN recclass LIKE '%IC%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IIAB%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IIC%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IID%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IIF%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IIG%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IIIAB%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IIIE%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IIIF%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IVA%' THEN 'Iron-Magmatic'
			WHEN recclass LIKE '%IVB%' THEN 'Iron-Magmatic'
		--Non-Magmatic
			WHEN recclass LIKE '%IAB%' THEN 'Iron-Non-Magmatic'
			WHEN recclass LIKE '%IIE%' THEN 'Iron-Non-Magmatic'
--Iron Unclassified
			WHEN recclass LIKE 'Iron' THEN 'Iron-Unclassified'
			WHEN recclass LIKE 'Iron, ungrouped' THEN 'Iron-Unclassified'
			WHEN recclass LIKE 'Iron?' THEN 'Iron-Unclassified'
		ELSE 'Unknown' END sub_class,
		mass_g,
		mass_g * 0.00220462 lbs,
		fall,
		year,
		reclat,
		reclong,
		Geolocation,
		CASE 
			WHEN reclat IS NULL THEN 'no location' 
			WHEN reclong IS NULL THEN 'no location' 
			WHEN GeoLocation IS NULL THEN 'no location'
		ELSE 'location' END location,
		COUNT(name) OVER (PARTITION BY year) landings_year
FROM Meteorite_Landings
WHERE year IS NOT NULL)

SELECT *,
	   CASE WHEN sub_class LIKE '%-%' THEN LEFT(sub_class, CHARINDEX('-', sub_class) - 1) ELSE sub_class END class   
FROM t1;
