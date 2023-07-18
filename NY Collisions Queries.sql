----------------------------Exploring Data-------------------------------------
--Added wekday column in schema then adding data of day
UPDATE `optimal-bivouac-388416.Vehicle_Collisions.collisions_data` 
  SET weekday = FORMAT_DATE('%A', DATE(CRASH_DATE))
  WHERE CRASH_DATE IS NOT NULL;


--Getting Percentage of Deaths from accidents
SELECT 
  SUM(NUMBER_OF_PERSONS_INJURED) AS total_injured, 
  SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths, 
  (SUM(NUMBER_OF_PERSONS_KILLED)/COUNT(COLLISION_ID))*100 AS percent_deaths
FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`;


--Getting Percentage of Injuries from accidents
SELECT 
  SUM(NUMBER_OF_PERSONS_INJURED) AS total_injured, 
  SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths, 
  (SUM(NUMBER_OF_PERSONS_INJURED)/COUNT(COLLISION_ID))*100 AS percent_injuries
FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`;

--Deaths per each day of week
SELECT 
  SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths, 
  weekday
FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
GROUP BY weekday;

--Injuries per each day of week
SELECT 
  SUM(NUMBER_OF_PERSONS_INJURED) AS total_injured, 
  weekday
FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
GROUP BY weekday;

--Crashes per each day of week
SELECT 
  Count(COLLISION_ID) AS total_collisions, 
  weekday
FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
GROUP BY weekday;


--Deaths, Injuries, Crashes per each day of week
SELECT 
  SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths, 
  SUM(NUMBER_OF_PERSONS_INJURED) AS total_injured, 
  Count(COLLISION_ID) AS total_collisions, 
  weekday
FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
GROUP BY weekday;

--Identifying number of collisions based on amount of vehicles involved
SELECT 
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NULL 
    AND VEHICLE_TYPE_CODE_3 IS NULL
    AND VEHICLE_TYPE_CODE_4 IS NULL
    AND VEHICLE_TYPE_CODE_5 IS NULL
    THEN 1 END) AS single_vehicle_collisions, 
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_3 IS NULL
    AND VEHICLE_TYPE_CODE_4 IS NULL
    AND VEHICLE_TYPE_CODE_5 IS NULL
    THEN 1 END) AS two_vehicle_collisions,
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_3 IS NOT NULL
    AND VEHICLE_TYPE_CODE_4 IS NULL
    AND VEHICLE_TYPE_CODE_5 IS NULL
    THEN 1 END) AS three_vehicle_collisions,
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_3 IS NOT NULL
    AND VEHICLE_TYPE_CODE_4 IS NOT NULL
    AND VEHICLE_TYPE_CODE_5 IS NULL
    THEN 1 END) AS four_vehicle_collisions,
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_3 IS NOT NULL
    AND VEHICLE_TYPE_CODE_4 IS NOT NULL
    AND VEHICLE_TYPE_CODE_5 IS NOT NULL
    THEN 1 END) AS five_vehicle_collisions
FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`;
----------------------------------------------------------------------


---------------------Accident Prone Crossings-------------------------
--Trimming street names
UPDATE
    `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
SET
    ON_STREET_NAME = TRIM(ON_STREET_NAME)
    WHERE ON_STREET_NAME IS NOT NULL;

UPDATE
    `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
SET
    CROSS_STREET_NAME = TRIM(CROSS_STREET_NAME)
    WHERE CROSS_STREET_NAME IS NOT NULL;

--Streets with most crashes, sum injuries and deaths
SELECT
  ON_STREET_NAME,
  CROSS_STREET_NAME,
  COUNT(COLLISION_ID) AS crashes,
  SUM(NUMBER_OF_PERSONS_INJURED) AS injuries,
  SUM(NUMBER_OF_PERSONS_KILLED) AS deaths,
  SUM(NUMBER_OF_PERSONS_KILLED)/COUNT(COLLISION_ID)*100 AS death_rate_percent
FROM
  `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
WHERE
  ON_STREET_NAME IS NOT NULL
  AND CROSS_STREET_NAME IS NOT NULL
GROUP BY
  ON_STREET_NAME,
  CROSS_STREET_NAME
ORDER BY
  crashes DESC
LIMIT
  25;

--Top 10 Accident Prone Crossings with Greatest Contrbuting Factor
SELECT
  a.ON_STREET_NAME,
  a.CROSS_STREET_NAME,
  b.CONTRIBUTING_FACTOR_VEHICLE_1,
  COUNT(COLLISION_ID) AS total_crashes,
  SUM(NUMBER_OF_PERSONS_INJURED) AS injuries,
  SUM(NUMBER_OF_PERSONS_KILLED) AS deaths,
  SUM(NUMBER_OF_PERSONS_KILLED)/COUNT(COLLISION_ID)*100 AS death_rate_percent,
FROM
  `optimal-bivouac-388416.Vehicle_Collisions.collisions_data` a
JOIN ((
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%ROCKAWAY BOULEVARD%"
      AND CROSS_STREET_NAME LIKE "%BROOKVILLE BOULEVARD%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%FLATBUSH AVENUE%"
      AND CROSS_STREET_NAME LIKE "%GRAND ARMY PLAZA%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%WEST FORDHAM ROAD%"
      AND CROSS_STREET_NAME LIKE "%MAJOR DEEGAN EXPRESSWAY%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%TILLARY STREET%"
      AND CROSS_STREET_NAME LIKE "%FLATBUSH AVENUE EXTENSION%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%BRUCKNER BOULEVARD%"
      AND CROSS_STREET_NAME LIKE "%EAST 138 STREET%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%EAST 59 STREET%"
      AND CROSS_STREET_NAME LIKE "%2 AVENUE%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%BRUCKNER BOULEVARD%"
      AND CROSS_STREET_NAME LIKE "%HUNTS POINT AVENUE%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%WEST 42 STREET%"
      AND CROSS_STREET_NAME LIKE "%8 AVENUE%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%ATLANTIC AVENUE%"
      AND CROSS_STREET_NAME LIKE "%LOGAN STREET%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)
  UNION ALL (
    SELECT
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      ON_STREET_NAME,
      CROSS_STREET_NAME
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND ON_STREET_NAME LIKE "%QUEENS BOULEVARD%"
      AND CROSS_STREET_NAME LIKE "%WOODHAVEN BOULEVARD%"
    GROUP BY
      ON_STREET_NAME,
      CROSS_STREET_NAME,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1)) b
ON
  a.ON_STREET_NAME = b.ON_STREET_NAME
  AND a.CROSS_STREET_NAME = b.CROSS_STREET_NAME
WHERE
  a.ON_STREET_NAME IS NOT NULL
  AND a.CROSS_STREET_NAME IS NOT NULL
GROUP BY
  a.ON_STREET_NAME,
  b.CONTRIBUTING_FACTOR_VEHICLE_1,
  a.CROSS_STREET_NAME
ORDER BY
  total_crashes DESC;
----------------------------------------------------------------------------------------------


--------------------Total Crashes and Fatalities By Time of Day-------------------------------
SELECT
  a.time_hour,
  b.CONTRIBUTING_FACTOR_VEHICLE_1,
  COUNT(COLLISION_ID) AS crashes,
  SUM(NUMBER_OF_PERSONS_KILLED)/COUNT(COLLISION_ID)*100 AS death_rate
FROM (
  SELECT
    *,
    TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
  FROM (
    SELECT
      *,
      CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
    FROM
      `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`)) a
JOIN ( (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T00:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T01:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T02:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T03:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T04:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T05:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T06:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T07:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T08:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T09:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T10:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T11:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T12:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T13:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T14:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T15:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T16:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T17:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T18:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T19:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T20:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T21:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T22:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 )
  UNION ALL (
    SELECT
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1,
      COUNT(COLLISION_ID) AS crashes,
      SUM(NUMBER_OF_PERSONS_KILLED) AS total_deaths
    FROM (
      SELECT
        *,
        TIMESTAMP_TRUNC(time_form, HOUR) AS time_hour
      FROM (
        SELECT
          *,
          CAST(CRASH_TIME AS DATETIME FORMAT 'HH24:MI') AS time_form
        FROM
          `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`))
    WHERE
      CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
      AND time_hour = "2023-06-01T23:00:00"
      AND NUMBER_OF_PERSONS_KILLED > 0
    GROUP BY
      time_hour,
      CONTRIBUTING_FACTOR_VEHICLE_1
    ORDER BY
      crashes DESC
    LIMIT
      1 ) ) b
ON
  a.time_hour = b.time_hour
WHERE
  b.CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
GROUP BY
  time_hour,
  b.CONTRIBUTING_FACTOR_VEHICLE_1
ORDER BY
  crashes DESC;
---------------------------------------------------------------------------------------------


--------------------Greatest Contributing Factors to Crashes---------------------------------
SELECT
  CONTRIBUTING_FACTOR_VEHICLE_1,
  COUNT(COLLISION_ID) AS crashes
FROM
  `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
WHERE
  CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified"
  AND ON_STREET_NAME IS NOT NULL
GROUP BY
  CONTRIBUTING_FACTOR_VEHICLE_1
ORDER BY
  crashes DESC;
----------------------------------------------------------------------------------------------


--------------------Severity of Crash Based on Number of Vehicles Involved--------------------
--Number of total crashes based on number of vehicles involved
SELECT
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NULL 
    AND VEHICLE_TYPE_CODE_3 IS NULL
    AND VEHICLE_TYPE_CODE_4 IS NULL
    AND VEHICLE_TYPE_CODE_5 IS NULL
    THEN 1 END) AS single_vehicle_collisions, 
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_3 IS NULL
    AND VEHICLE_TYPE_CODE_4 IS NULL
    AND VEHICLE_TYPE_CODE_5 IS NULL
    THEN 1 END) AS two_vehicle_collisions,
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_3 IS NOT NULL
    AND VEHICLE_TYPE_CODE_4 IS NULL
    AND VEHICLE_TYPE_CODE_5 IS NULL
    THEN 1 END) AS three_vehicle_collisions,
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_3 IS NOT NULL
    AND VEHICLE_TYPE_CODE_4 IS NOT NULL
    AND VEHICLE_TYPE_CODE_5 IS NULL
    THEN 1 END) AS four_vehicle_collisions,
  Count(CASE 
    WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
    AND VEHICLE_TYPE_CODE_3 IS NOT NULL
    AND VEHICLE_TYPE_CODE_4 IS NOT NULL
    AND VEHICLE_TYPE_CODE_5 IS NOT NULL
    THEN 1 END) AS five_vehicle_collisions
FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`;

--Number of total injuries based on number of vehicles involved
SELECT
  SUM(NUMBER_INJURED_1) AS NUMBER_INJURED_1,
  SUM(NUMBER_INJURED_2) AS NUMBER_INJURED_2,
  SUM(NUMBER_INJURED_3) AS NUMBER_INJURED_3,
  SUM(NUMBER_INJURED_4) AS NUMBER_INJURED_4,
  SUM(NUMBER_INJURED_5) AS NUMBER_INJURED_5,
FROM
  (
    SELECT
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NULL 
          AND VEHICLE_TYPE_CODE_3 IS NULL
          AND VEHICLE_TYPE_CODE_4 IS NULL
          AND VEHICLE_TYPE_CODE_5 IS NULL
        THEN SUM(NUMBER_OF_PERSONS_INJURED) END) AS NUMBER_INJURED_1,
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_3 IS NULL
          AND VEHICLE_TYPE_CODE_4 IS NULL
          AND VEHICLE_TYPE_CODE_5 IS NULL
        THEN SUM(NUMBER_OF_PERSONS_INJURED) END) AS NUMBER_INJURED_2,
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_3 IS NOT NULL
          AND VEHICLE_TYPE_CODE_4 IS NULL
          AND VEHICLE_TYPE_CODE_5 IS NULL
        THEN SUM(NUMBER_OF_PERSONS_INJURED) END) AS NUMBER_INJURED_3,
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_3 IS NOT NULL
          AND VEHICLE_TYPE_CODE_4 IS NOT NULL
          AND VEHICLE_TYPE_CODE_5 IS NULL
        THEN SUM(NUMBER_OF_PERSONS_INJURED) END) AS NUMBER_INJURED_4,
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_3 IS NOT NULL
          AND VEHICLE_TYPE_CODE_4 IS NOT NULL
          AND VEHICLE_TYPE_CODE_5 IS NOT NULL
        THEN SUM(NUMBER_OF_PERSONS_INJURED) END) AS NUMBER_INJURED_5
      FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
      GROUP BY VEHICLE_TYPE_CODE_1,
      VEHICLE_TYPE_CODE_2,
      VEHICLE_TYPE_CODE_3,
      VEHICLE_TYPE_CODE_4,
      VEHICLE_TYPE_CODE_5
  );

--Number of total fatalities based on number of vehicles involved
SELECT
  SUM(NUMBER_KILLED_1) AS NUMBER_KILLED_1,
  SUM(NUMBER_KILLED_2) AS NUMBER_KILLED_2,
  SUM(NUMBER_KILLED_2) AS NUMBER_KILLED_3,
  SUM(NUMBER_KILLED_4) AS NUMBER_KILLED_4,
  SUM(NUMBER_KILLED_5) AS NUMBER_KILLED_5,
FROM
  (
    SELECT
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NULL 
          AND VEHICLE_TYPE_CODE_3 IS NULL
          AND VEHICLE_TYPE_CODE_4 IS NULL
          AND VEHICLE_TYPE_CODE_5 IS NULL
      THEN SUM(NUMBER_OF_PERSONS_KILLED) END) AS NUMBER_KILLED_1,
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL  
          AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_3 IS NULL
          AND VEHICLE_TYPE_CODE_4 IS NULL
          AND VEHICLE_TYPE_CODE_5 IS NULL
        THEN SUM(NUMBER_OF_PERSONS_KILLED) END) AS NUMBER_KILLED_2,
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_3 IS NOT NULL
          AND VEHICLE_TYPE_CODE_4 IS NULL
          AND VEHICLE_TYPE_CODE_5 IS NULL
        THEN SUM(NUMBER_OF_PERSONS_KILLED) END) AS NUMBER_KILLED_3,
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_3 IS NOT NULL
          AND VEHICLE_TYPE_CODE_4 IS NOT NULL
          AND VEHICLE_TYPE_CODE_5 IS NULL
        THEN SUM(NUMBER_OF_PERSONS_KILLED) END) AS NUMBER_KILLED_4,
      (CASE 
        WHEN VEHICLE_TYPE_CODE_1 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_2 IS NOT NULL 
          AND VEHICLE_TYPE_CODE_3 IS NOT NULL
          AND VEHICLE_TYPE_CODE_4 IS NOT NULL
          AND VEHICLE_TYPE_CODE_5 IS NOT NULL
        THEN SUM(NUMBER_OF_PERSONS_KILLED) END) AS NUMBER_KILLED_5
    FROM `optimal-bivouac-388416.Vehicle_Collisions.collisions_data`
    GROUP BY 
      VEHICLE_TYPE_CODE_1,
      VEHICLE_TYPE_CODE_2,
      VEHICLE_TYPE_CODE_3,
      VEHICLE_TYPE_CODE_4,
      VEHICLE_TYPE_CODE_5
  );
  
----------------------------------------------------------------------------------------------