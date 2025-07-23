library(tidyverse)
data <- readRDS(file = "output/catch_proj_data.rds")
`%!in%` <- Negate(`%in%`)

source("simple_projection_fnc.R")

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


FLWGB_GROUND$plot
FLWGB_OTHER$plot
FLWSNEMA_CP$plot
FLWSNEMA_OTHER$plot
FLWSNEMA_SECT$plot
FLWSNEMA_STATE$plot
HKWGMMA_CP$plot
HKWGMMA_SECT$plot
HKWGMMA_STATE$plot
HKWGMMA_OTHER$plot
REDGMGBSS_SECT$plot
REDGMGBSS_CP$plot
REDGMGBSS_STATE$plot
REDGMGBSS_OTHER$plot
YELCCGM_CP$plot
YELCCGM_SECT$plot
YELCCGM_STATE$plot
YELCCGM_OTHER$plot
YELGB_GROUND$plot
YELGB_OTHER$plot
YELGB_SCALLOP$plot
`YELGB_SQUID/WHITING`$plot
YELSNE_CP$plot
YELSNE_SECT$plot
YELSNE_SCALLOP$plot
YELSNE_STATE$plot
YELSNE_OTHER$plot
