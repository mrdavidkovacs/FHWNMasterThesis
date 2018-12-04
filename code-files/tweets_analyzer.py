import os, glob
import pandas as pd
import numpy as np

from textblob import TextBlob
import re, sys
import random
import time
import getopt
import datetime
import nltk

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import LogisticRegression
from sklearn.linear_model import SGDClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn import metrics
from nltk.stem.snowball import SnowballStemmer

class CustomVectorizer(CountVectorizer):    
  # overwrite the build_analyzer method, allowing one to
  # create a custom analyzer for the vectorizer
  def build_analyzer(self):        
    # load stop words using CountVectorizer's built in method
    stop_words = self.get_stop_words()    
    # create the analyzer that will be returned by this method
    def analyser(doc):
      stemmer = nltk.stem.snowball.SnowballStemmer("english", ignore_stopwords=True)
      # apply the preprocessing and tokenzation steps
      tokens = [stemmer.stem(word) for word in doc.lower().split()]
      # use CountVectorizer's _word_ngrams built in method
      # to remove stop words and extract n-grams
      return(self._word_ngrams(tokens, stop_words))
    return(analyser)

def GetClassifierPipeline(clf, clf_params):
	negative_tweets = nltk.corpus.twitter_samples.strings("negative_tweets.json")
	positive_tweets = nltk.corpus.twitter_samples.strings("positive_tweets.json")
	tweets = negative_tweets + positive_tweets

	labels = np.empty(len(tweets))
	labels[:len(negative_tweets)] = -1
	labels[len(negative_tweets):] = 1

	x_train, x_test, y_train, y_test = train_test_split(tweets, labels, test_size=0.25, random_state=42)

	text_clf = Pipeline([('vect', CustomVectorizer()), ('tfidf', TfidfTransformer()), ('clf', clf)])
	parameters = {'vect__ngram_range': [(1, 1), (1, 2)], 'tfidf__use_idf': (True, False), **clf_params }

	gs_clf = GridSearchCV(text_clf, parameters, cv=5, iid=False) #, n_jobs=-1)

	start = time.time()
	gs_clf.fit(x_train, y_train)
	end = time.time()
	log(f'training the classifier finished in {end - start}')

	best_pipe = gs_clf.best_estimator_

	print(best_pipe)

	log(' %.5f' % gs_clf.best_score_)

	predicted = gs_clf.predict(x_test)
	#np.mean(predicted == y_test)

	log(metrics.classification_report(y_test, predicted))
	#metrics.confusion_matrix(y_test, predicted)

	return gs_clf
	
def log(text):
	print(f'{datetime.datetime.now()} > {text}')
	
def process_file(stats, filename, currentfile, totalcountoffiles, classifierInfo):
	log(f'start processing of file {currentfile}/{totalcountoffiles} ({filename}) ...')

	newfilename = filename[:-4] + f'_pol_{classifierInfo.Abbreviation}.csv'
	newfilename = 'results/' + newfilename[5:]

	if os.path.isfile(newfilename):
		log(f'file {newfilename} already there ..')
	else:

		clf = classifierInfo.BuildClassifier()

		start = time.time()
		tweets = pd.read_csv(filename, sep=";")
		read_csv_duration = time.time() - start
		count_of_tweets = len(tweets["text"])
		log(f'loaded {count_of_tweets} tweets.')

		log('starting sentiment analysis ...')
		
		SA = pd.DataFrame({ 'TweetId': tweets['id'], 'CreatedAt': tweets['created_at'] })

		log(f'Sentiment Analysis: {classifierInfo.Name}')
		start = time.time()
		doTheModificationsInSteps(tweets, 'text', SA, f'SA_{classifierInfo.Abbreviation}', clf.predict, 100000)
		#SA[f'SA_{classifierInfo.Abbreviation}'] = clf.predict(tweets['text'])
		SA_duration = time.time() - start
		log(f'Sentiment Analysis: {classifierInfo.Name} finished in {SA_duration}')

		log('Sentiment Analysis finished.')

		log(f'write new csv file {newfilename}')

		start = time.time()
		SA.to_csv(newfilename, sep=";")
		write_csv_duration = time.time() - start
		log(f'written csv file {newfilename}')

		myStats = [filename, classifierInfo.Abbreviation, count_of_tweets, read_csv_duration, SA_duration, write_csv_duration]
		stats.append(myStats)
		
		log(myStats)

		log(f'fin {filename} - {classifierInfo.Abbreviation}')

	log('--------------------------------------------')

def doTheModificationsInSteps(df_source, col_source, df_target, col_target, mod_func, step):
  df_target[col_target] = None
  
  for start in range(0, len(df_source), step):
    df_target[col_target].loc[start:start+step-1] = mod_func(df_source[col_source].loc[start:start+step-1])

def GetClassifierItem(name, abbreviation, classifier, options):
	log(f'{name} ... ')
	return ClassifierInfo(name, abbreviation, lambda: GetClassifierPipeline(classifier, options))

def GetTextBlobClassifierItem():
	log('TextBlob ... ')
	return ClassifierInfo('TextBlob', 'TB', lambda: TextBlobClassifier())

class ClassifierInfo:
	def __init__(self, name, abbreviation, buildClassifierCallback):
		self.Name = name
		self.Abbreviation = abbreviation
		self.buildClassifierCallback = buildClassifierCallback
		self.Classifier = None

	def BuildClassifier(self):
		if (self.Classifier is None):
			log(f'start training of classifier "{self.Name}" ...')
			start = time.time()
			self.Classifier = self.buildClassifierCallback()
			duration = time.time() - start
			log(f'trained {self.Name} in {duration}')

		return self.Classifier

class TextBlobClassifier:
	def predict(self, items):
		result = []
		for item in items:
			result.append(self.analyze_sentiment_TB(item))
		
		return result

	def analyze_sentiment_TB(self, tweet):
		cleaned_tweet = ' '.join(re.sub(r"(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)", " ", tweet).split())
		analysis = TextBlob(cleaned_tweet)
		#return analysis.sentiment.polarity
		if analysis.sentiment.polarity > 0:
			return 1
		elif analysis.sentiment.polarity == 0:
			return 0
		else:
			return -1

def main(args):
	if os.path.isfile("results/stats.csv"):
		os.remove("results/stats.csv")

	files = []

	for file in os.listdir('data'):
		if file.endswith(".csv"):
			files.append(os.path.join('data', file))
			log(os.path.join('data', file))

	log('--------------------------------------------')

	stats = []

	if os.path.isdir('results') == False:
		os.makedirs('results')
	
	classifiers = []
	classifiers.append(GetTextBlobClassifierItem())
	classifiers.append(GetClassifierItem('Naive Bayes - (MultinomialNB)', 'NB', MultinomialNB(), { 'clf__alpha': (1e-2, 1e-3) }))
	classifiers.append(GetClassifierItem('Maximum Entropy - (LogisticRegression)', 'ME', LogisticRegression(), {'clf__random_state': [42], 'clf__solver': ['lbfgs'], 'clf__multi_class': ['multinomial'] }))
	classifiers.append(GetClassifierItem('Support Vector Machine - (SGDClassifier)', 'SVM', SGDClassifier(), {'clf__max_iter': [1000], 'clf__tol': (1e-2, 1e-3), 'clf__loss': ['hinge'], 'clf__random_state': [42] }))

	log('--------------------------------------------')
		
	i = 0

	for classifier in classifiers:
		for file in files:
			i = i + 1
			process_file(stats, file, i, len(files) * len(classifiers), classifier)

		del classifier.Classifier
		
	log(stats)

if __name__ == "__main__":
	main(sys.argv[1:])