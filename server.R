server <-  function(input, output, session) {
  
  #### Heatmap 3D: Beginning ####
  con <- reactive(
    influxdbr::influx_connection(
      host = "localhost",
      port = as.numeric(input$connection),
      user = "username",
      pass = "password"
    )
  )
  
  
  datetime <- reactive({
    date <- input$date
    time <- strftime(input$time, format = "%H:%M:%S")
    datetime <- paste0(date, " ",time)
    datetime
  })
  
  dat <- reactive(
    influxdbr::influx_select(
      con(),
      db = input$dbname,
      measurement = input$measurement,
      field_keys = "X_ut, Y_ut, Z_ut, T_c",
      where = paste("time = ", paste0("'",datetime(),"'"),"and mag_type = 'LIS3MDL' "),
      limit = 6000,
      return_xts = F
    )[[1]]
  )
  
 # cat(input$datetime)
  
  mgf_submit <- function(indata, parm){
    mat <- matrix(indata[[parm]], nrow = 10, ncol = 10, byrow = T)
    values <- round(mat,2)
    title <- paste("3D heatmap from influxDB: ", parm)
    list(values, title)
  }
  
  # mgf_submit_x <- reactive({
  #   mgf_submit(dat(), "X_ut")
  # })
  # mgf_submit_y <- reactive({
  #   mgf_submit(dat(), "Y_ut")
  # })
  # mgf_submit_z <- reactive({
  #   mgf_submit(dat(), "Z_ut")
  # })
  #   
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
  # output$datatable <- renderDataTable({
  #   temp <- head(dat()[,3:8], n= 5)
  #     # select(time, X_ut, Y_ut, Z_ut ) 
  #     # knitr::kable("html") %>% 
  #     # kable_styling("striped", full_width = F)
  #   
  # })
  #### Heatmap 3D: End ####
  

  output$bigPlot <- renderPlot({
    hist(rnorm(input$bigObs))
  })
  

  
  # output$plot <- renderPlot({
  #   hist(rnorm(input$obs))
  # })
  
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
  
  
  observeEvent(input$current_tab, {
    if (input$current_tab == "cards") {
      showModal(
        modalDialog(
          title = "This event only triggers for the first tab!",
          "You clicked me! This event is the result of
          an input bound to the menu. By adding an id to the
          bs4SidebarMenu, input$id will give the currently selected
          tab. This is useful to trigger some events.",
          easyClose = TRUE,
          footer = NULL
        )
      )
    }
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