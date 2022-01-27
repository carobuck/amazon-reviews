# amazon-reviews

A collection of scripts used for pulling, cleaning, analyzing and visualizing Amazon reviews.

## What you need:
- ASINs for products you're interested in pulling reviews for
- Optional: additional metadata about each ASIN (e.g. product category) to group results

## How to:

1. Use 1_scrape_reviews.R to pull reviews. If you have multiple ASINs, use loops at bottom to run through multiple pages of reviews for multiple ASINs
  * Scraper code modified from [Martin Chan](https://martinctc.github.io/blog/vignette-scraping-amazon-reviews-in-r/)
  * Script currently pulls review title, text and star rating
  * TODO: add on pulling review date
  * TODO: add on filtering/pulling reviews for specific date range only

2. Use 2_clean_reviews.R to clean up reviews.
  * Delete leading/trailing whitespace
  * Join metadata associated with ASINs
  * Get lemmatised version of review text
  * Run sentiment + emotion analysis on lemmatised text (uses dictionary-based approach in [sentimentr](https://cran.r-project.org/web/packages/sentimentr/readme/README.html) package)

3. Use 3_summ_viz_reviews.R to summarise sentiment and emotion results
  * Can group + visualize results by metadata categories associated with ASINs (if joined in previous script)
