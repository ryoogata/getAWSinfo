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

# Memo
# ====
#   
# リージョン (e.g. us-east, us-west-2, etc )数の確認
# > length(jsondata[[2]]$regions)
# [1] 8
# 
# インスタンスタイプ ( e.g. generalCurrentGen, generalPreviousGen, etc ) 数の確認
# > length(jsondata[[2]]$regions[[1]]$instanceTypes)
# [1] 9
#
# size ( e.g. m3.xlarge, m3.2xlarge, etc) 数の確認
# インスタンスタイプによって数が異なる
# > length(jsondata[[2]]$regions[[1]]$instanceTypes[[1]]$size)