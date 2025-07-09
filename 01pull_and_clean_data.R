library(tidyverse)
library(stringr)
library(ROracle)
library(apsdFuns)
library(openxlsx2)

options(scipen = 999)

## oracle connection
con <- apsdFuns::roracle_login(key_name = 'apsd', key_service = 'DB01P', schema = 'apsd')

## get catch data
catch_data_orig <- dbGetQuery(conn = con,
                         statement = readr::read_file("sql/catch_data.sql"))

# get run date for
cams_run <- dbGetQuery(conn = con, statement = "SELECT MAX(DISTINCT date_run) date_run FROM cams_garfo.cams_land")$DATE_RUN

catch_data <- catch_data_orig |>
  mutate(FISHERY_GROUP = case_when(STOCK_ID %in% c('YELCCGM', 'FLWGB', 'FLWSNEMA', 'HKWGMMA', 'REDGMGBSS')
                                   & FISHERY_GROUP %in% c('GROUND', 'STATE') ~ FISHERY_GROUP,
                                   STOCK_ID == 'YELGB'
                                   & FISHERY_GROUP %in% c('GROUND', 'SCALLOP', 'WHITING', 'STATE') ~ FISHERY_GROUP,
                                   STOCK_ID == 'YELSNE'
                                   & FISHERY_GROUP %in% c('GROUND', 'SCALLOP', 'STATE') ~ FISHERY_GROUP,
                                   TRUE ~ 'OTHER')) |> ## re-group the fishery groups to align with groundfish sub-ACLs
  group_by(FISHERY_GROUP, DATE_TRIP, STOCK_ID) |>
  summarise(DISCARD = sum(DISCARD), ## re-sum daily totals
            LANDINGS = sum(LANDINGS),
            CATCH = sum(CATCH)) |>
  ungroup()



## get quota data
## groundfish has oracle table
gf_acls <- dbGetQuery(conn = con,
                        statement = readr::read_file("sql/gf_acls.sql")) |>
  mutate(FISHERY_GROUP = "GROUND",
         ACL = round(ACL, 1)) |>
  relocate(FISHERY_GROUP)


## I put other ACLs into a spreadsheet here:
other_acls <- read_xlsx("data/bridge_year_acls.xlsx")

acls <- gf_acls |>
  rbind(other_acls) |>
  dplyr::filter(STOCK_ID %in% c('YELCCGM', 'YELGB', 'YELSNE', 'FLWGB', 'FLWSNEMA', 'HKWGMMA', 'REDGMGBSS')) |>
  mutate(ACL = round(ACL*2204.62262)) # convert from MT to lbs

rm(gf_acls
   , other_acls
   , catch_data_orig)

## make frame for data such that there is a row for each combination of day of year, year, stock, & fishery group
frame <- dbGetQuery(conn = con, statement = "SELECT DISTINCT day date_trip FROM apsd.dates
                                             WHERE day BETWEEN '01-MAY-2020' AND '30-APR-2026'") |>
  cross_join(data.frame(STOCK_ID = unique(catch_data$STOCK_ID))) |>
  cross_join(data.frame(FISHERY_GROUP = unique(catch_data$FISHERY_GROUP)))



full_data <- frame |>
  left_join(catch_data) |>
  mutate(DISCARD = case_when(DATE_TRIP >= cams_run ~ NA, ## change NAs to 0s (lbs of daily catch) for all but future dates
                             TRUE ~ replace(DISCARD, is.na(DISCARD), 0)),
         LANDINGS = case_when(DATE_TRIP >= cams_run ~ NA,
                             TRUE ~ replace(LANDINGS, is.na(LANDINGS), 0)),
         CATCH = case_when(DATE_TRIP >= cams_run ~ NA,
                             TRUE ~ replace(CATCH, is.na(CATCH), 0)),
         DATE_TRIP = as.Date(format(as.Date(DATE_TRIP,format='%m/%d/%Y %H:%M:%S'), format='%Y-%m-%d')), ## remove hours from date
         YEAR = year(DATE_TRIP), ## add calendar year
         FISHING_YEAR = if_else(month(DATE_TRIP) %in% c(1,2,3,4), YEAR - 1, YEAR), ## add groundfish FY
         DOY = format(DATE_TRIP, "%m-%d")) |> ## day of year for plotting
  left_join(acls, by = join_by(FISHING_YEAR, STOCK_ID, FISHERY_GROUP)) |> ## join in ACL data
  group_by(STOCK_ID, FISHERY_GROUP, FISHING_YEAR) |>
  arrange(DATE_TRIP) |>
  mutate(TRAJ = cumsum(case_when(FISHING_YEAR == 2025 ~ round(ACL/365, 2)))) |>
  ungroup() |>
  group_by(STOCK_ID, FISHERY_GROUP, YEAR) |>
  arrange(DATE_TRIP) |>
  mutate(CY_LAND_CUMUL = round(cumsum(LANDINGS)),
         CY_DISC_CUMUL = round(cumsum(DISCARD)),
         CY_CATCH_CUMUL = round(cumsum(CATCH))) |>
  ungroup() |>
  group_by(STOCK_ID, FISHERY_GROUP, FISHING_YEAR) |>
  arrange(DATE_TRIP) |>
  mutate(FY_LAND_CUMUL = round(cumsum(LANDINGS)),
         FY_DISC_CUMUL = round(cumsum(DISCARD)),
         FY_CATCH_CUMUL = round(cumsum(CATCH)),
         PERC_QUOTA = round(FY_CATCH_CUMUL/ACL * 100, 1))

dbDisconnect(conn = con)
rm(acls, catch_data, con, frame, cams_run)

save(full_data, file = "output/catch_proj_data.rds")
