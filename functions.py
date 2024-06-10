import pandas as pd
import random
import numpy as np

def getStimulusShowTimes(data:pd.DataFrame):
    count = 0
    for index in range(1,len(data)):
        row = data.iloc[index]
        prev = data.iloc[index-1]
        if(prev['ShowStimulus'] == 0 and row['ShowStimulus'] == 1):
            count += 1

    return count

def getRT(data:pd.DataFrame):
    initialTime = 0.0
    show = False
    totalShows = 0
    returnData = []
    for index in range(1,len(data)):
        row = data.iloc[index]
        prev = data.iloc[index-1]
        time = row['RealTime'] - initialTime
        if(prev['ShowStimulus'] == 0 and row['ShowStimulus'] == 1):
            totalShows += 1
            initialTime = row['RealTime']
            show = True
            returnData.append({
                'RT': None,
                'HDegree': row['StimulusHorizontalDegree'], 
                'VDegree': row['StimulusVerticalDegree'], 
            })
        if(show and prev['IsRightButtonPressed'] == 0 and row['IsRightButtonPressed'] == 1):
            if(time < 2.0 and time > 0.2):
                returnData[-1]['RT'] = time
            show = False

    return returnData

def getVelocity(data:pd.DataFrame):
    data = data.query('mode != -1')
    initialIndex = 0
    control = []
    near = []
    far = []
    for index in range(1,len(data)):
        row = data.iloc[index]
        prev = data.iloc[index-1]
        if(prev['StimulusOff'] == 1 and row['StimulusOff'] == 1):
            continue
        elif(prev['StimulusOff'] == 1 and row['StimulusOff'] == 0):
            initialIndex = index
        elif(prev['isAsking'] == 0 and row['isAsking'] == 1):
            initialIndex = index
        elif(prev['isAsking'] != row['isAsking'] or prev['StimulusOff'] != row['StimulusOff']):
            sum = 0
            for j in range(initialIndex,index):
                sum += data.iloc[j]['speed[m/s]']
            # print(index - initialIndex)
            meanVelocity = sum / (index - initialIndex)
            if(index - initialIndex >= 100):
                if(prev['mode'] == 0):
                    control.append(meanVelocity)
                elif(prev['mode'] == 1):
                    near.append(meanVelocity)
                elif(prev['mode'] == 2):
                    far.append(meanVelocity)
            initialIndex = index

    return control,near,far

def getQuestionRT(data:pd.DataFrame):
    initialTime = 0.0
    asking = False
    returnData = []
    for index in range(1,len(data)):
        row = data.iloc[index]
        prev = data.iloc[index-1]
        time = row['RealTime'] - initialTime
        if(prev['isAsking'] == 1 and row['isAsking'] == 0):
            initialTime = row['RealTime']
            asking = True
            returnData.append({
                'RT': None,
            })
        if(asking and prev['isAnswering'] == 0 and row['isAnswering'] == 1):
            if(time < 2.0 and time > 0.2):
                returnData[-1]['RT'] = time
            asking = False

    return returnData