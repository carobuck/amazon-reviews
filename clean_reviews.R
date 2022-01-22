## 1/21/22
# Organize + clean up review data + run sentiment analysis


library(tidyverse) # bread n' butter package
library(janitor) # clean up column names
library(sentimentr) # get sentiment and emotion of text
library(textstem) # for lemmatizing text
library(magrittr) # for %<>% assignment pipe

# Bind dataframes together, and clean up text data, and join ASIN data ----
# use dataframes of reviews scraped in scrape_reviews.R
mens_reviews %>%
  rbind(womens_reviews,unisex_reviews) %>% 
  # Remove extra whitespace in title and text
  mutate(review_title = str_trim(review_title),
         review_text = str_trim(review_text)) %>%
  # Convert review stars to number
  mutate(review_star = as.double(str_sub(review_star,1,1))) %>% 
  # Join to ASIN data (use clean_names in janitor package to fix column names)
  inner_join(asin_data %>%
               clean_names() %>%
               mutate(asin = factor(asin))) %>%
  # Get lemma'd version of review text to do NLP sentiment/emo on it
  mutate(lemma_text = lemmatize_strings(review_text)) -> reviews_clean
  
# Get sentiment of text data ----
# https://cran.r-project.org/web/packages/sentimentr/readme/README.html
# Get sentiment + emotion, then join everything together
reviews_clean %$%
  sentiment_by(get_sentences(lemma_text)) -> temp
reviews_clean %$%
  emotion_by(get_sentences(lemma_text)) %>%
  select(element_id,emotion_type,emotion_count) %>%
  pivot_wider(names_from = emotion_type,values_from = emotion_count) %>%
  # Bind on sentiment and original review data
  cbind(.,temp,reviews_clean) -> reviews_analyzed

# Drop element id columns (don't need)
reviews_analyzed %<>% select(-element_id) 

# Save as csv ----
write_csv(reviews_analyzed,'reviews_analyzed.csv')
