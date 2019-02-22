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
from sklearn.metrics import accuracy_score, f1_score, confusion_matrix
from nltk.corpus import stopwords
from nltk.stem.snowball import SnowballStemmer
from nltk.stem.wordnet import WordNetLemmatizer
from nltk.tokenize import TweetTokenizer

def preprocess_text(texts):
  log(f'preprocessing text ({len(texts)}) ...')
  stemmer = nltk.stem.snowball.SnowballStemmer('english')
  wnl = WordNetLemmatizer()
  stop_words = set(stopwords.words('english'))
  tknzr = TweetTokenizer()
  processed_text = []
  for text in texts:
    #if text.startswith('RT @'): continue
    # remove @user, urls
    text = re.sub(r'(@\w+)', 'USER', text, flags=re.MULTILINE)
    text = re.sub(r'(\w+:\/\/\S+)', 'URI', text, flags=re.MULTILINE)
    # replace 2 or more consecutive characters with one character
    text = re.sub(r'((.)\2+)', r'\2', text, flags=re.MULTILINE)
    #text = re.sub(r'([^0-9A-Za-z \t])', ' ', text, flags=re.MULTILINE)
    text = re.sub(r'\?', ' QUESTION ', text, flags=re.MULTILINE)
    text = re.sub(r'\!', ' EXCLAMATION ', text, flags=re.MULTILINE)
    # remove # from hashtags
    text = re.sub(r'#(\w+)', r'\1', text, flags=re.MULTILINE)
    # perform some spelling correction due to lazy twitter users
    #text = TextBlob(text).correct() #this may destroys first the performance second the hashtags such as "#bestday" which becomes "#betray"
    processed_text.append(str((" ".join([stemmer.stem(wnl.lemmatize(word.lower())) for word in tknzr.tokenize(str(text)) if word not in stop_words]))))
  
  log(f'preprocessing finished ({len(processed_text)})')
  return processed_text

def GetClassifierPipeline(clf, clf_params):
  negative_tweets = nltk.corpus.twitter_samples.strings("negative_tweets.json")
  positive_tweets = nltk.corpus.twitter_samples.strings("positive_tweets.json")
  tweets = preprocess_text(negative_tweets + positive_tweets)
  
  labels = np.empty(len(tweets))
  labels[:len(negative_tweets)] = -1
  labels[len(negative_tweets):] = 1
  
  x_train, x_test, y_train, y_test = train_test_split(tweets, labels, test_size=0.2, random_state=42)
  
  text_clf = Pipeline([('vect', CountVectorizer()), ('tfidf', TfidfTransformer()), ('clf', clf)])
  parameters = { 
	  'vect__ngram_range': [(1, 1), (1, 2), (1, 3), (1, 4)], 
	  'vect__stop_words': [None],
	  'vect__binary': [True, False],
	  'tfidf__use_idf': (True, False), 
	  'tfidf__smooth_idf': [True], 
	  'tfidf__norm': ['l1', 'l2', None],
	  **clf_params }
  
  gs_clf = GridSearchCV(text_clf, parameters, cv=5, iid=False, scoring='accuracy', verbose=1, n_jobs=-1)
  
  start = time.time()
  gs_clf.fit(x_train, y_train)
  end = time.time()
  log(f'training the classifier finished in {end - start}')
   
  print(gs_clf.best_estimator_)  
  print('Best Score: %.5f' % gs_clf.best_score_)
  
  predicted = gs_clf.predict(x_test)
  
  print("Accuracy: {:.2f}%".format(accuracy_score(y_test, predicted) * 100))
  print("F1 Score: {:.2f}".format(f1_score(y_test, predicted) * 100))
  print("Confusion Matrix:\n", confusion_matrix(y_test, predicted))
  
  return gs_clf

def log(text):
  print(f'{datetime.datetime.now()} > {text}')
  
def process_file_standardize(filename, processed_files):
  newfilename = filename[:-4] + '_cleaned.csv'
  
  if newfilename in processed_files:
    log(f'skipping {filename} preprocessing as {newfilename} already exists!')
    return

  log(f'start preprocessing {filename} ...')
  start = time.time()
  tweets = pd.read_csv(filename, sep=";")
  read_csv_duration = time.time() - start
  count_of_tweets = len(tweets)
  log(f'loaded {count_of_tweets} tweets.')
  
  tweets['processed_text'] = preprocess_text(tweets['text'])
  tweets = tweets.drop(['text', 'from_user_name'], axis=1)
  
  tweets.to_csv(newfilename, sep=";")
  log(f'finished preprocessing and saved file {newfilename}')
  processed_files.append(newfilename)

def process_file_sentiment(stats, filename, currentfile, totalcountoffiles, classifierInfo):
  log(f'start processing of file {currentfile}/{totalcountoffiles} ({filename}) ...')
  
  newfilename = filename[:-12] + f'_pol_{classifierInfo.Abbreviation}.csv'
  newfilename = 'results/' + newfilename[5:]
  
  if os.path.isfile(newfilename):
    log(f'file {newfilename} already there ..')
  else:
    clf = classifierInfo.BuildClassifier()
    
    start = time.time()
    tweets = pd.read_csv(filename, sep=";")
    read_csv_duration = time.time() - start
    count_of_tweets = len(tweets)
    log(f'loaded {count_of_tweets} tweets.')
    
    log('starting sentiment analysis ...')
    
    SA = pd.DataFrame({ 'TweetId': tweets['id'], 'CreatedAt': tweets['created_at'] })
       
    log(f'Sentiment Analysis: {classifierInfo.Name}')
    start = time.time()
    doTheModificationsInSteps(tweets, 'processed_text', SA, f'SA_{classifierInfo.Abbreviation}', clf.predict, 100000)
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
    analysis = TextBlob(tweet)
    if analysis.sentiment.polarity > 0:
      return 1
    elif analysis.sentiment.polarity < 0:
      return -1
    else:
      return 0

def main(args):
  if os.path.isfile("results/stats.csv"):
    os.remove("results/stats.csv")
  
  original_files = []
  preprocessed_files = []
    
  for file in os.listdir('data'):
    if file.endswith("_cleaned.csv"):
      preprocessed_files.append(os.path.join('data', file))
      log(f"found cleaned csv: {os.path.join('data', file)}")
    elif file.endswith(".csv"):
      original_files.append(os.path.join('data', file))
      log(f"found original csv: {os.path.join('data', file)}")
  
  log('--------------------------------------------')
  
  stats = []
  
  if os.path.isdir('results') == False:
    os.makedirs('results')
  
  classifiers = []
  classifiers.append(GetTextBlobClassifierItem())
  classifiers.append(GetClassifierItem('Naive Bayes - (MultinomialNB)', 'NB', MultinomialNB(), { 'clf__alpha': (1e-2, 1e-3) }))
  classifiers.append(GetClassifierItem('Maximum Entropy - (LogisticRegression)', 'ME', LogisticRegression(), {'clf__random_state': [42], 'clf__solver': ['liblinear','lbfgs','sag','saga'], 'clf__multi_class': ['auto'] }))
  classifiers.append(GetClassifierItem('Support Vector Machine - (SGDClassifier)', 'SVM', SGDClassifier(), {'clf__max_iter': [2000], 'clf__tol': (1e-2, 1e-3), 'clf__loss': ['hinge'], 'clf__random_state': [42] }))
  
  log('--------------------------------------------')
  
  i = 0
  
  for file in original_files:
    process_file_standardize(file, preprocessed_files)
	
  log('--------------------------------------------')
  
  for classifier in classifiers:
    for file in preprocessed_files:
      i = i + 1
      process_file_sentiment(stats, file, i, len(preprocessed_files) * len(classifiers), classifier)
    
    del classifier.Classifier
  
  log(stats)

if __name__ == "__main__":
  main(sys.argv[1:])