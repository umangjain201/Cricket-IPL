# Importing data in sql

Alter table all_matches
modify column ball text,
modify column extras text,
modify column innings text,
modify column match_id text,
modify column runs_off_bat text;

Alter table all_matches
modify column innings int;

/* Alter table all_matches
modify column ball_number double,
modify column byes int,
modify column noballs int,
modify column legbyes int,
modify column extras int,
modify column over_number int,
modify column penalty int,
modify column total_runs_per_ball int,
modify column wides int,
modify column innings int,
modify column match_id int,
modify column runs_off_bat int; */


SET GLOBAL local_infile=1;

LOAD DATA LOCAL INFILE 'E:/Portfolio Project/Data/Cricksheet IPL/ipl_csv2/all_matches.csv' INTO TABLE all_matches
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

 delete from all_matches;

select * from all_matches;
select count(*) from all_matches;

# re- importing data
LOAD DATA LOCAL INFILE 'E:/Portfolio Project/Data/Cricksheet IPL/ipl_csv2/all_matches.csv' INTO TABLE all_matches
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

#Checking null values if any

select * 
from all_matches 
where match_id=NULL 
or season=null
or start_date=null
or venue=null
or innings=null
or ball=null
or batting_team=null
or bowling_team=null
or striker=null
or non_striker=null
or bowler=null
or runs_off_bat=null
or extras=null;

#cleaning data - wicket_type
select *
from all_matches 
where wicket_type in (5,1,4,2);

#cleaning data - innings
select *
from all_matches 
where innings not in (1,2,3,4,5,6)
and 
wicket_type not in ('caught','bowled','run out', 'lbw','',
'retired hurt', 'stumped','caught and bowled','hit wicket','obstructing the field');

#checking data penalty
select * 
from all_matches
where penalty not in (""); 

# checking other_player_dismissed an other_wicket_type
select * 
from all_matches 
where other_player_dismissed not in ("")
or other_wicket_type not in ("");

# checking wicket_type
select *
from all_matches 
where wicket_type not in ('caught','bowled','run out', 'lbw','','retired out',
'retired hurt', 'stumped','caught and bowled','hit wicket','obstructing the field');

#checking extras
select *
from all_matches
where wides+noballs+byes+legbyes+penalty > extras;

select *
from all_matches 
where wides*noballs*byes*legbyes*penalty !=0 ;



# Re structring data

# separating balls & overs
select match_id,ball,floor(ball)+1,round((ball - floor(ball)),1) 
from all_matches
where round((ball - floor(ball)),1) not in (0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9)
or (floor(ball)+1)>20;

select match_id,ball,floor(ball)+1,round((ball - floor(ball)),1) 
from all_matches;

alter table all_matches
add column over_number text as (floor(ball)+1),
add column ball_number text as (round((ball - floor(ball)),1));

select match_id, season, innings, ball, over_number, ball_number 
from all_matches 
where over_number is null
or ball_number is null;

select match_id, season, innings, ball, over_number, ball_number 
from all_matches
where ball-ball_number not between 0 and 19
or over_number != floor(ball)+1;


#restructuring - creating total_runs_per_ball as runs_off_bat+extras

select * 
from all_matches 
where runs_off_bat !=0 
		and extras not in (0);
        
select match_id, total_runs_per_ball 
from all_matches
where runs_off_bat !=0 
		and extras not in (0);

alter table all_matches
add column total_runs_per_ball text 
as (runs_off_bat+extras);
	
    
    
# Hypothesis - no. of extras

select season,
sum(wides) as Wides,
sum(noballs) as Noballs,
sum(byes) as Byes,
sum(legbyes) as Legbyes,
sum(penalty) as Penalty,
sum(extras) as total_extras,
sum(extras)-(lag(sum(extras)) over (order by season)) as diff_with_prev_season
from all_matches
group by season
order by season;

# Hypothesis - run rate over mid over has increased over the years

with 
	mid_15_overs (overs, runs, season) as (select max(round(over_number,0))-6, sum(total_runs_per_ball), season from all_matches
		where over_number between 7 and 15
		group by match_id, innings),
	First_6_overs (overs, runs, season) as (select max(round(over_number,0)), sum(total_runs_per_ball), season from all_matches
		where over_number between 1 and 6
		group by match_id, innings),
	Slog_Overs (overs, runs, season) as (select max(round(over_number,0))-15, sum(total_runs_per_ball), season from all_matches
		where over_number between 16 and 20
		group by match_id, innings)
select mid_15_overs.season,
/*sum(First_6_overs.runs) as runs_between_over_1_and_6,
sum(First_6_overs.overs) as total_overs_1_and_6,
sum(mid_15_overs.runs) as runs_between_over_5_and_15,
sum(mid_15_overs.overs) as total_overs_5_and_15,
sum(Slog_Overs.runs) as runs_between_over_16_and_20,
sum(Slog_Overs.overs) as total_overs_16_and_20,*/
round(sum(First_6_overs.runs)/sum(First_6_overs.overs),2) as Initial_run_rate,
round(sum(mid_15_overs.runs)/sum(mid_15_overs.overs),2) as mid_run_rate,
round(sum(Slog_Overs.runs)/sum(Slog_Overs.overs),2) as Slog_Overs_run_rate
from mid_15_overs, First_6_overs, Slog_Overs
where mid_15_overs.season = First_6_overs.season
and Slog_Overs.season = mid_15_overs.season
group by mid_15_overs.season
order by mid_15_overs.season;



# Hypothesis - T20 is a young people's game
# Hypothesis - mid overs are for stabilisation

select season, 
	count(case when over_number between 1 and 6 then wicket_type end) as Wickets_Initial_Overs_1_to_6,
	count(case when over_number between 7 and 15 then wicket_type end) as Wickets_Mid_Overs_7_to_15,
    count(case when over_number between 16 and 20 then wicket_type end) as Wickets_Final_Overs_16_to_20,
    count(case when over_number between 1 and 6 then wicket_type end) + count(case when over_number between 16 and 20 then wicket_type end) as Wickets_Intial_and_Final_Overs
from all_matches
group by season
order by season;


# Hypothesis - characteristicks per venue

#avg score per venue
-- select substring(venue, 1, locate(' ', venue)-1), substring(venue, locate(' ', venue), N)
select substring(venue, 1, if (Position("," in venue) = 0, length(venue), Position("," in venue)-1)) as Venue,
	sum(total_runs_per_ball) as Total_Runs, 
	count(distinct match_id) as Total_Matches, 
    round(sum(total_runs_per_ball)/(2*count(distinct match_id)),2) as avg_score_per_innings
from all_matches
group by substring(venue, 1, if (Position("," in venue) = 0, length(venue), Position("," in venue)-1))
order by substring(venue, 1, if (Position("," in venue) = 0, length(venue), Position("," in venue)-1));

select venue, 
	sum(total_runs_per_ball), 
	count(distinct match_id), 
    round(sum(total_runs_per_ball)/(2*count(distinct match_id)),2) as avg_score_per_match
from all_matches
group by venue
order by venue;


#avg wickets per venue

select substring(venue, 1, if (Position("," in venue) = 0, length(venue), Position("," in venue)-1)) as venue,
	count(wicket_type) as Total_wickets, 
	count(distinct match_id) as Total_matches, 
    round(count(wicket_type)/(2*count(distinct match_id)),2) as avg_wickets_per_innings
from all_matches
where wicket_type not in ("")
group by substring(venue, 1, if (Position("," in venue) = 0, length(venue), Position("," in venue)-1))
order by substring(venue, 1, if (Position("," in venue) = 0, length(venue), Position("," in venue)-1));


#Hypothesis - 30s & 40s are more important than 50s

# Highest Run Getter of all time
select striker, sum(runs_off_bat) as Total_Runs
from all_matches
group by striker
order by Total_Runs desc
Limit 10;

# Highest Run Getter per season

select season, 
		striker,
		Runs.Total_Runs 
from 
	(
	select season, 
			striker,
			sum(runs_off_bat) as Total_Runs,
			row_number() over (partition by season order by sum(runs_off_bat) desc) as Ranks
	from all_matches
	group by season, striker
	order by season, Total_Runs desc
	)Runs
where Runs.ranks=1;

# Highest Wicket taker of all time
select bowler, count(wicket_type) as Total_Wickets
from all_matches
where wicket_type in ('caught','bowled', 'lbw', 'stumped','caught and bowled','hit wicket','obstructing the field')
group by bowler
order by Total_Wickets desc
Limit 10;

# Highest Wicket taker per season
select season, bowler, Wickets.Total_Wickets from
	(select 
		season, bowler, count(wicket_type) as Total_Wickets,
		row_number() over (partition by season order by count(wicket_type) desc) as Ranks
	from all_matches
	where wicket_type in ('caught','bowled', 'lbw', 'stumped','caught and bowled','hit wicket','obstructing the field')
	group by bowler, season
	order by season, Total_Wickets desc) Wickets
where Wickets.Ranks=1;

# CHaracteristicks per Team

select batting_team,
		count(distinct match_id), 
		sum(total_runs_per_ball),
        sum(total_runs_per_ball)/count(distinct match_id)
from all_matches
group by batting_team
order by batting_team;
