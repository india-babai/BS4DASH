ui <-  bs4DashPage(
  sidebar_collapsed = TRUE,
  enable_preloader = TRUE,
  loading_duration = 3,
  controlbar_overlay = FALSE,
  navbar = bs4DashNavbar(
    status = "white",
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
        name = "Sinclair", 
        status = "primary",
        # src = "https://adminlte.io/themes/AdminLTE/dist/img/user2-160x160.jpg",
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
    skin = "light",
    status = "primary",
    title = "Sinclair Energy",
    brandColor = "primary",
    url = "https://www.influxdata.com/",
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
        "Defect data",
        tabName = "tabplot",
        icon = "cube"
      ),
      bs4SidebarMenuItem(
        "Social cards",
        tabName = "socialcards",
        icon = "id-card"
      ),
      bs4SidebarMenuItem(
        "Tab cards",
        tabName = "tabcards",
        icon = "picture-o"
      ),
      bs4SidebarMenuItem(
        "Sortable cards",
        tabName = "sortablecards",
        icon = "object-ungroup"
      ),
      bs4SidebarMenuItem(
        "Stats elements",
        tabName = "statsboxes",
        icon = "bank"
      ),
      bs4SidebarHeader("Boxes"),
      bs4SidebarMenuItem(
        "Basic boxes",
        tabName = "boxes",
        icon = "desktop"
      ),
      bs4SidebarMenuItem(
        "Value/Info boxes",
        tabName = "valueboxes",
        icon = "suitcase"
      ),
      
      bs4SidebarHeader("Colors"),
      
      bs4SidebarMenuItem(
        "Colors",
        tabName = "colors",
        icon = "tint"
      ),
      
      bs4SidebarHeader("BS4 gallery"),
      bs4SidebarMenuItem(
        text = "Galleries",
        icon = "cubes",
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(
          text = HTML(
            paste(
              "Gallery 1", 
              bs4Badge(
                "new", 
                position = "right", 
                status = "danger"
              )
            )
          ),
          tabName = "gallery1",
          icon = "circle-thin"
        ),
        bs4SidebarMenuSubItem(
          text = HTML(
            paste(
              "Gallery 2", 
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
      social_cards_tab,
      tab_cards_tab,
      sortable_cards_tab,
      statsboxes_tab,
      boxes_tab,
      value_boxes_tab,
      colors_tab,
      gallery_1_tab,
      gallery_2_tab
    )
  )
,
  footer = bs4DashFooter(
    right_text = a(href = "https://github.com/india-babai/BS4DASH",  target = "_blank", paste("Sinclair,", Sys.Date()))
  ),
  title = "InfluxDB Showcase"
)
