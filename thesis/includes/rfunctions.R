list.packages <- c("dplyr", "imputeTS", "ggplot2", "fUnitRoots", "urca", "vars", "aod", "zoo", "tseries", "tictoc", "reshape2", "readr", "tikzDevice", "xtable", "outliers")
new.packages <- list.packages[!(list.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(dplyr)
library(imputeTS)
library(ggplot2)
library(fUnitRoots)
library(urca)
library(vars)
library(aod)
library(zoo)
library(tseries)
library(tictoc)
library(reshape2)
library(readr)
library(tikzDevice)
library(xtable)
library(outliers)

options(tikzDefaultEngine = 'xetex')
options(tikzLwdUnit = 10 / 96)
Sys.setlocale("LC_TIME", "English")
Sys.setenv(LANG = "en_GB.UTF-8")

rootPath <- "D:/files/Tweets"
tweetsPath <- paste(rootPath, "data", sep="/")
resultsPath <- paste(rootPath, "results", sep="/")
indicesPath <- paste(rootPath, "indices", sep="/")

polTypes <- c("TB", "NB", "ME", "SVM")

dk.interpol <- function(x) {
	while ( anyNA(x) ) {
		minNaIndex <- min(which(is.na(x)))
		x[minNaIndex] <- (x[max(which(!is.na(x[0:minNaIndex])))] + x[min(which(!is.na(x[minNaIndex:length(x)]))) + minNaIndex - 1]) / 2		
	}
	
	return (x)
}

dk.loadindices <- function(indicesFile) {
	tic("> reading indices ...")
	#Columns: Date,Open,High,Low,Close,Adj Close,Volume
	indices <- read.csv(file=paste(indicesPath, paste0(indicesFile, '.csv'), sep="/"), header=TRUE, sep=",", colClasses=c("Date","NULL","NULL","NULL","numeric","numeric","NULL"))
	toc()

	tic("> interpolate missing stock data ...")
	interpolated <- indices
	interpolated$Close <- dk.interpol(interpolated$Close)
	interpolated$Adj.Close <- dk.interpol(interpolated$Adj.Close)
	toc()

	return (interpolated)
}

dk.load <- function(tweetFile, indicesFile, omitRt = F) {
	tic(paste0("> loading data ", tweetFile, " ..."))
	
	tic("> reading raw tweets ...")
	#Columns: "id";"created_at";"from_user_name";"text"
	tweets_raw <- read_csv2(file=paste(tweetsPath, paste0(tweetFile, '.csv'), sep="/"), col_names=TRUE, col_types=cols_only(id = col_character(), created_at = col_character(), text = col_character()))
	tweets_raw$date <- as.Date(tweets_raw$created_at, "%Y-%m-%d")
	tweets_raw$IsRT <- startsWith(tweets_raw$text, "RT ")
	toc()

	if(omitRt) {
		tic("> filtering retweets")
		tweets_raw <- tweets_raw[!tweets_raw$IsRT, ]
		toc()
	}

	tic("> reading sentiments ...")
	#Columns: ;TweetId;CreatedAt;SA_*
	tweets.pol.tb <- read.csv(file=paste(resultsPath, paste0(tweetFile, '_pol_TB', '.csv'), sep="/"), header=TRUE, sep=";", colClasses=c("NULL", "character", "NULL", "numeric"))
	tweets.pol.nb <- read.csv(file=paste(resultsPath, paste0(tweetFile, '_pol_NB', '.csv'), sep="/"), header=TRUE, sep=";", colClasses=c("NULL", "character", "NULL", "numeric"))
	tweets.pol.me <- read.csv(file=paste(resultsPath, paste0(tweetFile, '_pol_ME', '.csv'), sep="/"), header=TRUE, sep=";", colClasses=c("NULL", "character", "NULL", "numeric"))
	tweets.pol.svm <- read.csv(file=paste(resultsPath, paste0(tweetFile, '_pol_SVM', '.csv'), sep="/"), header=TRUE, sep=";", colClasses=c("NULL", "character", "NULL", "numeric"))
	toc()

	tic("> remove neutral sentiments ...")
	countOfNeutralTweets <- length(which(tweets.pol.tb==0))
	totalNumberOfTweets <- nrow(tweets.pol.tb)
	print(paste(" -> interpret", countOfNeutralTweets / totalNumberOfTweets * 100, "% neutral sentiments as positive ones ..."))
	tweets.pol.tb[tweets.pol.tb[2] == 0,2] <- 1
	toc()

	tic("> joining and summarize tweets ...")
	tweets <- tweets_raw %>%		
		left_join(tweets.pol.tb, by = c("id" = "TweetId")) %>%
		left_join(tweets.pol.nb, by = c("id" = "TweetId")) %>%
		left_join(tweets.pol.me, by = c("id" = "TweetId")) %>%
		left_join(tweets.pol.svm, by = c("id" = "TweetId")) %>%
		group_by(date) %>%
		summarize(SA_TB = sum(SA_TB), SA_NB = sum(SA_NB), SA_ME = sum(SA_ME), SA_SVM = sum(SA_SVM), tweet.count=n(), rt.count=sum(as.integer(IsRT)))
	toc()
	
	tic("> reading indices ...")
	#Columns: Date,Open,High,Low,Close,Adj Close,Volume
	indices <- read.csv(file=paste(indicesPath, paste0(indicesFile, '.csv'), sep="/"), header=TRUE, sep=",", colClasses=c("Date","NULL","NULL","NULL","numeric","numeric","NULL"))
	toc()
			
	tic("> joining tweets with indices ...")
	date <- seq(min(tweets$date, na.rm = TRUE), max(tweets$date, na.rm = TRUE), by="day")
	original <- data.frame(date)
	
	original <- original %>% 
		left_join(tweets, by = c("date" = "date")) %>%
		left_join(indices, by = c("date" = "Date"))
	toc()

	tic("> interpolate missing stock data ...")
	interpolated <- original
	interpolated$Close <- dk.interpol(interpolated$Close)
	interpolated$Adj.Close <- dk.interpol(interpolated$Adj.Close)
	toc()
	
	tic("> cleaning data ...")
	#cleaning data (remove all rows where no sentiment could be detected)
	cleaned <- interpolated 
	cleaned <- cleaned[complete.cases(cleaned),]
	
	cleaned$dategroup <- c(0, cumsum(diff(cleaned$date) > 1))
	cleaned <- cleaned %>% group_by(dategroup) %>% mutate(count = n())
	cleaned <- cleaned[cleaned$count > 5, ]
	toc()
	
	tic("> normalizing data ...")
	norm <- cleaned
	norm$SA_TB <- (norm$SA_TB - mean(norm$SA_TB)) / sd(norm$SA_TB)
	norm$SA_NB <- (norm$SA_NB - mean(norm$SA_NB)) / sd(norm$SA_NB)
	norm$SA_ME <- (norm$SA_ME - mean(norm$SA_ME)) / sd(norm$SA_ME)
	norm$SA_SVM <- (norm$SA_SVM - mean(norm$SA_SVM)) / sd(norm$SA_SVM)
	norm$Close <- (norm$Close - mean(norm$Close)) / sd(norm$Close)
	norm$Adj.Close <- (norm$Adj.Close - mean(norm$Adj.Close)) / sd(norm$Adj.Close)
	toc()
	
	toc()

	return (norm)
}

dk.show <- function(df) {
	melted <- melt(df[c(1:5,8)], id.vars='date', variable.name='type')
	melted$dategroup <- df$dategroup 
	legendtitle <- "Legend"
	grouptitles <- paste("Group", 1:length(unique(melted$dategroup)))
	names(grouptitles) <- unique(melted$dategroup)
	levels(melted$type) <- c("$S_{TB}$", "$S_{NB}$","$S_{ME}$", "$S_{SVM}$", "$P_{Share}$")
	lineValues <- c(1,1,1,1,2,0)

	ggplot(melted, aes(date, value, color=type)) + 
		geom_line(aes(linetype=type), size=1) +
		geom_point(aes(shape=type), size=1) +
		scale_linetype_manual(name = legendtitle, values = lineValues) +
		scale_shape_manual(name = legendtitle, values = lineValues) + 
		facet_wrap(vars(dategroup), scales = "free_x", labeller = labeller(dategroup = grouptitles)) + 
		labs(colour = legendtitle, x = "Date", y = "Normalized Value") +
		theme(axis.text.x = element_text(angle = 25, vjust = 1, hjust = 1))
}

dk.showsentiments <- function(df) {
	melted <- melt(df[1:5], id.vars='date', variable.name='type')
	# copy the dategroups
	melted$dategroup <- df$dategroup 	
	#https://stackoverflow.com/questions/21529332/how-to-not-plot-gaps-in-timeseries-with-r
	legendtitle <- "Legend"
	grouptitles <- paste("Group", 1:length(unique(melted$dategroup)))
	names(grouptitles) <- unique(melted$dategroup)
	levels(melted$type) <- c("$S_{TB}$", "$S_{NB}$","$S_{ME}$", "$S_{SVM}$")
	lineValues <- c(1,1,1,1,0,0)

	ggplot(melted, aes(date, value, color=type)) + 
		geom_line(aes(linetype=type), size=1) +
		geom_point(aes(shape=type), size=1) +
		scale_linetype_manual(name = legendtitle, values = lineValues) +
		scale_shape_manual(name = legendtitle, values = lineValues) + 
		facet_wrap(vars(dategroup), scales = "free_x", labeller = labeller(dategroup = grouptitles)) + 
		labs(colour = legendtitle, x = "Date", y = "Normalized Value") +
		theme(axis.text.x = element_text(angle = 25, vjust = 1, hjust = 1))
}

dk.oppositesentiments <- function(df, maxdiff = 1) {
	data <- df
	data$different <- abs(rowSums(sign(data[2:5]))) != 4
	data$diff <- rowMaxs(data[2:5]) - rowMins(data[2:5])
	
	data <- data[data$different & data$diff > maxdiff, ]
	data$min <- rowMins(data[2:5])
	data$max <- rowMaxs(data[2:5])
	data$rt.ratio = data$rt.count / data$tweet.count

	return (data)
}

dk.outliers <- function(df, maxdiff = 2.326348) {
	data <- df
	data <- data[apply(abs(data[2:5]) >= maxdiff, 1, any), ]
	return (data)
}

dk.formatnumber <- function(num, digits) {
	return (format(round(num, digits), nsmall=digits))
}

dk.latextableoppsent <- function(data) {
	#\printdate{2018-04-01}  &  \num{34629}  &  \num{1.750} \\
	v <- paste0("\\printdate{", data$date, "}   &  \\num{", dk.formatnumber(data$tweet.count, 0), "}   &  \\SI{", dk.formatnumber(data$rt.count / data$tweet.count * 100, 2), "}{\\percent}   & \\num{", dk.formatnumber(data$diff, 3), "} \\\\")
	
	return (cat(v, sep="\n\t"))
}

dk.latextablegrangercol <- function(num) {
	return (paste0("   & ", substr(dk.formatnumber(num, 4), 2, 6), ifelse(num <= 0.05, "*", "")))
}

dk.latextablegranger <- function(data.rt, data.nort) {
	data <- data.rt %>%		
		left_join(data.nort, by = c("lag" = "lag"))

	v <- paste0(data$lag,
		dk.latextablegrangercol(data$SA_TB.x),
		dk.latextablegrangercol(data$SA_TB.y),
		dk.latextablegrangercol(data$SA_NB.x),
		dk.latextablegrangercol(data$SA_NB.y),
		dk.latextablegrangercol(data$SA_ME.x),
		dk.latextablegrangercol(data$SA_ME.y),
		dk.latextablegrangercol(data$SA_SVM.x),
		dk.latextablegrangercol(data$SA_SVM.y),
		" \\\\")

	return (cat(v, sep="\n\t"))
}

dk.gettoptweetsofday <- function(data, count, omitRT = F) {
	tic("> group by text and order")

	x <- data
	
	if (omitRT) {
		x <- x[!x$IsRT, ]
	}
	
	rows <- nrow(x)
	
	x <- x %>%
		group_by(text) %>%
		summarize(total.count = n(), rt.percentage = n() / rows * 100) %>%
		arrange(desc(total.count)) %>%
		top_n(count)
	toc()

	return (x)
}

dk.gathertweetsbydate <- function(tweetFile, dates) {
	tic("> reading raw tweets ...")
	#Columns: "id";"created_at";"from_user_name";"text"
	tweets_raw <- read_csv2(file=paste(tweetsPath, paste0(tweetFile, '.csv'), sep="/"), col_names=TRUE, col_types=cols_only(id = col_character(), created_at = col_character(), from_user_name = col_character(), text = col_character()))
	tweets_raw$date <- as.Date(tweets_raw$created_at, "%Y-%m-%d")
	tweets_raw$IsRT <- startsWith(tweets_raw$text, "RT ")
	toc()

	tic(paste0("> filter by ", length(dates), " dates"))
	filtered <- tweets_raw[tweets_raw$date %in% dates,]
	toc()

	return (filtered)
}

dk.getspecificdate <- function(data, dateAsStr) {
	data[data$date == as.Date(dateAsStr), ]
}

dk.retweetstats <- function(data) {
	total <- sum(data$tweet.count)
	rt <- sum(data$rt.count)

	x <- c(total, rt, rt/total * 100)
	names(x) <- c("Total", "Retweets", "Ratio")

	return (x)
}

dk.granger <- function(df) {
	x <- data.frame(lag = 1:10)
	
	i <- 1
	while(i < 11) {
		# y ~ model
		x$SA_TB[i] <- grangertest(Close ~ SA_TB, order = i, data = df)[2,4]
		x$SA_NB[i] <- grangertest(Close ~ SA_NB, order = i, data = df)[2,4]
		x$SA_ME[i] <- grangertest(Close ~ SA_ME, order = i, data = df)[2,4]
		x$SA_SVM[i] <- grangertest(Close ~ SA_SVM, order = i, data = df)[2,4]
		i <- i + 1
	}
	
	return (x)
}

dk.analyze <- function(df) {
	print(dk.granger(df))
	dk.show(df)
}

dk.showindex <- function(df, sa, currency) {
	legendtitle <- "Legend"

	minDate <- min(sa$date)
	maxDate <- max(sa$date)

	print(minDate)
	print(maxDate)

	data <- df[df$Date >= minDate & df$Date < maxDate + 1, 1:2]

	ggplot(data, aes(x = Date, y = Close)) +
		geom_line() + geom_point() +
		labs(x = "Date", y = paste0("Price per share [", currency, "]")) +
		scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y")
}

dk.stats <- function(tweetData) {
	data <- c()

	dgs <- unique(tweetData$dategroup)
	
	for (dg in dgs) {
		d.min <- min(tweetData[tweetData$dategroup == dg, ]$date)
		d.max <- max(tweetData[tweetData$dategroup == dg, ]$date)
		d.days <- unique(tweetData[tweetData$dategroup == dg, ]$count)
		d.count <- sum(tweetData[tweetData$dategroup == dg, ]$tweet.count)

		data <- c(data, c(d.min, d.max, d.days, d.count))	
	}
	m <- matrix(data, ncol=4, byrow=T)

	d.min <- min(m[,1])
	d.max <- max(m[,2])
	d.days <- sum(m[,3])
	d.count <- sum(m[,4])

	data <- c(data, c(d.min, d.max, d.days, d.count))

	m <- matrix(data, ncol=4, byrow=T)
	
	data <- data.frame(m)
	colnames(data) <- c("From", "To", "Days", "Tweets")
	rownames(data)[1:(nrow(data)-1)] <- paste0("DG#", dgs)
	rownames(data)[nrow(data)] <- "Total"
	data$From <- as.Date(data$From)
	data$To <- as.Date(data$To)
	data
}

dk.retweetanalysis <- function(data) {
	data$different <- abs(rowSums(sign(data[2:5]))) != 4
	data$ratio <- data$rt.count / data$tweet.count
	x <- data[data$different, ][[13]]
	y <- data[!data$different, ][[13]]

	print(ks.test(x,y))
	print(ks.test(x,y, alternative="gr"))
	print(ks.test(x,y, alternative="l"))
	print(t.test(x,y))
	print(wilcox.test(x,y))
}

ggplotRegression <- function (fit) {
	ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
	  geom_point() +
	  stat_smooth(method = "lm", col = "red") +
	  labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                     "Intercept =",signif(fit$coef[[1]],5 ),
                     " Slope =",signif(fit$coef[[2]], 5),
                     " P =",signif(summary(fit)$coef[2,4], 5)))
}

dk.grangerstat <- function(data) {
	tic("> summarizing data ...")
	
	x <- data %>% 
		summarize(
			SA_TB.x = sum(type == "SA_TB" & !rt.omitted & significant),
			SA_TB.y = sum(type == "SA_TB" &  rt.omitted & significant),
			SA_NB.x = sum(type == "SA_NB" & !rt.omitted & significant),
			SA_NB.y = sum(type == "SA_NB" &  rt.omitted & significant),
			SA_ME.x = sum(type == "SA_ME" & !rt.omitted & significant),	
			SA_ME.y = sum(type == "SA_ME" &  rt.omitted & significant),
			SA_SVM.x = sum(type == "SA_SVM" & !rt.omitted & significant),
			SA_SVM.y = sum(type == "SA_SVM" &  rt.omitted & significant),
			SA_TB = sum(type == "SA_TB" & significant),
			SA_NB = sum(type == "SA_NB" & significant),
			SA_ME = sum(type == "SA_ME" & significant),	
			SA_SVM = sum(type == "SA_SVM" & significant),
			RT = sum(!rt.omitted & significant),
			NoRt = sum(rt.omitted & significant),
			total = sum(significant),
			count = n()
		)
	toc()

	return (x)
}

dk.sentimentstats <- function(df) {
	return (c(sum(df$SA_TB > 0) / nrow(df) * 100,
		sum(df$SA_NB > 0) / nrow(df) * 100,
		sum(df$SA_ME > 0) / nrow(df) * 100,
		sum(df$SA_SVM > 0) / nrow(df) * 100))
}

dk.realsentimentstats <- function(tweetFile, omitRt = F) {
	tic("> reading raw tweets ...")
	#Columns: "id";"created_at";"from_user_name";"text"
	tweets_raw <- read_csv2(file=paste(tweetsPath, paste0(tweetFile, '.csv'), sep="/"), col_names=TRUE, col_types=cols_only(id = col_character(), created_at = col_character(), text = col_character()))
	tweets_raw$date <- as.Date(tweets_raw$created_at, "%Y-%m-%d")
	tweets_raw$IsRT <- startsWith(tweets_raw$text, "RT ")
	toc()

	if(omitRt) {
		tic("> filtering retweets")
		tweets_raw <- tweets_raw[!tweets_raw$IsRT, ]
		toc()
	}

	tic("> reading sentiments ...")
	#Columns: ;TweetId;CreatedAt;SA_*
	tweets.pol.tb <- read.csv(file=paste(resultsPath, paste0(tweetFile, '_pol_TB', '.csv'), sep="/"), header=TRUE, sep=";", colClasses=c("NULL", "character", "NULL", "numeric"))
	tweets.pol.nb <- read.csv(file=paste(resultsPath, paste0(tweetFile, '_pol_NB', '.csv'), sep="/"), header=TRUE, sep=";", colClasses=c("NULL", "character", "NULL", "numeric"))
	tweets.pol.me <- read.csv(file=paste(resultsPath, paste0(tweetFile, '_pol_ME', '.csv'), sep="/"), header=TRUE, sep=";", colClasses=c("NULL", "character", "NULL", "numeric"))
	tweets.pol.svm <- read.csv(file=paste(resultsPath, paste0(tweetFile, '_pol_SVM', '.csv'), sep="/"), header=TRUE, sep=";", colClasses=c("NULL", "character", "NULL", "numeric"))
	toc()

	tic("> remove neutral sentiments ...")
	countOfNeutralTweets <- length(which(tweets.pol.tb==0))
	totalNumberOfTweets <- nrow(tweets.pol.tb)
	print(paste(" -> interpret", countOfNeutralTweets / totalNumberOfTweets * 100, "% neutral sentiments as positive ones ..."))
	tweets.pol.tb[tweets.pol.tb[2] == 0,2] <- 1
	toc()

	tic("> joining and summarize tweets ...")
	tweets <- tweets_raw %>%		
		left_join(tweets.pol.tb, by = c("id" = "TweetId")) %>%
		left_join(tweets.pol.nb, by = c("id" = "TweetId")) %>%
		left_join(tweets.pol.me, by = c("id" = "TweetId")) %>%
		left_join(tweets.pol.svm, by = c("id" = "TweetId"))
	toc()

	return (dk.sentimentstats(tweets))
}