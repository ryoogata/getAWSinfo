R から AWS 情報を収集する

価格表
====

* [EC2およびS3の価格をプログラマブルで計算したい人はJSONをたたこう](http://blog.cloudpack.jp/2013/06/04/aws-news-ec2-json-jq/)


EC2 スペック表
====

```
require(XML)
require(stringr)
theURL <- "http://aws.amazon.com/ec2/instance-types/"
table <- readHTMLTable(theURL, which = 10, header = TRUE, stringsAsFactors = FALSE)

table$"Clock Speed (GHz)" <- str_replace(string=table$"Clock Speed (GHz)", pattern = "Up to ", replacement = "")
table$"vCPU" <- as.numeric(table$"vCPU" )
table$"Memory (GiB)" <- as.numeric(table$"Memory (GiB)")
table$"Clock Speed (GHz)" <- as.numeric(table$"Clock Speed (GHz)")

table$"LocalStorage" <- NA
table$"LocalStorage"[which(grepl("SSD", table$"Storage (GB)"))] <- "SSD"
table$"LocalStorage"[which(grepl("EBS Only", table$"Storage (GB)"))] <- "EBS Only"
table$LocalStorage[which(is.na(table$LocalStorage))] <- "HDD"

table$"Storage (GB)" <- str_replace(string=table$"Storage (GB)", pattern = " SSD", replacement = "")
table$"Storage (GB)" <- str_replace(string=table$"Storage (GB)", pattern = "EBS Only", replacement = "")

list <- str_split(string = table$"Storage (GB)", pattern = "x")
localStorageDF <- t(data.frame(list))
localStorageDF <- data.frame(localStorageDF)
rownames(localStorageDF) <- NULL
names(localStorageDF) <- c("LocalStorageNUM", "LocalStorageGB")

localStorageDF$LocalStorageNUM <- as.numeric(as.character(localStorageDF$LocalStorageNUM))
localStorageDF$LocalStorageGB <- as.numeric(as.character(localStorageDF$LocalStorageGB))

table <- cbind(table, localStorageDF)
table$LocalStorageCapacity <- localStorageDF$LocalStorageNUM * localStorageDF$LocalStorageGB
table <- table[,-4]

table$LocalStorageNUM[is.na(table$LocalStorageNUM)] <- 0
table$LocalStorageGB[is.na(table$LocalStorageGB)] <- 0
table$LocalStorageCapacity[is.na(table$LocalStorageCapacity)] <- 0

instanceList <-str_split(string = table$"Instance Type", pattern = "\\.")
instanceMatrix <- data.frame(Reduce(rbind, instanceList))
names(instanceMatrix) <- c("InstanceCategory","InstanceSize")
table <- cbind(instanceMatrix, table)

names(table)[names(table) =="Instance Type"] <- "InstanceType"
names(table)[names(table) == "Memory (GiB)"] <- "Memory"
names(table)[names(table) == "Networking Performance"] <- "NetworkingPerformance"
names(table)[names(table) == "Physical Processor"] <- "PhysicalProcessor"
names(table)[names(table) == "Clock Speed (GHz)"] <- "ClockSpeed"
names(table)[names(table) == "Intel AVX†"] <- "IntelAVX"
names(table)[names(table) == "Intel AVX2†"] <- "Intel AVX2"
names(table)[names(table) == "Intel Turbo"] <- "IntelTurbo"
names(table)[names(table) == "EBS OPT"] <- "EBSOPT"
names(table)[names(table) == "Enhanced Networking†"] <- "EnhancedNetworking"

table$"PhysicalProcessor"[table$"InstanceType" == "g2.2xlarge"] <- "Intel Xeon E5-2670"
table$NetworkingPerformance <- factor(x = table$NetworkingPerformance, levels = c("Low to Moderate", "Moderate", "High" ,"10 Gigabit"))
table$PhysicalProcessor <- factor(x = table$PhysicalProcessor, levels = c("Intel Xeon family","Intel Xeon E5-2666 v3","Intel Xeon E5-2670","Intel Xeon E5-2670 v2*","Intel Xeon E5-2670 v2","Intel Xeon E5-2676 v3","Intel Xeon E5-2680 v2"))
```

古いタイプの EC2
----

theURL <- "http://aws.amazon.com/ec2/previous-generation/"
oldtable <- readHTMLTable(theURL, which = 7, header = TRUE, stringsAsFactors = FALSE)
oldtable$"vCPU" <- as.numeric(oldtable$"vCPU")
oldtable$"Memory (GiB)" <- as.numeric(oldtable$"Memory (GiB)")

oldtable$"LocalStorage" <- NA
oldtable$"LocalStorage"[which(grepl("SSD", oldtable$"Instance Storage (GB)"))] <- "SSD"
oldtable$"LocalStorage"[which(grepl("EBS Only", oldtable$"Instance Storage (GB)"))] <- "EBS Only"

oldtable$"Instance Storage (GB)" <- str_replace(string=oldtable$"Instance Storage (GB)", pattern = " SSD", replacement = "")
oldtable$"Instance Storage (GB)" <- str_replace(string=oldtable$"Instance Storage (GB)", pattern = "EBS Only", replacement = "")
oldtable$"Instance Storage (GB)" <- str_replace(string=oldtable$"Instance Storage (GB)", pattern = ",", replacement = "")

list <- str_split(string = oldtable$"Instance Storage (GB)", pattern = "x")
localStorageDF <- t(data.frame(list))
localStorageDF <- data.frame(localStorageDF)
rownames(localStorageDF) <- NULL
names(localStorageDF) <- c("LocalStorageNUM", "LocalStorageGB")

localStorageDF$LocalStorageNUM <- as.numeric(as.character(localStorageDF$LocalStorageNUM))
localStorageDF$LocalStorageGB <- as.numeric(as.character(localStorageDF$LocalStorageGB))

oldtable <- cbind(oldtable, localStorageDF)
oldtable$LocalStorageCapacity <- localStorageDF$LocalStorageNUM * localStorageDF$LocalStorageGB
oldtable <- oldtable[,-6]

instanceList <-str_split(string = oldtable$"Instance Type", pattern = "\\.")
instanceMatrix <- data.frame(Reduce(rbind, instanceList))
names(instanceMatrix) <- c("Instance Category","Instance Size")
oldtable <- cbind(instanceMatrix, oldtable)
oldtable$"LocalStorage"[which(is.na(oldtable$"LocalStorage"))] <- "HDD"



Memo
====



str_split(string = table$"Storage (GB)", pattern = " x ")


grep("SSD", table$"Storage (GB)")


```
t2 <- readHTMLTable(theURL, which = 1, header = TRUE, stringsAsFactors = FALSE)
m4 <- readHTMLTable(theURL, which = 2, header = TRUE, stringsAsFactors = FALSE)
m3 <- readHTMLTable(theURL, which = 3, header = TRUE, stringsAsFactors = FALSE)
c4 <- readHTMLTable(theURL, which = 4, header = TRUE, stringsAsFactors = FALSE)
c3 <- readHTMLTable(theURL, which = 5, header = TRUE, stringsAsFactors = FALSE)
r3 <- readHTMLTable(theURL, which = 6, header = TRUE, stringsAsFactors = FALSE)
g2 <- readHTMLTable(theURL, which = 7, header = TRUE, stringsAsFactors = FALSE)
i2 <- readHTMLTable(theURL, which = 8, header = TRUE, stringsAsFactors = FALSE)
d2 <- readHTMLTable(theURL, which = 9, header = TRUE, stringsAsFactors = FALSE)

require(XML)
require(stringr)
theURL <- "http://aws.amazon.com/jp/ec2/instance-types/"
table <- readHTMLTable(theURL, which = 10, header = TRUE, stringsAsFactors = FALSE)
table$"Intel AVX2†"[table$"Intel AVX2†" == "–"] <- NA
table$"EBS OPT"[table$"EBS OPT" == "–"] <- NA
table$"拡張ネットワーキング†"[table$"拡張ネットワーキング†" == "–"] <- NA
table$"クロック速度（GHz）" <- str_replace(string=table$"クロック速度（GHz）", pattern = "最大 ", replacement = "")
table$"vCPU" <- as.numeric(table$"vCPU" )
table$"メモリ（GiB）" <- as.numeric(table$"メモリ（GiB）")
table$"クロック速度（GHz）" <- as.numeric(table$"クロック速度（GHz）")
```
