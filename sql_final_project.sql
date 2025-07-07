CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;

-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

-- 1. What is the total emission per country for the most recent year available?
SELECT country, year, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country, year
ORDER BY total_emission DESC;


-- 2. What are the top 5 countries by GDP in the most recent year?

SELECT Country, year, Value AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY GDP DESC
LIMIT 5;


-- 3. Which energy types contribute most to emissions across all countries?

SELECT energy_type, SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;



-- 4. How have global emissions changed year over year?

SELECT year, SUM(emission) AS global_emission
FROM emission_3
GROUP BY year
ORDER BY year;




-- 5. What is the trend in GDP for each country over the given years?

SELECT Country, year, Value AS GDP
FROM gdp_3
ORDER BY Country, year;

-- 6. How has population growth affected total emissions in each country?

SELECT 
    e.country, 
    e.year, 
    SUM(e.emission) AS total_emission, 
    SUM(p.Value) AS total_population
FROM emission_3 e
JOIN population p ON e.country = p.countries AND e.year = p.year
GROUP BY e.country, e.year
ORDER BY e.country, e.year;


-- 7. What is the average yearly change in emissions per capita for each country?
SELECT country, 
       AVG(per_capita_emission) AS avg_per_capita_emission
FROM emission_3
GROUP BY country
ORDER BY avg_per_capita_emission DESC;

-- 8. What is the emission-to-GDP ratio for each country by year?

SELECT e.country, e.year, 
       SUM(e.emission) / g.Value AS emission_to_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g ON e.country = g.Country AND e.year = g.year
GROUP BY e.country, e.year, g.Value
ORDER BY e.year;

-- 9. How does energy production per capita vary across countries?
SELECT 
  p.countries,
  ROUND(SUM(p1.production * 1.0) / NULLIF(SUM(p.value), 0), 4) AS production_percapita
FROM population AS p
JOIN production AS p1 
  ON p.countries = p1.country 
 AND p.year = p1.year
GROUP BY p.countries
ORDER BY production_percapita DESC;

-- 10.  What is the correlation between GDP growth and energy production growth?

SELECT g.Country, g.year, g.Value AS GDP, 
       p.production
FROM gdp_3 g
JOIN (
    SELECT country, year, SUM(production) AS production
    FROM production
    GROUP BY country, year
) p ON g.Country = p.country AND g.year = p.year
ORDER BY g.Country, g.year;

-- 11 .What are the top 10 countries by population and how do their emissions compare?

SELECT 
  p.countries, 
  p.year, 
  SUM(p.Value) AS population, 
  SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e ON p.countries = e.country AND p.year = e.year
WHERE p.year = (
  SELECT MAX(p2.year)
  FROM population p2
  JOIN emission_3 e2 ON p2.countries = e2.country AND p2.year = e2.year
)
GROUP BY p.countries, p.year
ORDER BY population DESC
LIMIT 10;

-- 12. What is the global average GDP, emission, and population by year?

SELECT 
    g.year,
    AVG(g.Value) AS avg_gdp,
    (SELECT AVG(e.emission) FROM emission_3 e WHERE e.year = g.year) AS avg_emission,
    (SELECT AVG(p.Value) FROM population p WHERE p.year = g.year) AS avg_population
FROM gdp_3 g
GROUP BY g.year
ORDER BY g.year;