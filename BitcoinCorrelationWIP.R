#Bitcoin Analysis


library(Quandl)
library(plotly)
library(data.table)

exchanges <- c('KRAKENUSD','COINBASEUSD','BITSTAMPUSD','ITBITUSD')

#Append 'BCHARTS/' to each BTC Price Index
i <- 0;
g <- NULL;
while(i < length(exchanges)){
  i <- i+1;
  g <- c(g, paste('BCHARTS/', exchanges[i], sep=""))
   
}
print(g)

#Quandl extraction of BTC exchange datasets
btc_KR <- data.frame(Quandl(g[1]))
btc_CB <- data.frame(Quandl(g[2]))
btc_BS <- data.frame(Quandl(g[3]))
btc_IB <- data.frame(Quandl(g[4]))

btc_KR[btc_KR == 0] <- NA
btc_CB[btc_CB == 0] <- NA
btc_BS[btc_BS == 0] <- NA
btc_IB[btc_IB == 0] <- NA

#Graph BTC USD by exchange
plot_ly() %>%
  add_lines(x = btc_KR$Date, y = btc_KR$Weighted.Price, name = "Kraken") %>%
  add_lines(x = btc_CB$Date, y = btc_CB$`Weighted.Price`, name = "Coinbase") %>%
  add_lines(x = btc_BS$Date, y = btc_BS$`Weighted.Price`, name = "BitStamp") %>%
  add_lines(x = btc_IB$Date, y = btc_IB$`Weighted.Price`, name = "ItBit") %>%
  layout(
    title = "BTC Exchange Weighted Prices",
    yaxis = list(title="$USD"),
    xaxis = list(title="Date")
  )

#Aggregate Data
btc_exchange_series <- Reduce(function(x, y) merge(x, y, all=TRUE),
                       list(btc_KR, btc_CB, btc_BS, btc_IB))

btc_exchange_series$KR_WP <- btc_KR$Weighted.Price

#btc_exchange_series$ <- avg()


plot_ly() %>%
  add_lines(x = btc_exchange_series$Date, 
            y = btc_exchange_series$Weighted.Price, name = "WP")



#-------------------------------------------------------------------------------WIP
getPoloData <- function(symbol, start= "1405699200", tspan = 300){
  cat("Grabbing ", symbol, " prices from Poloniex", fill = TRUE)
  "https://poloniex.com/public?command=returnChartData&currencyPair=%s&start=%s&end=9999999999&period=%d" 
  %>%
    sprintf(symbol, as.character(start), tspan) %>%
    fromJSON() %>%
    lapply(function(y){
      y %>%
        t() %>%
        as.data.frame()
    }) %>%
    bind_rows() %>%
    mutate(date = as.character(date)) %>%
    select(date, weightedAverage, high, low, quoteVolume) %>%
    setNames(tolower(c("date",
                       symbol %+% "_price",
                       symbol %+% "_high",
                       symbol %+% "_low",
                       symbol %+% "_qvol")))}

altcoins <- c('ETH','LTC','XRP','ETC','STR','DASH','SC','XMR','XEM')
eth <- getPoloData('ETH')
