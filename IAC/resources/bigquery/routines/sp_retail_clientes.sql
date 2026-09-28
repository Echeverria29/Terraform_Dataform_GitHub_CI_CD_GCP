--CREATE OR REPLACE PROCEDURE `bronze_retail.sp_retail_clientes`()
BEGIN
  DECLARE max_timestamp TIMESTAMP;

  -- Obtener el último timestamp de carga
  SET max_timestamp =(
    SELECT MAX(load_timestamp_cl)
    FROM `bronze_retail.clientes`
    WHERE load_timestamp_cl >= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
  );

  -- Insertar los nuevos registros
  INSERT INTO `silver_retail.clientes` (
    cliente_id,
    nombre,
    email,
    fecha_registro,
    load_timestamp_cl
  )
  SELECT
    CAST(CLIENTE_ID AS INT64) AS cliente_id,
    CAST(NOMBRE AS STRING) AS nombre,
    CAST(EMAIL AS STRING) AS email,
    -- Opción segura para extraer solo la fecha sin importar si trae hora
    SAFE.PARSE_DATE('%Y-%m-%d', SUBSTR(CAST(FECHA_REGISTRO AS STRING), 1, 10)) AS fecha_registro,
    load_timestamp_cl
  FROM
    `bronze_retail.clientes`
  WHERE
    load_timestamp_cl = max_timestamp;

END;
