require(rjson)
require(rvest)

# Web 上から情報を取得
# jsondata は list
# 古いインスタンスタイプのデータ
# jsondata <- fromJSON(file = "https://aws.amazon.com/jp/ec2/pricing/pricing-on-demand-instances.json")

# オンデマンド linux
jsondata <- fromJSON(file = "https://aws.amazon.com/jp/ec2/pricing/json/linux-od.json")

# オンデマンド windows
#jsondata <- fromJSON(file = "https://aws.amazon.com/jp/ec2/pricing/json/mswin-od.json")

# オンデマンド RedHat
#jsondata <- fromJSON(file = "https://aws.amazon.com/jp/ec2/pricing/json/rhel-od.json")

# 空の list の作成
pricelist <- list()

# listcount の初期値を設定
listcount <- 1
      
for ( i_regions in 1:length(jsondata$config$regions))
{
  for ( i_instanceTypes in 1:length(jsondata$config$regions[[i_regions]]$instanceTypes))
  {
    for ( i_sizes in 1:length(jsondata$config$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$sizes))
    {
      region <- jsondata$config$regions[[i_regions]]$region
      type <- jsondata$config$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$type
      size <- jsondata$config$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$sizes[[i_sizes]]$size
      name <- jsondata$config$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$sizes[[i_sizes]]$valueColumns[[1]]$name
      USD <- jsondata$config$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$sizes[[i_sizes]]$valueColumns[[1]]$prices$USD
      pricelist[[listcount]] <- c(region, type, size, name, USD)
      listcount <- listcount + 1
    }
  }
}

# 価格表 ( data.frame ) の作成
priceDF <- data.frame(Reduce(rbind, pricelist))

# 列名の追加
names(priceDF) <- c("region", "type", "size", "name", "USD")

# USD を numeric 型に変換
priceDF$USD <- as.numeric(as.character(priceDF$USD))

# size を character 型に変換
priceDF$size <- as.character(priceDF$size)