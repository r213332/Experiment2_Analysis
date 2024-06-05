import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression

# CSVファイルからデータを読み込み、欠損値を削除
control_table = pd.read_csv("control.csv").dropna()
near_table = pd.read_csv("near.csv").dropna()
far_table = pd.read_csv("far.csv").dropna()

# 新しいウィンドウを作成
fig, axs = plt.subplots(3)

# 対照データをプロット
axs[0].scatter(control_table['HDegree'], control_table['RT'])
axs[0].set_xlim([32, 56])
axs[0].set_ylim([0.3, 1.0])
axs[0].set_title('control')

# 線形回帰モデルを作成し、描画、R2値を取得
X_control = control_table['HDegree'].values.reshape(-1, 1)
y_control = control_table['RT']
model_control = LinearRegression().fit(X_control, y_control)
R2_control = model_control.score(X_control, y_control)
print(f'R2_control: {R2_control}')
axs[0].plot(X_control, model_control.predict(X_control), color='red')

# 近傍データをプロット
axs[1].scatter(near_table['HDegree'], near_table['RT'])
axs[1].set_xlim([32, 56])
axs[1].set_ylim([0.3, 1.0])
axs[1].set_title('near')

# 線形回帰モデルを作成し、描画、R2値を取得
X_near = near_table['HDegree'].values.reshape(-1, 1)
y_near = near_table['RT']
model_near = LinearRegression().fit(X_near, y_near)
R2_near = model_near.score(X_near, y_near)
print(f'R2_near: {R2_near}')
axs[1].plot(X_near, model_near.predict(X_near), color='red')

# 遠方データをプロット
axs[2].scatter(far_table['HDegree'], far_table['RT'])
axs[2].set_xlim([32, 56])
axs[2].set_ylim([0.3, 1.0])
axs[2].set_title('far')

# 線形回帰モデルを作成し、描画、R2値を取得
X_far = far_table['HDegree'].values.reshape(-1, 1)
y_far = far_table['RT']
model_far = LinearRegression().fit(X_far, y_far)
R2_far = model_far.score(X_far, y_far)
print(f'R2_far: {R2_far}')
axs[2].plot(X_far, model_far.predict(X_far), color='red')

# グラフを表示
plt.show()