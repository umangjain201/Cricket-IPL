#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
get_ipython().run_line_magic('matplotlib', 'inline')
import calendar as cld
import mysql.connector  
import numpy as np


# In[2]:


import glob
import os


# Merging csv files (>950) for match specific info

# In[3]:


all_files = glob.glob("E:/Portfolio Project/Data/Cricksheet IPL/ipl_csv2/*_info.csv")
li = []
for file in all_files:
    df = pd.read_csv(file, index_col=False, header=None, on_bad_lines='skip', skiprows=[0,1]).drop(0, axis=1).T
    df.columns = df.loc[1]
    df = df.drop([1], axis = 0)
    file_name = str(file).split('\\')[1].split('_')[0]
    df.insert(0, 'Match_ID', file_name)
    df = df.reset_index(drop=True)
    columns = list(df.columns)
    if 'winner_runs' in columns:
        df['Margin'] = df['winner_runs']
        df['Margin_Type'] = 'runs'
        
    elif 'winner_wickets' in columns:
        df['Margin'] = df['winner_wickets']
        df['Margin_Type'] = 'wickets'
        
    elif (('winner' not in columns) and ('outcome' in columns)):
        df['winner'] = None
        df['Margin'] = 0
        df['player_of_match'] = None
        df['Margin_Type'] = 'Tie'
        
    df = df[['Match_ID', 'team', 'season', 'date',
             'venue', 'city', 'toss_winner', 'toss_decision',
             'winner', 'Margin', 'Margin_Type', 'player_of_match']]
    df.set_index('Match_ID')
    li.append(df)
match_info = pd.concat(li, axis=0, ignore_index=True)


# Cleaning 'season' column

# In[4]:


match_info.loc[match_info['season'] == '2007/08', 'season'] = '2008'
match_info.loc[match_info['season'] == '2009/10', 'season'] = '2010'
match_info.loc[match_info['season'] == '2020/21', 'season'] = '2020'
match_info.season.unique()


# Checking 'venue' column

# In[5]:


match_info.venue.unique()


# Cleaning 'venue' column & removing duplicates

# In[6]:


match_info.loc[match_info['venue'] == 'Arun Jaitley Stadium, Delhi', 'venue'] = 'Arun Jaitley Stadium'
match_info.loc[match_info['venue'] == 'Brabourne Stadium, Mumbai', 'venue'] = 'Brabourne Stadium'
match_info.loc[match_info['venue'] == 'Dr DY Patil Sports Academy, Mumbai', 'venue'] = 'Dr DY Patil Sports Academy'
match_info.loc[match_info['venue'] == 'Eden Gardens, Kolkata', 'venue'] = 'Eden Gardens'
match_info.loc[match_info['venue'] == 'M.Chinnaswamy Stadium', 'venue'] = 'M Chinnaswamy Stadium'
match_info.loc[match_info['venue'] == 'Rajiv Gandhi International Stadium, Uppal', 'venue'] = 'Rajiv Gandhi International Stadium'
match_info.loc[match_info['venue'] == 'Wankhede Stadium, Mumbai', 'venue'] = 'Wankhede Stadium'
match_info.loc[match_info['venue'] == 'Zayed Cricket Stadium, Abu Dhabi', 'venue'] = 'Arun Jaitley Stadium'
match_info.loc[match_info['venue'] == 'Feroz Shah Kotla', 'venue'] = 'Arun Jaitley Stadium'
match_info.loc[match_info['venue'].isin(['MA Chidambaram Stadium, Chepauk', 'MA Chidambaram Stadium, Chepauk, Chennai']), 'venue'] = 'MA Chidambaram Stadium'
match_info.loc[match_info['venue'].isin(['Maharashtra Cricket Association Stadium, Pune', 'Subrata Roy Sahara Stadium']), 'venue'] = 'Maharashtra Cricket Association Stadium'
match_info.loc[match_info['venue'].isin(['Punjab Cricket Association Stadium, Mohali', 'Punjab Cricket Association IS Bindra Stadium, Mohali']), 'venue'] = 'Punjab Cricket Association IS Bindra Stadium'
match_info.venue.unique()


# Filling Empty Cells for column 'city'

# In[7]:


match_info[match_info['city'].isnull()].venue.unique()


# In[8]:


match_info.loc[match_info['venue'] == 'Dubai International Cricket Stadium', 'city'] = 'Dubai'
match_info.loc[match_info['venue'] == 'Sharjah Cricket Stadium', 'city'] = 'Sharjah'
match_info[match_info['city'].isnull()].venue.unique()


# Renaming duplicate columns

# In[9]:


match_info.columns


# In[10]:


match_info.columns.values[1] = 'team1'
match_info.columns.values[2] = 'team2'
match_info.columns


# Changing datatypes of columns

# In[14]:


match_info['date'] = pd.to_datetime(match_info.date)
match_info['Match_ID'] = pd.to_numeric(match_info.Match_ID)
match_info['season'] = pd.to_numeric(match_info.season)
match_info['Margin'] = pd.to_numeric(match_info.Margin)
match_info.info()


# Removing duplicates in column 'team1' & 'team2'

# In[12]:


match_info.replace('Kings XI Punjab', 'Punjab Kings', inplace = True)
match_info.replace('Rising Pune Supergiant', 'Rising Pune Supergiants', inplace = True)


# Saving dataframe to csv file

# In[13]:


match_info.to_csv('matches_info.csv')

