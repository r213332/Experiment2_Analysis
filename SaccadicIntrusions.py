import pandas as pd
import functions
import numpy as np
from scipy.stats import mannwhitneyu
from scipy.stats import shapiro
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import glob
import os

plt.close('all')

subject = "testData"
csvFiles = glob.glob("./data/" + subject + "/*.csv")

AllData = []
for csvFile in csvFiles:
    df = pd.read_csv(csvFile)
    AllData.append(df)

control = []
near = []
far = []

for data in AllData:
    controlData, nearData, farData = functions.getSI(data)

    control += controlData
    near += nearData
    far += farData

# # 全視線の動きをグラフ化
control_GazeMovement_all = [[x["angle"],x["SICount"]]for x in control]
near_GazeMovement_all = [[x["angle"],x["SICount"]] for x in near]
far_GazeMovement_all = [[x["angle"],x["SICount"]] for x in far]

# plt.figure()
# plt.title("control")
# for i, gaze_array in enumerate(control_GazeMovement_all):
#     plt.plot(gaze_array[0],label="SIcount: "+str(gaze_array[1]))

# plt.legend()
# # plt.show()

# plt.figure()
# plt.title("near")
# for i, gaze_array in enumerate(near_GazeMovement_all):
#     plt.plot(gaze_array[0],label="SIcount: "+str(gaze_array[1]))

# plt.legend()
# # plt.show()

# plt.figure()
# plt.title("far")
# for i, gaze_array in enumerate(far_GazeMovement_all):
#     plt.plot(gaze_array[0],label="SIcount: "+str(gaze_array[1]))

# plt.legend()
# plt.show()

# CSVに出力するためのデータフレームを作成
# ディレクトリが存在しない場合のみ作成
# if not os.path.exists("./processedData/" + subject):
#     os.makedirs("./processedData/" + subject)

# pd.DataFrame({
#     'RT': [x['RT'] for x in control],
#     'GazeRT': [x['GazeRT'] for x in control],
#     'StimulusHorizontalDegree': [x['StimulusHorizontalDegree'] for x in control],
#     'StimulusVerticalDegree': [x['StimulusVerticalDegree'] for x in control],
#     'InitialGazeDistance': [x['InitialGazeDistance'] for x in control],
# }).to_csv("./processedData/" + subject + '/controlSI.csv', index=False)
# pd.DataFrame({
#     'RT': [x['RT'] for x in near],
#     'GazeRT': [x['GazeRT'] for x in near],
#     'StimulusHorizontalDegree': [x['StimulusHorizontalDegree'] for x in near],
#     'StimulusVerticalDegree': [x['StimulusVerticalDegree'] for x in near],
#     'InitialGazeDistance': [x['InitialGazeDistance'] for x in near],
# }).to_csv("./processedData/" + subject + '/nearSI.csv', index=False)
# pd.DataFrame({
#     'RT': [x['RT'] for x in far],
#     'GazeRT': [x['GazeRT'] for x in far],
#     'StimulusHorizontalDegree': [x['StimulusHorizontalDegree'] for x in far],
#     'StimulusVerticalDegree': [x['StimulusVerticalDegree'] for x in far],
#     'InitialGazeDistance': [x['InitialGazeDistance'] for x in far],
# }).to_csv("./processedData/" + subject + '/farSI.csv', index=False)
