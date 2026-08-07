/*q1 How many subjects are in the dataset, split by sex?*/
SELECT
	sex,
	COUNT(sex) AS total_geneder
FROM dbo.screen_time_mental_health 
GROUP BY 
	sex
ORDER BY
	total_geneder DESC;
/*q2 What's the average bdi_total and average screen_time_index overall?*/
SELECT
	AVG(bdi_total) AS avg_bdi,
	AVG(screen_time_index) AS avg_screen_time
FROM dbo.screen_time_mental_health;
/*q3 How many subjects are flagged depressed = 1 vs 0? What % of the sample is that?*/
SELECT
	depressed,
	COUNT(depressed) AS total_depressed
FROM dbo.screen_time_mental_health
GROUP BY 
	depressed;
/*q4 List the top 10 subjects with the highest screen_time_index, along with their bdi_total.*/
SELECT 
	TOP 10
	screen_time_index ,
	bdi_total
FROM dbo.screen_time_mental_health
ORDER BY
	screen_time_index DESC;
/*q5 compare average screen_normal_day_1to6 (table 1) against screen_time_index (table 2) per subject — do they roughly agree?*/
SELECT
	A.subject_id,
	AVG(A.screen_normal_day_1to6) AS screen_normal_day,
	ROUND(AVG(B.screen_time_index) ,0 )AS screen_time_index
FROM dbo.bdi_and_screen_items AS a
left join dbo.screen_time_mental_health AS b
	ON a.subject_id = b.subject_id
GROUP BY
	a.subject_id;
/*q6 Group subjects into screen-time buckets and find the average bdi_total per bucket.*/
SELECT	
	*
FROM
	(SELECT
		subject_id,
		ROUND(screen_time_index,0) AS screen_time_index,
		CASE
			WHEN ROUND(screen_time_index,0) = 6 THEN 'High'
			WHEN ROUND(screen_time_index,0) = 3 THEN 'Medium'
			WHEN ROUND(screen_time_index,0) = 1 THEN 'Low'
			ELSE ''
		END AS Category,
		AVG(bdi_total) over() AS bdi_total
	FROM dbo.screen_time_mental_health) AS screen_time_case
WHERE
	Category <> '';
/*q7 Same as above but bucket by avg_sleep_hours instead — does less sleep correlate with higher bdi_total?*/
SELECT
	COUNT(subject_id) AS total,
	AVG(bdi_total) AS avg_bdi,
	ROUND(avg_sleep_hours,0) AS avg_sleep_hours,
	CASE
		WHEN ROUND(avg_sleep_hours,0) between 10 and 12 THEN 'more than normal'
		WHEN ROUND(avg_sleep_hours,0) between 7 and 9  THEN 'great'
		WHEN ROUND(avg_sleep_hours,0) between 1 and 5 THEN 'less than normal'
		ELSE 'good'
	END AS Category
FROM dbo.screen_time_mental_health 
GROUP BY 
	ROUND(avg_sleep_hours,0) ,
CASE
	WHEN ROUND(avg_sleep_hours,0) between 10 and 12 THEN 'more than normal'
	WHEN ROUND(avg_sleep_hours,0) between 7 and 9  THEN 'great'
	WHEN ROUND(avg_sleep_hours,0) between 1 and 5 THEN 'less than normal'
	ELSE 'good'
END
 ;
/*q8 What is the average social_jetlag_hours for depressed vs. non-depressed subjects?*/
SELECT
	ROUND(AVG(social_jetlag_hours),2) AS avg_social_jetlag_hours , 
	depressed,
	CASE
		WHEN depressed = 0 THEN 'nondepressed'
		WHEN depressed = 1 THEN 'depressed'
	END AS Depression
FROM dbo.screen_time_mental_health 
GROUP BY
	depressed;
/*q9 Rank subjects by bdi_total within each sex group*/
SELECT
	RANK() OVER(PARTITION BY sex ORDER BY bdi_total DESC) AS rank_bdi_total,
	DENSE_RANK() OVER(PARTITION BY sex ORDER BY bdi_total DESC) AS dense_rank_bdi_total,
	sex,
	bdi_total
FROM dbo.screen_time_mental_health ;
/*q10Find subjects whose screen_weekend_1to6 is at least 2 points higher than screen_weekday_1to6 and what's their average bdi_total compared to everyone else?*/
SELECT
	COUNT(a.subject_id) AS count_total_subject_id,
	ROUND(AVG(A.bdi_total),2) AS avg_bdi_total,
	CASE 
		WHEN CAST(b.screen_weekend_1to6 AS INT) - CAST(b.screen_weekday_1to6 AS INT)  >= 2 THEN 'heavy weekend screen user'
		ELSE 'other'
	END AS category
FROM dbo.screen_time_mental_health AS a
left join bdi_and_screen_items AS b
	ON a.subject_id = b.subject_id
GROUP BY
	case 
		WHEN CAST(b.screen_weekend_1to6 AS INT) - CAST(b.screen_weekday_1to6 AS INT)  >=2 THEN 'heavy weekend screen user'
		ELSE 'other'
     END
;

/*q11compute each subject's total across the 21 bdi_item_* columns and check it matches bdi_total in table 2*/
WITH bdi_items AS 
(
SELECT
	subject_id,
	SUM(bdi_item_01+bdi_item_02+bdi_item_03+bdi_item_04+bdi_item_05+bdi_item_06+bdi_item_07+bdi_item_08+bdi_item_09+bdi_item_10+bdi_item_11+bdi_item_12+bdi_item_13+bdi_item_14+bdi_item_15+bdi_item_16+bdi_item_17+bdi_item_18+bdi_item_19+bdi_item_20+bdi_item_21) AS total_bdi2
FROM dbo.bdi_and_screen_items
GROUP BY
	subject_id
)
SELECT
	a.subject_id,
	a.bdi_total,
	b.total_bdi2
FROM dbo.screen_time_mental_health AS a
left join bdi_items AS b
	ON a.subject_id = b.subject_id ;
	
