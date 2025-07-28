library(tidyverse)
data <- readRDS(file = "output/catch_proj_data.rds")
`%!in%` <- Negate(`%in%`)

source("R/simple_projection_fnc.R")

stock <- unique(data$STOCK_ID)


for (i in 1:length(stock)) {

  data_stock <- filter(data, STOCK_ID == stock[i])
  fishery_group <- unique(data_stock$FISHERY_GROUP)

  for (j in 1:length(fishery_group)) {

    assign(paste0(stock[i],"_",fishery_group[j]), simple_projection(data = data_stock
                                                                    , stock = stock[i]
                                                                    , fishery_group = fishery_group[j]))


  }

}

#### change plot in function to offset label by some % of ACL


table <- data.frame(stock = "GOM Yellowtail",
                    total_catch = YELCCGM_SECT$final_MT + YELCCGM_CP$final_MT + YELCCGM_STATE$final_MT + YELCCGM_OTHER$final_MT,
                    total_groundfish = YELCCGM_SECT$final_MT + YELCCGM_CP$final_MT,
                    sector = YELCCGM_SECT$final_MT,
                    common_pool = YELCCGM_CP$final_MT,
                    recreational = '*',
                    scallop = 'NA*',
                    small_mesh = 'NA*',
                    state = YELCCGM_STATE$final_MT,
                    other = YELCCGM_OTHER$final_MT) |>
  rbind(data.frame(stock = "GB Yellowtail",
                    total_catch = YELGB_GROUND$final_MT + `YELGB_SQUID/WHITING`$final_MT + YELGB_SCALLOP$final_MT + YELCCGM_OTHER$final_MT,
                   total_groundfish = YELGB_GROUND$final_MT,
                    sector = 'NA**',
                    common_pool = 'NA**',
                    recreational = '*',
                    scallop = YELGB_SCALLOP$final_MT,
                    small_mesh = `YELGB_SQUID/WHITING`$final_MT,
                    state = "NA**",
                    other = YELGB_OTHER$final_MT)) |>
  rbind(data.frame(stock = "SNE Yellowtail",
                   total_catch = YELSNE_CP$final_MT + YELSNE_SECT$final_MT + YELSNE_SCALLOP$final_MT + YELSNE_STATE$final_MT + YELSNE_OTHER$final_MT,
                   total_groundfish =  YELSNE_CP$final_MT + YELSNE_SECT$final_MT,
                   sector = YELSNE_SECT$final_MT,
                   common_pool = YELSNE_CP$final_MT,
                   recreational = '*',
                   scallop = YELSNE_SCALLOP$final_MT,
                   small_mesh = "NA*",
                   state = YELSNE_STATE$final_MT,
                   other = YELSNE_OTHER$final_MT)) |>
  rbind(data.frame(stock = "GB Witch Flounder",
                   total_catch = FLWGB_GROUND$final_MT + FLWGB_OTHER$final_MT,
                   total_groundfish =  FLWGB_GROUND$final_MT,
                   sector = "NA**",
                   common_pool = "NA**",
                   recreational = '*',
                   scallop = "NA*",
                   small_mesh = "NA*",
                   state = "NA",
                   other = FLWGB_OTHER$final_MT)) |>
  rbind(data.frame(stock = "SNEMA Witch Flounder",
                   total_catch = FLWSNEMA_CP$final_MT + FLWSNEMA_OTHER$final_MT + FLWSNEMA_SECT$final_MT + FLWSNEMA_STATE$final_MT,
                   total_groundfish = FLWSNEMA_CP$final_MT + FLWSNEMA_SECT$final_MT,
                   sector = FLWSNEMA_SECT$final_MT,
                   common_pool = FLWSNEMA_CP$final_MT,
                   recreational = '*',
                   scallop = "NA*",
                   small_mesh = "NA*",
                   state = FLWSNEMA_STATE$final_MT,
                   other =  FLWSNEMA_OTHER$final_MT)) |>
  rbind(data.frame(stock = "White Hake",
                   total_catch = HKWGMMA_CP$final_MT + HKWGMMA_OTHER$final_MT + HKWGMMA_SECT$final_MT + HKWGMMA_STATE$final_MT,
                   total_groundfish = HKWGMMA_CP$final_MT + HKWGMMA_SECT$final_MT,
                   sector = HKWGMMA_SECT$final_MT,
                   common_pool = HKWGMMA_CP$final_MT,
                   recreational = '*',
                   scallop = "NA*",
                   small_mesh = "NA*",
                   state = HKWGMMA_STATE$final_MT,
                   other =  HKWGMMA_OTHER$final_MT)) |>
  rbind(data.frame(stock = "Redfish",
                   total_catch = REDGMGBSS_CP$final_MT + REDGMGBSS_OTHER$final_MT + REDGMGBSS_SECT$final_MT + REDGMGBSS_STATE$final_MT,
                   total_groundfish = REDGMGBSS_CP$final_MT + REDGMGBSS_SECT$final_MT,
                   sector = REDGMGBSS_SECT$final_MT,
                   common_pool = REDGMGBSS_CP$final_MT,
                   recreational = '*',
                   scallop = "NA*",
                   small_mesh = "NA*",
                   state = REDGMGBSS_STATE$final_MT,
                   other =  REDGMGBSS_OTHER$final_MT))


saveRDS(table, file = "output/table")



# FLWGB_GROUND$plot
# FLWGB_OTHER$plot
# FLWSNEMA_CP$plot
# FLWSNEMA_OTHER$plot
# FLWSNEMA_SECT$plot
# FLWSNEMA_STATE$plot
# HKWGMMA_CP$plot
# HKWGMMA_SECT$plot
# HKWGMMA_STATE$plot
# HKWGMMA_OTHER$plot
# REDGMGBSS_SECT$plot
# REDGMGBSS_CP$plot
# REDGMGBSS_STATE$plot
# REDGMGBSS_OTHER$plot
# YELCCGM_CP$plot
# YELCCGM_SECT$plot
# YELCCGM_STATE$plot
# YELCCGM_OTHER$plot
# YELGB_GROUND$plot
# YELGB_OTHER$plot
# YELGB_SCALLOP$plot
# `YELGB_SQUID/WHITING`$plot
# YELSNE_CP$plot
# YELSNE_SECT$plot
# YELSNE_SCALLOP$plot
# YELSNE_STATE$plot
# YELSNE_OTHER$plot
