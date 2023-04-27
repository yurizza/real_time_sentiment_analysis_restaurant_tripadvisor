# real_time_sentiment_analysis_restaurant_tripadvisor

A restaurant is one of the places visited to enjoy a variety of culinary that is in a particular area or place. The large amount of restaurant is one of the problems for visitors to choose a restaurant so that it is necessary to recommend or evaluate other visitors of the restaurant, and the assessment or review of visitors can be done with sentiment analysis based on the comments of restaurant visitors to see the satisfaction of visitors to the restaurant. Sentiment analysis is conducted by various methods such as Support Vector Machine (SVM), Maximum Entropy, Naïve Bayes, and other methods. This research was conducted to determine the performance of the Naïve Bayes Classifier algorithm in classifying based on restaurant visitor comments. By the visitor comment data and restaurant review data as training data parameters, it produces two categories: positive, implemented with the word "satisfied" and negative, which is implemented with the word "unsatisfied", and then produces an accuracy value of 73% in sentiment analysis using the Naïve Bayes Classifier method. The classification results of the analysis displayed on the R Shiny application consist of wordcloud and diagrams.

**Stages :**
**1. Retrieval of Testing Data with Web Scraping**

scraing from website tripadvisor.
<div class="row">
  <div class="column">
    <img src="https://github.com/yurizza/real_time_sentiment_analysis_restaurant_tripadvisor/blob/main/assets/hasil-web-scraping.png" width=300 height=300></img></div>
</div>
**2. Data Training**

in file "Restaurant_Reviews.csv".
<div class="row">
  <div class="column">
    <img src="https://github.com/yurizza/real_time_sentiment_analysis_restaurant_tripadvisor/blob/main/assets/data-training.png" width=300 height=300></img></div>
</div>
**3. Preprocessing**

preprocessing using library tm.
3.1 lower all character
3.2 delete punctuatin
3.3 delete numbers
3.3 delete stopword
3.4 delete strip white space

**4. R Shiny**

4.1. Show sentiment analysis
<div class="row">
  <div class="column">
    <img src="https://github.com/yurizza/real_time_sentiment_analysis_restaurant_tripadvisor/blob/main/assets/restaurant-reviews.png" width=500 height=400></img></div>
</div>

4.2 Plot compare any restaurant
<div class="row">
  <div class="column">
    <img src="https://github.com/yurizza/real_time_sentiment_analysis_restaurant_tripadvisor/blob/main/assets/compare-satisfied-any-restaurant.png" width=500 height=300></img></div>
</div>

4.3 Word cloud
<div class="row">
  <div class="column">
    <img src="https://github.com/yurizza/real_time_sentiment_analysis_restaurant_tripadvisor/blob/main/assets/word-cloud.png" width=600 height=300></img></div>
</div>

