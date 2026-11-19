-- HiveQL analysis of four existing CSV datasets. Upload each CSV to a separate HDFS folder.
-- Run: hive --hiveconf base_path=/user/YOUR_USERNAME/anthems -f hive/anthem_analysis.hql
CREATE DATABASE IF NOT EXISTS anthem_portfolio;
USE anthem_portfolio;
CREATE EXTERNAL TABLE IF NOT EXISTS belgium_words(country STRING,word STRING,word_count INT,word_length INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE
LOCATION '${hiveconf:base_path}/belgie' TBLPROPERTIES ('skip.header.line.count'='1');
CREATE EXTERNAL TABLE IF NOT EXISTS germany_words(country STRING,word STRING,word_count INT,word_length INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE
LOCATION '${hiveconf:base_path}/duitsland' TBLPROPERTIES ('skip.header.line.count'='1');
CREATE EXTERNAL TABLE IF NOT EXISTS france_words(country STRING,word STRING,word_count INT,word_length INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE
LOCATION '${hiveconf:base_path}/frankrijk' TBLPROPERTIES ('skip.header.line.count'='1');
CREATE EXTERNAL TABLE IF NOT EXISTS netherlands_words(country STRING,word STRING,word_count INT,word_length INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE
LOCATION '${hiveconf:base_path}/nederland' TBLPROPERTIES ('skip.header.line.count'='1');
CREATE VIEW IF NOT EXISTS all_anthem_words AS
SELECT * FROM belgium_words UNION ALL SELECT * FROM germany_words
UNION ALL SELECT * FROM france_words UNION ALL SELECT * FROM netherlands_words;
SELECT country,SUM(word_count) AS total_words,COUNT(DISTINCT word) AS unique_words,
ROUND(COUNT(DISTINCT word)/CAST(SUM(word_count) AS DOUBLE),4) AS vocabulary_richness,
ROUND(SUM(word_length*word_count)/CAST(SUM(word_count) AS DOUBLE),2) AS weighted_mean_word_length,
MAX(word_length) AS longest_word_length
FROM all_anthem_words GROUP BY country ORDER BY country;
