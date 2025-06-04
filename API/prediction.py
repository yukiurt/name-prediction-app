import pandas as pd
import numpy as np
import re
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor





data = pd.read_csv("fbi_name_features.csv")
data = data.dropna()  # Ensure no NaN values in the dataset

X = data[[
    'name_length',
    'word_count',
    'has_initials',
    'has_jr_or_sr',
    'vowel_ratio',
    'consonant_ratio',
    'first_letter'
]]


clf_bm = RandomForestClassifier(n_estimators=200, max_depth=5, random_state=42)
clf_bm.fit(X, data['birth_month'])

clf_sex = RandomForestClassifier(n_estimators=200, max_depth=5, random_state=42)
clf_sex.fit(X, data['sex'])

clf_subject = RandomForestClassifier(n_estimators=200, max_depth=5, random_state=42)
clf_subject.fit(X, data['subjects'])

clf_age = RandomForestRegressor(n_estimators=200, max_depth=5, random_state=42)
clf_age.fit(X, data['age_estimate'])

def extract_name_features(name):
    name_clean = name.strip()
    name_length = len(name_clean)
    word_count = len(name_clean.split())
    has_initials = int(bool(re.search(r"\b[A-Z]\.", name_clean)))
    has_jr_or_sr = int(bool(re.search(r"\b(JR|SR)\b", name_clean, flags=re.IGNORECASE)))
    
    vowels = len(re.findall(r"[aeiouAEIOU]", name_clean))
    consonants = len(re.findall(r"[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]", name_clean))
    
    vowel_ratio = vowels / name_length if name_length else 0
    consonant_ratio = consonants / name_length if name_length else 0
    first_letter = name_clean[0].upper() if name_length > 0 else 'A'
    
    # Convert first letter to index (A=0, B=1, ..., Z=25)
    first_letter_index = ord(first_letter) - ord('A')

    return {
        'name_length': name_length,
        'word_count': word_count,
        'has_initials': has_initials,
        'has_jr_or_sr': has_jr_or_sr,
        'vowel_ratio': vowel_ratio,
        'consonant_ratio': consonant_ratio,
        'first_letter': first_letter_index
    }

def predict(name, mode, clf_bm=clf_bm, clf_sex=clf_sex, clf_subject=clf_subject, clf_age=clf_age):
    features = extract_name_features(name)
    x = pd.DataFrame([features])[X.columns] 

    if mode == "birth_month":
        return clf_bm.predict(x)[0]
    elif mode == "sex":
        return clf_sex.predict(x)[0]
    elif mode == "subject":
        return clf_subject.predict(x)[0]
    elif mode == "age":
        return clf_age.predict(x)[0]
    else:
        raise ValueError("Invalid mode")

