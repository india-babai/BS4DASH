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
  date_time_paste <- function(date, time){
    # date should be in date format
    # time should be in POSIXct format
    time <- strftime(time, format = "%H:%M:%S")
    paste0(date, " ",time)
    }
  
  ts_dt1 <- reactive( date_time_paste(date = input$ts_daterange1, input$ts_time1))
  ts_dt2 <- reactive( date_time_paste(date = input$ts_daterange2, input$ts_time2))
  
  sensor_filter <- reactive({
    sensors <- input$ts_sensor
    
    s1 <- NULL
    if (length(sensors) > 0) {
      for (s in sensors) {
        s1 <- paste0(s1," Sensor = ","'",s,"'", " OR ")
      }
      s1 <- substring(s1, 1, nchar(s1) - 3)
    }
     # removing the last or
    s1
  })
  
  ts_dat <- eventReactive(input$ts_action,{
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
        "and ",
        sensor_filter()
      ),
      group_by = "mag_type, Sensor",
      limit = 100,
      return_xts = F
    )[[1]]
    
    final <- temp[,c("series_names", "Sensor", "mag_type", "time","X(uT)",	"Y(uT)",	"Z(uT)",	"T(*C)")]
    final
    
  })
  
  output$ts_plot <- renderPlotly({
    tsplot(data = ts_dat(), x = "time", y = input$ts_varname)
  })
  
  output$ts_data <- renderDataTable(ts_dat())
  ####Time series: End ####
  
  
  
  #### Heatmap 3D: Beginning ####
  datetime <- eventReactive(input$heatmap_action,{
    # date <- input$date
    # time <- strftime(input$time, format = "%H:%M:%S")
    # datetime <- paste0(date, " ",time)
    # datetime
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
    heatmap_3d(tempdat)
  })
  output$plot_heatmap_y <- renderPlotly({
    tempdat <- mgf_submit(dat(), "Y_ut")
    heatmap_3d(tempdat)
  })
  output$plot_heatmap_z <- renderPlotly({
    tempdat <- mgf_submit(dat(), "Z_ut")
    heatmap_3d(tempdat)
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
  
  
  # output$dt <-
  #   DT::renderDT(
  #     values$df,
  #     editable = T,
  #     rownames = F,
  #     width = "80%",
  #     escape = FALSE
  #   )

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
  
  
  # observeEvent(input$current_tab, {
  #   if (input$current_tab == "cards") {
  #     showModal(
  #       modalDialog(
  #         title = "This event only triggers for the first tab!",
  #         "You clicked me! This event is the result of
  #         an input bound to the menu. By adding an id to the
  #         bs4SidebarMenu, input$id will give the currently selected
  #         tab. This is useful to trigger some events.",
  #         easyClose = TRUE,
  #         footer = NULL
  #       )
  #     )
  #   }
  # })
  
  
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