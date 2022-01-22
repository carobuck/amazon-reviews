# 1/21/22
# Script to analyze/summarize/visualize sentiment/emotion data 
# Uses reviews_analyzed data frame made in clean_reviews.R

library(tidyverse)

# summarise sentiment by product family + department ----
reviews_analyzed %>%
  select(product_family,department,ave_sentiment) %>%
  group_by(product_family,department) %>%
  summarise(avg = mean(ave_sentiment,na.rm = TRUE),cnt = n()) #%>%
  pivot_wider(names_from = department,values_from = avg)

# summarise emotions by product family + department ----
reviews_analyzed %>%
  select(product_family,1:16) %>%
  #select(-contains('negated')) %>% head
  group_by(product_family) %>%
  summarise(across(-contains('negated'),sum)) %>%
  adorn_percentages(denominator = 'row') %>%
  adorn_pct_formatting()

# best/worst products by sentiment

