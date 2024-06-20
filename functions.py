import pandas as pd
import random
import numpy as np


def getStimulusShowTimes(data: pd.DataFrame):
    count = 0
    for index in range(1, len(data)):
        row = data.iloc[index]
        prev = data.iloc[index - 1]
        if prev["ShowStimulus"] == 0 and row["ShowStimulus"] == 1:
            count += 1

    return count


def getRT(data: pd.DataFrame):
    initialIndex = 1
    show = False
    totalShows = 0
    returnData = []
    for index in range(1, len(data)):
        row = data.iloc[index]
        prev = data.iloc[index - 1]
        time = row["RealTime"] - data.iloc[initialIndex]["RealTime"]
        if prev["ShowStimulus"] == 0 and row["ShowStimulus"] == 1:
            totalShows += 1
            initialIndex = index
            show = True
            returnData.append(
                {
                    "RT": None,
                    "MeanVelocity": None,
                    "HDegree": row["StimulusHorizontalDegree"],
                    "VDegree": row["StimulusVerticalDegree"],
                }
            )
        if (
            show
            and prev["IsRightButtonPressed"] == 0
            and row["IsRightButtonPressed"] == 1
        ):
            if time < 2.0 and time > 0.2:
                returnData[-1]["RT"] = time
                velocity_sum = 0
                for j in range(initialIndex, index):
                    velocity_sum += data.iloc[j]["speed[m/s]"]
                returnData[-1]["MeanVelocity"] = velocity_sum / (index - initialIndex)

            show = False

    return returnData


def extendedGetRT(data: pd.DataFrame):
    deltaTime = 0
    initialIndex = 1
    show = False
    gaze = False
    returnData = []
    prevDegree = None
    degree = None
    gazeOrigin = None
    gazeDirection = None
    stimulusPosition = None
    stimulusDireciton = None
    sitmulusDistance = 0.5
    StimulusHorizontalRadian = 0
    StimulusVerticalRadian = 0
    GazeMovement = []
    for index in range(1, len(data)):
        row = data.iloc[index]
        prev = data.iloc[index - 1]
        deltaTime = row["RealTime"] - prev["RealTime"]
        time = row["RealTime"] - data.iloc[initialIndex]["RealTime"]
        if prev["ShowStimulus"] == 0 and row["ShowStimulus"] == 1:
            initialIndex = index
            show = True
            gaze = True
            gazeOrigin = None
            prevDegree = None
            degree = None
            GazeMovement = []
            StimulusHorizontalRadian = np.deg2rad(row["StimulusHorizontalDegree"])
            StimulusVerticalRadian = np.deg2rad(row["StimulusVerticalDegree"])
            returnData.append(
                {
                    "StimulusShowTime": row["RealTime"],
                    "StimulusHorizontalDegree": row["StimulusHorizontalDegree"],
                    "StimulusVerticalDegree": row["StimulusVerticalDegree"],
                    "RT": None,
                    "GazeMovement": None,
                    "GazeRT": None,
                    "InitialGazeDistance": None,
                }
            )
        elif (
            show
            and prev["IsRightButtonPressed"] == 0
            and row["IsRightButtonPressed"] == 1
        ):
            if time < 2.0 and time > 0.2:
                returnData[-1]["RT"] = time
            show = False
        elif gaze and time >= 2.0 and returnData[-1]["RT"] != None:
            returnData[-1]["GazeMovement"] = linear_interpolate_none_values(
                GazeMovement
            )
            gaze = False

        if gaze:
            if row["GazeRay_IsValid"] == 1:
                # 頭部の位置と視線を複合計算
                x_2 = (
                    row["GazeRay_Direction_x"] ** 2
                    + row["GazeRay_Direction_y"] ** 2
                    + row["GazeRay_Direction_z"] ** 2
                )
                x_1 = (
                    2 * row["GazeRay_Origin_x"] * row["GazeRay_Direction_x"]
                    + 2 * row["GazeRay_Origin_y"] * row["GazeRay_Direction_y"]
                    + 2 * row["GazeRay_Origin_z"] * row["GazeRay_Direction_z"]
                )
                x_0 = (
                    sitmulusDistance**2
                    - row["GazeRay_Origin_x"] ** 2
                    - row["GazeRay_Origin_y"] ** 2
                    - row["GazeRay_Origin_z"] ** 2
                )
                x = np.roots([x_2, x_1, x_0])
                x = x[x >= 0]
                # print(x)
                calcuratedGazeDirection = np.array(
                    [
                        row["GazeRay_Origin_x"] + x[0] * row["GazeRay_Direction_x"],
                        row["GazeRay_Origin_y"] + x[0] * row["GazeRay_Direction_y"],
                        row["GazeRay_Origin_z"] + x[0] * row["GazeRay_Direction_z"],
                    ]
                )
                # gazeOrigin = np.array([row['GazeRay_Origin_x'],row['GazeRay_Origin_y'],row['GazeRay_Origin_z']])
                # gazeDirection = np.array([row['GazeRay_Direction_x'],row['GazeRay_Direction_y'],row['GazeRay_Direction_z']])
                stimulusPosition_y = np.sin(StimulusVerticalRadian) * sitmulusDistance
                stimulusTempDistance = np.cos(StimulusVerticalRadian) * sitmulusDistance
                stimulusPosition_x = (
                    -1 * stimulusTempDistance * np.sin(StimulusHorizontalRadian)
                )
                stimulusPosition_z = stimulusTempDistance * np.cos(
                    StimulusHorizontalRadian
                )
                stimulusPosition = np.array(
                    [stimulusPosition_x, stimulusPosition_y, stimulusPosition_z]
                )
                # stimulusDireciton = stimulusPosition - gazeOrigin
                i = np.inner(stimulusPosition, calcuratedGazeDirection)
                n = np.linalg.norm(stimulusPosition) * np.linalg.norm(
                    calcuratedGazeDirection
                )
                c = i / n
                degree = np.rad2deg(np.arccos(np.clip(c, -1.0, 1.0)))
                if returnData[-1]["InitialGazeDistance"] == None:
                    returnData[-1]["InitialGazeDistance"] = degree
                if (
                    prevDegree != None
                    and returnData[-1]["GazeRT"] == None
                    and deltaTime != 0
                ):
                    if (prevDegree - degree) / deltaTime > 200:
                        returnData[-1]["GazeRT"] = time
            elif row["GazeRay_IsValid"] == 0:
                degree = None
            GazeMovement.append(degree)
            prevDegree = degree

    return returnData


# test = [0,1,2,3,None,5,6,None,None,None,10,11,12,13,14,None,None,None,18,19,20]
# None値を線形補間で置き換える関数
def linear_interpolate_none_values(data):
    for i, value in enumerate(data):
        if value is None:
            # 直前の非None値を見つける
            prev_index = i - 1
            while prev_index >= 0 and data[prev_index] is None:
                prev_index -= 1

            # 直後の非None値を見つける
            next_index = i + 1
            while next_index < len(data) and data[next_index] is None:
                next_index += 1

            # 直前と直後の値で線形補間を行う
            if prev_index >= 0 and next_index < len(data):
                prev_value = data[prev_index]
                next_value = data[next_index]
                data[i] = prev_value + (next_value - prev_value) * (i - prev_index) / (
                    next_index - prev_index
                )

    return data


# print(linear_interpolate_none_values(test))


# TODO: 以下の関数を実装する 方針を決める 刺激提示中に限定するかしないか
def getSI(data: pd.DataFrame):
    data = data.query("mode != -1")
    gaze = False
    controlData = []
    nearData = []
    farData = []
    nowAngleData = []
    gazeOrigin = None
    gazeDirection = None
    for index in range(1, len(data)):
        row = data.iloc[index]
        prev = data.iloc[index - 1]
        if row["GazeRay_IsValid"] == 1:
            gazeOrigin = np.array(
                [
                    row["GazeRay_Origin_x"],
                    row["GazeRay_Origin_y"],
                    row["GazeRay_Origin_z"],
                ]
            )
            gazeDirection = np.array(
                [
                    row["GazeRay_Direction_x"],
                    row["GazeRay_Direction_y"],
                    row["GazeRay_Direction_z"],
                ]
            )
        else:
            gazeOrigin = None
            gazeDirection = None
        # 計算しない
        if prev["StimulusOff"] == 1 and row["StimulusOff"] == 1:
            continue
        ## 開始条件
        # 刺激が表示される区間になったとき
        elif prev["StimulusOff"] == 1 and row["StimulusOff"] == 0:
            # かつ、対照条件であるか、質問中であったとき
            if row["mode"] == 0 or row["isAsking"] == 1:
                gaze = True
                nowAngleData.append(getAngle(gazeDirection, gazeOrigin))
        # 質問されているとき
        elif prev["isAsking"] == 0 and row["isAsking"] == 1 and row["StimulusOff"] == 0:
            gaze = True
            nowAngleData.append(getAngle(gazeDirection, gazeOrigin))
        # 条件が切り替わり、それが対照条件であったとき
        elif prev["mode"] != 0 and row["mode"] == 0 and row["StimulusOff"] == 0:
            gaze = True
            nowAngleData.append(getAngle(gazeDirection, gazeOrigin))
        # 終了条件
        elif gaze and (
            prev["isAsking"] != row["isAsking"]
            or prev["StimulusOff"] != row["StimulusOff"]
            or (prev["mode"] != row["mode"] and prev["modo"] == 0)
        ):
            # print(len(nowAngleData))
            if prev["mode"] == 0:
                controlData.append(
                    {
                        "angle": linear_interpolate_none_values(nowAngleData),
                    }
                )
            elif prev["mode"] == 1:
                nearData.append(
                    {
                        "angle": linear_interpolate_none_values(nowAngleData),
                    }
                )
            elif prev["mode"] == 2:
                farData.append(
                    {
                        "angle": linear_interpolate_none_values(nowAngleData),
                    }
                )
            gaze = False
            nowAngleData = []
        # 継続条件
        elif gaze:
            nowAngleData.append(getAngle(gazeDirection, gazeOrigin))

    return controlData, nearData, farData


def getAngle(vector1, vector2):

    if vector1 is None and vector2 is None:
        return None
    i = np.inner(vector1, vector2)
    n = np.linalg.norm(vector1) * np.linalg.norm(vector2)
    c = i / n
    degree = np.rad2deg(np.arccos(np.clip(c, -1.0, 1.0)))
    return degree


def getVelocity(data: pd.DataFrame):
    data = data.query("mode != -1")
    initialIndex = 0
    control = []
    near = []
    far = []
    for index in range(1, len(data)):
        row = data.iloc[index]
        prev = data.iloc[index - 1]
        if prev["StimulusOff"] == 1 and row["StimulusOff"] == 1:
            continue
        elif prev["StimulusOff"] == 1 and row["StimulusOff"] == 0:
            initialIndex = index
        elif prev["isAsking"] == 0 and row["isAsking"] == 1:
            initialIndex = index
        elif (
            prev["isAsking"] != row["isAsking"]
            or prev["StimulusOff"] != row["StimulusOff"]
        ):
            sum = 0
            for j in range(initialIndex, index):
                sum += data.iloc[j]["speed[m/s]"]
            # print(index - initialIndex)
            meanVelocity = sum / (index - initialIndex)
            if index - initialIndex >= 100:
                if prev["mode"] == 0:
                    control.append(meanVelocity)
                elif prev["mode"] == 1:
                    near.append(meanVelocity)
                elif prev["mode"] == 2:
                    far.append(meanVelocity)
            initialIndex = index

    return control, near, far


def getQuestionRT(data: pd.DataFrame):
    initialTime = 0.0
    asking = False
    returnData = []
    for index in range(1, len(data)):
        row = data.iloc[index]
        prev = data.iloc[index - 1]
        time = row["RealTime"] - initialTime
        if prev["isAsking"] == 1 and row["isAsking"] == 0:
            initialTime = row["RealTime"]
            asking = True
            returnData.append(
                {
                    "RT": None,
                }
            )
        if asking and prev["isAnswering"] == 0 and row["isAnswering"] == 1:
            if time < 2.0 and time > 0.2:
                returnData[-1]["RT"] = time
            asking = False

    return returnData
