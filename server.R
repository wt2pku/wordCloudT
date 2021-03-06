library(shiny)
library(shinyIncubator)
library(twitteR)
library(RCurl)
library(RJSONIO)
library(stringr)
library(tm)
library(wordcloud)
library(memoise)

## Clean Twitter's text
clean.text <- function(some_txt)
{
  some_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", some_txt)
  some_txt = gsub("@\\w+", "", some_txt)
  some_txt = gsub("[[:punct:]]", "", some_txt)
  some_txt = gsub("[[:digit:]]", "", some_txt)
  some_txt = gsub("http\\w+", "", some_txt)
  some_txt = gsub("[ \t]{2,}", "", some_txt)
  some_txt = gsub("^\\s+|\\s+$", "", some_txt)
  some_txt = gsub("amp", "", some_txt)
  # define "tolower error handling" function
  try.tolower = function(x)
  {
    y = NA
    try_error = tryCatch(tolower(x), error=function(e) e)
    if (!inherits(try_error, "error"))
      y = tolower(x)
    return(y)
  }
  
  some_txt = sapply(some_txt, try.tolower)
  some_txt = some_txt[some_txt != ""]
  names(some_txt) = NULL
  return(some_txt)
}


# Using "memoise" to automatically cache the results
getTermMatrix <- memoise(function(keyword) {
  api_key <- "GePrVvnw0tysHBTXPO1nbVov7"
  api_secret <- "z0qG4Mk2S4bDAaOyMa8FkAbltbCyVLVZZ73139VNae5obdqZR1"
  access_token <- "222338872-cicb0nf7xST4PG3mzeg0XYv5wc2jebfqDZJXRLEa"
  access_token_secret <- "IGNXWjCBZ7rCdBPU857jlyHeaM0N0MykVfNICXAluBzHm"
  setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)
  # Search the tweets using the keyword
  tweets <- searchTwitter(keyword, 1000, lang="en")
  # get text
  tweet_txt <- sapply(tweets, function(x) x$getText())
  
  # clean text
  tweet_clean <- clean.text(tweet_txt)
  
  #word cloud processing
  myCorpus = Corpus(VectorSource(tweet_clean))
  myCorpus = tm_map(myCorpus, tolower)
  myCorpus = tm_map(myCorpus, removePunctuation)
  
  myCorpus = tm_map(myCorpus, removeNumbers)
  
  myDTM = TermDocumentMatrix(myCorpus,
                             control = list(minWordLength = 1))
  
  m = as.matrix(myDTM)
  
  sort(rowSums(m), decreasing = TRUE)
})

shinyServer(function(input, output, session) {
  # Define a reactive expression for the document term matrix
  terms <- reactive({
    # Change when the "update" button is pressed...
    input$update
    # ...but not for anything else
    isolate({
      withProgress(session, {
        setProgress(message = "Processing corpus...")
        getTermMatrix(input$selection)
      })
    })
  })
  
  # Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)
  
  output$plot <- renderPlot({
    #comparison.cloud(terms, max.words = 30, colors = brewer.pal(nemo, "Dark2"),
                  #   scale = c(3,.5), random.order = FALSE, title.size = 1.5)
    v <- terms()
    wordcloud_rep(names(v), v, scale=c(8,1),
                  min.freq = input$freq, max.words=input$max,
                  colors=brewer.pal(8, "Dark2"))
  })
})