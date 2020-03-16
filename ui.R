ui <-  bs4DashPage(
  sidebar_collapsed = TRUE,
  enable_preloader = TRUE,
  loading_duration = 3,
  controlbar_overlay = FALSE,
  navbar = bs4DashNavbar(
    status = "info",
    rightUi = tagList(
      bs4DropdownMenu(
        show = FALSE,
        labelText = "!",
        status = "danger",
        src = "https://www.google.com",
        bs4DropdownMenuItem(
          message = "update your system",
          time = "today",
          type = "notification"
        ),
        bs4DropdownMenuItem(
          src = "ap_dp.jpg",
          from = "Arijit Pal",
          message = "Call me whenever you can...",
          time = "4 Minutes Ago",
          type = "message"
        )
      ),
      bs4UserMenu(
        name = strong("Sinclair"), 
        status = "primary",
        src = "sinclair logo.png",
        title = "bs4Dash",
        subtitle = "Author", 
        footer = p("The footer", class = "text-center"),
        "This is the menu content."
      )
    )
  ),
  sidebar = bs4DashSidebar(
    expand_on_hover = TRUE,
    skin = "dark",
    status = "olive",
    title = "Sinclair Energy",
    brandColor = "dark",
    url = "https://sinclairenergy.co.uk/",
    src = "sinclair logo.png",
    elevation = 3,
    opacity = 0.8,
    bs4SidebarMenu(
      id = "current_tab",
      flat = FALSE,
      compact = FALSE,
      child_indent = TRUE,
      bs4SidebarHeader(h4(strong("Explore me!"))),
      bs4SidebarMenuItem(
        "Time series",
        tabName = "timeseries",
        icon = "chart-line"
      ),
      bs4SidebarMenuItem(
        "Heatmap",
        tabName = "cards",
        icon = "cube"
      ),
      bs4SidebarMenuItem(
        "Cross reference data",
        tabName = "tabplot",
        icon = "cube"
      ),
      bs4SidebarMenuItem(
        "Track defect",
        tabName = "tdefect",
        icon = "cube"
      ),
      bs4SidebarMenuItem(
        "Simulation input data",
        tabName = "siminput",
        icon = "cube"
      ),
      
      bs4SidebarHeader("Social network"),
      bs4SidebarMenuItem(
        "Feedbacks",
        tabName = "socialcards",
        icon = "id-card"
      ),
      bs4SidebarHeader("BS4 gallery"),
      bs4SidebarMenuItem(
        text = "Galleries",
        icon = "cubes",
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(
          text = HTML(
            paste(
              "Gallery", 
              bs4Badge(
                "!", 
                position = "right", 
                status = "success"
              )
            )
          ),
          tabName = "gallery2",
          icon = "circle-thin"
        )
      )
    )
  ),
  body = bs4DashBody(
    bs4TabItems(
      ts_card_tab,
      basic_cards_tab,
      cards_api_tab,
      track_defect_tab,
      social_cards_tab,
      gallery_2_tab
    )
  )
,
  footer = bs4DashFooter(
    right_text = a(href = "https://github.com/india-babai/BS4DASH",  target = "_blank", paste("Sinclair,", Sys.Date()))
  ),
  title = "InfluxDB Showcase"
)
