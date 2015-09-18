require(rjson)
require(rvest)

# Web 上から情報を取得
# jsondata は list
jsondata <- fromJSON(file = "https://aws.amazon.com/jp/ec2/pricing/pricing-on-demand-instances.json")

# 空の list の作成
pricelist <- list()

# listcount の初期値を設定
listcount <- 1
      
for ( i_regions in 1:length(jsondata[[2]]$regions))
{
  for ( i_instanceTypes in 1:length(jsondata[[2]]$regions[[i_regions]]$instanceTypes))
  {
    for ( i_sizes in 1:length(jsondata[[2]]$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$sizes))
    {
      region <- jsondata[[2]]$regions[[i_regions]]$region
      type <- jsondata[[2]]$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$type
      size <- jsondata[[2]]$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$sizes[[i_sizes]]$size
      name <- jsondata[[2]]$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$sizes[[i_sizes]]$valueColumns[[1]]$name
      USD <- jsondata[[2]]$regions[[i_regions]]$instanceTypes[[i_instanceTypes]]$sizes[[i_sizes]]$valueColumns[[1]]$prices$USD
      pricelist[[listcount]] <- c(region, type, size, name, USD)
      listcount <- listcount + 1
    }
  }
}

# 価格表 ( data.frame ) の作成
priceDF <- data.frame(Reduce(rbind, pricelist))
