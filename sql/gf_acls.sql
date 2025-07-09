SELECT
  ap_year fishing_year
  , stock_id
  , CASE WHEN stock_id IN ('HALGMMA', 'OPTGMMA', 'WOLGMMA', 'FLDSNEMA', 'FLGMGBSS') THEN sum(ACL)/2 ELSE sum(ACL) END AS ACL
FROM (
  SELECT
    ap_year
    , stock_id
    , COALESCE(sub_abc, sub_acl) ACL
  FROM apsd.t_mul_acls
  WHERE ap_year >= 2020
  )
GROUP BY
  ap_year
  , stock_id


