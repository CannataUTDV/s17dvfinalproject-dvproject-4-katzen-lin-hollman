#ui.R
require(shiny)
require(shinydashboard)
require(DT)
require(leaflet)
require(plotly)

#boxplot items-----
boxplotmenuitem <- menuItem("Box Plots", tabName = "boxplot", icon = icon("dashboard"))
boxplotdatapanel <- tabPanel("Data", uiOutput("boxplotlist"),
                             actionButton("boxplotbtn", "Get Data"),
                             DT::dataTableOutput("boxplotData"))
boxplotvispanel <- tabPanel("Boxplot", plotlyOutput("boxplotPlot1", height=500))
boxplottabitems <- tabItem(tabName = "boxplot", tabsetPanel(boxplotdatapanel, boxplotvispanel))
#end boxplot items-----

#histogram items-----
histogrammenuitem <- menuItem("Histograms", tabName = "histogram", icon = icon("dashboard"))
histogramdatapanel <- tabPanel("Data", uiOutput("histogramlist"),
                             actionButton("histogrambtn", "Get Data"),
                             DT::dataTableOutput("histogramData"))
histogramvispanel <- tabPanel("Histogram", sliderInput("Bin_Size", "Bins:", min = 1, max = 50,  value = 1),
                              plotlyOutput("histogramPlot1", height=500))
histogramtabitems <- tabItem(tabName = "histogram", tabsetPanel(histogramdatapanel, histogramvispanel))
#end histogram items-----

#scatter items-----
scattermenuitem <- menuItem("Scatter Plots", tabName = "scatter", icon = icon("dashboard"))
scatterdatapanel <- tabPanel("Data", uiOutput("scatterlist"),
                             actionButton("scatterbtn", "Get Data"),
                             DT::dataTableOutput("scatterData"))
scattervispanel <- tabPanel("Scatter Plot", plotlyOutput("scatterPlot1", height=500))
scattertabitems <- tabItem(tabName = "scatter", tabsetPanel(scatterdatapanel, scattervispanel))
#end scatter items-----

#crosstab items-----
crosstabmenuitem <- menuItem("Crosstabs", tabName = "crosstab", icon = icon("dashboard"))
crosstabdatapanel <- tabPanel("Data", uiOutput("crosstablist"),
                              sliderInput("KPI1", "KPI_Low:", 
                                          min = 20, max = 30,  value = 1),
                              sliderInput("KPI2", "KPI_Medium:", 
                                          min = 30, max = 40,  value = 1),
                             actionButton("crosstabbtn", "Get Data"),
                             DT::dataTableOutput("crosstabData"))
crosstabvispanel <- tabPanel("Crosstab", plotlyOutput("crosstabPlot1", height=1200))
crosstabtabitems <- tabItem(tabName = "crosstab", tabsetPanel(crosstabdatapanel, crosstabvispanel))
#end crosstab items-----

#barchart items-----
barchartmenuitem <- menuItem("Bar Charts", tabName = "barchart", icon = icon("dashboard"))
barchartdatapanel <- tabPanel("Data", uiOutput("barchartlist"),
                             actionButton("barchartbtn", "Get Data"),
                             DT::dataTableOutput("barchartData"))
barchartvispanel <- tabPanel("Bar Chart", plotlyOutput("barchartPlot1", height=500))
barcharttabitems <- tabItem(tabName = "barchart", tabsetPanel(barchartdatapanel, barchartvispanel))
#end barchart items-----

#################### SHINY STRUCTURE ########################

dashboardPage(
  dashboardHeader(
  ),
  dashboardSidebar(
    sidebarMenu(
      boxplotmenuitem,
      histogrammenuitem,
      scattermenuitem,
      crosstabmenuitem,
      barchartmenuitem
    )
    
  ),
  dashboardBody(
    
    tabItems(
      boxplottabitems,
      histogramtabitems,
      scattertabitems,
      crosstabtabitems,
      barcharttabitems
    )
  )
)

