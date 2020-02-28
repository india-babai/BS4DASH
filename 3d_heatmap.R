# df_11 <-  read.mat(input$file$datapath)
# data_path <- "D:/DS/IoT/Field test/Bukom/BUKOM_01/2019-01-10_02-00-01.mat"
# df_11 <-  rmatio::read.mat(data_path)
# dat <- "data"
# parm <- "Bx"
# values <- df_11[[dat]][[parm]][[1]] %>% round(2)
# title <- paste("3D plot: ", dat, parm)
# 
# mgf_submit_1 <- list(values, title)


# output$all_stat_lineplot_1 =  renderPlotly({

heatmap_3d <- function(mgf_submit_1){

  trace1 <- list(
    uid = "e3b508",
    type = "surface",
    #Changes made
    x = as.character(1:10),
    y = as.character(1:10),
    z = matrix(mgf_submit_1[[1]], nrow = 10, ncol = 10), #Changes made
    colorbar = list(tickfont = list(color = "rgb(255, 255, 255)")),
    contours = list(
      x = list(highlight = TRUE,
               highlightColor = "rgb(255, 255, 255)"),
      y = list(highlight = TRUE,
               highlightColor = "rgb(255, 255, 255)"),
      z = list(highlight = TRUE,
               highlightColor = "rgb(255, 255, 255)")
    ),
    lighting = list(
      ambient = 0.88,
      diffuse = 0.99,
      specular = 0.09,
      roughness = 0.49
    ),
    colorscale = list(
      c(0, "rgb(158,1,66)"),
      list(0.1, "rgb(213,62,79)"),
      list(0.2, "rgb(244,109,67)"),
      list(0.3, "rgb(253,174,97)"),
      list(0.4, "rgb(254,224,139)"),
      list(0.5, "rgb(255,255,191)"),
      list(0.6, "rgb(230,245,152)"),
      list(0.7, "rgb(171,221,164)"),
      list(0.8, "rgb(102,194,165)"),
      list(0.9, "rgb(50,136,189)"),
      list(1, "rgb(94,79,162)")
    )
  )
  
  
  
  data <- list(trace1)
  
  
  layout <- list(
    scene = list(
      xaxis = list(
        type = "category",
        title = "x-obs (cm)",
        tickfont = list(color = "#C2C2C2"),
        gridcolor = "rgb(217, 217, 217)",
        gridwidth = 0.5,
        titlefont = list(color = "#D9D9D9"),
        spikecolor = "rgb(255, 255, 255)",
        zerolinecolor = "rgb(217, 217, 217)",
        zerolinewidth = 0.5
      ),
      yaxis = list(
        type = "category",
        title = "y-obs (cm)",
        tickfont = list(color = "#C2C2C2"),
        gridcolor = "rgb(217, 217, 217)",
        gridwidth = 0.5,
        titlefont = list(color = "#D9D9D9"),
        spikecolor = "rgb(255, 255, 255)",
        zerolinecolor = "rgb(217, 217, 217)",
        zerolinewidth = 0.5
      ),
      zaxis = list(
        title = "Micro Tesla",
        tickfont = list(color = "#C2C2C2"),
        gridcolor = "rgb(217, 217, 217)",
        gridwidth = 0.5,
        titlefont = list(color = "#D9D9D9"),
        spikecolor = "rgb(255, 255, 255)",
        zerolinecolor = "rgb(217, 217, 217)",
        zerolinewidth = 0.5
      ),
      cameraposition = list(
        c(
          0.09135505779278284,
          0.715812311878477,
          0.6778043612155135,
          -0.14088376590685395
        ),
        c(
          -0.0781888546817032,
          -0.17976553846204504,
          -0.18583299555288108
        ),
        1.62975145083398
      )
    ),
    title = mgf_submit_1[[2]],
    width = 1290,
    height = 452,
    legend = list(font = list(color = "#D9D9D9"),
                  bgcolor = "#151516"),
    margin = list(
      b = 10,
      l = 10,
      r = 10,
      t = 60
    ),
    autosize = 700,
    titlefont = list(color = "#D9D9D9"),
    showlegend = FALSE,
    plot_bgcolor = "#151516",
    paper_bgcolor = "#151516"
  )
  
  
  p <- plot_ly()
  p <-
    add_trace(
      p,
      uid = trace1$uid,
      type = trace1$type,
      x = trace1$x,
      y = trace1$y,
      z = trace1$z,
      colorbar = trace1$colorbar,
      contours = trace1$contours,
      lighting = trace1$lighting,
      colorscale = trace1$colorscale
    )
  p <-
    layout(
      p,
      scene = layout$scene,
      title = layout$title,
      width = layout$width,
      height = layout$height,
      legend = layout$legend,
      margin = layout$margin,
      autosize = layout$autosize,
      titlefont = layout$titlefont,
      showlegend = layout$showlegend,
      plot_bgcolor = layout$plot_bgcolor,
      paper_bgcolor = layout$paper_bgcolor
    )
  p
}