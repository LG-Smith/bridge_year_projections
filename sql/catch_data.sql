WITH landings AS (
SELECT date_trip, fishery_group,  stock_id, sum(livlb) landings
FROM (
    -- cams_land
    SELECT TRUNC(l.date_trip) date_trip
        , CASE WHEN s.gf = 1 and s.sectid <> 2 THEN 'SECT'
               WHEN s.gf = 1 and s.sectid = 2 THEN 'CP'
               ELSE fishery_group END AS fishery_group
        , stock_id
        , sum(l.livlb) livlb
    FROM cams_garfo.cams_land l
    LEFT JOIN cams_garfo.cams_subtrip s
        ON l.camsid = s.camsid AND l.subtrip = s.subtrip
    LEFT JOIN (
        SELECT DISTINCT area, stock_id, species_itis
        FROM apsd.t_dc_obspeciesstockarea) st
        ON l.area = st.area AND l.itis_tsn = st.species_itis
    LEFT JOIN cams_garfo.cams_fishery_group fg
        ON l.camsid = fg.camsid
        AND l.subtrip = fg.subtrip
        WHERE l.date_trip >= '01-MAY-2020'
        AND stock_id IN ('YELCCGM', 'YELGB', 'YELSNE', 'FLWGB', 'FLWSNEMA', 'HKWGMMA', 'REDGMGBSS')
        AND status <> 'VTR_DISCARD'
    GROUP BY TRUNC(l.date_trip)
        , CASE WHEN s.gf = 1 and s.sectid <> 2 THEN 'SECT'
               WHEN s.gf = 1 and s.sectid = 2 THEN 'CP'
               ELSE fishery_group END
        , stock_id


    UNION ALL

    -- cams_vtr_orphans
    SELECT TRUNC(l.date_trip) date_trip
        , CASE WHEN s.gf = 1 and s.sectid <> 2 THEN 'SECT'
               WHEN s.gf = 1 and s.sectid = 2 THEN 'CP'
               ELSE fishery_group END AS fishery_group
        , stock_id
        , sum(l.livlb) livlb
    FROM cams_garfo.cams_vtr_orphans l
    LEFT JOIN cams_garfo.cams_vtr_orphans_subtrip s
        ON l.camsid = s.camsid AND l.subtrip = s.subtrip
    LEFT JOIN (
        SELECT DISTINCT area, stock_id, species_itis
        FROM apsd.t_dc_obspeciesstockarea) st
      ON l.area = st.area AND l.itis_tsn = st.species_itis
    LEFT JOIN cams_garfo.cams_fishery_group fg
        ON l.camsid = fg.camsid
        AND l.subtrip = fg.subtrip
        WHERE l.date_trip >= '01-MAY-2020'
        AND stock_id IN ('YELCCGM', 'YELGB', 'YELSNE', 'FLWGB', 'FLWSNEMA', 'HKWGMMA', 'REDGMGBSS')
        AND status <> 'VTR_DISCARD'
    GROUP BY TRUNC(l.date_trip)
        , CASE WHEN s.gf = 1 and s.sectid <> 2 THEN 'SECT'
               WHEN s.gf = 1 and s.sectid = 2 THEN 'CP'
               ELSE fishery_group END
        , stock_id
) GROUP BY date_trip
, fishery_group, stock_id
),
discards AS (
    SELECT TRUNC(d.date_trip) date_trip
        , CASE WHEN s.gf = 1 and s.sectid <> 2 THEN 'SECT'
               WHEN s.gf = 1 and s.sectid = 2 THEN 'CP'
               ELSE fishery_group END AS fishery_group
        , fg.RECREATIONAL
        , stock_id
        , SUM(d.cams_discard) AS discard
    FROM cams_garfo.cams_discard_all_years d
    LEFT JOIN cams_garfo.cams_subtrip s
        ON d.camsid = s.camsid AND d.subtrip = s.subtrip
    LEFT JOIN (
        SELECT DISTINCT area, stock_id, species_itis
        FROM apsd.t_dc_obspeciesstockarea) st
        ON s.area = st.area AND d.itis_tsn = st.species_itis
    LEFT JOIN cams_garfo.cams_fishery_group fg
        ON d.camsid = fg.camsid
        AND d.subtrip = fg.subtrip
    WHERE d.date_trip >= '01-MAY-2020'
      AND stock_id IN ('YELCCGM', 'YELGB', 'YELSNE', 'FLWGB', 'FLWSNEMA', 'HKWGMMA', 'REDGMGBSS')
    GROUP BY  TRUNC(d.date_trip)
        , CASE WHEN s.gf = 1 and s.sectid <> 2 THEN 'SECT'
               WHEN s.gf = 1 and s.sectid = 2 THEN 'CP'
               ELSE fishery_group END
        , stock_id
        , fg.RECREATIONAL
)

--- main ----
SELECT disc.date_trip
, disc.stock_id
, disc.fishery_group
, COALESCE(landings, 0) landings
, discard
, (discard + COALESCE(landings, 0)) catch
FROM discards disc
LEFT JOIN landings land
ON disc.stock_id = land.stock_id
AND disc.fishery_group = land.fishery_group
AND disc.date_trip = land.date_trip
WHERE disc.fishery_group NOT IN ('PCHARTER','NAFO','OUTSIDE','RESEARCH', 'RECREATIONAL')
AND disc.recreational = 0
