import os
import pandas as pd
import numpy as np
import datetime


data_dir = 'data/SafegraphMobility/H/Hot Springs, AR Metro Area'
census = 'data/Urban Region Census/Region_Demographics/Hot Springs, AR Metro Area.csv'

census_df = pd.read_csv(census, index_col = 0)
census_df = census_df.sort_values(by=['census_tract'])

census_in_region = census_df['commuting_time_less_than_20_minutes'] * 7
census_out_region = (census_df['commuting_time_between_20_and_60_minutes'] + census_df['commuting_time_over_60_minutes']) * 7

date = []
in_region = []
out_region = []

tractid = data_dir + '/TractID_List.csv'
ids = pd.read_csv(tractid, header=None)
ids = ids[0].tolist()

for filename in os.listdir(data_dir):
    if filename == 'TractID_List.csv':
        pass
    else:

        date.append(filename.split('.')[0])

        data = pd.read_csv(data_dir + '/' + filename, header=None)
        in_region_mob = np.diag(data)
        total_mob = np.sum(data, axis=0)
        out_region_mob = total_mob - in_region_mob

        in_region_per = ((in_region_mob / census_in_region).multiply(100)).astype(str) + '%'
        out_region_per = ((out_region_mob / census_out_region).multiply(100)).astype(str) + '%'

        in_region.append(in_region_per)
        out_region.append(out_region_per)

in_region_df = pd.concat(in_region, axis=1)
in_region_df.columns = date
in_region_df = in_region_df.reindex(sorted(in_region_df.columns), axis=1)
in_region_df['new_index'] = ids
in_region_df.set_index('new_index', inplace=True)

out_region_df = pd.concat(out_region, axis=1)
out_region_df.columns = date
out_region_df = out_region_df.reindex(sorted(out_region_df.columns), axis=1)
out_region_df['TractID'] = ids
out_region_df.set_index('TractID', inplace=True)

in_region_df.to_csv(data_dir+'/in_region_percentage_by_week.csv')
out_region_df.to_csv(data_dir+'/out_region_percentage_by_week.csv')