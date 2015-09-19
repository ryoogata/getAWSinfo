source("getEC2info.R")
source("getEC2price.R")

tokyoprice <- priceDF[priceDF$region == "ap-northeast-1",c("size", "USD")]

alltable <- merge( x = table, y = priceDF, by.x = "InstanceType", by.y = "size")
tokyotable <- merge( x = table, y = tokyoprice, by.x = "InstanceType", by.y = "size")