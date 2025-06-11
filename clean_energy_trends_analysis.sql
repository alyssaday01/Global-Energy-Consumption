-- =====================================================
-- SECTION 1: Clean base table
-- =====================================================
CREATE TABLE energy_clean AS
SELECT
	country,
	year,
	fossil_fuel_consumption,
	fossil_share_energy,
	fossil_share_elec,
	renewables_electricity,
	renewables_share_energy,
	renewables_share_elec,
	energy_per_capita,
	energy_per_gdp,
	carbon_intensity_elec,
	greenhouse_gas_emissions
FROM energy_staging
WHERE year IS NOT NULL
AND country IS NOT NULL;

-- =====================================================
-- SECTION 2: Energy Mix & Decarbonization Analysis
-- =====================================================

-- Compare fossil vs. renewable energy share over time for key global economies
-- Focused on United States, Germany, China, and India
-- Power BI: Use as a multi-line chart (time series) showing energy mix trends
SELECT
	country,
	year,
	fossil_share_energy,
	renewables_share_energy
FROM energy_clean
WHERE country IN ('United States', 'Germany', 'China', 'India')
	AND fossil_share_energy IS NOT NULL
	AND renewables_share_energy IS NOT NULL
ORDER BY country, year;

-- Evaluate energy efficiency and carbon intensity (2020 snapshot)
-- Useful for scatter plot analysis of decoupling trends
-- Filters out nulls to ensure clean visuals and accurate correlations
-- Power BI: Scatter plot showing relationship between energy productivity and electricity carbon intensity
SELECT
	country,
    energy_per_gdp,
    carbon_intensity_elec
FROM energy_clean
WHERE year = 2020
  AND energy_per_gdp IS NOT NULL
  AND carbon_intensity_elec IS NOT NULL;


-- Top 10 countries by peak renewable energy share since 2015
-- Power BI: Horizontal bar chart to highlight renewable energy leaders
SELECT
	country,
	MAX(renewables_share_energy) AS max_renewable_share
FROM energy_clean
WHERE year >= 2015
	AND renewables_share_energy IS NOT NULL
GROUP BY country
ORDER BY max_renewable_share DESC
LIMIT 10;

-- Countries with consistent carbon intensity data (more than 5 years)
-- Identify countries with enough historical data for meaningful carbon intensity comparison
-- Power BI: Filter base to ensure trendline visuals are reliable
WITH countries_with_data AS (
	SELECT country
	FROM energy_clean
	WHERE carbon_intensity_elec IS NOT NULL
	GROUP BY country
	HAVING COUNT(*) > 5
)

-- Largest carbon intensity shifts over time (best vs. worst year)
-- Power BI: Use for slope chart or bar chart comparing carbon progress by country
SELECT
	e.country,
	MIN(e.carbon_intensity_elec) AS best_carbon_intensity,
	MAX(e.carbon_intensity_elec) AS worst_carbon_intensity,
	MAX(e.carbon_intensity_elec) - MIN(e.carbon_intensity_elec) AS carbon_intensity_change
FROM energy_clean e
JOIN countries_with_data c
ON e.country = c.country
GROUP BY e.country
ORDER BY carbon_intensity_change DESC
LIMIT 10;

-- =====================================================
-- END OF ANALYSIS: Clean Energy Trends & Performance
-- =====================================================
