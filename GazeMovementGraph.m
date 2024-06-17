directory = "./processedData/";
subject = "subject7/";

dataPath = strcat(directory, subject);

controlTable = readtable(strcat(dataPath,"controlGazeMovement.csv"));
verifiedControlTable = rmmissing(controlTable);
missingControlRTRows = controlTable(ismissing(controlTable.RT), :);
nearTable = readtable(strcat(dataPath,"nearGazeMovement.csv"));
verifiedNearTable = rmmissing(nearTable);
missingNearRTRows = nearTable(ismissing(nearTable.RT), :);
farTable = readtable(strcat(dataPath,"farGazeMovement.csv"));
verifiedFarTable = rmmissing(farTable);
missingFarRTRows = farTable(ismissing(farTable.RT), :);

figure
nexttile
plot(verifiedControlTable.MeanGazeMovement,verifiedControlTable.RT,'o');
% xlim([0,1.0]);
ylim([0,1.5]);
xlabel('速度[degree/s]');
ylabel('応答時間[s]');
title('対照');
lsline;
mdl = fitlm(verifiedControlTable,'RT~MeanGazeMovement');  % Create a linear regression model
a_control = mdl.Coefficients.Estimate(1);  % Get the intercept
R2_control = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(0.8, 1.4, ['a = ', num2str(a_control)]);
text(0.8, 1.3, ['R^2 = ', num2str(R2_control)]);

nexttile
plot(verifiedNearTable.MeanGazeMovement,verifiedNearTable.RT,'o');
% xlim([0,1.0]);
ylim([0,1.5]);
xlabel('速度[degree/s]');
ylabel('応答時間[s]');
title('近傍');
lsline;
mdl = fitlm(verifiedNearTable,'RT~MeanGazeMovement');  % Create a linear regression model
a_near = mdl.Coefficients.Estimate(1);  % Get the intercept
R2_near = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(0.8, 1.4, ['a = ', num2str(a_near)]);
text(0.8, 1.3, ['R^2 = ', num2str(R2_near)]);

nexttile
plot(verifiedFarTable.MeanGazeMovement,verifiedFarTable.RT,'o');
% xlim([0,1.0]);
ylim([0,1.5]);
xlabel('速度[degree/s]');
ylabel('応答時間[s]');
title('遠方');
lsline;
mdl = fitlm(verifiedFarTable,'RT~MeanGazeMovement');  % Create a linear regression model
a_far = mdl.Coefficients.Estimate(1);  % Get the intercept
R2_far = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(0.8, 1.4, ['a = ', num2str(a_far)]);
text(0.8, 1.3, ['R^2 = ', num2str(R2_far)]);