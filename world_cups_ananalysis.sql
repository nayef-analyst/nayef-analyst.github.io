/*Q1(squads_2026) How many players are in each position (GK, CB, etc.) across all 2026 squads?*/
SELECT
    COUNT(id) AS id,
    position
FROM dbo.world_cup_2026_squads_new
GROUP BY 
    position ;
/*Q2 Which country has the oldest average squad age, and which has the youngest?*/
SELECT
    TOP 1
    country,
    MAX(age) AS oldest
FROM dbo.world_cup_2026_squads_new
GROUP BY
    country
ORDER BY
    oldest DESC;
SELECT
    TOP 1
    country,
    AVG(age) AS avg_age
FROM dbo.world_cup_2026_squads_new
GROUP BY
    country;
SELECT
    TOP 1
    country,
    MIN(age) AS youngest
FROM dbo.world_cup_2026_squads_new
GROUP BY
    country
ORDER BY
    youngest ASC;
/*Q3 List the top 5 countries by Historical_Goals_Scored*/
SELECT
    TOP 5 
    country,
    Historical_Goals_Scored
FROM dbo.team_summaries_2026;
/*Q4 How many matches were played in each World Cup Year?*/
SELECT
    MatchYear,
    COUNT(MatchYear) AS total_matchies
FROM dbo.WorldCupMatches_selected
GROUP BY 
    MatchYear
ORDER BY
    MatchYear ASC;
/*Q5 What are the top 5 highest-scoring matches?*/
SELECT
    TOP 5
    MatchYear,
    Home_Team_Goals + Away_Team_Goals AS total_goals
FROM dbo.WorldCupMatches_selected;
/*Q6 Produce a squad list with each player's 3-letter ISO code instead of full country name.*/
SELECT
a.name,
b.iso_3_code
FROM dbo.world_cup_2026_squads_new AS a
left join dbo.country_iso_mapping1 AS b
    ON a.country = b.country
/*Q7 For each country, compare its 2026 average age against the average age you calculate yourself from the squads table — do they match?*/
SELECT
    b.country,
    AVG(a.age) AS average_age,
    ROUND(AVG(b._2026_Average_Age),0) AS average_age_2026
FROM dbo.world_cup_2026_squads_new AS a 
left join dbo.team_summaries_2026 AS b 
    ON a.country = b.country 
GROUP BY
    b.country; 
/*Q8 classify each match as "Home Win", "Away Win", or "Draw", then count how many of each occurred per decade*/
SELECT
    (MatchYear/10)*10 AS decade,
    COUNT(*)AS total,
    CASE
        WHEN Home_Team_Goals>Away_Team_Goals THEN 'home win'
        WHEN Away_Team_Goals>Home_Team_Goals THEN 'away win'
        ELSE 'draw'
    END AS winner
FROM dbo.WorldCupMatches_selected
GROUP BY 
    (MatchYear/10)*10 ,
    CASE 
    WHEN Home_Team_Goals > Away_Team_Goals THEN 'home win'
    WHEN Away_Team_Goals > Home_Team_Goals THEN 'away win'
    ELSE 'draw'
END
ORDER BY
    decade;
/*Q9 Which stadiums have hosted more than 10 matches, and what's the average combined goals per match at each?*/
SELECT
    MatchYear,
    AVG(Home_Team_Goals+Away_Team_Goals) as avg_goals,
    CASE
        WHEN COUNT( DISTINCT Stadium) > 10 THEN '10_time_host'
        ELSE 'other'
    END AS Hoster
FROM dbo.WorldCupMatches_selected
GROUP BY
    MatchYear; 
/*Q10 For each shootout (Tournament_Year + Match_Stage + Team_A + Team_B), determine the final winner*/
SELECT
    Tournament_Year,
    Match_Stage,
    Team_A,
    Team_B,
    Shooter_Team AS winner,
    Is_Winning_Kick
FROM dbo.wc_penshoototu_perfected
WHERE Is_Winning_Kick = 1;
/*Q11 What is each goalkeeper's save percentage across all shootouts they appear in for keepers who faced at least 5 kicks?*/
SELECT
    Goalkeeper_Name,
    COUNT(Shoot_Outcome) AS total_outcome,
    CAST(SUM(CASE 
                WHEN Shoot_Outcome = 'saved' THEN 1 
                ELSE 0 
              END) AS FLOAT)/ 
    COUNT(Shoot_outcome)*100 AS perc_outcome
FROM dbo.wc_penshoototu_perfected
GROUP BY
    Goalkeeper_Name 
HAVING
    COUNT(Shoot_Outcome) >= 5
ORDER BY
    total_outcome ASC;


