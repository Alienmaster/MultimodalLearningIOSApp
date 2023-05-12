path_to_articles_file = "./corpus.txt"
path_to_article_files = "./articles/"

with open(path_to_articles_file, "r", encoding="UTF-8") as f:
    next_line_is_title = True
    title = ""
    content = ""
    for line in f:
        if next_line_is_title:
            title = line
            next_line_is_title = False
        elif line == "\n":
            next_line_is_title = True
        else:
            content = content + line
            next_line_is_title = False
        if next_line_is_title:
            article = title + content
            title = title.replace("/", "-")
            with open(f"{path_to_article_files}{title.rstrip()}.txt", "w", encoding="UTF-8") as text_file:
                text_file.write(article)
            title = ""
            content = ""
    article = title + content
    title = title.replace("/", "-")
    with open(f"{path_to_article_files}{title.rstrip()}.txt", "w", encoding="UTF-8") as text_file:
        text_file.write(article)
