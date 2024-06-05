directory = "./processedData/";
subject = "subject3/";

dataPath = strcat(directory, subject);

controlTable = readtable(strcat(dataPath,"controlRT.csv"));
verifiedControlTable = rmmissing(controlTable);
missingControlRTRows = controlTable(ismissing(controlTable.RT), :);
nearTable = readtable(strcat(dataPath,"nearRT.csv"));
verifiedNearTable = rmmissing(nearTable);
missingNearRTRows = nearTable(ismissing(nearTable.RT), :);
farTable = readtable(strcat(dataPath,"farRT.csv"));
verifiedFarTable = rmmissing(farTable);
missingFarRTRows = farTable(ismissing(farTable.RT), :);

figure
nexttile
plot(verifiedControlTable.HDegree,verifiedControlTable.RT,'o');
xlim([32,56]);
ylim([0.3,1.0]);
title('対照');
lsline;
mdl = fitlm(verifiedControlTable,'RT~HDegree');  % Create a linear regression model
R2_control = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(33, 0.9, ['R^2 = ', num2str(R2_control)]);

nexttile
plot(verifiedNearTable.HDegree,verifiedNearTable.RT,'o');
xlim([32,56]);
ylim([0.3,1.0]);
title('近傍');
lsline;
mdl = fitlm(verifiedNearTable,'RT~HDegree');  % Create a linear regression model
R2_near = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(33, 0.9, ['R^2 = ', num2str(R2_near)]);

nexttile
plot(verifiedFarTable.HDegree,verifiedFarTable.RT,'o');
xlim([32,56]);
ylim([0.3,1.0]);
lsline;
title('遠方');
mdl = fitlm(verifiedFarTable,'RT~HDegree');  % Create a linear regression model
R2_far = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(33, 0.9, ['R^2 = ', num2str(R2_far)]);

nexttile
histogram(missingControlRTRows.HDegree);
title('対照miss');


nexttile
histogram(missingNearRTRows.HDegree);
title('近傍miss');

nexttile
histogram(missingFarRTRows.HDegree);
title('遠方miss');



