# Pig and Hive processing

These are **new reproducibility scripts** written from the four existing country-level word-frequency CSVs in `data/`. They are not recovered original coursework scripts. Their execution has not been verified in a Pig/Hive runtime.

## Input
Each CSV has the fields `country,word,word_count,word_length`. Each row represents a distinct word with its frequency, not an individual word occurrence.

## Pig
From the repository root, with Apache Pig installed:

```bash
pig -x local -param INPUT_DIR=data -param OUTPUT_DIR=output/pig pig/anthem_analysis.pig
```

Remove the output directory before rerunning: Pig STORE requires a new output location.

## Hive
Upload each source CSV to a separate HDFS directory:

```bash
hdfs dfs -mkdir -p /user/$USER/anthems/belgie /user/$USER/anthems/duitsland /user/$USER/anthems/frankrijk /user/$USER/anthems/nederland
hdfs dfs -put -f data/belgie_words.csv /user/$USER/anthems/belgie/
hdfs dfs -put -f data/duitsland_words.csv /user/$USER/anthems/duitsland/
hdfs dfs -put -f data/frankrijk_words.csv /user/$USER/anthems/frankrijk/
hdfs dfs -put -f data/nederland_words.csv /user/$USER/anthems/nederland/
hive --hiveconf base_path=/user/YOUR_USERNAME/anthems -f hive/anthem_analysis.hql
```

Replace YOUR_USERNAME with your HDFS username.

## Definitions and limitations
Total words = SUM(word_count). Unique words = count of distinct word strings per country. Vocabulary richness = unique words / total occurrences. Weighted average word length = SUM(word_length * word_count) / SUM(word_count).

The original Power BI measure AVERAGE(word_length) is an unweighted average over word rows, so it has a different interpretation. These scripts analyse the already-tokenized CSVs; they do not reproduce extraction or tokenization of the full anthem texts. No Hadoop execution results are claimed.
