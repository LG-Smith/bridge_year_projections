catch_by_week <- plot_data |>
  mutate(WEEK = floor_date(DATE_TRIP, "weeks", week_start = 1)) |>
  group_by(YEAR, WEEK, STOCK_ID, FISHERY_GROUP) |>
  summarise(DISCARD = sum(DISCARD),
            LANDINGS = sum(LANDINGS),
            CATCH = sum(CATCH)) |>
  ungroup() |>
  arrange(WEEK) |>
  group_by(YEAR, STOCK_ID, FISHERY_GROUP) |>
  mutate(CY_DISCARD_CUMUL = cumsum(DISCARD),
         CY_LANDING_CUMUL = cumsum(LANDINGS),
         CY_CATCH_CUMUL = cumsum(CATCH),
         FISHING_YEAR = )
