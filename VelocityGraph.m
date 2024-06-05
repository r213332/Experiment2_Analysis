import swtest.*;


directory = "./processedData/";

% Subject 1
subject1 = struct();
subject1.control = readtable(strcat(directory, "subject1/controlVelocity.csv"));
subject1.near = readtable(strcat(directory, "subject1/nearVelocity.csv"));
subject1.far = readtable(strcat(directory, "subject1/farVelocity.csv"));

% Subject 2
subject2 = struct();
subject2.control = readtable(strcat(directory, "subject2/controlVelocity.csv"));
subject2.near = readtable(strcat(directory, "subject2/nearVelocity.csv"));
subject2.far = readtable(strcat(directory, "subject2/farVelocity.csv"));

% Subject 3
subject3 = struct();
subject3.control = readtable(strcat(directory, "subject3/controlVelocity.csv"));
subject3.near = readtable(strcat(directory, "subject3/nearVelocity.csv"));
subject3.far = readtable(strcat(directory, "subject3/farVelocity.csv"));

% Subject 4
subject4 = struct();
subject4.control = readtable(strcat(directory, "subject4/controlVelocity.csv"));
subject4.near = readtable(strcat(directory, "subject4/nearVelocity.csv"));
subject4.far = readtable(strcat(directory, "subject4/farVelocity.csv"));

% 速度取得＆データのバリデーション
% Subject 1
subject1.control = rmmissing(subject1.control{:, 1});
subject1.near = rmmissing(subject1.near{:, 1});
subject1.far = rmmissing(subject1.far{:, 1});
%シャピロウィルク検定
[s1_c_h,subject1_c_p] = swtest(subject1.control);
[s1_n_h,subject1_n_p] = swtest(subject1.near);
[s1_f_h,subject1_f_p] = swtest(subject1.far);

% Subject 2
subject2.control = rmmissing(subject2.control{:, 1});
subject2.near = rmmissing(subject2.near{:, 1});
subject2.far = rmmissing(subject2.far{:, 1});
%シャピロウィルク検定
[s2_c_h,subject2_c_p] = swtest(subject2.control);
[s2_n_h,subject2_n_p] = swtest(subject2.near);
[s2_f_h,subject2_f_p] = swtest(subject2.far);


% Subject 3
subject3.control = rmmissing(subject3.control{:, 1});
subject3.near = rmmissing(subject3.near{:, 1});
subject3.far = rmmissing(subject3.far{:, 1});
%シャピロウィルク検定
[s3_c_h,subject3_c_p] = swtest(subject3.control);
[s3_n_h,subject3_n_p] = swtest(subject3.near);
[s3_f_h,subject3_f_p] = swtest(subject3.far);


% Subject 4
subject4.control = rmmissing(subject4.control{:, 1});
subject4.near = rmmissing(subject4.near{:, 1});
subject4.far = rmmissing(subject4.far{:, 1});
%シャピロウィルク検定
[s4_c_h,subject4_c_p] = swtest(subject4.control);
[s4_n_h,subject4_n_p] = swtest(subject4.near);
[s4_f_h,subject4_f_p] = swtest(subject4.far);

% 全てのデータを連結
all_control = [subject1.control; subject2.control; subject3.control; subject4.control];
all_near = [subject1.near; subject2.near; subject3.near; subject4.near];
all_far = [subject1.far; subject2.far; subject3.far; subject4.far];
%シャピロウィルク検定
[all_c_h,all_c_p] = swtest(all_control);
[all_n_h,all_n_p] = swtest(all_near);
[all_f_h,all_f_p] = swtest(all_far);

figure;
histogram(all_near);
figure;
histogram(all_far);


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
% シャピロ・ウィルク検定のp値の表示
%control
xtips = b(1).XEndPoints;
ytips = b(1).YEndPoints + 6;
labels = [string(subject1_c_p),string(subject2_c_p),string(subject3_c_p),string(subject4_c_p),string(all_c_p)];
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);

%near
xtips = b(2).XEndPoints;
ytips = b(1).YEndPoints +  4;
labels = [string(subject1_n_p),string(subject2_n_p),string(subject3_n_p),string(subject4_n_p),string(all_n_p)];
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);

%far
xtips = b(3).XEndPoints;
ytips = b(1).YEndPoints + 2;
labels = [string(subject1_f_p),string(subject2_f_p),string(subject3_f_p),string(subject4_f_p),string(all_f_p)];
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);

% エラーバーの描画
[ngroups,nbars] = size(Median);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

errorbar(x.',Median, error, 'k', 'linestyle', 'none');

fontsize(gcf,24,'points')
title("速度の比較（区間平均の中央値）");
ylabel("速度[m/s]");
ylim([0, 30]);
legend("対照条件", "近接条件", "遠方条件",'四分位範囲','',''); 
xticklabels({'Subject 1', 'Subject 2', 'Subject 3', 'Subject 4','All'});


