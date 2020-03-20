server <-  function(input, output, session) {
  
  # Connection settings ----
  # InfluxDB connection
  con <- reactive(
    influxdbr::influx_connection(
      host = "localhost",
      port = as.numeric(input$connection),
      user = "username",
      pass = "password"
    )
  )
  
  
  
  #### Time series: Beginning ####
  ts_dt1 <- callModule(fromTo, "ts_daterange1") # Use of shiny module: Refer to 'from_to_module.R'
  ts_dt2 <- callModule(fromTo, "ts_daterange2") # Use of shiny module: Refer to 'from_to_module.R'
  
  output$ts_sensor_out <- renderUI({
    choices <- switch(input$ts_mag_type,
                      "LIS3MDL" = 1:100,
                      "MLX90393" = 201:300,
                      "Unidentified Magnetometer" = 401:500)
    
    selectInput(inputId = "ts_sensor", label = "Sensor number", choices = c("All",as.character(choices)), multiple = T,
                selected = as.character(choices)[1])
    
  })
  
  sensor_filter <- reactive({
    sensors <- input$ts_sensor
    
    if (sensors != "All") {
      s1 <- NULL
      if (length(sensors) > 0) {
        for (s in sensors) {
          s1 <- paste0(s1, " Sensor = ", "'", s, "'", " OR ")
        }
        s1 <- substring(s1, 1, nchar(s1) - 3)
      }
    }
    else {
      choices_all <- switch(input$ts_mag_type,
                        "LIS3MDL" = 1:100,
                        "MLX90393" = 201:300,
                        "Unidentified Magnetometer" = 401:500)
      s1 <- NULL
      if (length(sensors) > 0) {
        for (s in choices_all) {
          s1 <- paste0(s1, " Sensor = ", "'", s, "'", " OR ")
        }
        s1 <- substring(s1, 1, nchar(s1) - 3)
      }
      
    }
    s1
  })
  
  
  ts_dat <- 
    eventReactive(input$ts_action,{
    # reactive({
      if (input$ts_sensor == "All") {
        showModal(
          modalDialog(
            title = h3(icon("exclamation-triangle"),"Warning"),
            "This could take several minutes as all sensors are selected",
            easyClose = T,
            fade = T
            
            
            
          )
        )
      }
      
      
    temp <- influxdbr::influx_select(
      con(),
      db = "example",
      measurement = input$ts_measurement,
      field_keys = '"X(uT)",	"Y(uT)",	"Z(uT)",	"T(*C)"',
      where = paste(
        "time >= ",
        paste0("'", ts_dt1(), "'"),
        "and time <= ",
        paste0("'", ts_dt2(), "'"),
        "and mag_type = ",
        paste0("'", input$ts_mag_type, "'"),
        "and ( ",
        sensor_filter(),
        " )"
      ),
      group_by = "mag_type, Sensor",
      # limit = 1000,
      return_xts = F
    )[[1]]
    
    if (sum(sapply(temp, function(x)
           all(is.na(x)))) == 5) {
      final <- NULL
    }
    else {
      final <- temp
    }
    final
  # })
  }, ignoreNULL = T)
  
  
  
  
  
  observe({
    if (is.null(ts_dat())) {
      shinyalert::shinyalert(
        title = "Error",
        text = "No data fetched. PLease change the inputs",
        type = "error",
        closeOnEsc = T,
        closeOnClickOutside = T,
        timer = 0
      )
    }
  })
  observeEvent(input$ts_mag_type, {
    shinyalert::shinyalert(
      title = "Press SUBMIT",
      text = "Click on submitt button in the panel on right to see updated graph!",
      type = "info",
      closeOnClickOutside = T,
      closeOnEsc = T,
      showConfirmButton = T,
      timer = 1500
    )
  }, ignoreInit = T)
  

  output$ts_dy_plot <- dygraphs::renderDygraph({
    if (!is.null(ts_dat())) {
      mag <- ts_dat()[["mag_type"]][1]
      if (input$ts_varname %in% c("X(uT)",	"Y(uT)", "Z(uT)", "T(*C)")) {
        tsdyplot(
          data = ts_dat(),
          var = input$ts_varname,
          title_comp = mag
        )
      }
      # For LLR, Max_T and LLR & Max_T the graphs to be added here
      else {
        NULL
      }
    }
  })

  
  output$ts_site_img <- renderUI({
    if (input$ts_mag_type == "LIS3MDL") {
      img_name <- "LIS"
    }
    else if (input$ts_mag_type == "MLX90393") {
      img_name <- "MLX"
    }
    else {
      img_name <- "OTH"
    }
    
    tagList(h6(strong(
      paste0("Site-image of sensor (", img_name, ")")
    )),
    tags$img(
      src = paste0(img_name, ".jpg"),
      height = '200px',
      width = '300px'
    ))
    
  })
  
  output$ts_img_attr <- 
    
    renderDT({
      attr <-
        data.frame(
          feature = c("Pipe diameter(m)", "Location", "Orientation"),
          value = c("1", "London", "North-West")
        )
      
      attr %>% datatable(
        editable = T,
        rownames = F,
        options = list(
          initComplete = JS(
            "function(settings, json) {",
            "$('body').css({'font-family': 'Calibri'});",
            "}"
          ),
          dom = 't', lengthChange = FALSE, columns.orderable = F
        )
      ) %>% formatStyle('feature', backgroundColor = '#ADA7A7')
    })
  
  
  
  output$ts_data <-
    renderDataTable({
      if (input$showdata) {
        temp <-
          ts_dat()[, c("series_names",
                       "Sensor",
                       "mag_type",
                       "time",
                       "X(uT)",
                       "Y(uT)",
                       "Z(uT)",
                       "T(*C)")]
        temp
      }
    })
  ####Time series: End ####
  
  
  
  #### Heatmap 3D: Beginning ####
  date_time_paste <- function(date, time){
    # date should be in date format
    # time should be in POSIXct format
    time <- strftime(time, format = "%H:%M:%S")
    paste0(date, " ",time)
  }
  datetime <- eventReactive(input$heatmap_action,{
    date_time_paste(input$date, input$time)
  })
  
  dat <- eventReactive(input$heatmap_action,{
    influxdbr::influx_select(
      con(),
      db = input$dbname,
      measurement = input$measurement,
      field_keys = "X_ut, Y_ut, Z_ut, T_c",
      where = paste("time = ", paste0("'",datetime(),"'"),"and mag_type = ",paste0("'", input$magtype, "'" )),
      limit = 6000,
      return_xts = F
    )[[1]]
  })
  
  # Pop-up error when no data fetched from influxDB database
  observe({
    if (sum(sapply(dat(), function(x)
      all(is.na(x)))) == 5) {
      showModal(
        modalDialog(
          title = "ERROR",
          "No records returned. Try changing the date/time",
          easyClose = TRUE,
          footer = NULL
        )
      )
    }
  })
  
  
  mgf_submit <- function(indata, parm){
    mat <- matrix(indata[[parm]], nrow = 10, ncol = 10, byrow = T)
    values <- round(mat,2)
    title <- paste("3D Heatmap - ", parm)
    list(values, title)
  }
  

  
  output$show_date_time <- renderText(paste("Date and time: ", datetime()))
  output$plot_heatmap_x <- renderPlotly({
    tempdat <- mgf_submit(dat(), "X_ut")
    heatmap_3d(tempdat, wd = 600, ht = 400)
  })
  output$plot_heatmap_y <- renderPlotly({
    tempdat <- mgf_submit(dat(), "Y_ut")
    heatmap_3d(tempdat, wd = 600, ht = 400)
  })
  output$plot_heatmap_z <- renderPlotly({
    tempdat <- mgf_submit(dat(), "Z_ut")
    heatmap_3d(tempdat, wd = 1250, ht = 400)
  })

  #### Heatmap 3D: End ####
  
  
  #### Table plots: Beginning ####
 
  values <- reactiveValues()
  # values$df <- blank_tab
  values$df <- initial_tab
  
  observeEvent(input$add.button,{
    cat("addEntry\n")

    if (!is.null(input$dt_pic)) {
      im <- imager::load.image(input$dt_pic$datapath)
      im_name <-
        Sys.time() %>%
        as.character() %>%
        gsub(" ", replacement = "_", .) %>%
        gsub(":", "_", .) %>%
        gsub("-", "_", .)
      
      save.image(
        im = im,
        file =  paste0("D:/DS/IoT my task/AP/bs4dash/BS4DASH/www/", im_name, ".png")
      )
      im_html <-
        paste0('<img src = ', "'", im_name, ".png", "'", " height = '52' ></img>")
    }
    else{
      im_html <- NA
    }
    
    
    temp <- data.frame(input$dt_date,
                       input$dt_method,
                       input$dt_location,
                       input$dt_volume,
                       input$dt_x,
                       input$dt_y,
                       im_html
                       )
    colnames(temp) <- colnames(values$df)
    values$df <- rbind(values$df, temp)
    openxlsx::write.xlsx(values$df, file = datapath)
  })
  
  observeEvent(input$delete.button, {
    cat("deleteEntry\n")
    if (is.na(input$row.selection)) {
      values$df <- values$df[-nrow(values$df),]
    } else {
      values$df <- values$df[-input$row.selection,]
    }
    openxlsx::write.xlsx(values$df, file = datapath)
  })
  
  observeEvent(input$savedat, {
    cat("saving")
    openxlsx::write.xlsx(values$df, file = datapath)
    showModal(modalDialog(title = "Saved!",fade = T, easyClose = T, footer = NULL, size = "s", 
                          style = "color: #fff; background-color: #336600; border-color: #336600"))
  })
  
  
  # https://stackoverflow.com/questions/56535488/how-to-download-editable-data-table-in-shiny
  output$dt <- 
    DT::renderDT(
      datatable(values$df, editable = "cell", escape = F, rownames = T )
    )
 
  observeEvent(input[["dt_cell_edit"]], {
    cellinfo <- input[["dt_cell_edit"]]
    values$df <- editData(values$df, input[["dt_cell_edit"]], "dt")
  })
  
  
  #### Table plots: End ####
  
  
  #### Track defect: Beginning ####
  
  # Similar fetching of data was used earlier as well: This calls for modularizing the code
  # This need to be updated as, LLR/Max depth will not depend on sensor
  d_frm <- callModule(fromTo, "dfct_from")
  d_to <- callModule(fromTo, "dfct_to")
  
  dfct_dat <- 
    eventReactive(input$dfct_action,{
      # reactive({
      temp <- influxdbr::influx_select(
        con(),
        db = "example",
        measurement = "two_mab_test_run",
        field_keys = '"X(uT)",	"Y(uT)",	"Z(uT)",	"T(*C)"',
        where = paste(
          "time >= ",
          paste0("'", d_frm(), "'"),
          "and time <= ",
          paste0("'", d_to(), "'"),
          "and mag_type = ",
          paste0("'", "LIS3MDL", "'")
        ),
        group_by = "mag_type, Sensor",
        limit = 100,
        return_xts = F
      )[[1]]
      
      if (sum(sapply(temp, function(x)
        all(is.na(x)))) == 5) {
        final <- NULL
      }
      else {
        final <- temp
      }
      final
      # })
    }, ignoreNULL = T)
  
  output$dfct_dt <- 
    renderDataTable({
        temp <-
          dfct_dat()[, c("series_names",
                       "Sensor",
                       "mag_type",
                       "time",
                       "X(uT)",
                       "Y(uT)",
                       "Z(uT)",
                       "T(*C)")]
        head(temp, 5)

    })
  
 
  # p2 <- reactive( hist(rnorm(input$no_hmaps*100)))
  
  output$dfct_plot <- renderPlot({
    p1 <- levelplot(volcano, col.regions = terrain.colors(100, alpha = 01))
    p2 <- gridExtra::grid.arrange(p1,p1,p1,p1,p1,p1, nrow = 2)
    p2
  })
  
  
  #### Track defect: End ####
  
  

  output$bigPlot <- renderPlot({
    hist(rnorm(input$bigObs))
  })

  # this is not reactive but just for fixing the plot size on the client side.
  output$riverPlot <- renderEcharts4r({
    river %>%
      e_charts(dates) %>%
      e_river(apples) %>%
      e_river(bananas) %>%
      e_river(pears) %>%
      e_tooltip(trigger = "axis") %>%
      e_title("River charts", "(Streamgraphs)") %>%
      e_theme("shine")
  })
  
  output$plot2 <- renderPlotly({
    p <- plot_ly(df, x = ~ x) %>%
      add_lines(y = ~ y1, name = "A") %>%
      add_lines(y = ~ y2,
                name = "B",
                visible = F) %>%
      layout(
        xaxis = list(domain = c(0.1, 1)),
        yaxis = list(title = "y"),
        updatemenus = list(list(
          y = 0.8,
          buttons = list(
            list(
              method = "restyle",
              args = list("line.color", "blue"),
              label = "Blue"
            ),
            
            list(
              method = "restyle",
              args = list("line.color", "red"),
              label = "Red"
            )
          )
        ),
        
        list(
          y = 0.7,
          buttons = list(
            list(
              method = "restyle",
              args = list("visible", list(TRUE, FALSE)),
              label = "Sin"
            ),
            
            list(
              method = "restyle",
              args = list("visible", list(FALSE, TRUE)),
              label = "Cos"
            )
          )
        ))
      )
  })
  
  output$plot3 <- renderPlotly({
    s <- subplot(
      plot_ly(x = x, type = "histogram"),
      plotly_empty(),
      plot_ly(x = x, y = y, type = "histogram2dcontour"),
      plot_ly(y = y, type = "histogram"),
      nrows = 2,
      heights = c(0.2, 0.8),
      widths = c(0.8, 0.2),
      margin = 0,
      shareX = TRUE,
      shareY = TRUE,
      titleX = FALSE,
      titleY = FALSE
    )
    p <- layout(s, showlegend = FALSE)
  })
  

  
  output$cardAPIPlot <- renderPlot({
    if (input$mycard$maximized) {
      hist(rnorm(input$obsAPI))
    }
  })
  
  observeEvent(input$triggerCard, {
    updatebs4Card(
      inputId = "mycard",
      session = session,
      action = input$cardAction
    )
  })
  
  observe({
    print(
      list(
        collapsed = input$mycard$collapsed,
        maximized = input$mycard$maximized,
        visible = input$mycard$visible
      )
    )
  })
  
  observeEvent(input$controlbar, {
    if (input$controlbar) {
      showModal(
        modalDialog(
          title = "Alert",
          "The controlbar is opened.",
          easyClose = TRUE,
          footer = NULL
        )
      )
    }
  })
  
  observeEvent(input$controlbarToggle, {
    updatebs4Controlbar(inputId = "controlbar", session = session)
  })
  
  observe({
    print(input$controlbar)
  })
  
}