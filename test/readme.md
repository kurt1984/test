
Table of Contents
=================

  * [Summary](#summary)
 
  * [1. Using API](#1-using-api)
  * [2. Explore Zillow data using rvest](#2-Explore Zillow data using rvest)
 
## Summary
* Demonstrate using Zillow official API to extract information
* Alternatively, scrape Zillow website to get richer information and geocoding the address
* Visualize relationship between real estate location and value in a map

##1.Using API 
<http://www.zillow.com/howto/api/GetSearchResults.htm>

```{r}
library(knitr)
opts_chunk$set(tidy = TRUE, cache=TRUE, autodep=TRUE, message=FALSE)

library(httr)
library(rvest)
library(magrittr)
library(ggmap)
library(stringr)
library(knitr)
sample <- GET("http://www.zillow.com/webservice/GetSearchResults.htm", 
              query = list('zws-id' = "X1-ZWz1f063o0dzij_7yjzz", 
                           address = "2114 Bigelow Ave",
                           citystatezip = "Seattle, WA"))

result <- content(sample)

zpid <- result %>% html_node("zpid")%>%html_text()
amount <- result %>% html_node("amount")%>%html_text()
low <- result %>% html_node("low")%>%html_text()
high <- result %>% html_node("high")%>%html_text()
valueChange30Day <- result %>% html_node("valueChange")%>%html_text()
kable(data.frame(zpid,amount,low,high,valueChange30Day))

```



##2.Explore Zillow data using rvest

Hui adapted from https://raw.githubusercontent.com/notesofdabbler/blog_notesofdabbler/master/learn_rvest/exploreZillow_w_rvest.R
 
```{r}


# here the search is filtered to just homes for sale
# if there are less filters in search, the code will need to be modified since the css might be different
# for different types of results (eg. homes for sales vs new homes vs homes for rent)
url="http://www.zillow.com/homes/for_sale/Greenwood-IN/fsba,fsbo,fore,cmsn_lt/house_type/52333_rid/39.638414,-86.011362,39.550714,-86.179419_rect/12_zm/0_mmm/"

# get list of houses for sales that appears on the page
houselist <- url%>%html()%>%html_nodes("article")

# Extract zillow id for each listing
zpid <- houselist %>% html_attr("id") %>% str_replace_all("zpid_", "")

# get the address for each listing

staddrlink <- houselist%>%html_node(".property-address a")%>%html_attr("href")
straddr <- sapply(strsplit(staddrlink,"/"),function(x) x[3])
straddr <- str_replace_all(straddr, "-", " ")

lat_lon <- geocode(straddr, source = "google")

lotsqft <- houselist %>% html_node(".lot-size") %>% html_text() %>% str_replace_all(",", "")
lotsqft <- sapply(lotsqft, function(x) {
        num <- as.numeric(str_extract_all(x, "(\\d*\\.)?\\d+"))
        if (!is.na(num) & str_detect(x, "(ac|acre)")) {
            num <- num * 43560
        }
        num
}
)

yrbuilt <- houselist%>%html_node(".built-year")%>%html_text()
yrbuilt <- as.numeric(str_extract_all(yrbuilt, "\\d+"))

price <- houselist%>%html_node(".price-large")%>%html_text()%>%gsub("[\\$a-zA-Z,]","",.)%>%as.numeric()

# house parameters (number of beds, baths, house area)
houseparams <- houselist%>%html_node(".property-data")%>%html_text()
houseparamsSplit <- strsplit(houseparams,", ")
## get number of beds
numbeds <- sapply(houseparamsSplit,function(x) as.numeric(strsplit(x[1]," ")[[1]][1]))
## get number of baths
numbaths <- sapply(houseparamsSplit,function(x) as.numeric(strsplit(x[1]," ")[[1]][4]))

housesqft <- sapply(houseparamsSplit,function(x) strsplit(x[1]," ")[[1]][7]) %>%
    str_replace_all(",", "") %>% as.numeric()

#houseData <- data.frame(zpid,price,yrbuilt,numbeds,numbaths,housesqft,lotsqft,straddr)
houseData <- data.frame(zpid,price,yrbuilt,numbeds,numbaths,housesqft,lotsqft,straddr,lat_lon)
kable(houseData)
```




##3. Mapping

```{r, fig.width=15, fig.height=12}
library(ggmap)

houseData$price_cat[houseData$price > 0] <- 1
houseData$price_cat[houseData$price > 100000] <- 2
houseData$price_cat[houseData$price > 200000] <- 3
houseData$price_cat[houseData$price > 300000] <- 4
houseData$price_cat <- as.factor(houseData$price_cat)

theme_set(theme_bw(16))
gw_in <- qmap("Greenwood IN", color = "bw", zoom = 12)

gw_in +
    stat_bin2d(
        aes(x = lon, y = lat, price_cat, fill = price_cat),
        size = .5, bins = 25, alpha = 1/2,
        data = houseData
    ) + 
    scale_fill_manual(
        values = c("1" = "#c7e9c0","2" = "#74c476","3" = "#31a354",
                   "4" = "#006d2c"),  
        labels = c("<100,000", "100,000-200,000", "200,000-300,000", ">300,000")) +
    
    theme(    axis.line = element_blank(),
              axis.text.x = element_blank(),
              axis.text.y = element_blank(),
              axis.ticks = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank(),
              legend.text = element_text(size=16))

```


