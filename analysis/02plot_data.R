library(tidyverse)
library(scales)
catch_proj_data <- readRDS(file = "output/catch_proj_data.rds")
`%!in%` <- Negate(`%in%`)

plot_data <- catch_proj_data |>
  mutate(YEAR = as.factor(YEAR),
         FISHING_YEAR = as.factor(FISHING_YEAR),
         DOY = as.Date(paste0('2025-', DOY), format = "%Y-%m-%d"),
         WEEKDAY = wday(DATE_TRIP)) |>
  dplyr::filter(YEAR %!in% c(2020, 2026))

stocks <- unique(plot_data$STOCK_ID)


## groundfish


for(j in 1:length(stocks)){

  plot_data_stock <- plot_data |>
    filter(STOCK_ID == stocks[j])

  fishery_groups <- unique(plot_data_stock$FISHERY_GROUP)
  for(i in 1:length(fishery_group)) {

FY25_ACL <- max(filter(plot_data_stock, FISHERY_GROUP == fishery_groups[i], FISHING_YEAR == 2025)$ACL)/2204.62262

line_plot <- ggplot(data = filter(plot_data_stock, FISHERY_GROUP == fishery_groups[i], STOCK_ID == stocks[j])) +
  geom_line(aes(x = DOY, y = CY_CATCH_CUMUL/2204.62262, colour = YEAR, group = YEAR)) +
  geom_hline(aes(yintercept = FY25_ACL), color = "red") +
  scale_x_date(date_breaks = "1 month",
               date_labels = "%B") +
  labs(title = "Calendar Year Cumulative Catch", subtitle = paste0(stocks[j], " in ", fishery_groups[i], " fishery group")) +
  ylab("Catch (MT)") +
  xlab("Day of Year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


ggsave(line_plot, filename = paste0("output/line_plots/",stocks[j], "_", fishery_groups[i], "_plot.jpg"))


perc_quota_plot <- ggplot(data = filter(plot_data, FISHERY_GROUP == fishery_groups[i], STOCK_ID == stocks[j])) +
  geom_point(aes(x = PERC_QUOTA, y = CATCH)) +
  facet_wrap(~FISHING_YEAR) +
  labs(title = "Daily Catch Values vs Percent of Quota", subtitle = paste0(stocks[j], " in ", fishery_groups[i], " fishery group")) +
  ylab("Daily Catch (lbs)") +
  xlab("Percent of Quota")

ggsave(perc_quota_plot, filename = paste0("output/scatter_plots/perc_quota/",stocks[j], "_", fishery_groups[i], "_plot.jpg"))

day_of_week_plot <- ggplot(data = filter(plot_data, FISHERY_GROUP == fishery_groups[i], STOCK_ID == stocks[j])) +
  geom_point(aes(x = WEEKDAY, y = CATCH)) +
  facet_wrap(~FISHING_YEAR) +
  labs(title = "Daily Catch Values vs Day of Week", subtitle = paste0(stocks[j], " in ", fishery_groups[i], " fishery group")) +
  ylab("Daily Catch (lbs)") +
  xlab("Percent of Quota")

ggsave(day_of_week_plot, filename = paste0("output/scatter_plots/day_of_week/",stocks[j], "_", fishery_groups[i], "_plot.jpg"))


  }
}





