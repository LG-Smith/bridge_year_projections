SELECT
    ap_year fishing_year
    , stock_id
    , COALESCE(sub_abc, sub_acl) ACL
    , sector_group as fishery_group
  FROM apsd.t_mul_acls
  WHERE ap_year >= 2020



