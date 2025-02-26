# 実験１解析プログラム

- 基本的に python で unity から出力されたデータを前処理して、matlab でグラフの描画を行っています。
- python は被験者ごとに実行するプログラムであり、matlab は実験ごとに実行するファイルです。

## 共通

```
# 依存関係のインストール
pip install -r .\requirements.txt
```

### function.py

  - 各前処理プログラム(.py)で使用する関数群です。

## RT.py

- unity のデータから PDT への反応時間と、その時の平均速度、刺激の位置を計算して出力します。
- 前述の通り、被験者ごとに実行する必要があります。

## RT.m

- RT.py で得たデータを格納し、検定などを行うためのクラスです。ここではクラスの記述のみなので、実行はできません。

## PDTRTGraph.m (RT.py実行後)

- 前述の RT.m で記述されるクラスを使用して、被験者ごとのデータを集計してグラフ化します。
- 併せて検定も行います。多群の検定ではクラスカル・ウォリス検定を使用し、多重比較にウィルコクソンの順位和検定を使用しています。

## EccentricityGraph.m (RT.py実行後)

 - 刺激の偏心度と反応時間、刺激の偏心度と見逃しのヒストグラムを出力

### その他は試行錯誤の結果生まれたので省略します。