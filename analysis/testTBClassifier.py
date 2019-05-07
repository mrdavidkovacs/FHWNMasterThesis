from tweets_analyzer import *
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

from pprint import pprint

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

def TestClassifier():
  negative_tweets = nltk.corpus.twitter_samples.strings("negative_tweets.json")
  positive_tweets = nltk.corpus.twitter_samples.strings("positive_tweets.json")
  tweets = preprocess_text(negative_tweets + positive_tweets)
  
  labels = np.empty(len(tweets))
  labels[:len(negative_tweets)] = -1
  labels[len(negative_tweets):] = 1
  
  cls = TextBlobClassifier()
  predicted = cls.predict(tweets)
  
  p = np.array(predicted)
  p[p == 0] = 1
  
  print("Accuracy: {:.2f}%".format(accuracy_score(labels, p) * 100))
  print("F1 Score: {:.2f}".format(f1_score(labels, p) * 100))
  print("Confusion Matrix:\n", confusion_matrix(labels, p))

if __name__ == "__main__":
  TestClassifier()