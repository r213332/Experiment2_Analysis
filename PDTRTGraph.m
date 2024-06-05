directory = "./processedData/";

% Subject 1
subject1 = struct();
subject1.control = readtable(strcat(directory, "subject1/controlRT.csv"));
subject1.near = readtable(strcat(directory, "subject1/nearRT.csv"));
subject1.far = readtable(strcat(directory, "subject1/farRT.csv"));


% Subject 2
subject2 = struct();
subject2.control = readtable(strcat(directory, "subject2/controlRT.csv"));
subject2.near = readtable(strcat(directory, "subject2/nearRT.csv"));
subject2.far = readtable(strcat(directory, "subject2/farRT.csv"));

% Subject 3
subject3 = struct();
subject3.control = readtable(strcat(directory, "subject3/controlRT.csv"));
subject3.near = readtable(strcat(directory, "subject3/nearRT.csv"));
subject3.far = readtable(strcat(directory, "subject3/farRT.csv"));

% Subject 4
subject4 = struct();
subject4.control = readtable(strcat(directory, "subject4/controlRT.csv"));
subject4.near = readtable(strcat(directory, "subject4/nearRT.csv"));
subject4.far = readtable(strcat(directory, "subject4/farRT.csv"));

%刺激の見逃し率計算
miss = (height(subject1.control) - length(rmmissing(subject1.control{:, 1}))) / height(subject1.control);
disp(['subject1 control miss: ', num2str(miss)]);   
miss = (height(subject1.near) - length(rmmissing(subject1.near{:, 1}))) / height(subject1.near);
disp(['subject1 near miss: ', num2str(miss)]);
miss = (height(subject1.far) - length(rmmissing(subject1.far{:, 1}))) / height(subject1.far);
disp(['subject1 far miss: ', num2str(miss)]);
miss = (height(subject2.control) - length(rmmissing(subject2.control{:, 1}))) / height(subject2.control);
disp(['subject2 control miss: ', num2str(miss)]);
miss = (height(subject2.near) - length(rmmissing(subject2.near{:, 1}))) / height(subject2.near);
disp(['subject2 near miss: ', num2str(miss)]);
miss = (height(subject2.far) - length(rmmissing(subject2.far{:, 1}))) / height(subject2.far);
disp(['subject2 far miss: ', num2str(miss)]);
miss = (height(subject3.control) - length(rmmissing(subject3.control{:, 1}))) / height(subject3.control);
disp(['subject3 control miss: ', num2str(miss)]);
miss = (height(subject3.near) - length(rmmissing(subject3.near{:, 1}))) / height(subject3.near);
disp(['subject3 near miss: ', num2str(miss)]);
miss = (height(subject3.far) - length(rmmissing(subject3.far{:, 1}))) / height(subject3.far);
disp(['subject3 far miss: ', num2str(miss)]);
miss = (height(subject4.control) - length(rmmissing(subject4.control{:, 1}))) / height(subject4.control);
disp(['subject4 control miss: ', num2str(miss)]);
miss = (height(subject4.near) - length(rmmissing(subject4.near{:, 1}))) / height(subject4.near);
disp(['subject4 near miss: ', num2str(miss)]);
miss = (height(subject4.far) - length(rmmissing(subject4.far{:, 1}))) / height(subject4.far);
disp(['subject4 far miss: ', num2str(miss)]);

disp('------------------------');

% RT取得＆データのバリデーション
% Subject 1
subject1.control = rmmissing(subject1.control{:, 1});
subject1.near = rmmissing(subject1.near{:, 1});
subject1.far = rmmissing(subject1.far{:, 1});

% Subject 2
subject2.control = rmmissing(subject2.control{:, 1});
subject2.near = rmmissing(subject2.near{:, 1});
subject2.far = rmmissing(subject2.far{:, 1});

% Subject 3
subject3.control = rmmissing(subject3.control{:, 1});
subject3.near = rmmissing(subject3.near{:, 1});
subject3.far = rmmissing(subject3.far{:, 1});

% Subject 4
subject4.control = rmmissing(subject4.control{:, 1});
subject4.near = rmmissing(subject4.near{:, 1});
subject4.far = rmmissing(subject4.far{:, 1});

% 全てのデータを連結
all_control = [subject1.control; subject2.control; subject3.control; subject4.control];
all_near = [subject1.near; subject2.near; subject3.near; subject4.near];
all_far = [subject1.far; subject2.far; subject3.far; subject4.far];

% クラスカルウォリス検定
% Subject 1
% 配列の次元数を揃える
% 配列の長さを取得
len_control = length(subject1.control);
len_near = length(subject1.near);
len_far = length(subject1.far);
% 最大の長さを取得
max_len = max([len_control, len_near, len_far]);
% 配列をNaNでパディング
padded_control = [subject1.control; nan(max_len - len_control, 1)];
padded_near = [subject1.near; nan(max_len - len_near, 1)];
padded_far = [subject1.far; nan(max_len - len_far, 1)];
% パディングされた配列を連結
concatenated_array = [padded_control, padded_near, padded_far];
% クラスカルウォリス検定
[subject1_p,subject1_tbl,subject1_stats] = kruskalwallis(concatenated_array, [], 'off');
% disp(['subject1: ', num2str(subject1_p)]);
% figure;
% subject1_c = multcompare(subject1_stats);
% 多重比較 ウィルコクソンの順位和検定
[subject1_c_p,subject1_c_h] = ranksum(subject1.control, subject1.near, 'alpha', 0.05);
disp(['subject1 control vs near: ', num2str(subject1_c_p)]);
[subject1_c_p,subject1_c_h] = ranksum(subject1.control, subject1.far, 'alpha', 0.05);
disp(['subject1 control vs far: ', num2str(subject1_c_p)]);
[subject1_c_p,subject1_c_h] = ranksum(subject1.near, subject1.far, 'alpha', 0.05);
disp(['subject1 near vs far: ', num2str(subject1_c_p)]);



% Subject 2
% 配列の次元数を揃える
% 配列の長さを取得
len_control = length(subject2.control);
len_near = length(subject2.near);
len_far = length(subject2.far);
% 最大の長さを取得
max_len = max([len_control, len_near, len_far]);
% 配列をNaNでパディング
padded_control = [subject2.control; nan(max_len - len_control, 1)];
padded_near = [subject2.near; nan(max_len - len_near, 1)];
padded_far = [subject2.far; nan(max_len - len_far, 1)];
% パディングされた配列を連結
concatenated_array = [padded_control, padded_near, padded_far];
% クラスカルウォリス検定
[subject2_p,subject2_tbl,subject2_stats] = kruskalwallis(concatenated_array, [], 'off');
% disp(['subject2: ', num2str(subject2_p)]);
% figure;
% subject2_c = multcompare(subject2_stats);
% 多重比較 ウィルコクソンの順位和検定
[subject2_c_p,subject2_c_h] = ranksum(subject2.control, subject2.near, 'alpha', 0.05);
disp(['subject2 control vs near: ', num2str(subject2_c_p)]);
[subject2_c_p,subject2_c_h] = ranksum(subject2.control, subject2.far, 'alpha', 0.05);
disp(['subject2 control vs far: ', num2str(subject2_c_p)]);
[subject2_c_p,subject2_c_h] = ranksum(subject2.near, subject2.far, 'alpha', 0.05);
disp(['subject2 near vs far: ', num2str(subject2_c_p)]);


% Subject 3
% 配列の次元数を揃える
% 配列の長さを取得
len_control = length(subject3.control);
len_near = length(subject3.near);
len_far = length(subject3.far);
% 最大の長さを取得
max_len = max([len_control, len_near, len_far]);
% 配列をNaNでパディング
padded_control = [subject3.control; nan(max_len - len_control, 1)];
padded_near = [subject3.near; nan(max_len - len_near, 1)];
padded_far = [subject3.far; nan(max_len - len_far, 1)];
% パディングされた配列を連結
concatenated_array = [padded_control, padded_near, padded_far];
% クラスカルウォリス検定
[subject3_p,subject3_tbl,subject3_stats] = kruskalwallis(concatenated_array, [], 'off');
% disp(['subject3: ', num2str(subject3_p)]);
% figure;
% subject3_c = multcompare(subject3_stats);
% 多重比較 ウィルコクソンの順位和検定
[subject3_c_p,subject3_c_h] = ranksum(subject3.control, subject3.near, 'alpha', 0.05);
disp(['subject3 control vs near: ', num2str(subject3_c_p)]);
[subject3_c_p,subject3_c_h] = ranksum(subject3.control, subject3.far, 'alpha', 0.05);
disp(['subject3 control vs far: ', num2str(subject3_c_p)]);
[subject3_c_p,subject3_c_h] = ranksum(subject3.near, subject3.far, 'alpha', 0.05);
disp(['subject3 near vs far: ', num2str(subject3_c_p)]);

% Subject 4
% 配列の次元数を揃える
% 配列の長さを取得
len_control = length(subject4.control);
len_near = length(subject4.near);
len_far = length(subject4.far);
% 最大の長さを取得
max_len = max([len_control, len_near, len_far]);
% 配列をNaNでパディング
padded_control = [subject4.control; nan(max_len - len_control, 1)];
padded_near = [subject4.near; nan(max_len - len_near, 1)];
padded_far = [subject4.far; nan(max_len - len_far, 1)];
% パディングされた配列を連結
concatenated_array = [padded_control, padded_near, padded_far];
% クラスカルウォリス検定
[subject4_p,subject4_tbl,subject4_stats] = kruskalwallis(concatenated_array, [], 'off');
% disp(['subject4: ', num2str(subject4_p)]);
% figure;
% subject4_c = multcompare(subject4_stats);
% 多重比較 ウィルコクソンの順位和検定
[subject4_c_p,subject4_c_h] = ranksum(subject4.control, subject4.near, 'alpha', 0.05);
disp(['subject4 control vs near: ', num2str(subject4_c_p)]);
[subject4_c_p,subject4_c_h] = ranksum(subject4.control, subject4.far, 'alpha', 0.05);
disp(['subject4 control vs far: ', num2str(subject4_c_p)]);
[subject4_c_p,subject4_c_h] = ranksum(subject4.near, subject4.far, 'alpha', 0.05);
disp(['subject4 near vs far: ', num2str(subject4_c_p)]);

% all
len_control = length(all_control);
len_near = length(all_near);
len_far = length(all_far);
max_len = max([len_control, len_near, len_far]);
padded_control = [all_control; nan(max_len - len_control, 1)];
padded_near = [all_near; nan(max_len - len_near, 1)];
padded_far = [all_far; nan(max_len - len_far, 1)];
concatenated_array = [padded_control, padded_near, padded_far];
[all_p,all_tbl,all_stats] = kruskalwallis(concatenated_array, [], 'off');
% disp(['all: ', num2str(all_p)]);
% 多重比較 ウィルコクソンの順位和検定
[all_c_p,all_c_h] = ranksum(all_control, all_near, 'alpha', 0.05);
disp(['all control vs near: ', num2str(all_c_p)]);
[all_c_p,all_c_h] = ranksum(all_control, all_far, 'alpha', 0.05);
disp(['all control vs far: ', num2str(all_c_p)]);
[all_c_p,all_c_h] = ranksum(all_near, all_far, 'alpha', 0.05);
disp(['all near vs far: ', num2str(all_c_p)]);


% 各データを棒グラフで中央値を表示
Median = [median(subject1.control), median(subject1.near), median(subject1.far);
          median(subject2.control), median(subject2.near), median(subject2.far);
          median(subject3.control), median(subject3.near), median(subject3.far);
          median(subject4.control), median(subject4.near), median(subject4.far);
          median(all_control), median(all_near), median(all_far)];

% 四分位範囲を計算
% Subject 1
subject1_control_quantiles = quantile(subject1.control, [0.25 0.75]);
subject1_near_quantiles = quantile(subject1.near, [0.25 0.75]);
subject1_far_quantiles = quantile(subject1.far, [0.25 0.75]);
% 差を計算
subject1_control_iqr = subject1_control_quantiles(2) - subject1_control_quantiles(1);
subject1_near_iqr = subject1_near_quantiles(2) - subject1_near_quantiles(1);
subject1_far_iqr = subject1_far_quantiles(2) - subject1_far_quantiles(1);

% Subject 2
subject2_control_quantiles = quantile(subject2.control, [0.25 0.75]);
subject2_near_quantiles = quantile(subject2.near, [0.25 0.75]);
subject2_far_quantiles = quantile(subject2.far, [0.25 0.75]);
% 差を計算
subject2_control_iqr = subject2_control_quantiles(2) - subject2_control_quantiles(1);
subject2_near_iqr = subject2_near_quantiles(2) - subject2_near_quantiles(1);
subject2_far_iqr = subject2_far_quantiles(2) - subject2_far_quantiles(1);

% Subject 3
subject3_control_quantiles = quantile(subject3.control, [0.25 0.75]);
subject3_near_quantiles = quantile(subject3.near, [0.25 0.75]);
subject3_far_quantiles = quantile(subject3.far, [0.25 0.75]);
% 差を計算
subject3_control_iqr = subject3_control_quantiles(2) - subject3_control_quantiles(1);
subject3_near_iqr = subject3_near_quantiles(2) - subject3_near_quantiles(1);
subject3_far_iqr = subject3_far_quantiles(2) - subject3_far_quantiles(1);

% Subject 4
subject4_control_quantiles = quantile(subject4.control, [0.25 0.75]);
subject4_near_quantiles = quantile(subject4.near, [0.25 0.75]);
subject4_far_quantiles = quantile(subject4.far, [0.25 0.75]);
% 差を計算
subject4_control_iqr = subject4_control_quantiles(2) - subject4_control_quantiles(1);
subject4_near_iqr = subject4_near_quantiles(2) - subject4_near_quantiles(1);
subject4_far_iqr = subject4_far_quantiles(2) - subject4_far_quantiles(1);

% all
all_control_quantiles = quantile(all_control, [0.25 0.75]);
all_near_quantiles = quantile(all_near, [0.25 0.75]);
all_far_quantiles = quantile(all_far, [0.25 0.75]);
all_control_iqr = all_control_quantiles(2) - all_control_quantiles(1);
all_near_iqr = all_near_quantiles(2) - all_near_quantiles(1);
all_far_iqr = all_far_quantiles(2) - all_far_quantiles(1);

error = [subject1_control_iqr, subject1_near_iqr, subject1_far_iqr;
         subject2_control_iqr, subject2_near_iqr, subject2_far_iqr;
         subject3_control_iqr, subject3_near_iqr, subject3_far_iqr;
         subject4_control_iqr, subject4_near_iqr, subject4_far_iqr;
         all_control_iqr, all_near_iqr, all_far_iqr];

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
labels = [strcat("p=",string(subject1_p)), strcat("p=",string(subject2_p)), strcat("p=",string(subject3_p)), strcat("p=",string(subject4_p)), strcat("p=",string(all_p))];
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');

% エラーバーの描画
[ngroups,nbars] = size(Median);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

errorbar(x.',Median, error, 'k', 'linestyle', 'none');

fontsize(gcf,24,'points')
title("PDTへの反応時間（中央値）");
ylabel("反応時間[s]");
ylim([0, 1.5]);
legend("対照条件", "近接条件", "遠方条件",'四分位範囲','',''); 
xticklabels({'Subject 1', 'Subject 2', 'Subject 3', 'Subject 4','All'});


