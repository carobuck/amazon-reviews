# 1/21/22
# Script to analyze/summarize/visualize sentiment/emotion data 
# Uses reviews_analyzed data frame made in clean_reviews.R
# Things to look at (from Galen)
#1. Men v women
#2. Men's product family's v womens prod families
#3. Mens fabric weight v womens fabric weigh
#4 per fabricweight across both men and women. 


library(tidyverse)

# summarise sentiment by product family + department ----
reviews_analyzed %>%
  select(product_family,department,ave_sentiment,sd) %>%
  group_by(product_family,department) %>%
  summarise(avg_sent = mean(ave_sentiment,na.rm = TRUE),avg_sd = mean(sd,na.rm = TRUE),cnt = n()) #%>%
  #pivot_wider(names_from = department,values_from = avg)

# how many pos/neg/neutral?
reviews_analyzed %>% 
  select(product_family,department,ave_sentiment,sd) %>%
  mutate(sent_polarity = case_when(
    ave_sentiment <= -0.07 ~ 'Negative',
    ave_sentiment <= 0.07 ~ 'Neutral',
    TRUE ~ 'Positive'
  )) %>%
  count(department,sent_polarity) %>%
  ggplot(aes(x=department,y=n,fill=sent_polarity)) +
  geom_col(position = 'dodge',color = 'black') +
  labs(x='Department',y='Review Count',
       fill = 'Review Polarity',
       title = 'Review Sentiment Polarity by Department' )+
  theme_bw()
  
reviews_analyzed %>% 
  filter(department != 'Unisex') %>%
  select(product_family,department,ave_sentiment,sd) %>%
  mutate(sent_polarity = case_when(
    ave_sentiment <= -0.07 ~ 'Negative',
    ave_sentiment <= 0.07 ~ 'Neutral',
    TRUE ~ 'Positive'
  )) %>%
  count(product_family,department,sent_polarity) %>%
  ggplot(aes(x=product_family,y=n,fill=sent_polarity)) +
  geom_col(position = 'dodge',color = 'black') +
  labs(x='Department',y='Review Count',
       fill = 'Review Polarity',
       title = 'Review Sentiment Polarity by Department' )+
  theme_bw() +
  facet_grid(department~.,scales = 'free_y')

reviews_analyzed %>% 
  filter(department != 'Unisex') %>%
  select(product_family,department,ave_sentiment,sd) %>%
  mutate(sent_polarity = case_when(
    ave_sentiment <= -0.07 ~ 'Negative',
    ave_sentiment <= 0.07 ~ 'Neutral',
    TRUE ~ 'Positive'
  )) %>%
  count(product_family,department,sent_polarity) %>%
  pivot_wider(names_from = sent_polarity,values_from = n) %>%
  adorn_percentages(denominator = 'row') %>%
  pivot_longer(3:5) %>%
  #
  ggplot(aes(x=product_family,y=value,fill=name,label=scales::percent(value,accuracy = .1))) +
  geom_col(position = 'dodge',color = 'black') +
  geom_label(position = position_dodge2(0.9),fill = 'white') +
  labs(x='Department',y='Review Count',
       fill = 'Review Polarity',
       title = 'Review Sentiment Polarity by Department' )+
  theme_bw() +
  facet_grid(department~.,scales = 'free_y') +
  scale_y_continuous(labels = scales::percent)


reviews_analyzed %>% 
  select(product_family,department,ave_sentiment,sd) %>%
  mutate(sent_polarity = case_when(
    ave_sentiment <= -0.07 ~ 'Negative',
    ave_sentiment <= 0.07 ~ 'Neutral',
    TRUE ~ 'Positive'
  )) %>%
  count(product_family,sent_polarity) %>%
  pivot_wider(names_from = sent_polarity,values_from = n) %>%
  adorn_percentages(denominator = 'row') %>%
  pivot_longer(2:4) %>%
  ggplot(aes(x=product_family,y=value,fill=name,label=scales::percent(value,accuracy = .1))) +
  geom_col(position = 'dodge',color = 'black') +
  geom_label(position = position_dodge2(0.9)) +
  labs(x='Department',y='Review Count',
       fill = 'Review Polarity',
       title = 'Review Sentiment Polarity by Department',
       subtitle = 'Includes Men, Women and Unisex')+
  theme_bw() +
  scale_y_continuous(labels = scales::percent)


# summarise emotions by product family + department ----
reviews_analyzed %>%
  select(product_family,1:16) %>%
  #select(-contains('negated')) %>% head
  group_by(product_family) %>%
  summarise(across(-contains('negated'),sum)) %>%
  adorn_percentages(denominator = 'row') %>%
  adorn_pct_formatting()

# 1. sentiment + emotion by men's vs. women's products
reviews_analyzed %>%
  select(department,ave_sentiment) %>%
  group_by(department) %>%
  summarise(average_sentiment = mean(ave_sentiment,na.rm = TRUE),review_count = n()) #%>%
  write_csv('sentiment_by_dept.csv')

# KEEP IN MIND THAT NEED TO 
reviews_analyzed %>%
  select(department,1:16) %>%
  #select(-contains('negated')) %>% head
  mutate(rev_cnt = case_when(
    department == 'Mens' ~ 1606,
    department == 'Unisex' ~ 108,
    department == 'Womens' ~ 743
  )) %>%
  group_by(department,rev_cnt) %>%
  summarise(across(-contains('negated'),sum))
  
