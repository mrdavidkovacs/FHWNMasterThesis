file.index.hyundai <- "Hyundai"
file.index.gm <- "GM"
file.index.toyota <- "Toyota"
file.index.ford <- "Ford"
file.index.vw <- "VW"

file.tweet.hyundai <- "01_hyundai_motor_company_tweets"
file.tweet.gm <- "02_general_motors_company_tweets"
file.tweet.toyota <- "03_toyota_motor_corporation_tweets"
file.tweet.ford <- "04_ford_tweets"
file.tweet.vw <- "05_volkswagen_tweets"

indices.hyundai <- dk.loadindices(file.index.hyundai)
indices.gm <- dk.loadindices(file.index.gm)
indices.toyota <- dk.loadindices(file.index.toyota)
indices.ford <- dk.loadindices(file.index.ford)
indices.vw <- dk.loadindices(file.index.vw)

data.hyundai <- dk.load(file.tweet.hyundai, file.index.hyundai)
data.gm <- dk.load(file.tweet.gm, file.index.gm)
data.toyota <- dk.load(file.tweet.toyota, file.index.toyota)
data.ford <- dk.load(file.tweet.ford, file.index.ford)
data.vw <- dk.load(file.tweet.vw, file.index.vw)

dk.stats(data.ford)
dk.stats(data.gm)
dk.stats(data.hyundai)
dk.stats(data.toyota)
dk.stats(data.vw)

dk.retweetstats(data.ford)
dk.retweetstats(data.gm)
dk.retweetstats(data.hyundai)
dk.retweetstats(data.toyota)
dk.retweetstats(data.vw)

indexGraphWidth <- 5.5
indexGraphHeight <- indexGraphWidth * 0.65

tikz('graphs/indices-hyundai.tex', width=indexGraphWidth, height=indexGraphHeight)
dk.showindex(indices.hyundai, data.hyundai, "KRW")
dev.off()

tikz('graphs/indices-gm.tex', width=indexGraphWidth, height=indexGraphHeight)
dk.showindex(indices.gm, data.gm, "USD")
dev.off()

tikz('graphs/indices-toyota.tex', width=indexGraphWidth, height=indexGraphHeight)
dk.showindex(indices.toyota, data.toyota, "JPY")
dev.off()

tikz('graphs/indices-ford.tex', width=indexGraphWidth, height=indexGraphHeight)
dk.showindex(indices.ford, data.ford, "USD")
dev.off()

tikz('graphs/indices-vw.tex', width=indexGraphWidth, height=indexGraphHeight)
dk.showindex(indices.vw, data.vw, "EUR")
dev.off()

resultsGraphWidth  <- 6
resultsGraphHeight <- 4

tikz('graphs/sentiments-hyundai.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.showsentiments(data.hyundai)
dev.off()

tikz('graphs/sentiments-gm.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.showsentiments(data.gm)
dev.off()

tikz('graphs/sentiments-toyota.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.showsentiments(data.toyota)
dev.off()

tikz('graphs/sentiments-ford.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.showsentiments(data.ford)
dev.off()

tikz('graphs/sentiments-vw.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.showsentiments(data.vw)
dev.off()

os.ford <- dk.oppositesentiments(data.ford)
os.gm <- dk.oppositesentiments(data.gm)
os.hyundai <- dk.oppositesentiments(data.hyundai)
os.toyota <- dk.oppositesentiments(data.toyota)
os.vw <- dk.oppositesentiments(data.vw)

os <- os.ford
os <- rbind(os, os.gm)
os <- rbind(os, os.hyundai)
os <- rbind(os, os.toyota)
os <- rbind(os, os.vw)

fit <- lm(diff ~ rt.ratio, data=os)
summary(fit)

data.ford$company <- "Ford"
data.gm$company <- "GM"
data.hyundai$company <- "Hyundai"
data.toyota$company <- "Toyota"
data.vw$company <- "VW"

osa <- data.ford
osa <- rbind(osa, data.gm)
osa <- rbind(osa, data.hyundai)
osa <- rbind(osa, data.toyota)
osa <- rbind(osa, data.vw)
osa$diff <- rowMaxs(osa[2:5]) - rowMins(osa[2:5])
osa$rt.ratio = osa$rt.count / osa$tweet.count

fit2 <- lm(diff ~ rt.ratio, data=osa)
summary(fit2)

tikz('graphs/retweet_vs_diff.tex', width=resultsGraphWidth, height=resultsGraphHeight)
ggplot(osa, aes(rt.ratio, diff)) + 
	geom_point(aes(colour=company)) + 
	stat_smooth(method= "lm", col = "red") +
	labs(colour="Company", x = "Retweet Ratio", y = "Absolute Difference", title = "")
dev.off()

dk.latextableoppsent(os.ford)
dk.latextableoppsent(os.gm)
dk.latextableoppsent(os.hyundai)
dk.latextableoppsent(os.toyota)
dk.latextableoppsent(os.vw)

dk.outliers(data.ford)
dk.getspecificdate(data.ford, "2018-07-13")
funkydates.ford <- c(as.Date("2018-07-13"))
funkydates.ford <- c(as.Date("2018-07-17"))
funkydates.ford <- c(as.Date("2018-08-22"))
funkydates.ford <- c(as.Date("2018-08-23"))
funkydates.fordtweets <- dk.gathertweetsbydate(file.tweet.ford, funkydates.ford)
dk.gettoptweetsofday(funkydates.fordtweets, 20)

dk.outliers(data.gm)
dk.getspecificdate(data.gm, "2018-07-20")
funkydates.gm <- c(as.Date("2018-07-20"))
funkydates.gm <- c(as.Date("2018-07-21"))
funkydates.gmtweets <- dk.gathertweetsbydate(file.tweet.gm, funkydates.gm)
dk.gettoptweetsofday(funkydates.gmtweets, 20)

dk.outliers(data.hyundai)
funkydates.hyundai <- c(as.Date("2018-03-21"))
funkydates.hyundai <- c(as.Date("2018-04-04"))
funkydates.hyundai <- c(as.Date("2018-04-05"))
funkydates.hyundaitweets <- dk.gathertweetsbydate(file.tweet.hyundai, funkydates.hyundai)
dk.gettoptweetsofday(funkydates.hyundaitweets, 20)

dk.outliers(data.toyota)
funkydates.toyota<- c(as.Date("2018-07-20"))
funkydates.toyota<- c(as.Date("2018-07-21"))
funkydates.toyota<- c(as.Date("2018-07-22"))
funkydates.toyotatweets <- dk.gathertweetsbydate(file.tweet.toyota, funkydates.toyota)
dk.gettoptweetsofday(funkydates.toyotatweets, 20)

dk.outliers(data.vw, 2.5)
funkydates.vw <- c(as.Date("2018-03-12"))
funkydates.vw <- c(as.Date("2018-03-30"))
funkydates.vw <- c(as.Date("2018-04-06"))
funkydates.vw <- c(as.Date("2018-06-28"))
funkydates.vwtweets <- dk.gathertweetsbydate(file.tweet.vw, funkydates.vw)
dk.gettoptweetsofday(funkydates.vwtweets, 20)

dk.gathertweetsbydate(file.tweet.hyundai, os.hyundai$date)
dk.gathertweetsbydate(file.tweet.gm, os.gm$date)
dk.gathertweetsbydate(file.tweet.toyota, os.toyota$date)
dk.gathertweetsbydate(file.tweet.ford, os.ford$date)
dk.gathertweetsbydate(file.tweet.vw, os.vw$date)

tikz('graphs/results-hyundai.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.show(data.hyundai) + coord_cartesian(ylim = c(-2, 2))
dev.off()

tikz('graphs/results-gm.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.show(data.gm) + coord_cartesian(ylim = c(-2, 2))
dev.off()

tikz('graphs/results-toyota.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.show(data.toyota) + coord_cartesian(ylim = c(-2.5, 2))
dev.off()

tikz('graphs/results-ford.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.show(data.ford) + coord_cartesian(ylim = c(-2.5, 2.5))
dev.off()

tikz('graphs/results-vw.tex', width=resultsGraphWidth, height=resultsGraphHeight)
dk.show(data.vw)
dev.off()

granger.ford <- dk.granger(data.ford)
granger.gm <- dk.granger(data.gm)
granger.hyundai <- dk.granger(data.hyundai)
granger.toyota <- dk.granger(data.toyota)
granger.vw <- dk.granger(data.vw)

granger.nort.ford <- dk.granger(data.ford)
granger.nort.gm <- dk.granger(data.gm)
granger.nort.hyundai <- dk.granger(data.hyundai)
granger.nort.toyota <- dk.granger(data.toyota)
granger.nort.vw <- dk.granger(data.vw)

dk.latextablegranger(granger.ford, granger.nort.ford)
dk.latextablegranger(granger.gm, granger.nort.gm)
dk.latextablegranger(granger.hyundai, granger.nort.hyundai)
dk.latextablegranger(granger.toyota, granger.nort.toyota)
dk.latextablegranger(granger.vw, granger.nort.vw)

granger.ford$company <- "Ford"
granger.gm$company <- "GM"
granger.hyundai$company <- "Hyundai"
granger.toyota$company <- "Toyota"
granger.vw$company <- "VW"
granger.nort.ford$company <- "Ford"
granger.nort.gm$company <- "GM"
granger.nort.hyundai$company <- "Hyundai"
granger.nort.toyota$company <- "Toyota"
granger.nort.vw$company <- "VW"
granger.ford$rt.omitted <- F
granger.gm$rt.omitted <- F
granger.hyundai$rt.omitted <- F
granger.toyota$rt.omitted <- F
granger.vw$rt.omitted <- F
granger.nort.ford$rt.omitted <- T
granger.nort.gm$rt.omitted <- T
granger.nort.hyundai$rt.omitted <- T
granger.nort.toyota$rt.omitted <- T
granger.nort.vw$rt.omitted <- T

granger.x <- granger.ford
granger.x <- rbind(granger.x, granger.gm)
granger.x <- rbind(granger.x, granger.hyundai)
granger.x <- rbind(granger.x, granger.toyota)
granger.x <- rbind(granger.x, granger.vw)
granger.y <- granger.nort.ford
granger.y <- rbind(granger.y, granger.nort.gm)
granger.y <- rbind(granger.y, granger.nort.hyundai)
granger.y <- rbind(granger.y, granger.nort.toyota)
granger.y <- rbind(granger.y, granger.nort.vw)

granger <- granger.x %>%		
	left_join(granger.y, by = c("lag" = "lag", "company" = "company"))

granger <- granger.ford
granger <- rbind(granger, granger.gm)
granger <- rbind(granger, granger.hyundai)
granger <- rbind(granger, granger.toyota)
granger <- rbind(granger, granger.vw)
granger <- rbind(granger, granger.nort.ford)
granger <- rbind(granger, granger.nort.gm)
granger <- rbind(granger, granger.nort.hyundai)
granger <- rbind(granger, granger.nort.toyota)
granger <- rbind(granger, granger.nort.vw)

granger.melted <- melt(granger, variable.name='type', id.vars=c('company', 'rt.omitted', 'lag'))
granger.melted$significant <- granger.melted$value <= 0.05

dk.grangerstat(granger.melted)
dk.grangerstat(group_by(granger.melted, company))
dk.grangerstat(group_by(granger.melted, rt.omitted))
dk.grangerstat(group_by(granger.melted, lag))

granger.lag <- dk.grangerstat(group_by(granger.melted, lag))
granger.lag.melted <- melt(granger.lag[,c(1,14,15,16)], variable.name='type', id.vars=c('lag'))
levels(granger.lag.melted$type) <- c('All', 'No RT', 'Total')

tikz('graphs/results-lag.tex', width=resultsGraphWidth, height=resultsGraphHeight/4*3)
ggplot(granger.lag.melted, aes(lag, value, color=type)) + 
	geom_line() + 
	scale_x_discrete(limits=1:10) +
	scale_y_continuous(breaks=seq(2, 12, 2)) +
	labs(colour = 'Legend', x = 'Lag', y = '\\# significant values')
dev.off()	

summary(lm(NoRt ~ lag, data = granger.lag))
summary(lm(RT ~ lag, data = granger.lag))
summary(lm(total ~ lag, data = granger.lag))


positive.tweets <- data.frame(matrix(c(
dk.sentimentstats(data.ford),
dk.sentimentstats(data.gm),
dk.sentimentstats(data.hyundai),
dk.sentimentstats(data.toyota),
dk.sentimentstats(data.vw)), ncol=4, byrow=T))

names(positive.tweets) <- c('\\tb{}', '\\nb{}', '\\me{}', '\\svm{}')
rownames(positive.tweets) <- c('\\ford{}', '\\gm{}', '\\hyundai{}', '\\toyota{}', '\\vw{}')

sentiments.ford <- dk.realsentimentstats(file.tweet.ford)
sentiments.gm <- dk.realsentimentstats(file.tweet.gm)
sentiments.hyundai <- dk.realsentimentstats(file.tweet.hyundai)
sentiments.toyota <- dk.realsentimentstats(file.tweet.toyota)
sentiments.vw <- dk.realsentimentstats(file.tweet.vw)

sentiments <- data.frame(matrix(c(sentiments.ford, sentiments.gm, sentiments.hyundai, sentiments.toyota, sentiments.vw), byrow=T, ncol=4))
names(sentiments) <- c('\\tb{}', '\\nb{}', '\\me{}', '\\svm{}')
rownames(sentiments) <- c('\\ford{}', '\\gm{}', '\\hyundai{}', '\\toyota{}', '\\vw{}')