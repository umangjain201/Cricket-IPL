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


# Coonecting to MySQL server to get refined table data

# In[2]:


try:
    cnx = mysql.connector.connect(user='root', password='Enter paasword here',
                              host='localhost',
                              database='cricket_ipl')
    query = "select * from all_matches;"
    ipl_df = pd.read_sql(query, cnx)
except Exception as e:
    print(str(e))
finally:
     cnx.close()


# In[3]:


ipl_df.info()


# Replacing null values with 0

# In[4]:


ipl_df[['wides','noballs','byes','legbyes','penalty']] = ipl_df[['wides','noballs','byes','legbyes','penalty']
                                                               ].replace(to_replace='',value = '0')


# Changing data types of columns

# In[5]:


ipl_df['match_id'] = pd.to_numeric(ipl_df.match_id)
ipl_df['season'] = pd.to_numeric(ipl_df.season)
ipl_df['start_date'] = pd.to_datetime(ipl_df.start_date)
ipl_df['runs_off_bat'] = pd.to_numeric(ipl_df.runs_off_bat)
ipl_df['extras'] = pd.to_numeric(ipl_df.extras)
ipl_df['wides'] = pd.to_numeric(ipl_df.wides)
ipl_df['noballs'] = pd.to_numeric(ipl_df.noballs)
ipl_df['byes'] = pd.to_numeric(ipl_df.byes)
ipl_df['legbyes'] = pd.to_numeric(ipl_df.legbyes)
ipl_df['penalty'] = pd.to_numeric(ipl_df.penalty)
ipl_df['over_number'] = pd.to_numeric(ipl_df.over_number)
ipl_df['total_runs_per_ball'] = pd.to_numeric(ipl_df.total_runs_per_ball)
ipl_df['ball_number'] = pd.to_numeric(ipl_df.ball_number)
ipl_df.info()


# Deleting unwanted columns

# In[6]:


ipl_df.drop(['other_player_dismissed', 'other_wicket_type'], axis = 1, inplace = True)


# In[7]:


ipl_df.info()


# Saving dataframe to csv file

# In[8]:


ipl_df.to_csv('all_matches.csv')

