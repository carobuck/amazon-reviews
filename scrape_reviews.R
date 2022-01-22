# Helping Galen with scraping Amazon reviews + NLP/analysis of reviews
library(tidyverse)

# https://martinctc.github.io/blog/vignette-scraping-amazon-reviews-in-r/

## Define function to scrape reviews, for a particular ASIN and page ----
scrape_amazon <- function(ASIN, page_num){
  
  url_reviews <- paste0("https://www.amazon.com/product-reviews/",ASIN,"/?pageNumber=",page_num)
  
  doc <- read_html(url_reviews) # Assign results to `doc`
  
  # Review Title
  doc %>% 
    html_nodes("[class='a-size-base a-link-normal review-title a-color-base review-title-content a-text-bold']") %>%
    html_text() -> review_title
  
  # Review Text
  doc %>% 
    html_nodes("[class='a-size-base review-text review-text-content']") %>%
    html_text() -> review_text
  
  # Number of stars in review
  doc %>%
    html_nodes("[data-hook='review-star-rating']") %>%
    html_text() -> review_star
  
  # Return a tibble
  data.frame(review_title,
         review_text,
         review_star,
         page = page_num,
         asin = ASIN) %>% return()
}
test <- scrape_amazon(ASIN = "B07C12MRNX", page_num = 5) 

## Avoid bot detection ----
ASIN <- "B07C12MRNX" # Specify ASIN
page_range <- 1:10 # Let's say we want to scrape pages 1 to 10

# Create a table that scrambles page numbers using `sample()`
# For randomising page reads!
match_key <- tibble(n = page_range,
                    key = sample(page_range,length(page_range)))

lapply(page_range, function(i){
  j <- match_key[match_key$n==i,]$key
  
  message("Getting page ",i, " of ",length(page_range), "; Actual: page ",j) # Progress bar
  
  Sys.sleep(3) # Take a three second break
  
  if((i %% 3) == 0){ # After every three scrapes... take another two second break
    
    message("Taking a break...") # Prints a 'taking a break' message on your console
    
    Sys.sleep(2) # Take an additional two second break
  }
  scrape_amazon(ASIN = ASIN, page_num = j) # Scrape
}) -> output_list

## Putting it all together (pull reviews for list of ASINs) ----
# Read in ASIN data
asin_data <- readxl::read_xlsx('/Users/caroline.buck/Desktop/Fun_R/amazon-reviews/Reveiw_Source_Data.xlsx')

# Running all 92 ASINs kills the process...so run by dept for smaller group
asin_data %>% count(Department)

## With the double loops, I don't think it's necessary to break into three chunks; we could prob run all at once and be fine (would just take a while to run)
mens <- asin_data %>% filter(Department == 'Mens')
unisex <- asin_data %>% filter(Department == 'Unisex')
womens <- asin_data %>% filter(Department == 'Womens')

page_range <- 1:10 # Let's say we want to scrape pages 1 to 10

test_asin <- mens$ASIN
results <- data.frame()
for(i in test_asin){
  for(j in page_range){
    Sys.sleep(3) # Take a three second break
    if((j %% 3) == 0){ # After every three scrapes... take another two second break
      message("Taking a break...") 
      Sys.sleep(2) 
    }
    skip_to_next <- FALSE
    tryCatch(
      {
        temp = scrape_amazon(ASIN = i, page_num = j) # Scrape
        print(paste('round:',i,j))
        print('got here')
        results = rbind(results,temp)
      }, error = function(e) { skip_to_next <<- TRUE}
    )
    if(skip_to_next) { break }  # use break instead of next to skip to next ASIN, once hit errors on empty review pages
  }
}


unisex_reviews <- results
write_csv(unisex_reviews,'unisex_reviews.csv')

womens_reviews <- results
write_csv(womens_reviews,'womens_reviews.csv')

womens_reviews %>%
  mutate(test = str_trim(review_text)) -> test

mens_reviews <- results
write_csv(mens_reviews,'mens_reviews.csv')
