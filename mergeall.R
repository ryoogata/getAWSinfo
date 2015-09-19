# getEC2info.R スクリプト実行
source("getEC2info.R")

# getEC2price.R スクリプト実行
source("getEC2price.R")

# 東京リージョン情報収集
tokyoprice <- priceDF[priceDF$region == "ap-northeast-1",c("size", "USD")]

# 全リージョンの価格情報を含めて merge
alltable <- merge( x = table, y = priceDF, by.x = "InstanceType", by.y = "size")

# 東京リージョンのみ価格情報を含めて merge
tokyotable <- merge( x = table, y = tokyoprice, by.x = "InstanceType", by.y = "size")