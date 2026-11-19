-- Reproducible Pig analysis of existing word-frequency CSVs.
-- Run: pig -x local -param INPUT_DIR=data -param OUTPUT_DIR=output/pig pig/anthem_analysis.pig
be = LOAD '$INPUT_DIR/belgie_words.csv' USING PigStorage(',') AS (country:chararray,word:chararray,word_count:int,word_length:int);
de = LOAD '$INPUT_DIR/duitsland_words.csv' USING PigStorage(',') AS (country:chararray,word:chararray,word_count:int,word_length:int);
fr = LOAD '$INPUT_DIR/frankrijk_words.csv' USING PigStorage(',') AS (country:chararray,word:chararray,word_count:int,word_length:int);
nl = LOAD '$INPUT_DIR/nederland_words.csv' USING PigStorage(',') AS (country:chararray,word:chararray,word_count:int,word_length:int);
combined = UNION ONSCHEMA be,de,fr,nl;
words = FILTER combined BY country != 'country' AND word_count IS NOT NULL AND word_length IS NOT NULL;
by_country = GROUP words BY country;
metrics = FOREACH by_country {
  total = SUM(words.word_count);
  distinct_count = COUNT(words);
  weighted_sum = SUM(words.word_count * words.word_length);
  GENERATE group AS country,total AS total_words,distinct_count AS unique_words,
    (double)distinct_count/(double)total AS vocabulary_richness,
    (double)weighted_sum/(double)total AS weighted_mean_word_length;
};
STORE metrics INTO '$OUTPUT_DIR/country_metrics' USING PigStorage(',');
