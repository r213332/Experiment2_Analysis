directory = "./processedData/";
% ディレクトリ内のすべてのサブディレクトリを取得
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外

% RTクラスの配列を宣言
subjects = RT.empty(length(subdirs)+1, 0);
all = RT.empty(1, 0);

% 各サブディレクトリに対してRTクラスのインスタンスを作成
for i = 1:length(subdirs)
    subdirName = subdirs(i).name;
    
    % 各CSVファイルを読み込む
    control = readtable(fullfile(directory, subdirName, "controlRT.csv"));
    near = readtable(fullfile(directory, subdirName, "nearRT.csv"));
    far = readtable(fullfile(directory, subdirName, "farRT.csv"));
    
    % RTクラスのインスタンスを作成
    subjects(i) = RT(subdirName,control, near, far);
    if(i == 1)
        all = RT('All',control, near, far);
    else
        all = all.addData(control, near, far);
    end
end
% allを結合
subjects(length(subdirs)+1) = all;

for i = 1:length(subjects)
    subject = subjects(i);
end

% 各データを棒グラフで中央値を表示
Median = zeros(length(subjects), 3);
error = zeros(length(subjects), 3);

for i = 1:length(subjects)
    subject = subjects(i);
    [controlMedian, nearMedian, farMedian] = subject.getMedians();
    Median(i,1) = controlMedian;
    Median(i,2) = nearMedian;
    Median(i,3) = farMedian;
    
    [controlQuantilesError, nearQuantilesError, farQuantilesError] = subject.getQuantilesError();
    error(i,1) = controlQuantilesError;
    error(i,2) = nearQuantilesError;
    error(i,3) = farQuantilesError;
end

% 棒グラフの描画
figure;
b = bar(Median);
hold on;
% p値の表示
xtips = b(2).XEndPoints;
control_y = b(1).YEndPoints;
near_y = b(2).YEndPoints;
far_y = b(3).YEndPoints;
ytips = max([control_y;near_y; far_y]) + 0.5;
% labels = [strcat("p=",string(subject1_p)), strcat("p=",string(subject2_p)), strcat("p=",string(subject3_p)), strcat("p=",string(subject4_p)), strcat("p=",string(all_p))];
labels = strings(length(subjects),1);
for i = 1:length(subjects)
    subject = subjects(i);
    labels(i) = strcat("p=",string(subject.kruskalwallis()));
end
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');

% エラーバーの描画
[ngroups,nbars] = size(Median);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

errorbar(x.',Median, error, 'k', 'linestyle', 'none');

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
fontsize(gcf,24,'points')
title("PDTへの反応時間（中央値）");
ylabel("反応時間[s]");
ylim([0, 1.5]);
legend("対照条件", "近接条件", "遠方条件",'四分位範囲','',''); 
subjectNames = {};
for i = 1:length(subjects)
    subject = subjects(i);
    subjectNames{i} = subject.name;
end
xticklabels(subjectNames);

% グラフを保存
graphDir = './graphs';
mkdir(graphDir);
saveas(gcf, fullfile(graphDir, 'PDT_RT_Graph.png'));

% allのデータを表示
all = subjects(length(subjects));
P = all.kruskalwallis();
[C_N_P,C_F_P,N_F_P] = all.ranksum();
disp("allのクラスカルワリス検定");
disp(P);
disp("対照条件と近接条件のウィルコクソン順位和検定");
disp(C_N_P);
disp("対照条件と遠方条件のウィルコクソン順位和検定");
disp(C_F_P);
disp("近接条件と遠方条件のウィルコクソン順位和検定");
disp(N_F_P);


