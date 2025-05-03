%clear 

%Trial_input = 2
%providedPath = "/Users/keirdaniels/Documents/MATLAB/Sunday calibration test/atmop/back to bak/Calibration_60V_"
%run_lenght = 30
%reg_gap = 3


function [Finsh,final_output,figure_for_sensor_data] = thrust(Trial_input, providedPath, run_lenght, req_gap,experiment,show_graphs_of_original_experiments)
experiment = convertStringsToChars(experiment); % this is to be used in the plot names. 
This_Trial = 1;
%This_Trialstring = num2str(This_Trial);
%file =  strcat('/Users/keirdaniels/Documents/MATLAB/Examples/For Denis/Test fire 8_21_18/thurst_30htz_',This_Trialstring,'.txt')
 % opts = detectImportOptions(file)
 % B1 = readtable(file);
 %m =  mean(B1.Var6);
%providedPath = '/Users/keirdaniels/Documents/MATLAB/Examples/Test_Fire_9_12_18_test/Calibration_175V_'
%Trial_input= 10;
%run_lenght = 30;
%req_gap = 3;
Number_of_trials = Trial_input;
path = providedPath;

for This_Trial = 1:Number_of_trials
% This_Trial = 1
 
    This_Trialstring = num2str(This_Trial);
    file =  strcat(path,This_Trialstring,'.txt');
    B1 = readtable(file); %'/Users/keirdaniels/Documents/MATLAB/Examples/For Denis/Test fire 8_21_18/thurst_20htz_1.txt');
    H = height(B1);
    %old_leng= length(trial_num)
    %trial_num((length(trial_num)+1):(length(trial_num)+H),1) = This_Trial
    if This_Trial == 1
        B = B1;
        trial_num(1:H,1) = This_Trial;
        Trial_observations(This_Trial,1) = H;
    else
    B = [B;B1];
    trial_num(length(trial_num)+1:length(trial_num)+H,1) = This_Trial;
    Trial_observations(This_Trial,1) = H;
    end
end

%Table creation and adding trial and time duration for the whole trial


B = addvars(B,trial_num,'Before','Var1');
datevect = datenum(B.Var1);
diff_date = [0;diff(datevect)];

%Adjustments for time columns so that duration only applies to the
%individual trials and not the whole expirment

%This section sets the variables for time duration
value = length(datevect);
observation(1:value,1) = 0;
sum_date_diff(1:value,1) = 0;
data_in_seconds(1:value,1) = 0;
data_in_minutes(1:value,1) = 0;
minlocation = 1;
maxlocation = 0;

% This is the set of loops that calculate the duration within each trial
for Num_trial = 1:Number_of_trials
    
    %sum_date_diff(minlocation,1) = 0;%zeros(minlocation,1);
    %data_in_seconds(minlocation,1) = 0;%zeros(minlocation,1);
    %data_in_minutes(minlocation,1) = 0;%zeros(minlocation,1);
    maxlocation = (maxlocation + Trial_observations(Num_trial,1));
    if minlocation == 1
        observation(1:1) = 1;
    else
        observation(minlocation,1) = (observation(minlocation -1 , 1) + 1);
    end
        %Num_trial
    
   
   for location = (minlocation +1):maxlocation
    
   %minlocation
   %location
    
    observation(location,1) = (observation(location -1 , 1) + 1);
    sum_date_diff(location,1)=(sum_date_diff(location-1,1) + diff_date(location,1));
    data_in_seconds(location,1)= (sum_date_diff(location)*(24*60*60));
    data_in_minutes(location,1)= (sum_date_diff(location)*(24*60));
    
    end
    
    minlocation = (maxlocation + 1);
    
end

%Data processing:

Distance = B.Var7; %This sets what column the distance is stored in on the table//it used to be vr 6!! from before sandbox


[C,A] = butter(5,0.005,'low');
Filtered_dataX = filtfilt(C,A,Distance);
[C2,A2] = butter(5,0.05,'low');
Filtered_data = filtfilt(C2,A2,Distance);

Total_Table = table(trial_num,observation,data_in_minutes,data_in_seconds,sum_date_diff,Distance,Filtered_data,Filtered_dataX);

%histogram(Distance);

%req_gap = 3; %in seconds

%total_length = Trial_observations(Num_trialb,1);

for Num_trialb = 1:Number_of_trials

pos1a = (find(Total_Table.data_in_seconds > (0 + req_gap) & Total_Table.trial_num == Num_trialb ,1)-1);
pos2a = (find(Total_Table.data_in_seconds > ((1*run_lenght) - req_gap) & Total_Table.trial_num == Num_trialb ,1)-1);

pos1b = (find(Total_Table.data_in_seconds > ((1*run_lenght) + req_gap) & Total_Table.trial_num == Num_trialb ,1)-1);
pos2b = (find(Total_Table.data_in_seconds > ((2*run_lenght) - req_gap) & Total_Table.trial_num == Num_trialb ,1)-1);

pos1c = (find(Total_Table.data_in_seconds > ((2*run_lenght) + req_gap) & Total_Table.trial_num == Num_trialb ,1)-1);
pos2c = (find(Total_Table.data_in_seconds > ((3*run_lenght) - req_gap) & Total_Table.trial_num == Num_trialb ,1)-1);

a = Total_Table(pos1a:pos2a,6:8);%,Total_Table(pos1a:pos2a,Filtered_data),Total_Table(pos1a:pos2a,Filtered_dataX);
b = Total_Table(pos1b:pos2b,6:8);%,Total_Table(pos1b:pos2b,Filtered_data),Total_Table(pos1b:pos2b,Filtered_dataX);
c = Total_Table(pos1c:pos2c,6:8);%,Total_Table(pos1c:pos2c,Filtered_data),Total_Table(pos1c:pos2c,Filtered_dataX);


a_mean = [mean(a.Distance), mean(a.Filtered_data) , mean(a.Filtered_dataX)];
b_mean = [mean(b.Distance), mean(b.Filtered_data) , mean(b.Filtered_dataX)];
c_mean = [mean(c.Distance), mean(c.Filtered_data) , mean(c.Filtered_dataX)];

a_b_diff_mean = abs(a_mean - b_mean);
c_d_diff_mean = abs(b_mean - c_mean);
steep_mean_distance = ((a_b_diff_mean +c_d_diff_mean)/2);
summary_tableA = table(Num_trialb, steep_mean_distance);


if Num_trialb == 1
    summary_table = summary_tableA;
        
   
else 
    summary_table = [summary_table;summary_tableA];

end

% this will be for adding the indvidual paths, you have to read the table,
% look that the last time enter from postions 2c but also look for part on
% the table where you will want to pull only the experiment data. 
%this is the plot for each trial:
if show_graphs_of_original_experiments == true;
trail = convertStringsToChars(Num_trialb);
figure_for_sensor_data_trial = figure;
plot(Total_Table.data_in_seconds(pos1a:pos2c),Total_Table.Distance(pos1a:pos2c) ,Total_Table.data_in_seconds(pos1a:pos2c),Total_Table.Filtered_data(pos1a:pos2c),Total_Table.data_in_seconds(pos1a:pos2c),Total_Table.Filtered_dataX(pos1a:pos2c))
title({'Box Plots of the Force Estimates Raw Data', experiment,trail});
xlabel('Time in Seconds ');
ylabel('Distance in Micro Meters')

end
end


summary_table.Properties.VariableNames{2} = ('OriginalMean_FilteredMean_xFilteredMean');
summary_table;
Trial_data_for_export=table2array(summary_table);
%summary(summary_table);
Standard_dev = std(summary_table.OriginalMean_FilteredMean_xFilteredMean);
Averg = mean(summary_table.OriginalMean_FilteredMean_xFilteredMean);
Finsh = [Averg(1,1),Averg(1,2),Averg(1,3), Standard_dev(1,1),Standard_dev(1,2),Standard_dev(1,3)];
final_output =  Trial_data_for_export;



figure_for_sensor_data = figure;
plot(observation,Distance ,observation,Filtered_data,observation,Filtered_dataX)
title({'Plots of the Force Estimates Raw Data', experiment});
xlabel('Observation Count');
ylabel('Distance in Micro Meters')

end

