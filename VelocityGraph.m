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
    control = readtable(fullfile(directory, subdirName, "controlVelocity.csv"));
    near = readtable(fullfile(directory, subdirName, "nearVelocity.csv"));
    far = readtable(fullfile(directory, subdirName, "farVelocity.csv"));
    
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
% シャピロ・ウィルク検定のp値の表示
%control
xtips = b(1).XEndPoints;
ytips = b(1).YEndPoints + 6;
% labels = [string(subject1_c_p),string(subject2_c_p),string(subject3_c_p),string(subject4_c_p),string(all_c_p)];
labels = strings(length(subjects),1);
for i = 1:length(subjects)
    subject = subjects(i);
    [c_p,n_p,f_p] = subject.swtest();
    labels(i) = strcat("p=",string(c_p));
end
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);

%near
xtips = b(2).XEndPoints;
ytips = b(1).YEndPoints +  4;
labels = strings(length(subjects),1);
for i = 1:length(subjects)
    subject = subjects(i);
    [c_p,n_p,f_p] = subject.swtest();
    labels(i) = strcat("p=",string(n_p));
end
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);

%far
xtips = b(3).XEndPoints;
ytips = b(1).YEndPoints + 2;
labels = strings(length(subjects),1);
for i = 1:length(subjects)
    subject = subjects(i);
    [c_p,n_p,f_p] = subject.swtest();
    labels(i) = strcat("p=",string(f_p));
end
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);

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
title("速度の比較（区間平均の中央値）");
ylabel("速度[m/s]");
ylim([0, 30]);
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
saveas(gcf, fullfile(graphDir, 'Velocity_Graph.png'));

% allのクラスカルワリス及び各条件でのウィルコクソン順位和検定
all = subjects(length(subdirs)+1);
all_p = all.kruskalwallis();
[C_N_P,C_F_P,N_F_P] = all.ranksum();
disp("allのクラスカルワリス検定p値");
disp(all_p);
disp("対照条件と近接条件のウィルコクソン順位和検定p値");
disp(C_N_P);
disp("対照条件と遠方条件のウィルコクソン順位和検定p値");
disp(C_F_P);
disp("近接条件と遠方条件のウィルコクソン順位和検定p値");
disp(N_F_P);


