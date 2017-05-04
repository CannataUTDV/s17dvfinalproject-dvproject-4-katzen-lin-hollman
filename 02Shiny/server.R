# server.R
require(ggplot2)
require(ggthemes)
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
list_forboxplot <- list_forcustomertype
#l


######################## REMEBER TO INCLUDE THESE ######################

  
############################## SHINY ################################

shinyServer(function(input, output){
    #Widgets for BoxPlot Tab
    output$boxplotlist <- renderUI({
      selectInput("selectedboxplotlist", "Choose things:", list_forboxplot, 
                  multiple = TRUE, selected = "All")
    })
    
    #widgets for Histogram Tab
    Bins <- reactive({input$Bin_Size})
    
    #Widgets for Crosstabs Tab
    KPI_Low <- reactive({input$KPI1})
    KPI_Medium <- reactive({input$KPI2})
    
    #Widgets for Barcharts Tab
    output$barchartlist <- renderUI({
      selectInput("selectedbarchartlist", "Choose things:", list_forbarchart,
                  multiple = TRUE, selected = "All")
    })
    
    
    ############################# QUERIES ################################
    
    
    boxplotquery <- "select Topic, Greater_Risk_Data_Value
                    from postMED
                    where (? = 'All' or postMED.Topic in (?, ?, ?, ?, ?, ?, ?, ?, ?))"
    
    boxplotquery2 <- "select postMED.YEAR, postMED.Grade, 
                    postMED.Greater_Risk_Data_Value, postMED.ShortQuestionText,
                    postINC.`med.inc.age.25to44`
                    from postMED
                    inner join postINC on postMED.State = postINC.State
                    where postMED.Grade != 'Total' and (postMED.YEAR = 1991 or postMED.YEAR = 2015)
                    limit 1000"
    
    histogramquery <- "SELECT Greater_Risk_Data_Value, Race
                      from postMED"
    
    scatterquery <- "SELECT pr.State, pr.`pop.total` total, pr.`pop.white` white, 
                    pr.`pop.white`/pr.`pop.total` whiteper, 
                    AVG(pm.postMED.Greater_Risk_Data_Value) avg_risk
                    from postMED pm
                    inner join postRAC pr on pr.State = pm.State
                    group by pm.State"
    
    crosstabquery <- "SELECT AVG(postMED.Greater_Risk_Data_Value) avg_risk, postMED.State, postMED.Race,
                      case
                      when AVG(postMED.Greater_Risk_Data_Value) < ? then '03 Low'
                      when AVG(postMED.Greater_Risk_Data_Value) < ? then '02 Medium'
                      else '01 High'
                      end as kpi
    
                      FROM postMED
                      Group By State, Race
                      Order by State, Race"
    
    crosstabquery2 <- "select postMED.ShortQuestionText, postMED.Sex, postMED.Race,
AVG((Lesser_Risk_Data_Value - Greater_Risk_Data_Value) * ((postEDU.`edu.pacificislander.female.bachelors`+postEDU.`edu.pacificislander.male.bachelors`+postEDU.`edu.americanindian.male.bachelors`+postEDU.`edu.americanindian.female.bachelors`+postEDU.`edu.asian.male.bachelors`+postEDU.`edu.asian.female.bachelors`+postEDU.`edu.black.male.bachelors`+postEDU.`edu.black.female.bachelors`+postEDU.`edu.white.male.bachelors`+postEDU.`edu.white.female.bachelors`)/(postEDU.`edu.white`+postEDU.`edu.black`+postEDU.`edu.asian`+postEDU.`edu.americanindian`+postEDU.`edu.pacificislander`))) as kpi
    from postMED
    Inner Join postEDU on postEDU.State = postMED.State
    where YEAR not in (1991, 1993, 1995, 1997, 1999) and Sex != 'Total' and Race != 'Total'
    group by ShortQuestionText, Race, Sex
    order by ShortQuestionText, Race, Sex desc
    limit 1000"
    
    barchartquery <- "select Race, Topic, AVG(Greater_Risk_Data_Value) avg_grisk from postMED 
                      where (? = 'All' or Topic in (?, ?, ?, ?, ?, ?, ?, ?, ?))
                      group by Race, Topic"
    
    mapquery <- "SELECT Latitude, Longitude, AVG(postMED.Greater_Risk_Data_Value) avg_risk, State
                FROM `postMED.csv/postMED`
                Group by Latitude, Longitude"
    
    
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
        queryParameters = list_forboxplot)
    })  
    
    boxplotfunc2 <- query(
        data.world(propsfile = ".data.world"),
        dataset= database, 
        type="sql",
        query=boxplotquery2)
    boxplotfunc2$Grade <- factor(boxplotfunc2$Grade, levels=c("9th", "10th", "11th", "12th"))

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
    
    crosstabfunc2 <- query(
        data.world(propsfile = ".data.world"),
        dataset= database, 
        type="sql",
        query=crosstabquery2)
    
    

    barchartfunc <- eventReactive(input$barchartbtn, {
      if(input$selectedbarchartlist == 'All') list_forbarchart <- input$selectedbarchartlist
      else list_forbarchart <- append(list("Skip" = "Skip"), input$selectedbarchartlist)
      if (TRUE) {
        print("Getting from data.world")
        tdf <- query(
          data.world(propsfile = ".data.world"),
          dataset= database, 
          type="sql",
          query=barchartquery,
          queryParameters = list_forbarchart)
      }
      
      tdf2 <- tdf %>% dplyr::group_by(Race) %>% dplyr::summarize(window_avg = mean(avg_grisk))
      dplyr::inner_join(tdf, tdf2, by = "Race")
    })  
    
    mapfunc <-  query(
        data.world(propsfile = ".data.world"),
        dataset= database, 
        type="sql",
        query=mapquery)
    

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
    
    ##########################GGPLOTLY STUFF
    output$boxplotPlot1 <- renderPlotly({
      bxp <- ggplot(boxplotfunc()) +
             geom_boxplot(aes(x=Topic, y = Greater_Risk_Data_Value))+
        labs(title = "Distribution of Risk Values by Topic", x = "Topics", y = "Risk Factor Values") +
        ggthemes::theme_wsj() + scale_color_wsj() 
      ggplotly(bxp)
    })
    
    boxplot2 <- ggplot(boxplotfunc2, aes(x = Grade, y = Greater_Risk_Data_Value)) +
      facet_grid(~ShortQuestionText)+
      geom_point(aes(color = factor(YEAR), size =med.inc.age.25to44)) +
      geom_boxplot(aes(x = Grade, y = Greater_Risk_Data_Value, color = NULL), alpha = .1)+
      geom_point(alpha = .01) +
      scale_color_manual(values = c("orange", "purple"))+
      ggthemes::theme_wsj() + 
      labs(x = "Grade Levels", y = "Risk Values\n(Greater is Riskier)", color = "Years", size = "Median Income") + 
      ggtitle("How Income, Grade, and Year affect Risk Values") +
      theme(axis.title = element_text(), plot.title = element_text(hjust = 0))
    
    output$boxplotPlot2 <- renderPlot({
      boxplot2
    })
    
    output$boxplotPlot3 <- renderPlotly({
      boxplot3 <- ggplot(boxplotfunc2, aes(x = Grade, y = Greater_Risk_Data_Value)) +
        facet_grid(~ShortQuestionText)+
        geom_point(aes(color = factor(YEAR), size =med.inc.age.25to44)) +
        geom_boxplot(aes(x = Grade, y = Greater_Risk_Data_Value, color = NULL), alpha = .1)+
        geom_point(alpha = .01) +
        scale_color_manual(values = c("orange", "purple"))+
        ggthemes::theme_wsj() + 
        labs(x = "Grade Levels", y = "Risk Values\n(Greater is Riskier)", color = "Years", size = "Median Income") + 
        ggtitle("How Income, Grade, and Year affect Risk Values") +
      theme(axis.title = element_text(), plot.title = element_text(hjust = 0))
      ggplotly(boxplot3)
    })
      
    boxplot4 <- ggplot(boxplotfunc2, aes(x = Grade, y = Greater_Risk_Data_Value)) +
      facet_grid(~ShortQuestionText)+
      geom_point(aes(color = med.inc.age.25to44, size =med.inc.age.25to44)) +
      geom_boxplot(aes(x = Grade, y = Greater_Risk_Data_Value, color = NULL), alpha = .1)+
      scale_color_gradient(low = "red", high = "green") +
      geom_point(alpha = .01) +
      ggthemes::theme_wsj() + 
      labs(x = "Grade Levels", y = "Risk Values\n(Greater is Riskier)", color = "Median Income", size = "Median Income") + 
      ggtitle("How Income and Grade affect Risk Values")+
      theme(axis.title = element_text(), plot.title = element_text(hjust = 0))
    
    output$boxplotPlot4 <- renderPlot({
      boxplot4
    })
    
    output$boxplotPlot5 <- renderPlotly({
      boxplot5 <- ggplot(boxplotfunc2, aes(x = Grade, y = Greater_Risk_Data_Value)) +
        facet_grid(~ShortQuestionText)+
        geom_point(aes(color = med.inc.age.25to44, size =med.inc.age.25to44)) +
        geom_boxplot(aes(x = Grade, y = Greater_Risk_Data_Value, color = NULL), alpha = .1)+
        scale_color_gradient(low = "red", high = "green") +
        geom_point(alpha = .01) +
        ggthemes::theme_wsj() + 
        labs(x = "Grade Levels", y = "Risk Values\n(Greater is Riskier)", color = "Median Income", size = "Median Income") + 
        ggtitle("How Income and Grade affect Risk Values")+
        theme(axis.title = element_text(), plot.title = element_text(hjust = 0))
      ggplotly(boxplot5)
    })
      
    output$histogramPlot1 <- renderPlotly({
      histogramplot <- ggplot(histogramfunc()) + 
        theme(axis.text.x=element_text(angle=90, size=16, vjust=0.5)) + 
        geom_histogram(aes(x= Greater_Risk_Data_Value, y = ..ncount..), binwidth = as.numeric(Bins())) +
        facet_wrap(~Race) +
        labs(x = "Risk Factor Values", y = "Count of Studies", "Does Intensity of Risk Factors vary by Race?") +
        ggthemes::theme_wsj() + scale_color_wsj()
      ggplotly(histogramplot)
    })

    output$scatterPlot1 <- renderPlotly({
      scatterplot <- ggplot(scatterfunc(), aes(x = whiteper, y = avg_risk)) + 
        theme(axis.text.x=element_text(angle=90, size=16, vjust=0.5)) + 
        theme(axis.text.y=element_text(size=16, hjust=0.5)) +
        geom_point(aes(x=whiteper, y = avg_risk, size=6)) +
        geom_smooth(method=lm, se=FALSE, color = "red") +
        labs(x = "Percentage of Whites", y = "Average Risk Factor", 
             title = "Does Population perportion affect Risk Factors?") +
        ggthemes::theme_wsj() + scale_color_wsj()
      ggplotly(scatterplot)
    })

    output$crosstabPlot1 <- renderPlotly({
      crossplot <- ggplot(crosstabfunc()) + 
        geom_text(aes(x=Race, y=State, label=round(avg_risk)), size=6) +
        geom_tile(aes(x=Race, y=State, fill=kpi), alpha=0.5) +
        labs(title = "The Average Risk By Race and State") +
        ggthemes::theme_wsj() + scale_color_wsj()
      ggplotly(crossplot)
    })

    crosstab2 <- ggplot(crosstabfunc2, aes(x = ShortQuestionText, y = Sex)) +
      geom_tile(aes(fill=crosstabfunc2$kpi)) +
      geom_text(label= round(crosstabfunc2$kpi), size=6) +
      facet_wrap(~Race, ncol = 1) +
      ggthemes::theme_wsj() + scale_fill_continuous(low = "red", high = "green") +
      labs(y="", fill = "Positive Health KPI (larger is better)") + 
      ggtitle("Breakdown of Positive Health Measures by Race and Sex") +
      theme(axis.title = element_text(), plot.title = element_text(hjust = 0))
        
    output$crosstabPlot2 <- renderPlot({
      crosstab2
    })
    
    output$crosstabPlot3 <- renderPlotly({
      crosstab3 <- ggplot(crosstabfunc2, aes(x = ShortQuestionText, y = Sex)) +
        geom_tile(aes(fill=crosstabfunc2$kpi)) +
        geom_text(label= round(crosstabfunc2$kpi), size=6) +
        facet_wrap(~Race, ncol = 1) +
        ggthemes::theme_wsj() + scale_fill_continuous(low = "red", high = "green") +
        labs(y="", fill = "Positive Health KPI (larger is better)") + 
        ggtitle("Breakdown of Positive Health Measures by Race and Sex") +
        theme(axis.title = element_text(), plot.title = element_text(hjust = 0))
      ggplotly(crosstab3)
    })
    
    
    output$barchartPlot1 <- renderPlotly({
      barplot <- ggplot(barchartfunc(), aes(x = Topic, y=avg_grisk)) +
        scale_y_continuous(labels = scales::comma) + # no scientific notation
        theme(axis.text.x=element_text(angle=0, size=12, vjust=0.5)) + 
        theme(axis.text.y=element_text(size=12, hjust=0.5)) +
        geom_bar(stat = "identity") + 
        facet_wrap(~ Race) + 
        coord_flip() + 
        geom_text(mapping=aes(x=Topic, y=avg_grisk+2, label=round(avg_grisk)),colour="black", nudge_x = .15) +
        geom_text(mapping=aes(x=Topic, y=avg_grisk+7, label=round(avg_grisk - window_avg)),colour="blue", nudge_x = .15) +
        # Add reference line with a label.
        geom_hline(aes(yintercept = round(window_avg)), color="red") +
        geom_text(aes( .5, window_avg+5, label = round(window_avg), vjust = -.5, hjust = 1), color="red") +
        labs(x = "", y = "Average Risk", title = "Average Risk by Race and Topic")+
        ggthemes::theme_wsj() + scale_color_wsj()
      ggplotly(barplot)
    })
    
    output$Map1 <- renderLeaflet({leaflet(width = 400, height = 800) %>% 
        setView(lng = -98.35, lat = 39.5, zoom = 4) %>% 
        addTiles() %>% 
        addMarkers(lng = mapfunc$Longitude,
                   lat = mapfunc$Latitude,
                   options = markerOptions(draggable = TRUE, riseOnHover = TRUE),
                   popup = as.character(paste("Average Risk: ", mapfunc$avg_risk, ", ", mapfunc$State)))
    })
    
    
    
    
    
})



