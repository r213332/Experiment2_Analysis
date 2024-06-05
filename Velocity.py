import pandas as pd
import functions
import numpy as np
from scipy.stats import mannwhitneyu
from scipy.stats import shapiro
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import glob
import os

subject = "subject4"
csvFiles = glob.glob("./data/" + subject + "/*.csv")

AllData = []
for csvFile in csvFiles:
    df = pd.read_csv(csvFile)
    AllData.append(df)

control = []
near = []
far = []

for data in AllData:
    [controlData,nearData,farData] = functions.getVelocity(data)
    control += controlData
    near += nearData
    far += farData


# CSVに出力するためのデータフレームを作成
# ディレクトリが存在しない場合のみ作成
if not os.path.exists("./processedData/" + subject):
    os.makedirs("./processedData/" + subject)
pd.DataFrame({
    'Velocity': control,
}).to_csv("./processedData/" + subject + '/controlVelocity.csv', index=False)
pd.DataFrame({
    'Velocity': near,
}).to_csv("./processedData/" + subject + '/nearVelocity.csv', index=False)
pd.DataFrame({
    'Velocity': far,
}).to_csv("./processedData/" + subject + '/farVelocity.csv', index=False)

# 正規性の検定
# Shapiro-Wilk検定
C_w,C_p = shapiro(control)
N_w,N_p = shapiro(near)
F_w,F_p = shapiro(far)

print("正規性(対照):p=",C_p)
print("正規性(近傍):p=",N_p)
print("正規性(遠方):p=",F_p)