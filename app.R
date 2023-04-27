#install 
#install.packages("shiny")
#install.packages("shinycssloaders")
#install.packages("wordcloud2")
#install.packages("ggplot2")
#install.packages("shinydashboard")
#install.packages("dplyr")
#install.packages("tidytext")
#install.packages("DT")
# Load library
library(shiny)
library(shinycssloaders)
library(wordcloud2)
library(ggplot2)
library(shinydashboard)
library(dplyr)
library(tidytext)
library(DT)

nbClassifier <- load("NaiveBayesClassifier.rda")
restaurant <- readRDS("restaurant.rds")
source("restaurantreviews.R")
source("featureExtraction.R")

ui <- dashboardPage(
    skin="green",
    dashboardHeader(title = "Singapore Restaurant Review"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Bandingkan Restaurant", tabName = "da", icon = icon("poll")),
      menuItem("Author", tabName = "author",icon = icon("pen"))
    ), 
    fluidPage(
      hr(),
      helpText(
        "Data review restaurant akan diambil langsung (scraping) dari website ",
        a("Tripadvisor", href = "https://www.tripadvisor.com/"),
        ". Mohon tunggu beberapa saat."
      ),
      hr(),
      helpText(
        "Review Restaurant yang di-scrape akan di klasifikasikan dengan Naive Bayes"
      ),
      hr(),
      helpText(
        "Peringatan: Mungkin terjadi lost connection saat scraping data. Refresh halaman jika terjadi error.", style = "color:#d9534f"
      )
    )  
  ),
  
  dashboardBody(
    tags$style(HTML("
                    .box.box-solid.box-primary>.box-header {
                    color:#fff;
                    background:#000000
                    }
                    .box.box-solid.box-primary{
                     border-bottom-color:#000000;
                    border-left-color:#000000;
                    border-right-color:#000000;
                    border-top-color:#000000;
                    background:#BE5504
                    }
                    ")),
        tabItems(
      tabItem(
        tabName = "dashboard",
        fluidRow(
          box(
          selectInput(
            "selectRestaurant",
            label = h5("Pilih Restaurant"),
            setNames(restaurant$link, restaurant$name)
            ),
            status = "primary",
          width=12,
          solidHeader = T
          )
          ),
        fluidRow(
          valueBoxOutput("total_review"),
          valueBoxOutput("happy_review"),
          valueBoxOutput("not_happy_review")
        ),
        fluidRow(
          box(
            title = "Restaurant review dan Klasifikasi Sentiment",
            solidHeader = T,
            width = 12,
            collapsible = T,
            div(DT::dataTableOutput("table_review") %>% withSpinner(color="#1167b1"), style = "font-size: 70%;")
          ),
        ),
        fluidRow(
          box(title = "Wordcloud",
              solidHeader = T,
              width = 6,
              collapsible = T,
              wordcloud2Output("wordcloud") %>% withSpinner(color="#1167b1")
          ),
          box(title = "Word Count",
              solidHeader = T,
              width = 6,
              collapsible = T,
              plotOutput("word_count") %>% withSpinner(color="#1167b1")
          )
        ),
        fluidRow(
          box(title = "Sentimen Negatif / Positif yang Paling Umum",
              solidHeader = T,
              width = 12,
              collapsible = T,
              plotOutput("kontribusi_sentimen") %>% withSpinner(color="#1167b1")
          )
        )
      ),
      tabItem(
        tabName = "da",
        fluidRow(
          box(
            solidHeader = T,
            width = 12,
            status = "primary",
            selectInput(
              "Restaurant_1",
              label = "Select Restaurant", 
              #choices = restaurant$link,
              setNames(restaurant$link, restaurant$name),
              multiple = TRUE
              )
            )
        ),
        fluidRow(
          box(title = "Plot Satisfied",
              status = "primary",
              solidHeader = T,
              width = 12,
              collapsible = T,
              plotOutput("banding") %>% withSpinner(color="#1167b1")
          ),
        ),
      ),
      tabItem(
        tabName = "author",
        fluidRow(
          box(
            status = "primary",
            solidHeader = T,
            div(style="text-align:center","This is information about authors"),
          width = 12,
          
          )
        ),
        fluidRow(
        valueBox(
          "Alivi Milova",
          paste0("123170062"),
          icon = icon("pen"),
          color = "fuchsia",
          width = 6
        ),
        valueBox(
          "Cici Yuriza",
          paste0("123170055"),
          icon = icon("pen"),
          color = "red",
          width = 6
        ))
      )
    )
  )
)

server <- function(input, output) {
  
  data <- reactive({
    get_restaurant_reviews(input$selectRestaurant)
  })
  
  dataNB <- reactive({
    reviews <- data()$Review
    withProgress({
      setProgress(message = "Proses Ekstraksi Fitur...")
      newData <- extract_feature(reviews)
    })
    withProgress({
      setProgress(message = "Klasifikasi...")
      pred <- predict(get(nbClassifier), newData)
    })
    data.frame(name=data()$name, Review = data()$Review, Prediksi = as.factor(pred), stringsAsFactors = FALSE)
  })
  
  dataWord <- reactive({
    v <- sort(colSums(as.matrix(create_dtm(data()$Review))), decreasing = TRUE)
    data.frame(Kata=names(v), Jumlah=as.integer(v), row.names=NULL, stringsAsFactors = FALSE) %>%
      filter(Jumlah > 0)
  })
  
  output$table_review <- renderDataTable(datatable({
    dataNB()
  }))
  
  output$total_review <- renderValueBox({
    valueBox(
      "Total", 
      paste0(nrow(dataNB()), " review"),
      icon = icon("pen"),
      color = "green"
    )
  })
  
  output$happy_review <- renderValueBox({
    valueBox(
      "Satisfied", 
      paste0(nrow(dataNB() %>% filter(Prediksi == "1")), " pengunjung merasa senang"),
      icon = icon("smile"),
      color = "fuchsia")
  })
  
  output$not_happy_review <- renderValueBox({
    valueBox(
      "Unsatisfied",
      paste0(nrow(dataNB() %>% filter(Prediksi == "0")), " pengunjung merasa tidak senang"), 
      icon = icon("frown"),
      color = "black")
  })
  
  output$wordcloud <- renderWordcloud2({
    wordcloud2(top_n(dataWord(), 50, Jumlah))
  })
  
  output$word_count <- renderPlot({
    countedWord <- dataWord() %>%
      top_n(10, Jumlah) %>%
      mutate(Kata = reorder(Kata, Jumlah))
    
    ggplot(countedWord, aes(Kata, Jumlah, fill = -Jumlah)) +
      geom_col() +
      guides(fill = FALSE) +
      theme_minimal()+
      labs(x = NULL, y = "Word Count") +
      ggtitle("Most Frequent Words") +
      coord_flip()
  })
  
  output$kontribusi_sentimen <- renderPlot({
    sentiments <- dataWord() %>% 
      inner_join(get_sentiments("bing"), by = c("Kata" = "word"))
    
    positive <- sentiments %>% filter(sentiment == "positive") %>% top_n(10, Jumlah) 
    negative <- sentiments %>% filter(sentiment == "negative") %>% top_n(10, Jumlah)
    sentiments <- rbind(positive, negative)
    
    sentiments <- sentiments %>%
      mutate(Jumlah=ifelse(sentiment =="negative", -Jumlah, Jumlah))%>%
      mutate(Kata = reorder(Kata, Jumlah))
    
    ggplot(sentiments, aes(Kata, Jumlah, fill=sentiment))+
      geom_bar(stat = "identity")+
      theme(axis.text.x = element_text(angle = 90, hjust = 1))+
      ylab("Kontibusi Sentimen")
  })

    banding <- reactive({
      dataa = unlist(input$Restaurant_1)
      dataa<-c(dataa)
      dataa <- data.frame(nama=dataa)
      jum <- nrow(dataa)
      a<- c()
      b<-c()
      d<- c()
      j=1
      while (jum!=0) {
        data_1 <- reactive({
          get_restaurant_reviews(dataa$nama[j])
        })
        dataNB_1 <- reactive({
          reviews <- data_1()$Review
          withProgress({
            setProgress(message = "Proses Ekstraksi Fitur...")
            newData <- extract_feature(reviews)
          })
          withProgress({
            setProgress(message = "Klasifikasi...")
            pred <- predict(get(nbClassifier), newData)
          })
          
          data.frame(name=data_1()$name, Review = data_1()$Review, Prediksi = as.factor(pred), stringsAsFactors = FALSE)
        })
        tot=nrow(dataNB_1())
        for (i in 1:tot) {
          b<-c(b,paste("resto",j))
        }
        a<-c(a,dataNB_1()$Review)
        d<-c(d,dataNB_1()$Prediksi)
        j=j+1
        jum=jum-1
      }
      hasil <- data.frame(name=b, Review = a, prediksi = as.factor(d), stringsAsFactors = FALSE)
      hasil$prediksi<- ifelse(hasil$prediksi=='1',hasil$prediksi<-"Unsatiesfied",hasil$prediksi<-"Satisfied")
      
      hasil %>%
        ggplot() +
        geom_bar(aes(x = name, fill=as.factor(prediksi)), 
                 position = "dodge", stat = "count") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1))+
        labs(
          x= "Restaurant",
          y= "Jumlah",
          fill="Klasifikasi"
        )+
        theme_light()
     
    })
    output$banding <- renderPlot({
      banding()
    })
}

shinyApp(ui=ui, server=server)
