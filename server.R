shinyServer(function(input, output) {
  
  # create reactive data set that is filtered by user inputs
  data <- reactive({
    data <- 
      schools %>% 
      # school type filter
      filter(type %in% input$school_type) %>% 
      # enrollment filter
      filter(enrollment >= input$enrollment[1]) %>% 
      filter(enrollment <= input$enrollment[2])

    data
    
  })
  
  # Render leaflet base map and legend once
  output$school_map <- renderLeaflet({
    
    m  %>% 
      addLegend(pal = pal, values = c("Public Secondary", "Private Secondary", 
                                      'Public 4-year College', 'Private nonprofit 4-year College'),
                position = "bottomright", opacity = 1)
    
  })
  
  # update leaflet map by clearing and redrawing markers whenever user input filers are updated
  # this prevents the map zoom and center from resetting when users change filters
  observe({
    leafletProxy("school_map") %>%
      clearMarkers() %>% 
      clearMarkerClusters() %>% 
      addCircleMarkers(data = data(), popup = ~text, radius = 4, clusterOptions = markerClusterOptions(), color = ~pal(type)) %>% 
      addCircleMarkers(data = nols, popup = ~name, color = "black")
  })
  
  # create reactive data set that contains only schools that are visible on the map
  data_map <- reactive({
    
    # get current lat/lon bounds of map
    bounds <- input$school_map_bounds
    
    # filter data that is already filtered by user inputs by lat/lon bounds of map
    data() %>%
      filter(
        latitude > bounds$south &
          latitude < bounds$north &
          longitude < bounds$east & 
          longitude > bounds$west)
    
  })
  
  # create data table of schools that are visible on the map
  output$tbl <- DT::renderDataTable({
    
    DT::datatable(
      data_map() %>% 
        # sort data by enrollment
        arrange(desc(enrollment)) %>% 
        select(name, type, enrollment),
      extensions = "Scroller",
      class = "compact",
      width = "100%",
      options = list(
        deferRender = TRUE,
        scrollY = 300,
        scroller = TRUE
      ), rownames= FALSE
    ) %>% formatCurrency('enrollment',currency = "", interval = 3, mark = ",", digits = 0)
  })
  
  
})