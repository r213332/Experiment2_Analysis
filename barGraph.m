% データの読み込み
controlTable = readtable('control.csv');
nearTable = readtable('near.csv');
farTable = readtable('far.csv');

% データの整形
controlData = table2array(controlTable);
nearData = table2array(nearTable);
farData = table2array(farTable);

% データのプロット
figure;
bar(controlData);
hold on;
bar(nearData);
bar(farData);
hold off;

