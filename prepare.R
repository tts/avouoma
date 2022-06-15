library(sf)
library(tidyverse)
library(igraph)
library(leaflet)

baseurl <- "https://kartta.hel.fi/ws/geoserver/avoindata/wfs?request=GetFeature&service=WFS&version=2.0.0"
type <- "avoindata:Avouomat"
wfs_request <- paste0(baseurl, "&typeName=", type, "&outputFormat=json")
res <- st_read(wfs_request, quiet = TRUE, stringsAsFactors = FALSE)
res_4326 <- st_transform(res, crs = 4326)

write_rds(res_4326, "res_4326.RDS")
res_4326 <- readRDS("res_4326.RDS")

rm(res)
gc()

norot <- res_4326 %>% 
  filter(uomatyyppi == "noro")

joet <- res_4326 %>% 
  filter(uomatyyppi == "joki")

ojat <- res_4326 %>% 
  filter(uomatyyppi == "oja")

purot <- res_4326 %>% 
  filter(uomatyyppi == "puro")

# Merge adjacent lines
# https://stackoverflow.com/a/69178982

merge_them <- function(x) {
  touching_list = st_touches(x)
  my_igraph <- graph_from_adj_list(touching_list)
  components <- components(my_igraph)$membership
  return(components)
}
 
uoma_components <- merge_them(joet)
joet_m <- joet %>% 
  group_by(line = as.character({{uoma_components}}),
           nimi = nimi) %>% 
  summarise()
write_rds(joet_m, "joet_m.RDS")

uoma_components <- merge_them(purot)
purot_m <- purot %>% 
  group_by(line = as.character({{uoma_components}}),
           nimi = nimi) %>% 
  summarise()
write_rds(purot_m, "purot_m.RDS")

uoma_components <- merge_them(ojat)
ojat_m <- ojat %>% 
  group_by(line = as.character({{uoma_components}})) %>% 
  summarise()
write_rds(ojat_m, "ojat_m.RDS")

uoma_components <- merge_them(norot)
norot_m <- norot %>% 
  group_by(line = as.character({{uoma_components}}),
           nimi = nimi) %>% 
  summarise()
write_rds(norot_m, "norot_m.RDS")

rm(res_4326, joet, ojat, norot, purot)
gc()

