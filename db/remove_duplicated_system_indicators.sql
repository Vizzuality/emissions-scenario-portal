WITH duplicated_system_indicators AS (
  SELECT min_id, dup_id FROM (
    SELECT min_id, UNNEST(duplicated_ids) AS dup_id FROM (
      SELECT category, subcategory, name, MIN(id) AS min_id, ARRAY_AGG(id) AS duplicated_ids, COUNT(*)
      FROM indicators
      WHERE parent_id IS NULL AND model_id IS NULL
      GROUP BY (category, subcategory, name)
      HAVING COUNT(*) > 1
    ) s
  ) ss
  WHERE ss.dup_id != ss.min_id
), updated_variations AS (
  UPDATE indicators i
  SET parent_id = d.min_id
  FROM duplicated_system_indicators d
  WHERE d.dup_id = i.parent_id
), updated_values AS (
  UPDATE time_series_values ts
  SET indicator_id = d.min_id
  FROM duplicated_system_indicators d
  WHERE d.dup_id = ts.indicator_id
)
DELETE FROM indicators
USING duplicated_system_indicators d
WHERE indicators.id = d.dup_id;
