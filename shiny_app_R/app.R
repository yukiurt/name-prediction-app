library(shiny)
library(httr)
library(jsonlite)
library(ggplot2)
library(dplyr)
library(readr)

FLASK_APP_URL <- "https://finalproject-418-api-883217264014.us-west1.run.app/predict"
data <- read_csv("fbi_name_features.csv")

# Feature extraction
extract_name_features <- function(name) {
  name_clean <- trimws(name)
  name_length <- nchar(name_clean)
  word_count <- length(strsplit(name_clean, "\\s+")[[1]])
  has_initials <- grepl("\\b[A-Z]\\.", name_clean)
  has_jr_or_sr <- grepl("\\b(JR|SR)\\b", name_clean, ignore.case = TRUE)

  vowels <- gregexpr("[aeiouAEIOU]", name_clean)[[1]]
  consonants <- gregexpr("[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]", name_clean)[[1]]

  vowel_ratio <- if (name_length > 0) length(vowels[vowels > 0]) / name_length else 0
  consonant_ratio <- if (name_length > 0) length(consonants[consonants > 0]) / name_length else 0
  first_letter <- if (name_length > 0) toupper(substr(name_clean, 1, 1)) else 'A'
  first_letter_index <- utf8ToInt(first_letter) - utf8ToInt('A')

  return(data.frame(
    name_length = name_length,
    word_count = word_count,
    has_initials = as.integer(has_initials),
    has_jr_or_sr = as.integer(has_jr_or_sr),
    vowel_ratio = vowel_ratio,
    consonant_ratio = consonant_ratio,
    first_letter = first_letter_index
  ))
}

# Clean and train model
feature_cols <- c("name_length", "word_count", "has_initials", "has_jr_or_sr",
                  "vowel_ratio", "consonant_ratio", "first_letter")
data <- na.omit(data)
name_titles <- data$title

# UI
ui <- fluidPage(
  titlePanel("Name-Based Predictor"),
  fluidRow(
    column(6,
      textInput("name", "Enter a name:"),
      selectInput("mode", "Select mode:", choices = c("birth_month", "sex", "subject", "age")),
      actionButton("predict", "Predict!"),
      actionButton("reset", "Reset"),
      uiOutput("prediction")
    ),
    column(6,
      h3("Similar Name"),
      verbatimTextOutput("nearest_name")
    )
  ),
  hr(),
  fluidRow(
    column(6,
      selectInput("hist_var", "Select variable to plot:",
                  choices = c("name_length", "word_count", "vowel_ratio", "consonant_ratio"))
    ),
    column(6,
      plotOutput("hist_plot")
    )
  ),
  hr(),
  fluidRow(
    column(12,
      h4("🎲 Generate Random Name"),
      actionButton("random_name", "Generate"),
      uiOutput("random_info")
    )
  )
)

# Server
server <- function(input, output, session) {
  observeEvent(input$reset, {
    session$reload()
  })

  prediction_result <- eventReactive(input$predict, {
    req(input$name, input$mode)
    res <- tryCatch({
      POST(FLASK_APP_URL,
           body = list(name = input$name, mode = input$mode),
           encode = "json",
           timeout(10))
    }, error = function(e) {
      return(NULL)
    })
    if (!is.null(res) && status_code(res) == 200) {
      parsed <- content(res, as = "parsed", simplifyVector = TRUE)
      return(parsed[[1]])
    } else {
      return("API error.")
    }
  })

  output$prediction <- renderUI({
    req(prediction_result())
    div(style = "font-size: 24px; font-weight: bold; color: #333;", prediction_result())
  })

  output$nearest_name <- renderText({
    req(input$name)
    features <- extract_name_features(input$name)
    x <- as.matrix(data[, feature_cols])
    dists <- sqrt(rowSums((x - matrix(unlist(features), nrow = nrow(x), ncol = ncol(x), byrow = TRUE))^2))
    idx <- which.min(dists)
    paste("Similar Name:\n", name_titles[idx])
  })

  output$hist_plot <- renderPlot({
    req(input$hist_var, input$name)
    var <- input$hist_var
    features <- extract_name_features(input$name)
    name_val <- features[[var]]

    ggplot(data, aes_string(x = var)) +
      geom_histogram(bins = 20, fill = "skyblue", color = "black") +
      geom_vline(xintercept = name_val, color = "red", linetype = "dashed", linewidth = 1.2) +
      ggtitle(paste("Distribution of", var)) +
      xlab(var) +
      ylab("Frequency")
  })

  observeEvent(input$random_name, {
    res <- tryCatch({
      GET("https://randomuser.me/api/")
    }, error = function(e) NULL)
    
    if (!is.null(res) && status_code(res) == 200) {
      user <- content(res, as = "parsed")$results[[1]]
      output$random_info <- renderUI({
        tagList(
          div(paste("Name:", user$name$first, user$name$last)), br(),
          div(paste("Gender:", user$gender)), br(),
          div(paste("DOB:", substr(user$dob$date, 1, 10))), br(),
          div(paste("Age:", user$dob$age))
        )
      })
    } else {
      output$random_info <- renderUI({
        div("Error fetching random user.")
      })
    }
  })
}

shinyApp(ui = ui, server = server)