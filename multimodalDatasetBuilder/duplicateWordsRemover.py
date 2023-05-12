from nltk.stem import WordNetLemmatizer

def remove_duplicate_words(words: []) -> []:
    """
    Removes duplicate words from the list if these occur similarly in different forms again
    (e.g., "apple" and "APPLES" are duplicates in this context).
    
    :param [] words: list of words (nouns) to be processed
    :return: list of words (nouns) without duplicates
    :rtype: []
    """
    
    filtered_words = []
    if len(words) > 1:
        wnl = WordNetLemmatizer()
        words_set = set()
        for word in words:
            word_lower = word.lower()
            word_lower_lemmatized = wnl.lemmatize(word_lower)
            if not (word_lower in words_set or word_lower_lemmatized in words_set):
                filtered_words.append(word)
                words_set.add(word_lower)
                words_set.add(word_lower_lemmatized)
    return filtered_words
