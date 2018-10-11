SELECT
  ROW_NUMBER() OVER () AS id,
  locations.id AS location_id,
  locations.iso_code AS iso_code2,
  locations.name AS location,
  models.id AS model_id,
  models.full_name AS model,
  scenarios.id AS scenario_id,
  scenarios.name AS scenario,
  categories.id AS category_id,
  categories.name AS category,
  subcategories.id AS subcategory_id,
  subcategories.name AS subcategory,
  indicators.id AS indicator_id,
  indicators.name AS indicator,
  REPLACE(indicators.composite_name, '|', ' | ') AS composite_name,
  indicators.unit AS unit, indicators.definition AS definition,
  JSONB_AGG(
    JSONB_BUILD_OBJECT(
      'year', time_series_values.year,
      'value', ROUND(time_series_values.value, 2)
    )
  ) AS emissions,
  JSONB_OBJECT_AGG(
      time_series_values.year, ROUND(time_series_values.value::NUMERIC, 2)
  ) AS emissions_dict
FROM time_series_values
INNER JOIN locations ON locations.id = time_series_values.location_id
INNER JOIN scenarios ON scenarios.id = time_series_values.scenario_id
INNER JOIN models ON models.id = scenarios.model_id
INNER JOIN indicators ON indicators.id = time_series_values.indicator_id
LEFT JOIN categories subcategories ON subcategories.id = indicators.subcategory_id
LEFT JOIN categories ON categories.id = subcategories.parent_id
GROUP BY
  locations.id,
  locations.iso_code,
  locations.name,
  models.id,
  models.full_name,
  scenarios.id,
  scenarios.name,
  categories.id,
  categories.name,
  subcategories.id,
  subcategories.name,
  indicators.id,
  indicators.name,
  REPLACE(indicators.composite_name, '|', ' | '),
  indicators.unit,
  indicators.definition
ORDER BY locations.name ASC;
