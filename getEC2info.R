require(XML)
require(stringr)

# Web 上から情報を取得
theURL <- "http://aws.amazon.com/ec2/instance-types/"

# ページの 10 個目のテーブルに EC2 の一覧があるのでそれを取得
table <- readHTMLTable(theURL, which = 10, header = TRUE, stringsAsFactors = FALSE)

# CPU Clock Speed の不要な記述 ( Up to ) を削除
table$"Clock Speed (GHz)" <- str_replace(string=table$"Clock Speed (GHz)", pattern = "Up to ", replacement = "")

# vCPU, Memory (GiB), Clock Speed (GHz) の列を数値化
table$"vCPU" <- as.numeric(table$"vCPU" )
table$"Memory (GiB)" <- as.numeric(table$"Memory (GiB)")
table$"Clock Speed (GHz)" <- as.numeric(table$"Clock Speed (GHz)")

# LocalStorage の項目の追加 ( Storage (GB) の列から加工 )
table$"LocalStorage" <- NA
table$"LocalStorage"[which(grepl("SSD", table$"Storage (GB)"))] <- "SSD"
table$"LocalStorage"[which(grepl("EBS Only", table$"Storage (GB)"))] <- "EBS Only"
table$LocalStorage[which(is.na(table$LocalStorage))] <- "HDD"

# 列: Storage (GB) から不要な文字列を削除
table$"Storage (GB)" <- str_replace(string=table$"Storage (GB)", pattern = " SSD", replacement = "")
table$"Storage (GB)" <- str_replace(string=table$"Storage (GB)", pattern = "EBS Only", replacement = "")

# 列: Storage (GB) を LocalStorageNUM と LocalStorageGB の列に分割
list <- str_split(string = table$"Storage (GB)", pattern = "x")
localStorageDF <- t(data.frame(list))
localStorageDF <- data.frame(localStorageDF)
rownames(localStorageDF) <- NULL
names(localStorageDF) <- c("LocalStorageNUM", "LocalStorageGB")

# LocalStorageNUM と LocalStorageGB の値を数値化
localStorageDF$LocalStorageNUM <- as.numeric(as.character(localStorageDF$LocalStorageNUM))
localStorageDF$LocalStorageGB <- as.numeric(as.character(localStorageDF$LocalStorageGB))

# テーブルの結合と不要な列の削除
table <- cbind(table, localStorageDF)
table$LocalStorageCapacity <- localStorageDF$LocalStorageNUM * localStorageDF$LocalStorageGB
table <- table[,-4]

# 数値データ列の NA を 0 に置き換える
table$LocalStorageNUM[is.na(table$LocalStorageNUM)] <- 0
table$LocalStorageGB[is.na(table$LocalStorageGB)] <- 0
table$LocalStorageCapacity[is.na(table$LocalStorageCapacity)] <- 0

# 列: Instance Type を カテゴリーとサイズ情報として分割
instanceList <-str_split(string = table$"Instance Type", pattern = "\\.")
instanceMatrix <- data.frame(Reduce(rbind, instanceList))
names(instanceMatrix) <- c("InstanceCategory","InstanceSize")
table <- cbind(instanceMatrix, table)

# 列名の変更
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

# CPU 表記が崩れた所を修正
table$"PhysicalProcessor"[table$"InstanceType" == "g2.2xlarge"] <- "Intel Xeon E5-2670"

# NetworkingPerformance と PhysicalProcessor 列を factor 化
table$NetworkingPerformance <- factor(x = table$NetworkingPerformance, levels = c("Low to Moderate", "Moderate", "High" ,"10 Gigabit"))
table$PhysicalProcessor <- factor(x = table$PhysicalProcessor, levels = c("Intel Xeon family","Intel Xeon E5-2666 v3","Intel Xeon E5-2670","Intel Xeon E5-2670 v2*","Intel Xeon E5-2670 v2","Intel Xeon E5-2676 v3","Intel Xeon E5-2680 v2"))

# ファイルの書き出し
write.table(table, file="ec2list.csv", sep=",", row.names = FALSE)