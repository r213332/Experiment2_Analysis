import pandas as pd
import random
import numpy as np
import quaternion
import matplotlib.pyplot as plt


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
        if show and (
            (prev["IsRightButtonPressed"] == 0 and row["IsRightButtonPressed"] == 1)
            or (prev["IsLeftButtonPressed"] == 0 and row["IsLeftButtonPressed"] == 1)
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


def linear_interpolate_and_smooth_for_getSI(values, window_size=3):
    """線形補完を行い、その後でデータに平滑化フィルタを適用する。窓のサイズは可変。"""
    # 補完された値を格納するリスト
    interpolated = []
    for i, value in enumerate(values):
        if value is not None:
            interpolated.append(value)
        else:
            # 前後の非None値を見つける
            prev_val = next((v for v in values[i::-1] if v is not None), None)
            next_val = next((v for v in values[i:] if v is not None), None)
            # 両方の非None値が見つかった場合は線形補完を行う
            if prev_val is not None and next_val is not None:
                interpolated.append((prev_val + next_val) / 2)
            elif prev_val is not None:
                interpolated.append(prev_val)
            elif next_val is not None:
                interpolated.append(next_val)
            else:
                interpolated.append(None)  # すべてNoneの場合は補完不可

    if(window_size > 1):
        # smoothed_values = []
        # for i in range(len(interpolated)):
        #     if i < window_size // 2 or i > len(interpolated) - window_size // 2 - 1:
        #         # リストの端では、元の値を使用
        #         smoothed_values.append(interpolated[i])
        #     else:
        #         # 指定された窓のサイズで平均を取る
        #         window_sum = sum(
        #             interpolated[i - window_size // 2 : i + window_size // 2 + 1]
        #         )
        #         smoothed_value = window_sum / window_size
        #         smoothed_values.append(smoothed_value)

        # return smoothed_values
        return kalman_filter(interpolated)
    else:  
        return interpolated
    
def kalman_filter(values):
    if not values or len(values) == 0:
        return []

    # 初期化
    x_est = values[0]  # 最初の観測値を初期状態推定値とする
    P = 1.0  # 初期誤差共分散
    Q = 1.1  # 推定誤差
    R = 1.0  # 観測誤差

    filtered_values = [x_est]

    for z in values[1:]:
        if z is None:
            filtered_values.append(x_est)  # 観測値がNoneの場合、推定値をそのまま使用
            continue

        # 予測ステップ
        x_pred = x_est
        P_pred = P + Q

        # 更新ステップ
        K = P_pred / (P_pred + R)  # カルマンゲイン
        x_est = x_pred + K * (z - x_pred)  # 状態推定値の更新
        P = (1 - K) * P_pred  # 誤差共分散の更新

        filtered_values.append(x_est)

    return filtered_values


# TODO: 以下の関数を実装する 方針を決める 刺激提示中に限定するかしないか
def getSI(data: pd.DataFrame):
    data = data.query("mode != -1")
    gaze = False
    startTime = 0
    controlData = []
    nearData = []
    farData = []
    nowAngleData = []
    gazeDirection = None
    rotateData = []
    rotatedFrontVector = None
    rotatedFrontVectors = []
    GazeRay = []
    for index in range(1, len(data)):
        row = data.iloc[index]
        prev = data.iloc[index - 1]
        headRotation = np.quaternion(
            row["head_rw"],
            row["head_rx"],
            row["head_ry"],
            row["head_rz"],
        )
        # テスト用
        # print(np.degrees(quaternion.as_euler_angles(headRotation)))
        rotateData.append(np.degrees(quaternion.as_euler_angles(headRotation)))
        frontVector = np.array([0, 0, 1])
        rotatedFrontVector = quaternion.rotate_vectors(headRotation, frontVector)
        # rotatedFrontVector = quaternion.as_rotation_vector(headRotation)
        if row["GazeRay_IsValid"] == 1:
            gazeDirection = np.array(
                [
                    row["GazeRay_Direction_x"],
                    row["GazeRay_Direction_y"],
                    row["GazeRay_Direction_z"],
                ]
            )
            GazeRay.append(gazeDirection)
            rotatedFrontVectors.append(rotatedFrontVector)
        else:
            rotatedFrontVector = None
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
                startTime = row["RealTime"]
                # nowAngleData.append(getAngle(gazeDirection, rotatedFrontVector))
                nowAngleData.append(
                    {
                        "angle": getAngle(gazeDirection, rotatedFrontVector),
                        "time": row["RealTime"],
                    }
                )
        # 質問されているとき
        elif prev["isAsking"] == 0 and row["isAsking"] == 1 and row["StimulusOff"] == 0:
            gaze = True
            startTime = row["RealTime"]
            # nowAngleData.append(getAngle(gazeDirection, rotatedFrontVector))
            nowAngleData.append(
                {
                    "angle": getAngle(gazeDirection, rotatedFrontVector),
                    "time": row["RealTime"],
                }
            )
        # 条件が切り替わり、それが対照条件であったとき
        elif prev["mode"] != 0 and row["mode"] == 0 and row["StimulusOff"] == 0:
            gaze = True
            startTime = row["RealTime"]
            # nowAngleData.append(getAngle(gazeDirection, rotatedFrontVector))
            nowAngleData.append(
                {
                    "angle": getAngle(gazeDirection, rotatedFrontVector),
                    "time": row["RealTime"],
                }
            )
        # 終了条件
        elif gaze and (
            prev["isAsking"] != row["isAsking"]
            or prev["StimulusOff"] != row["StimulusOff"]
            or (prev["mode"] != row["mode"] and prev["mode"] == 0)
        ):
            # nowAngleDataからangleのリストを抽出
            angles = [item["angle"] for item in nowAngleData]

            # angleのリストを線形補完
            interpolated_angles = linear_interpolate_and_smooth_for_getSI(angles,window_size=1)

            # 補完されたangleの値をnowAngleDataに戻す
            for i, item in enumerate(nowAngleData):
                item["angle"] = interpolated_angles[i]

            SICount = 0
            if len(farData) == 0 and prev["mode"] == 2:
                SICount = detectSI(
                    nowAngleData,
                    startTime,
                    row["RealTime"],
                )

            if prev["mode"] == 0:
                controlData.append(
                    {
                        # "angle": linear_interpolate_none_values(nowAngleData),
                        "angle": [
                            nowAngleData["angle"] for nowAngleData in nowAngleData
                        ],
                        "SICount": SICount,
                    }
                )
            elif prev["mode"] == 1:
                nearData.append(
                    {
                        # "angle": linear_interpolate_none_values(nowAngleData),
                        "angle": [
                            nowAngleData["angle"] for nowAngleData in nowAngleData
                        ],
                        "SICount": SICount,
                    }
                )
            elif prev["mode"] == 2:
                farData.append(
                    {
                        # "angle": linear_interpolate_none_values(nowAngleData),
                        "angle": [
                            nowAngleData["angle"] for nowAngleData in nowAngleData
                        ],
                        "SICount": SICount,
                    }
                )
            gaze = False
            startTime = 0
            nowAngleData = []
        # 継続条件
        elif gaze:
            # nowAngleData.append(getAngle(gazeDirection, rotatedFrontVector))
            nowAngleData.append(
                {
                    "angle": getAngle(gazeDirection, rotatedFrontVector),
                    "time": row["RealTime"],
                }
            )

    # X, Y, Z = zip(*rotatedFrontVectors)
    # U, V, W = [0] * len(X), [0] * len(Y), [0] * len(Z)

    # GX,GY,GZ = zip(*GazeRay)

    # print(getAngle(rotatedFrontVectors[2000], GazeRay[2000]))
    # # ベクトルを描画
    # fig = plt.figure()
    # ax = fig.add_subplot(111, projection="3d")
    # ax.quiver(U[2000:2005], V[2000:2005], W[2000:2005], X[2000:2005], Y[2000:2005], Z[2000:2005])
    # ax.quiver(X[2000:2005], Y[2000:2005], Z[2000:2005], GX[2000:2005], GY[2000:2005], GZ[2000:2005],color="red")
    # ax.set_xlabel("X")
    # ax.set_ylabel("Y")
    # ax.set_zlabel("Z")
    # ax.set_xlim(-2, 2)
    # ax.set_ylim(-2, 2)
    # ax.set_zlim(-2, 2)
    # plt.show()
    # plt.figure()

    return controlData, nearData, farData


def getAngle(vector1, vector2):
    if vector1 is None or vector2 is None:
        return None
    i = np.inner(vector1, vector2)
    n = np.linalg.norm(vector1) * np.linalg.norm(vector2)
    c = i / n
    degree = np.rad2deg(np.arccos(np.clip(c, -1.0, 1.0)))
    return degree


def detectSI(data: list, start: float, end: float):
    # print("ditectSI:",data)
    time = [item["time"] for item in data]
    angle = [item["angle"] for item in data]
    plt.plot(time, angle, color="blue")

    onMoveing = False
    onRaiseSaccrdic = False
    onFallSaccrdic = False
    onRaiseSaccrdicTime = None
    onFallSaccrdicTime = None
    raisedValue = 0
    raiseInitialIndex = 1
    raiseFinishIndex = 1
    fallInitialIndex = 1
    fallFinishIndex = 1
    SICount = 0
    saccrdicThreshold = 50
    foldTimeThresholdMin = 0.05
    foldTimeThresholdMax = 0.4
    amplitudeTreashold = 2
    maxError = 1.1 
    # 以下デバッグ用
    risingCount = 0
    for index in range(1, len(data)):
        gazeMoving = data[index]["angle"] - data[index - 1]["angle"]
        gazeVelocity = gazeMoving / (data[index]["time"] - data[index - 1]["time"])
        if gazeVelocity > saccrdicThreshold and onRaiseSaccrdic == False:
            onRaiseSaccrdic = True
            raiseInitialIndex = index
            while (
                data[raiseInitialIndex]["angle"] - data[raiseInitialIndex - 1]["angle"]
                > 0
            ):
                raiseInitialIndex -= 1
                if raiseInitialIndex == 0:
                    break
            raisedValue = data[raiseInitialIndex]["angle"]
            # print("raise start")
        elif gazeVelocity < saccrdicThreshold and onRaiseSaccrdic:
            onRaiseSaccrdic = False
            raiseFinishIndex = index
            while (
                data[raiseFinishIndex + 1]["angle"] - data[raiseFinishIndex]["angle"]
                > 0
            ):
                raiseFinishIndex += 1
                if raiseFinishIndex == len(data) - 1:
                    break
            if (
                abs(data[raiseFinishIndex]["angle"] - data[raiseInitialIndex]["angle"])
                < amplitudeTreashold
            ):
                onRaiseSaccrdicTime = data[raiseInitialIndex]["time"]
                # print(
                #     "detect Raise:",
                #     onRaiseSaccrdicTime,
                #     "move angle:",
                #     data[raiseFinishIndex]["angle"] - data[raiseInitialIndex]["angle"],
                # )

        if gazeVelocity < -saccrdicThreshold and onFallSaccrdic == False:
            onFallSaccrdic = True
            fallInitialIndex = index
            while (
                data[fallInitialIndex]["angle"] - data[fallInitialIndex - 1]["angle"]
                < 0
            ):
                fallInitialIndex -= 1
                if fallInitialIndex == 0:
                    break
            # print("fall start")
        elif gazeVelocity > -saccrdicThreshold and onFallSaccrdic:
            onFallSaccrdic = False
            fallFinishIndex = index
            while (
                data[fallFinishIndex + 1]["angle"] - data[fallFinishIndex]["angle"] < 0
            ):
                fallFinishIndex += 1
                if fallFinishIndex == len(data) - 1:
                    break
            if (
                abs(data[fallFinishIndex]["angle"] - raisedValue)
                < maxError
            ):
                onFallSaccrdicTime = data[fallFinishIndex]["time"]
                # print(
                #     "detect Fall:",
                #     onFallSaccrdicTime,
                #     "move angle:",
                #     data[fallFinishIndex]["angle"] - data[fallInitialIndex]["angle"],
                # )

        if onRaiseSaccrdicTime != None and onFallSaccrdicTime != None:
            if (onFallSaccrdicTime - onRaiseSaccrdicTime) > foldTimeThresholdMin and (
                onFallSaccrdicTime - onRaiseSaccrdicTime
            ) < foldTimeThresholdMax:
                plotData = data[raiseInitialIndex:fallFinishIndex]
                time = [item["time"] for item in plotData]
                angle = [item["angle"] for item in plotData]
                plt.plot(time, angle, color="red")
                print("--------------------")
                print(
                    "SI Detected! RaiseTime:",
                    onRaiseSaccrdicTime,
                    "FallTime:",
                    onFallSaccrdicTime,
                )
                print("--------------------")
                SICount += 1
                risingCount += 1
                onFallSaccrdicTime = None
                onRaiseSaccrdicTime = None

    print("risingCount:", risingCount)

    plt.title("SI Count: " + str(SICount))
    plt.legend()
    plt.show()

    return SICount


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
