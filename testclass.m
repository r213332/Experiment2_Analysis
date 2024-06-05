directory = "./processedData/";
import RT.*;

% Subject 1
subject1 = struct();
subject1.control = readtable("C:\workspace\Experiment1_Analysis\processedData\subject1\controlRT.csv");
subject1.near = readtable("C:\workspace\Experiment1_Analysis\processedData\subject1\nearRT.csv");
subject1.far = readtable("C:\workspace\Experiment1_Analysis\processedData\subject1\farRT.csv");

subject1 = RT(subject1.control, subject1.near, subject1.far);

subject1.control
subject1.getMissingRate()



