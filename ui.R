
shinyUI(bootstrapPage(theme="bootstrap.css",
                      tags$head(
                        # Include custom CSS
                        includeCSS("styles.css"), 
                        
                        # prevent error message related to element loading sequence that needs to be resolved
                        tags$style(type="text/css",
                                   ".shiny-output-error { visibility: hidden; }",
                                   ".shiny-output-error:before { visibility: hidden; }"
                        )
                      ),
                      
                      shinyjs::useShinyjs(),                      
                      
                      tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
                      
                      # display leaflet map at 100% of window
                      leafletOutput("school_map", width = "100%", height = "100%"),
                      
                      # create panel to show filters and table
                      # definte panel properties
                      absolutePanel(id = "controls", 
                                    fixed = TRUE,
                                    draggable = TRUE, 
                                    top = 60, left = "auto", right = 20, bottom = "auto",
                                    width = "750", 
                                    height = "auto",
                                    
                                    # display data table
                                    dataTableOutput("tbl"),
                                    
                                    # display data filters
                                    br(),
                                    strong("Filter Data"),
                                    br(),
                                    
                                    selectInput("school_type", label = "Select School Types", multiple = TRUE,
                                                selected = c("Public Secondary", "Private Secondary", 'Public 4-year College', 'Private nonprofit 4-year College'),
                                                choices = c("Public Secondary", "Private Secondary", 'Public 4-year College', 'Private nonprofit 4-year College')
                                                ),
                                    
                                    br(),
                                    
                                    sliderInput("enrollment", label = "School Enrollment", min = 1, max = 150000, step = 500, width = '100%', value = c(1, 150000))
                                    
                      )
)
)