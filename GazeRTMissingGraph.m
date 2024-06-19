import swtest.*;

directory = "./processedData/";
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外


controlTable = table();
nearTable = table();
farTable = table();

for i = 1:length(subdirs)
    subdirName = subdirs(i).name;
    % ファイルの存在をチェック
    if exist(fullfile(directory, subdirName, "controlGazeRT.csv"), 'file') ~= 2
        continue;
    end
    % 各CSVファイルを読み込む
    control = readtable(fullfile(directory, subdirName, "controlGazeRT.csv"));
    near = readtable(fullfile(directory, subdirName, "nearGazeRT.csv"));
    far = readtable(fullfile(directory, subdirName, "fargazeRT.csv"));
    
    % 連結
    controlTable = vertcat(controlTable, control);
    nearTable = vertcat(nearTable, near);
    farTable = vertcat(farTable, far);
end

% サッケードが起きなかったデータを抽出
missingControlRTRows = controlTable(ismissing(controlTable.GazeRT), :);
missingNearRTRows = nearTable(ismissing(nearTable.GazeRT), :);
missingFarRTRows = farTable(ismissing(farTable.GazeRT), :);

% サッケードが起きたデータを抽出
controlTable = rmmissing(controlTable,"DataVariables","GazeRT");
nearTable = rmmissing(nearTable,"DataVariables","GazeRT");
farTable = rmmissing(farTable,"DataVariables","GazeRT");

% RT用に欠損値を除外
verifiedControlTable = rmmissing(controlTable,"DataVariables","RT");
verifiedNearTable = rmmissing(nearTable,"DataVariables","RT");
verifiedFarTable = rmmissing(farTable,"DataVariables","RT");
verifiedMissingControlRTRows = rmmissing(missingControlRTRows,"DataVariables","RT");
verifiedMissingNearRTRows = rmmissing(missingNearRTRows,"DataVariables","RT");
verifiedMissingFarRTRows = rmmissing(missingFarRTRows,"DataVariables","RT");
% RT
[p,h] = ranksum(verifiedControlTable.RT, verifiedMissingControlRTRows.RT);
if h == 1
    disp("対照条件においてRTのサッカードの有無による切り分けでは、2群は有意に異なる");
end
[p,h] = ranksum(verifiedNearTable.RT, verifiedMissingNearRTRows.RT);
if h == 1
    disp("近傍条件においてRTのサッカードの有無による切り分けでは、2群は有意に異なる");
end
[p,h] = ranksum(verifiedFarTable.RT, verifiedMissingFarRTRows.RT);
if h == 1
    disp("遠方条件においてRTのサッカードの有無による切り分けでは、2群は有意に異なる");
end
medians = [median(verifiedControlTable.RT), median(verifiedMissingControlRTRows.RT); ...
    median(verifiedNearTable.RT), median(verifiedMissingNearRTRows.RT); ...
    median(verifiedFarTable.RT), median(verifiedMissingFarRTRows.RT)];
figure;
bar(medians);
xticklabels({'対照','近傍','遠方'});
legend('サッカードあり','サッカードなし');

% 初期差
[p,h] = ranksum(controlTable.InitialGazeDistance, missingControlRTRows.InitialGazeDistance);
if h == 1
    disp("対照条件において初期差のサッカードの有無による切り分けでは、2群は有意に異なる");
end
[p,h] = ranksum(nearTable.InitialGazeDistance, missingNearRTRows.InitialGazeDistance);
if h == 1
    disp("近傍条件において初期差のサッカードの有無による切り分けでは、2群は有意に異なる");
end
[p,h] = ranksum(farTable.InitialGazeDistance, missingFarRTRows.InitialGazeDistance);
if h == 1
    disp("遠方条件において初期差のサッカードの有無による切り分けでは、2群は有意に異なる");
end
medians = [median(controlTable.InitialGazeDistance), median(missingControlRTRows.InitialGazeDistance); ...
    median(nearTable.InitialGazeDistance), median(missingNearRTRows.InitialGazeDistance); ...
    median(farTable.InitialGazeDistance), median(missingFarRTRows.InitialGazeDistance)];
figure;
bar(medians);
xticklabels({'対照','近傍','遠方'});

% グラフ保存用
graphDir = './graphs';
mkdir(graphDir);

% 水平方向の偏心度でサッカードなしをプロット
figure
nexttile
histogram(missingControlRTRows.StimulusHorizontalDegree, 'BinWidth', 5);
xlim([0,55]);
xlabel('水平方向の偏心度[°]');
ylabel('回数');
title('対照条件');

nexttile
histogram(missingNearRTRows.StimulusHorizontalDegree, 'BinWidth', 5);
xlim([0,55]);
xlabel('水平方向の偏心度[°]');
ylabel('回数');
title('近傍条件');

nexttile
histogram(missingFarRTRows.StimulusHorizontalDegree, 'BinWidth', 5);
xlim([0,55]);
xlabel('水平方向の偏心度[°]');
ylabel('回数');
title('遠方条件');

% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'StimulusHorizontalDegree~GazeRT_MissingGraph.png'));

% 初期の距離でサッカードなしをプロット
figure
nexttile
histogram(missingControlRTRows.InitialGazeDistance, 'BinWidth', 10);
xlim([0,80]);
xlabel('刺激提示時の角度差[°]');
ylabel('回数');
title('対照条件');

nexttile
histogram(missingNearRTRows.InitialGazeDistance, 'BinWidth', 10);
xlim([0,80]);
xlabel('刺激提示時の角度差[°]');
ylabel('回数');
title('近傍条件');

nexttile
histogram(missingFarRTRows.InitialGazeDistance, 'BinWidth', 10);
xlim([0,80]);
xlabel('刺激提示時の角度差[°]');
ylabel('回数');
title('遠方条件');

% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'InitialGazeDistance~GazeRT_MissingGraph.png'));

% RTでサッカードなしをプロット
figure
nexttile
histogram(missingControlRTRows.RT, 'BinWidth', 0.2);
xlim([0,2.0]);
xlabel('RT[s]');
ylabel('回数');
title('対照条件');

nexttile
histogram(missingNearRTRows.RT, 'BinWidth', 0.2);
xlim([0,2.0]);
xlabel('RT[s]');
ylabel('回数');
title('近傍条件');

nexttile
histogram(missingFarRTRows.RT, 'BinWidth', 0.2);
xlim([0,2.0]);
xlabel('RT[s]');
ylabel('回数');
title('遠方条件');


% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'RT~GazeRT_MissingGraph.png'));