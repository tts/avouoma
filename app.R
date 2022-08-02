library(shiny)
library(sf)
library(leaflet)

Rivers <- readRDS("joet_m.RDS")
Streams <- readRDS("purot_m.RDS")
Dribbles <- readRDS("norot_m.RDS")
#Ditches <- readRDS("ojat_m.RDS")

targets <- c("Dribbles", "Rivers", "Streams")

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(bottom = 400, right = 20,
                draggable = TRUE,
                selectInput(inputId = "target",
                            label = "Waterway",
                            choices = targets,
                            selected = "Rivers"),
                HTML("<div><br/><a target='blank' href='https://github.com/tts/avouoma/'>Code</a></div>")
  )
)

server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
    
    o <- get(input$target)
    
    leaflet() %>%
      addProviderTiles("CartoDB.Positron",
                       options = providerTileOptions(minZoom = 9, maxZoom = 15)) %>% 
      addPolylines(data = o, color = "#148F77", weight = 2,
                   label = o$nimi)

    })
  
}

shinyApp(ui, server)