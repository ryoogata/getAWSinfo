require(XML)
require(stringr)

# Web 上から情報を取得
theURL <- "http://aws.amazon.com/ec2/previous-generation/"

# ページの 7 個目のテーブルに EC2 の一覧があるのでそれを取得
oldtable <- readHTMLTable(theURL, which = 7, header = TRUE, stringsAsFactors = FALSE)

# vCPU, Memory (GiB) の列を数値化
oldtable$"vCPU" <- as.numeric(oldtable$"vCPU")
oldtable$"Memory (GiB)" <- as.numeric(oldtable$"Memory (GiB)")

# LocalStorage の項目の追加 ( Instance Storage (GB) の列から加工 )
oldtable$"LocalStorage" <- NA
oldtable$"LocalStorage"[which(grepl("SSD", oldtable$"Instance Storage (GB)"))] <- "SSD"
oldtable$"LocalStorage"[which(grepl("EBS Only", oldtable$"Instance Storage (GB)"))] <- "EBS Only"

# 列: Instance Storage (GB) から不要な文字列を削除
oldtable$"Instance Storage (GB)" <- str_replace(string=oldtable$"Instance Storage (GB)", pattern = " SSD", replacement = "")
oldtable$"Instance Storage (GB)" <- str_replace(string=oldtable$"Instance Storage (GB)", pattern = "EBS Only", replacement = "")
oldtable$"Instance Storage (GB)" <- str_replace(string=oldtable$"Instance Storage (GB)", pattern = ",", replacement = "")

# 列: Instance Storage (GB) を LocalStorageNUM と LocalStorageGB の列に分割
list <- str_split(string = oldtable$"Instance Storage (GB)", pattern = "x")
localStorageDF <- t(data.frame(list))
localStorageDF <- data.frame(localStorageDF)
rownames(localStorageDF) <- NULL
names(localStorageDF) <- c("LocalStorageNUM", "LocalStorageGB")

# LocalStorageNUM と LocalStorageGB の値を数値化
localStorageDF$LocalStorageNUM <- as.numeric(as.character(localStorageDF$LocalStorageNUM))
localStorageDF$LocalStorageGB <- as.numeric(as.character(localStorageDF$LocalStorageGB))

# テーブルの結合と不要な列の削除
oldtable <- cbind(oldtable, localStorageDF)
oldtable$LocalStorageCapacity <- localStorageDF$LocalStorageNUM * localStorageDF$LocalStorageGB
oldtable <- oldtable[,-6]

# 列: Instance Type を カテゴリーとサイズ情報として分割
instanceList <-str_split(string = oldtable$"Instance Type", pattern = "\\.")
instanceMatrix <- data.frame(Reduce(rbind, instanceList))
names(instanceMatrix) <- c("Instance Category","Instance Size")
oldtable <- cbind(instanceMatrix, oldtable)
oldtable$"LocalStorage"[which(is.na(oldtable$"LocalStorage"))] <- "HDD"

# ファイルの書き出し
write.table(table, file="oldec2list.csv", sep=",", row.names = FALSE)