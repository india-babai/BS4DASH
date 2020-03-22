# Load packages
library(shiny)
library(shinyWidgets)
library(bs4Dash)
library(plotly)
library(echarts4r)
library(shinyTime)
library(kableExtra)
library(DT)
library(imager)
library(scales)
library(shinyjs)
library(dygraphs)
library(shinyalert)
library(lattice)
library(shinycssloaders)
library(openxlsx)
library(magick)


source("D:/DS/IoT my task/AP/bs4dash/BS4DASH/3d_heatmap.R")
source("D:/DS/IoT my task/AP/bs4dash/BS4DASH/ts_plot.R")
source("D:/DS/IoT my task/AP/bs4dash/BS4DASH/from_to_module.R")
source("D:/DS/IoT my task/AP/bs4dash/BS4DASH/readme_html.R")

# The following excel is required for the 'Cross reference data' tab
datapath <- "D:/DS/IoT my task/AP/bs4dash/BS4DASH/inputs/table_for_user.xlsx"

# blank table
blank_tab <- data.frame()
blank_tab$Date <- character(0)
blank_tab$Method <- character(0)
blank_tab$`Volume(cc)` <- numeric(0)
blank_tab$`X axis(mm)` <- numeric(0)
blank_tab$`Y axis(mm)` <- numeric(0)
blank_tab$`Picture of defect` = character(0)

# initial - table
initial_tab <- openxlsx::read.xlsx(datapath, sep.names = ' ', detectDates = T)


# color statuses
statusColors <- c(
  "navy",
  "gray-dark",
  "gray",
  "secondary",
  "indigo",
  "purple",
  "primary",
  "info",
  "success",
  "olive",
  "teal",
  "lime",
  "warning",
  "orange",
  "danger",
  "fuchsia",
  "maroon",
  "pink",
  "light"
)


# Time-series tab ----
    # InfluxDB Database contains many measurements
    # measurements ---> table-name
    # tag ---> Character variable (group_by variable)
    # field ---> floating/numeric variable on which time series will be plotted 

ts_card_tab <- bs4TabItem(
  tabName = "timeseries",
    fluidPage(
      useShinyalert(),
      useShinyjs(),
      sidebarLayout(position = "right",
                        sidebarPanel(width = 2,
                      h6(icon("wrench"),strong("Customizations")),
                      hr(),
                      selectInput("ts_measurement", label = "Table name", choices = "two_mab_test_run" ),
                      selectInput("ts_mag_type", label = "Sensor patches", choices = c("MAB 1(LIS)" = "LIS3MDL", "MAB 2(MLX)" = "MLX90393", "MAB 3(Unidentified)" = "Unidentified Magnetometer") ),
                      uiOutput("ts_sensor_out"),
                      selectInput("ts_varname", label = "Parameter", choices = c("X(uT)",	"Y(uT)", "Z(uT)", "T(*C)",
                                                                                 "LLR", "Max_T", "LLR & Max_T") ),
                      hr(),
                      fromToInput("ts_daterange1", offset = 365), # Use of shiny module: Refer to 'from_to_module.R'
                      fromToInput("ts_daterange2", label = "To date", offset = 0), # Use of shiny module: Refer to 'from_to_module.R'
                      
                      actionButton("ts_action", "Submit", icon = icon("refresh"),
                                   style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
                      

                    ),
                    mainPanel(
                      h6(strong("Timeseries analysis")),
                      hr(),
                      shinycssloaders::withSpinner(
                      dygraphOutput("ts_dy_plot", height = "700px", width = "auto"), type = 1, color = "#991B1B"
                      ),
                      hr(),
                      bs4Card(
                        title = "Sensor patch description",
                        status = "dark",
                        width = 12,
                        collapsible = T,
                        collapsed = T,
                        
                      
                      fluidRow(
                      shiny::column(width = 3,
                                             # h6(strong("Site-image of sensor")),
                      uiOutput("ts_site_img")
                      # tags$img(src = "LIS.jpg", height = '200px', width = '300px' )
                      ),
                      shiny::column(
                        width = 3,
                        h6(strong("Attributes")),
                        DTOutput("ts_img_attr")
                      ),
                      shiny::column(
                        width = 3,
                        textAreaInput(
                          "ts_img_remarks",
                          "Comments",
                          value = "Free text",
                          width = "300px",
                          height = "200px"
                        )
                      ),
                      shiny::column(
                        width = 3,
                        fileInput("ts_new_img", "Upload a new site-image", accept = c("jpg", "png", "PNG", "JPG")),
                        br(),
                        br(),
                        actionButton("ts_img_save", label = "Save", icon = icon("save"), style = "color: #fff; background-color: #000104; border-color: #2e6da4" )
                      )
                      )
                      
                      ),#bs4card
                      hr(),
                      h5("Sample data"),
                      shinyWidgets::prettySwitch(inputId = "showdata", "Show sample data", value = F, status = "success", fill = T),
                      dataTableOutput("ts_data"),
                      width = 10
                    )
                    
      )
    )
)
  




# 3d heatmap tab ----
basic_cards_tab <- bs4TabItem(
  tabName = "cards",
  fluidPage(
    sidebarLayout(
      sidebarPanel(
        h6(icon("wrench"),strong("Customizations")),
        # textInput("connection", "InfluxDB connection", value = 8086),
        # textInput("dbname", "InfluxDB database name", value = "example3"),
        textInput("measurement", "Table name", value = "two_mab_test_run"),
        selectInput("magtype", "Sensor patches", choices =  c("MAB 1(LIS)" = "LIS3MDL", "MAB 2(MLX)" = "MLX90393")),
        dateInput("date", "Date", value = "2020-01-07" ),
        timeInput("time", "Time", value = "2020-01-07 16:53:00"),
        actionButton("heatmap_action", "Submit", icon = icon("refresh"),
                     style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"),
        width = 2
      ),
      mainPanel(
        h6(strong("Heatmap visualisation")),
        hr(),
        h6(textOutput("show_date_time")),
        br(),
        fluidRow(
        bs4Card(
          title = "Bx",
          status = "primary",
          collapsible = T,
          closable = T,
          maximizable = T,
          collapsed = F,
          # width = 12,
          shinycssloaders::withSpinner(
          plotlyOutput("plot_heatmap_x"),type = 1, color = "#991B1B")
        ),
        bs4Card(
          title = "By",
          status = "primary",
          collapsible = T,
          closable = T,
          maximizable = T,
          collapsed = F,
          # width = 6,
          shinycssloaders::withSpinner(
            plotlyOutput("plot_heatmap_y"),type = 1, color = "#991B1B")
        ),
        
        br(),
        hr(),
        bs4Card(
          title = "Bz",
          status = "primary",
          collapsible = T,
          closable = T,
          maximizable = T,
          width = 12,
          shinycssloaders::withSpinner(
            plotlyOutput("plot_heatmap_z"),type = 1, color = "#991B1B")
        )
        )
        ,
        width = 10
      ),
      position = "right"
    )
  )
)

# Table plot ----
cards_api_tab <- bs4TabItem(
  tabName = "tabplot",
  bs4Card(
    inputId = "mycard",
    title = "The table is visible when you maximize the card", 
    closable = TRUE, 
    maximizable = TRUE,
    width = 12,
    status = "secondary", 
    solidHeader = FALSE, 
    collapsible = TRUE,
    shinycssloaders::withSpinner(
    DTOutput("dt"), type = 4, color = "#991B1B"),
    actionButton(inputId = "savedat", "Save", icon = icon("save"))
  ),
  hr(),
  h4("Add or delete rows here"),
  br(),
  fluidRow(
    column(width = 2,
           dateInput("dt_date", label = "Date")),

    column(width = 2,
           textInput("dt_method", "Method", value = "Optical")),
    
    column(width = 2,
           textInput("dt_location", "Defect location", value = "30cm from the end, at the pipe bottom")),
    
    column(width = 1, offset = 1,
           numericInput("dt_volume", "Volume", round(runif(1),2) )),
    
    column(width = 1,
           numericInput("dt_x", "X axis(mm)", round(runif(1)*10,2))),
    
    column(width = 1,
           numericInput("dt_y", "Y axis(mm)", round(runif(1)*100,2))),
    
    column(width = 2,
           fileInput("dt_pic", "Picture of the defect", accept = c("jpg", "png", "PNG", "JPG"))),
  ),
  # Add button
  actionButton(inputId = "add.button", label = "Add row", icon =  icon("plus"),
               style = "color: #fff; background-color: #336600; border-color: #336600"), 
  
  hr(),
  # Row selection for deletion
  numericInput(inputId = "row.selection", label = "Select row to be 
                     deleted", min = 1, max = 100, value = ""),

  # Delete button 
  actionButton(inputId = "delete.button", label = "Del row", icon = icon("minus"),
               style = "color: #fff; background-color: #ff0000; border-color: #ff0000" ),
                
  textOutput("all"),
  hr()
  # submitButton(text = "Submit", icon = icon("refresh"))
  
)


# Track defect ----
track_defect_tab <- bs4TabItem(tabName = "tdefect",
                               fluidPage(
                                 sidebarLayout(
                                   position = "right",
                                   sidebarPanel =
                                     sidebarPanel(
                                       width = 2,
                                       h6(icon("cogs"), strong("Settings")),
                                       fromToInput("dfct_from", offset = 365),
                                       fromToInput("dfct_to", label = "To date", offset = 0),
                                       numericInput(
                                         "no_hmaps",
                                         "Frequency of snapshots",
                                         value = 5,
                                         min = 1,
                                         max = 10,
                                         step = 1
                                       ),
                                       actionButton("dfct_action", "Submit", icon = icon("refresh"),
                                                    style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
                          
                                     ),
                                   mainPanel = mainPanel(width = 10,
                                                         
                                                         bs4Card(

                                                           title = "Progression of depth profiler output over time",
                                                           closable = TRUE,
                                                           maximizable = TRUE,
                                                           width = 12,
                                                           status = "secondary",
                                                           solidHeader = FALSE,
                                                           collapsible = TRUE,
                                                           plotOutput("dfct_plot")
                                                         ),
                                                         
                                                         bs4Card(
                                                           
                                                           title = "Graph of LLR, Threshold, Max of depth profile",
                                                           closable = TRUE,
                                                           maximizable = TRUE,
                                                           width = 12,
                                                           status = "secondary",
                                                           solidHeader = FALSE,
                                                           collapsible = TRUE,
                                                           collapsed = F,
                                                           tags$img(
                                                             src = paste0("Line plot defect", ".png"),
                                                             height = '500px',
                                                             width = '1200px'
                                                           )
                                                         ),
                                                        
                                                         bs4Card(
                                                           inputId = "mycard",
                                                           title = "Data",
                                                           closable = TRUE,
                                                           maximizable = TRUE,
                                                           width = 12,
                                                           status = "secondary",
                                                           solidHeader = FALSE,
                                                           collapsible = TRUE,
                                                           DTOutput("dfct_dt")
                                                           )
                                                        
                                                         )
                                 )
                               ))

#  sim_input_tab ----
sim_input_tab <- bs4TabItem(
  tabName = "siminput",
  fluidPage()
)


# social_cards_tab ----
social_cards_tab <- bs4TabItem(
  tabName = "socialcards",
  fluidRow(
    bs4UserCard(
      src = "https://adminlte.io/themes/AdminLTE/dist/img/user1-128x128.jpg",
      status = "info",
      title = "User card type 1",
      subtitle = "a subtitle here",
      elevation = 4,
      "Any content here"
    ),
    bs4UserCard(
      type = 2,
      src = "https://adminlte.io/themes/AdminLTE/dist/img/user7-128x128.jpg",
      status = "success",
      imageElevation = 4,
      title = "User card type 2",
      subtitle = "a subtitle here",
      bs4ProgressBar(
        value = 5,
        striped = FALSE,
        status = "info"
      ),
      bs4ProgressBar(
        value = 20,
        striped = TRUE,
        status = "warning"
      )
    )
  ),
  fluidRow(
    bs4SocialCard(
      title = "Social Card",
      subtitle = "example-01.05.2018",
      src = "https://adminlte.io/themes/AdminLTE/dist/img/user4-128x128.jpg",
      "Some text here!",
      comments = tagList(
        lapply(X = 1:10, FUN = function(i) {
          cardComment(
            src = "https://adminlte.io/themes/AdminLTE/dist/img/user3-128x128.jpg",
            title = paste("Comment", i),
            date = "01.05.2018",
            paste0("The ", i, "-th comment")
          )
        })
      ),
      footer = "The footer here!"
    ),
    bs4Card(
      title = "Box with user comment",
      status = "primary",
      userPost(
        id = 1,
        collapse_status = "secondary",
        src = "https://adminlte.io/themes/AdminLTE/dist/img/user1-128x128.jpg",
        author = "Jonathan Burke Jr.",
        description = "Shared publicly - 7:30 PM today",
        "Lorem ipsum represents a long-held tradition for designers, 
       typographers and the like. Some people hate it and argue for 
       its demise, but others ignore the hate as they create awesome 
       tools to help create filler text for everyone from bacon 
       lovers to Charlie Sheen fans.",
        userPostTagItems(
          userPostTagItem(bs4Badge("item 1", status = "warning")),
          userPostTagItem(bs4Badge("item 2", status = "danger"))
        )
      ),
      userPost(
        id = 2,
        collapse_status = "secondary",
        src = "https://adminlte.io/themes/AdminLTE/dist/img/user6-128x128.jpg",
        author = "Adam Jones",
        description = "Shared publicly - 5 days ago",
        userPostMedia(src = "https://adminlte.io/themes/AdminLTE/dist/img/photo2.png"),
        userPostTagItems(
          userPostTagItem(bs4Badge("item 1", status = "info")),
          userPostTagItem(bs4Badge("item 2", status = "danger"))
        )
      )
    )
  ),
  fluidRow(
    bs4Card(
      status = "primary",
      width = 3,
      solidHeader = TRUE,
      cardProfile(
        src = "https://adminlte.io/themes/AdminLTE/dist/img/user4-128x128.jpg",
        title = "Nina Mcintire",
        subtitle = "Software Engineer",
        cardProfileItemList(
          bordered = TRUE,
          cardProfileItem(
            title = "Followers",
            description = 1322
          ),
          cardProfileItem(
            title = "Following",
            description = 543
          ),
          cardProfileItem(
            title = "Friends",
            description = 13287
          )
        )
      )
    ),
    bs4Card(
      title = "Card with messages",
      width = 9,
      userMessages(
        width = 12,
        status = "success",
        userMessage(
          author = "Alexander Pierce",
          date = "20 Jan 2:00 pm",
          src = "https://adminlte.io/themes/AdminLTE/dist/img/user1-128x128.jpg",
          side = NULL,
          "Is this template really for free? That's unbelievable!"
        ),
        userMessage(
          author = "Dana Pierce",
          date = "21 Jan 4:00 pm",
          src = "https://adminlte.io/themes/AdminLTE/dist/img/user5-128x128.jpg",
          side = "right",
          "Indeed, that's unbelievable!"
        )
      )
    )
  )
)



# Read me ----
readme_tab <- bs4TabItem(
  tabName = "user_guide",
  readme_html
  
)

# gallery_2_tab ----
gallery_2_tab <- bs4TabItem(
  tabName = "gallery2",
  bs4Jumbotron(
    title = "I am a Jumbotron!",
    lead = "This is a simple hero unit, a simple jumbotron-style 
                    component for calling extra attention to featured 
                    content or information.",
    "It uses utility classes for typography and spacing 
            to space content out within the larger container.",
    status = "primary",
    href = "https://www.google.fr"
  ),
  
  br(),
  
  fluidRow(
    bs4Card(
      title = "Badges",
      bs4Badge(status = "secondary", "blabla", rounded = TRUE),
      bs4Badge(status = "info", "blabla", rounded = TRUE)
    )
  ),
  
  br(),
  
  h4("BS4 list group"),
  fluidRow(
    bs4ListGroup(
      bs4ListGroupItem(
        type = "basic",
        "Cras justo odio"
      ),
      bs4ListGroupItem(
        type = "basic",
        "Dapibus ac facilisis in"
      ),
      bs4ListGroupItem(
        type = "basic",
        "Morbi leo risus"
      )
    ),
    bs4ListGroup(
      bs4ListGroupItem(
        "Cras justo odio",
        active = TRUE, 
        disabled = FALSE, 
        type = "action",
        src = "https://www.google.fr"
      ),
      bs4ListGroupItem(
        active = FALSE, 
        disabled = FALSE, 
        type = "action",
        "Dapibus ac facilisis in",
        src = "https://www.google.fr"
      ),
      bs4ListGroupItem(
        "Morbi leo risus",
        active = FALSE, 
        disabled = TRUE, 
        type = "action",
        src = "https://www.google.fr"
      )
    ),
    bs4ListGroup(
      bs4ListGroupItem(
        "Donec id elit non mi porta gravida at eget metus. 
                Maecenas sed diam eget risus varius blandit.",
        active = TRUE, 
        disabled = FALSE, 
        type = "heading",
        title = "List group item heading", 
        subtitle = "3 days ago", 
        footer = "Donec id elit non mi porta."
      ),
      bs4ListGroupItem(
        "Donec id elit non mi porta gravida at eget metus. 
                Maecenas sed diam eget risus varius blandit.",
        active = FALSE, 
        disabled = FALSE, 
        type = "heading",
        title = "List group item heading", 
        subtitle = "3 days ago", 
        footer = "Donec id elit non mi porta."
      )
    )
  )
)
