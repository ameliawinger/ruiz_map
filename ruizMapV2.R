setwd("~/Desktop/ruiz_map")

#Load libraries
packages <- c("tidyverse", "rvest", "dplyr", "lubridate", "tidygeocoder", "ggplot2", "stringr", "readr", "leaflet", "htmltools", "htmlwidgets", "geojsonio",
              "rgdal", "leafem", "raster", "sf", "lattice", "xml2", "leaflet.extras")
lapply(packages, require, character.only = TRUE)    

#Import data
ruiz_sold <- read_csv("ruizSold.csv")
ruiz_notsold <- read_csv("ruizNotSold.csv")
ruiz_miami <- read_csv("ruizMiami.csv")

##Labels for sold
labs_sold <- lapply(seq(nrow(ruiz_sold)), function(i) {
  paste0('<img src=', ruiz_sold[i,"GithubLink"], 'width="250" /><br />',
         "<b>Purchase Price: </b>",ruiz_sold[i, "Purchase_price_pretty"], '<br />',
         "<b>Purchase Date: </b>", ruiz_sold[i,"Purchase_date_pretty"], '<br />',
         "<b>Sale Price: </b>", ruiz_sold[i, "sale_price_pretty"], '<br />',
         "<b>Sale Date: </b>", ruiz_sold[i,"Sale_date_pretty"])})

##Labels for not sold
labs_notsold <- lapply(seq(nrow(ruiz_notsold)), function(i) {
  paste0('<img src=', ruiz_notsold[i,"GithubLink"], 'width="250" /><br />',
         "<b>Purchase Price: </b>",ruiz_notsold[i, "Purchase_price_pretty"], '<br />',
         "<b>Purchase Date: </b>", ruiz_notsold[i,"Purchase_date_pretty"], '<br />')})

##Label for Miami property
lab_miami <- lapply(seq(nrow(ruiz_miami)), function(i) {
  paste0("<b>",ruiz_miami[i,"add_pretty"], "</b><br />", 
         '<img src=', ruiz_miami[i, "GithubLink"],'width="300" /><br />',
         "<b>Purchase Price: </b>",ruiz_miami[i, "Purchase_price_pretty"], '<br />',
         "<b>Purchase Date: </b>", ruiz_miami[i,"Purchase_date_pretty"], '<br />',
         "<b>Sale Date: </b>", ruiz_miami[i,"Sale_date_pretty"])})


#Map
m <- leaflet(ruiz_sold, options = leafletOptions(zoomControl=F)) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(lng = -80.25798388870786, lat = 25.690846123410093, zoom = 16) %>% 
  addEasyButton(easyButton(
    icon = "<b>Zoom to Miami</b>",
    states=list(
      easyButtonState(
        stateName = "miami",
        icon= "<rect width='130px'><b>Zoom to Miami</b></rect>",
        title = "Zoom to Miami",
        onClick = JS("function(btn, map) {
                   map.flyTo([25.77244666,	-80.38881243], 17, {animate: true, duration: 2.5});
                   btn.state('gable-estates');
                   btn.button.style.width = '160px';
                   btn.button.style.textAlign='center';
                   }")),
      easyButtonState(
        stateName = "gable-estates",
        icon= "<rect width='160px'><b>Zoom to Gable Estates</b></rect>",
        title = "Zoom to Gable Estates",
        onClick = JS("function(btn, map) {
                     map.flyTo([25.690846123410093, -80.25798388870786], 16, {animate: true, duration: 2.5});
                     btn.state('miami');
                     btn.button.style.width = '110px';
                     btn.button.style.textAlign='center';
                     }")
      )))) %>% 
  htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topleft' }).addTo(this)
    }") %>% 
  addCircles(lng=ruiz_sold$Y, lat=ruiz_sold$X,
             fillColor="#743a80", stroke=T, color="#743a80",
             weight=4, fillOpacity=1, radius=30, opacity=1,
             label=lapply(labs_sold, htmltools::HTML),
             labelOptions = labelOptions(direction="right", textsize = "15px"),
             highlightOptions = highlightOptions(
               fillOpacity=0,
               weight=2)) %>% 
  addCircles(lng=ruiz_notsold$Y, lat=ruiz_notsold$X,
             fillColor="#743a80", stroke=T, color="#743a80",
             weight=4, fillOpacity=1, radius=30, opacity=1,
             label=lapply(labs_notsold, htmltools::HTML),
             labelOptions = labelOptions(direction="right", textsize = "15px"),
             highlightOptions = highlightOptions(
               fillOpacity=0,
               weight=2)) %>% 
  addCircles(lng=-80.38875744150997, lat=25.772182176782206,
             fillColor="#743a80", stroke=T, color="#743a80",
             weight=4, fillOpacity=1, radius=20, opacity=1,
             label=lapply(lab_miami, htmltools::HTML),
             labelOptions = labelOptions(direction="right", textsize = "15px"),
             highlightOptions=highlightOptions(
               fillOpacity=0, weight=2))
m
#Export
saveWidget(m, file="ruizmap.html")  