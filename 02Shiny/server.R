# server.R
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(data.world)
require(readr)
require(DT)
require(leaflet)
require(plotly)
require(lubridate)

database = "khollman/s-17-dvfinalproject-dvproject-4-katzen-lin-hollman"


############################### GENERAL #############################

generalquery <- "select distinct postMED.Topic D, postMED.Topic R
                from postMED
                Order by 1"

generalfunction <- data.world::query(
  data.world(propsfile = ".data.world"),
  dataset = database,
  type = "sql",
  query = generalquery
)


list_forcustomertype <- as.list(generalfunction$D, generalfunction$R)
list_forcustomertype <- append(list("All" = "All"), list_forcustomertype)

list_forboxplot <- list_forcustomertype
list_forbarchart <- list_forcustomertype
#l


######################## REMEBER TO INCLUDE THESE ######################

  
############################## SHINY ################################

shinyServer(function(input, output){
    #Widgets for BoxPlot Tab
    output$boxplotlist <- renderUI({
      selectInput("selectedboxplotlist", "Choose things:", list_forboxplot, 
                  multiple = TRUE, selected = "All")
    })
    
    #Widgets for Crosstabs Tab
    KPI_Low <- reactive({input$KPI1})
    KPI_Medium <- reactive({input$KPI2})
    
    #Widgets for Barcharts Tab
    output$barchartlist <- renderUI({
      selectInput("selectedbarchartlist", "Choose things:", list_forbarchart,
                  multiple = TRUE, selected = "All")
    })
    
    
    ############################# QUERIES ################################
    
    
    boxplotquery <- "select *
                    from postMED
                    where (? = 'All' or postMED.Topic in (?, ?, ?, ?, ?, ?, ?, ?, ?))
                    limit 100"
    
    histogramquery <- "select *
                      from postMED
                      limit 100"
    
    scatterquery <- "select *
                    from postMED
                    limit 100"
    
    crosstabquery <- "SELECT AVG(postMED.Greater_Risk_Data_Value) avg_risk, postMED.State, postMED.Race,
                      case
                      when AVG(postMED.Greater_Risk_Data_Value) < ? then '03 Low'
                      when AVG(postMED.Greater_Risk_Data_Value) < ? then '02 Medium'
                      else '01 High'
                      end as kpi
    
                      FROM postMED
                      Group By State, Race
                      Order by State, Race"
    
    barchartquery <- "select Race, Topic, AVG(Greater_Risk_Data_Value) avg_grisk from postMED group by Race, Topic"    
    
    
######################## FUNCTIONS FOR DATA FRAMES ####################
    
    boxplotfunc <- eventReactive(input$boxplotbtn, {
      if(input$selectedboxplotlist == 'All') list_forboxplot <- input$selectedboxplotlist
      else list_forboxplot <- append(list("Skip" = "Skip"), input$selectedboxplotlist)
      print("Getting from data.world")
      df <- query(
        data.world(propsfile = ".data.world"),
        dataset= database, 
        type="sql",
        query=boxplotquery,
        queryParameters = list_forboxplot )
    })  

    histogramfunc <- eventReactive(input$histogrambtn, {
      print("Getting from data.world")
      df <- query(
        data.world(propsfile = ".data.world"),
        dataset= database, 
        type="sql",
        query=histogramquery)
    })  
    
    
    scatterfunc <- eventReactive(input$scatterbtn, {
      print("Getting from data.world")
      df <- query(
        data.world(propsfile = ".data.world"),
        dataset= database, 
        type="sql",
        query=scatterquery)
    })  
    

    crosstabfunc <- eventReactive(input$crosstabbtn, {
      print("Getting from data.world")
      df <- query(
        data.world(propsfile = ".data.world"),
        dataset= database, 
        type="sql",
        query=crosstabquery,
        queryParameters = list(KPI_Low(), KPI_Medium()))
    })  
    

    barchartfunc <- eventReactive(input$barchartbtn, {
      if(input$selectedbarchartlist == 'All') list_forbarchart <- input$selectedbarchartlist
      else list_forbarchart <- append(list("Skip" = "Skip"), input$selectedbarchartlist)
      print("Getting from data.world")
      df <- query(
        data.world(propsfile = ".data.world"),
        dataset= database, 
        type="sql",
        query=barchartquery,
        queryParameters = list_forbarchart )
      
      df2 <- df %>% dplyr::group_by(Race) %>% dplyr::summarize(window_avg = mean(avg_grisk))
      dplyr::inner_join(df, df2, by = "Race")
    })  
    

    ################################################################
    ##################################### DATA TABLES
    ###############################################################
    
    output$boxplotData <- renderDataTable({DT::datatable(boxplotfunc(), rownames = FALSE,
                                                      extensions = list(Responsive = TRUE, 
                                                                        FixedHeader = TRUE)
    )})
    
    output$histogramData <- renderDataTable({DT::datatable(histogramfunc(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, 
                                                                           FixedHeader = TRUE)
    )})
    
    output$scatterData <- renderDataTable({DT::datatable(scatterfunc(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, 
                                                                           FixedHeader = TRUE)
    )})
    
    output$crosstabData <- renderDataTable({DT::datatable(crosstabfunc(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, 
                                                                           FixedHeader = TRUE)
    )})
    
    output$barchartData <- renderDataTable({DT::datatable(barchartfunc(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, 
                                                                           FixedHeader = TRUE)
    )})
    
    #GGPLOTLY STUFF
    output$boxplotPlot1 <- renderPlotly({
      bxp <- ggplot(boxplotfunc()) +
             geom_boxplot(aes(x=CustomerType, y = PurchaseAmount))+
             theme_classic()
      ggplotly(bxp)
    })
    
    ########################################COME BACK TO MAKE THESE GOOD ##############
        
    # output$histogramPlot1 <- renderPlotly({
    #   bxp <- ggplot(histogramfunc()) +
    #     geom_boxplot(aes(x=CustomerType, y = PurchaseAmount))+
    #     theme_classic()
    #   ggplotly(bxp)
    # })
    # 
    # output$scatterPlot1 <- renderPlotly({
    #   bxp <- ggplot(scatterfunc()) +
    #     geom_boxplot(aes(x=CustomerType, y = PurchaseAmount))+
    #     theme_classic()
    #   ggplotly(bxp)
    # })
    # 
    output$crosstabPlot1 <- renderPlotly({
      crossplot <- ggplot(crosstabfunc()) + 
        #theme(axis.text.x=element_text(angle=90, size=16, vjust=0.5)) + 
        #theme(axis.text.y=element_text(size=16, hjust=0.5)) +
        geom_text(aes(x=Race, y=State, label=round(avg_risk)), size=6) +
        geom_tile(aes(x=Race, y=State, fill=kpi), alpha=0.5)
      ggplotly(crossplot)
    })
    # 
    output$barchartPlot1 <- renderPlotly({
      barplot <- ggplot(barchartfunc(), aes(x = Topic, y=avg_grisk)) +
        scale_y_continuous(labels = scales::comma) + # no scientific notation
        theme(axis.text.x=element_text(angle=0, size=12, vjust=0.5)) + 
        theme(axis.text.y=element_text(size=12, hjust=0.5)) +
        geom_bar(stat = "identity") + 
        facet_wrap(~ Race) + 
        coord_flip() + 
        # Add sum_sales, and (sum_sales - window_avg_sales) label.
        geom_text(mapping=aes(x=Topic, y=avg_grisk, label=round(avg_grisk)),colour="black", hjust=-.5) +
        geom_text(mapping=aes(x=Topic, y=avg_grisk, label=round(avg_grisk - window_avg)),colour="blue", hjust=-2) +
        # Add reference line with a label.
        geom_hline(aes(yintercept = round(window_avg)), color="red") +
        geom_text(aes( -1, window_avg, label = window_avg, vjust = -.5, hjust = -.25), color="red")
      ggplotly(barplot)
    })
    
    
    
})



