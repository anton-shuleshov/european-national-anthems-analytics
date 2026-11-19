-- Apache Pig analysis of the four word-frequency CSV datasets.
-- Run from repository root: pig -x local -param INPUT_DIR=data -param OUTPUT_DIR=output/pig pig/anthem_analysis.pig
-- Pig STORE requires an output directory that does not yet exist.
be = LOAD '$INPUT_DIR/belgie_words.csv' USING PigStorage(',') AS (country:chararray,word:chararray,word_count:int,word_length:int);
de = LOAD '$INPUT_DIR/duitsland_words.csv' USING PigStorage(',') AS (country:chararray,word:chararray,word_count:int,word_length:int);
fr = LOAD '$INPUT_DIR/frankrijk_words.csv' USING PigStorage(',') AS (country:chararray,word:chararray,word_count:int,word_length:int);
nl = LOAD '$INPUT_DIR/nederland_words.csv' USING PigStorage(',') AS (country:chararray,word:chararray,word_count:int,word_length:int);
combined = UNION ONSCHEMA be,de,fr,nl;
words = FILTER combined BY country IS NOT NULL AND country != 'country' AND word IS NOT NULL AND word_count IS NOT NULL AND word_length IS NOT NULL AND word_count > 0;
weighted_rows = FOREACH words GENERATE country,word,word_count,word_length,(long)word_count * (long)word_length AS weighted_length;
by_country = GROUP weighted_rows BY country;
metrics = FOREACH by_country {
  total = SUM(weighted_rows.word_count);
  distinct_count = COUNT(weighted_rows);
  weighted_sum = SUM(weighted_rows.weighted_length);
  GENERATE group AS country,total AS total_words,distinct_count AS distinct_word_rows,
    (double)distinct_count/(double)total AS vocabulary_richness,
    (double)weighted_sum/(double)total AS weighted_mean_word_length;
};
STORE metrics INTO '$OUTPUT_DIR/country_metrics' USING PigStorage(',');
