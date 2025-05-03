function [calibration_force_to_distance_data, calibration_force_to_distance_data_no_outliers] = calibration_Force_distance(exp_list_sensor_stats, Cal_cof)

%This pulls the data out of the entered struct
A = exp_list_sensor_stats.A;
Raw_distance_data = exp_list_sensor_stats.Raw_distance_data;
Filtered_Mean_level1 = exp_list_sensor_stats.Filtered_Mean_level1;
Filtered_Mean_level2 = exp_list_sensor_stats.Filtered_Mean_level2;
Number_of_calibration_experiments = exp_list_sensor_stats.Number_of_calibration_experiments;
Number_of_experiments = exp_list_sensor_stats.Number_of_experiments;


%This section just outputs the calibration data at box charts
Experiment = categorical(cellstr(exp_list_sensor_stats.A(1:exp_list_sensor_stats.Number_of_calibration_experiments,4)));


for row_number =  1 : exp_list_sensor_stats.Number_of_calibration_experiments %This section organizes the force and expriment data into one matrix. The rows come from matrix A which will be used to pull in the experiment level info
    number_of_trials = int32(double(exp_list_sensor_stats.A(row_number,1))); % need an int for number of trials but cant convert string directly to a int. 
  
    if row_number ==  1 %This section will make the calibration thrust to distance matrix. the if part starts the matrix, the else part grows the matrix. The row idenntifies each row of matrix A which has the list of experiments
        
    experiment_list_for_boxplot = repmat(Experiment(row_number,1),number_of_trials,1); %Enters the EXPERIMENT into the first column
    distance_list_for_boxplot = [exp_list_sensor_stats.Raw_distance_data(1:number_of_trials,row_number ),exp_list_sensor_stats.Filtered_Mean_level1(1:number_of_trials,row_number),exp_list_sensor_stats.Filtered_Mean_level2(1:number_of_trials,row_number)]; %This enters the the changes in distance that were caluclated from the sensor output. The sensor output comes from 

    else
        
            experiment_list_for_boxplot = [experiment_list_for_boxplot; repmat(Experiment(row_number,1),number_of_trials,1)];
            distance_list_for_boxplot = [distance_list_for_boxplot; exp_list_sensor_stats.Raw_distance_data(1:number_of_trials,row_number),exp_list_sensor_stats.Filtered_Mean_level1(1:number_of_trials,row_number),exp_list_sensor_stats.Filtered_Mean_level2(1:number_of_trials,row_number)]; %This grows the Calibration_thrust_to_distance, adding new records for additional volts and force readings
    end
   
    %Note the row number on matrix A correponds to the column number on the distane data matrix
     
end
  %keep working on this and come back to this look at line224 for helpful
  %hints since you made this already
  


    
%thrust_per_experiment_for_boxplot = [thrust_per_experiment_for_boxplot; [repmat(Experiment,number_of_trials,1),Thrust_measurement_avg_raw(1:number_of_trials,row_number),exp_list_sensor_stats.exp_list_sensor_stats.Filtered_Mean_level1(1:number_of_trials,row_number),exp_list_sensor_stats.Filtered_Mean_level2(1:number_of_trials,row_number)]]; %This grows the Calibration_thrust_to_distance, adding new records for additional volts and force readings
        
box_plots_of_calibration = figure()

subplot(3,1,1);
boxplot(distance_list_for_boxplot(:,1),experiment_list_for_boxplot)
title('Box Plots of the Calibration Distance Raw Data');
xlabel('Experiment');
ylabel('Distance in Micor Meters')


subplot(3,1,2);
boxplot(distance_list_for_boxplot(:,2),experiment_list_for_boxplot)
title('Box Plots of the Calibration Distance filtered 1');
xlabel('Experiment');
ylabel('Distance in Micor Meters')


subplot(3,1,3);
boxplot(distance_list_for_boxplot(:,3),experiment_list_for_boxplot)
title('Box Plots of the Calibration Distance filtered 2');
xlabel('Experiment');
ylabel('Distance in Micor Meters')

%------------------------%
%This next section takes the volts that were caluclated in the volts to force curve and converts them to
%force. The force values are then added to the last column in matrix A. 

%add Cal_cof from above to the new function

for row_number = 1:Number_of_calibration_experiments %This section organizes the calibration distance data into a matrix. The rows come from matrix A which will be used to pull in the experiment level info
    number_of_trials = int32(double(A(row_number,1))); % need an int for number of trials but cant convert string directly to a int. 
    Calibration_thrust = [double(A(row_number,5)), (double(A(row_number,5)).^2) * Cal_cof(1,1) + (double(A(row_number,5)).* Cal_cof(1,2)) + Cal_cof(1,3)]; %This takes the volts value in the calibration experiments and converts it to a force for each volts reading . The output is a volts column and force columns matrix
    
    if row_number == 1 %This section will make the calibration thrust to distance matrix. the if part starts the matrix, the else part grows the matrix. The row idenntifies each row of matrix A which has the list of experiments
        
    Calibration_thrust_to_distance = repmat(Calibration_thrust,number_of_trials,1); %Enters the force into the first column
    Calibration_thrust_to_distance = [Calibration_thrust_to_distance, Raw_distance_data(1:number_of_trials,row_number),Filtered_Mean_level1(1:number_of_trials,row_number),Filtered_Mean_level2(1:number_of_trials,row_number)]; %This enters the the changes in distance that were caluclated from the sensor output. The sensor output comes from 
 
    else
        Calibration_thrust_to_distance = [Calibration_thrust_to_distance; [repmat(Calibration_thrust,number_of_trials,1),Raw_distance_data(1:number_of_trials,row_number),Filtered_Mean_level1(1:number_of_trials,row_number),Filtered_Mean_level2(1:number_of_trials,row_number)]]; %This grows the Calibration_thrust_to_distance matrix, adding new records for additional volts and force readings
             
    end
   
    %Note the row number on matrix A correponds to the column number on the distane data matrix
     
end



%This sections formats the data for use in the fit function (i.e removes
 %nans)
 
[force_calibration_data, distance_calibration_raw] = prepareCurveData(Calibration_thrust_to_distance(:,2), Calibration_thrust_to_distance(:,3));
[force_calibration_data, distance_calibration_filter1] = prepareCurveData(Calibration_thrust_to_distance(:,2),Calibration_thrust_to_distance(:,4));
[force_calibration_data, distance_calibration_filter2] = prepareCurveData(Calibration_thrust_to_distance(:,2),Calibration_thrust_to_distance(:,5));

%Creates the curve fit data for the calibration curves
[curve_raw_calibration, goodness_raw_calibration, output_raw_calibration] = fit(force_calibration_data, distance_calibration_raw, 'poly1'); %you will want to output the goodness stuff as part of the verification on the of the fit

%extra stuff for just thrust bar eval)
betas_for_bar = coeffvalues(curve_raw_calibration);
beta_confidence_interval = confint(curve_raw_calibration);

[curve_filter1_calibration, goodness_filter1_calibration, output_filter1_calibration] = fit(force_calibration_data, distance_calibration_filter1, 'poly1'); 
[curve_filter2_calibration, goodness_filter2_calibration, output_filter2_calibration] = fit(force_calibration_data, distance_calibration_filter2, 'poly1'); 


%identify and do curves with outliers

 
 outlier_raw_data_calibration = abs((feval(curve_raw_calibration,force_calibration_data)) - distance_calibration_raw) > 1.5 * std(distance_calibration_raw);
outlier_raw_data_calibration_index =  excludedata(force_calibration_data,distance_calibration_raw,'indices',outlier_raw_data_calibration);
[no_outlier_raw_calibration_curve, goodness_no_outlier_raw_calibration, output_no_outlier_raw_calibration] = fit(force_calibration_data,distance_calibration_raw,'poly1','Exclude',outlier_raw_data_calibration_index);
raw_data_to_outlier_logic_map = [force_calibration_data,distance_calibration_raw,outlier_raw_data_calibration_index];

outlier_filter1_calibration = abs((feval(curve_filter1_calibration,force_calibration_data)) - distance_calibration_filter1) > 1.5 * std(distance_calibration_filter1);
outlier_filter1_calibration_index =  excludedata(force_calibration_data,distance_calibration_filter1,'indices',outlier_filter1_calibration);
[no_outlier_filter1_calibration_curve, goodness_no_outlier_filter1_calibration, output_no_outlier_filter1_calibration] = fit(force_calibration_data,distance_calibration_filter1,'poly1','Exclude',outlier_filter1_calibration_index);
filter1_data_to_outlier_logic_map = [force_calibration_data,distance_calibration_filter1,outlier_filter1_calibration_index];

outlier_filter2_calibration = abs((feval(curve_filter2_calibration,force_calibration_data)) - distance_calibration_filter2) > 1.5 * std(distance_calibration_filter2);
outlier_filter2_calibration_index =  excludedata(force_calibration_data,distance_calibration_filter2,'indices',outlier_filter2_calibration);
[no_outlier_filter2_calibration_curve, goodness_no_outlier_filter2_calibration, output_no_outlier_filter2_calibration] = fit(force_calibration_data,distance_calibration_filter2,'poly1','Exclude',outlier_filter2_calibration_index);
filter2_data_to_outlier_logic_map =[force_calibration_data,distance_calibration_filter2,outlier_filter2_calibration_index];

outlier_list = [outlier_raw_data_calibration, outlier_filter1_calibration, outlier_filter2_calibration];

    

%creates the stats for computing systematic errors on the calibration curve
%and extracts the curve betas from the above experiments. Note, the first
%beta indicates the sensesitivity of the thrust stand to changes in force. 
Calibration_force_avg = mean(force_calibration_data); %calcualtes the average of the forces that were used in the calibration (the calibration in the chamber)
Calibration_sse_force = sum((force_calibration_data - Calibration_force_avg).^2); %calculates the sse (sum of the square of the erros) of the forces that were used in the calibration (the calibration in the chamber)
Calibration_delta_x_avg = mean([distance_calibration_raw distance_calibration_filter1,distance_calibration_filter2]); %This makes a row vector of calibration distance averages where each column is a data type such as raw or filter. 
betas = [coeffvalues(curve_raw_calibration); coeffvalues(curve_filter1_calibration); coeffvalues(curve_filter2_calibration)]; %column 1 has the has beta1 which is the delta x/ delta force. the rows represent the various types of calibration data: i.e raw, filtered.

%for outlier:
% this removes the outliers from the sample arrays so the errors can be
% calculated

no_outliers_force_calibration_data_raw = raw_data_to_outlier_logic_map(raw_data_to_outlier_logic_map(:,3) == 0, 1);
no_outliers_force_calibration_data_filt1 = filter1_data_to_outlier_logic_map(filter1_data_to_outlier_logic_map(:,3) == 0, 1);
no_outliers_force_calibration_data_filt2 = filter2_data_to_outlier_logic_map(filter2_data_to_outlier_logic_map(:,3) == 0, 1);


no_outliers_distance_calibration_raw = raw_data_to_outlier_logic_map(raw_data_to_outlier_logic_map(:,3) == 0, 2);
no_outliers_distance_calibration_filter1 = filter1_data_to_outlier_logic_map(filter1_data_to_outlier_logic_map(:,3) == 0, 2);
no_outliers_distance_calibration_filter2 = filter2_data_to_outlier_logic_map(filter2_data_to_outlier_logic_map(:,3) == 0, 2);

trials_with_no_outliers_for_thrust_experiment = sum([outlier_raw_data_calibration_index, outlier_filter1_calibration_index, outlier_filter2_calibration_index]);


%creates the stats for computing systematic errors on the calibration curve
%without outliers
%and extracts the curve betas from the above experiments. Note, the first
%beta indicates the sensesitivity of the thrust stand to changes in force.

no_outlier_Calibration_force_avg = mean([no_outliers_force_calibration_data_raw, no_outliers_force_calibration_data_filt1, no_outliers_force_calibration_data_filt2]);
no_outlier_Calibration_sse_force = [sum((no_outliers_force_calibration_data_raw - no_outlier_Calibration_force_avg(1,1)).^2),sum((no_outliers_force_calibration_data_filt1 - no_outlier_Calibration_force_avg(1,2)).^2),sum((no_outliers_force_calibration_data_filt2 - no_outlier_Calibration_force_avg(1,3)).^2)];
no_calibration_Calibration_delta_x_avg = mean([no_outliers_distance_calibration_raw, no_outliers_distance_calibration_filter1, no_outliers_distance_calibration_filter2]);
no_outliers_betas = [coeffvalues(no_outlier_raw_calibration_curve); coeffvalues(no_outlier_filter1_calibration_curve); coeffvalues(no_outlier_filter2_calibration_curve)]; %column 1 has the has beta1 which is the delta x/ delta force. the rows represent the various types of calibration data: i.e raw, filtered.



%The next section is the thrust experiment section which used to caluclate
%the total error for each thrust experiment and the error for each trial. It takes in the info for raw and filtered data and runs through the list of thrust experiments from matrix A 

if sum(outlier_raw_data_calibration) == 0 %if there are no model outliers than you do not need to run the outlier part of the code

for position_of_data = (Number_of_calibration_experiments + 1) : Number_of_experiments %this flags the number of experiments and where this data is stored on A. 

    %with outliers
rmse = [goodness_raw_calibration.rmse; goodness_filter1_calibration.rmse; goodness_filter2_calibration.rmse]; %makse a vector of the rmse for each data type using the output from the previous section    
degrees_of_freedom = [goodness_raw_calibration.dfe; goodness_filter1_calibration.dfe; goodness_filter2_calibration.dfe];
experiment_distance_x_avg = nanmean([Raw_distance_data(:,position_of_data), Filtered_Mean_level1(:,position_of_data), Filtered_Mean_level2(:,position_of_data)]); % This list the avaerage distance for each thrust experiment as a column where the rows represent the data type such as raw or filtered


total_estimate_error_raw = (rmse(1)/ betas(1,1))*((1/double(A(position_of_data,1)))+(1/degrees_of_freedom(1))+((experiment_distance_x_avg(1)-Calibration_delta_x_avg(1))^2)/((betas(1,1)^2 )* Calibration_sse_force))^(1/2); %%Total error for raw data
total_estimate_error_filter1 = (rmse(2)/ betas(2,1))*((1/double(A(position_of_data,1)))+(1/degrees_of_freedom(2))+((experiment_distance_x_avg(2)-Calibration_delta_x_avg(2))^2)/((betas(2,1)^2 )* Calibration_sse_force))^(1/2); %%Total error for filter 1 data
total_estimate_error_filter2 =  (rmse(3)/ betas(3,1))*((1/double(A(position_of_data,1)))+(1/degrees_of_freedom(3))+((experiment_distance_x_avg(3)-Calibration_delta_x_avg(3))^2)/((betas(3,1)^2 )* Calibration_sse_force))^(1/2); %%Total error for filter 2 data
total_estimate_error(:,(position_of_data - Number_of_calibration_experiments)) = [total_estimate_error_raw; total_estimate_error_filter1; total_estimate_error_filter2]; % Makes the total list of erros. Each column is a different exeperiment and the rows are the different data types. Raw or filtered
 
stand_alone_estimate_error_raw(:,(position_of_data - Number_of_calibration_experiments)) = [(rmse(1) / betas(1,1))*(1+(1/degrees_of_freedom(1))+((Raw_distance_data(:,position_of_data)-Calibration_delta_x_avg(1)).^2)/((betas(1,1)^2 )* Calibration_sse_force)).^(1/2)]; %Error for each trial raw the next two are the erros for the filter settings
stand_alone_estimate_error_filter1(:,(position_of_data - Number_of_calibration_experiments)) =[(rmse(2) / betas(2,1))*(1+(1/degrees_of_freedom(2))+((Filtered_Mean_level1(:,position_of_data)-Calibration_delta_x_avg(2)).^2)/((betas(2,1)^2 )* Calibration_sse_force)).^(1/2)]; 
stand_alone_estimate_error_raw_filter2(:,(position_of_data - Number_of_calibration_experiments)) = [(rmse(3) / betas(3,1))*(1+(1/degrees_of_freedom(3))+((Filtered_Mean_level2(:,position_of_data)-Calibration_delta_x_avg(3)).^2)/((betas(3,1)^2 )* Calibration_sse_force)).^(1/2)]; 



end
else
    for position_of_data = (Number_of_calibration_experiments + 1) : Number_of_experiments %this flags the number of experiments and where this data is stored on A. 

    %with outliers
rmse = [goodness_raw_calibration.rmse; goodness_filter1_calibration.rmse; goodness_filter2_calibration.rmse]; %makse a vector of the rmse for each data type using the output from the previous section    
degrees_of_freedom = [goodness_raw_calibration.dfe; goodness_filter1_calibration.dfe; goodness_filter2_calibration.dfe];
experiment_distance_x_avg = mean([Raw_distance_data(:,position_of_data), Filtered_Mean_level1(:,position_of_data), Filtered_Mean_level2(:,position_of_data)]); % This list the avaerage distance for each thrust experiment as a column where the rows represent the data type such as raw or filtered


total_estimate_error_raw = (rmse(1)/ betas(1,1))*((1/double(A(position_of_data,1)))+(1/degrees_of_freedom(1))+((experiment_distance_x_avg(1)-Calibration_delta_x_avg(1))^2)/((betas(1,1)^2 )* Calibration_sse_force))^(1/2); %%Total error for raw data
total_estimate_error_filter1 = (rmse(2)/ betas(2,1))*((1/double(A(position_of_data,1)))+(1/degrees_of_freedom(2))+((experiment_distance_x_avg(2)-Calibration_delta_x_avg(2))^2)/((betas(2,1)^2 )* Calibration_sse_force))^(1/2); %%Total error for filter 1 data
total_estimate_error_filter2 =  (rmse(3)/ betas(3,1))*((1/double(A(position_of_data,1)))+(1/degrees_of_freedom(3))+((experiment_distance_x_avg(3)-Calibration_delta_x_avg(3))^2)/((betas(3,1)^2 )* Calibration_sse_force))^(1/2); %%Total error for filter 2 data
total_estimate_error(:,(position_of_data - Number_of_calibration_experiments)) = [total_estimate_error_raw; total_estimate_error_filter1; total_estimate_error_filter2]; % Makes the total list of erros. Each column is a different exeperiment and the rows are the different data types. Raw or filtered
 
stand_alone_estimate_error_raw(:,(position_of_data - Number_of_calibration_experiments)) = [(rmse(1) / betas(1,1))*(1+(1/degrees_of_freedom(1))+((Raw_distance_data(:,position_of_data)-Calibration_delta_x_avg(1)).^2)/((betas(1,1)^2 )* Calibration_sse_force)).^(1/2)]; %Error for each trial raw the next two are the erros for the filter settings
stand_alone_estimate_error_filter1(:,(position_of_data - Number_of_calibration_experiments)) =[(rmse(2) / betas(2,1))*(1+(1/degrees_of_freedom(2))+((Filtered_Mean_level1(:,position_of_data)-Calibration_delta_x_avg(2)).^2)/((betas(2,1)^2 )* Calibration_sse_force)).^(1/2)]; 
stand_alone_estimate_error_raw_filter2(:,(position_of_data - Number_of_calibration_experiments)) = [(rmse(3) / betas(3,1))*(1+(1/degrees_of_freedom(3))+((Filtered_Mean_level2(:,position_of_data)-Calibration_delta_x_avg(3)).^2)/((betas(3,1)^2 )* Calibration_sse_force)).^(1/2)]; 


%without outliers erros calc
no_outlier_rmse = [goodness_no_outlier_raw_calibration.rmse; goodness_no_outlier_filter1_calibration.rmse; goodness_no_outlier_filter2_calibration.rmse]; %makse a vector of the rmse for each data type using the output from the previous section    
no_outlier_degrees_of_freedom = [goodness_no_outlier_raw_calibration.dfe; goodness_no_outlier_filter1_calibration.dfe; goodness_no_outlier_filter2_calibration.dfe];
%no_outlier_experiment_distance_x_avg = mean([no_outliers_distance_calibration_raw(:,position_of_data), no_outliers_distance_calibration_filter1(:,position_of_data), no_outliers_distance_calibration_filter2(:,position_of_data)]); % This list the avaerage distance for each thrust experiment as a column where the rows represent the data type such as raw or filtered

no_outlier_total_estimate_error_raw = (no_outlier_rmse(1)/ no_outliers_betas(1,1))*((1/double(A(position_of_data,1)))+(1/no_outlier_degrees_of_freedom(1))+((experiment_distance_x_avg(1)-no_calibration_Calibration_delta_x_avg(1))^2)/((no_outliers_betas(1,1)^2 )* no_outlier_Calibration_sse_force(1)))^(1/2); %%Total error for raw data
no_outlier_total_estimate_error_filter1 = (no_outlier_rmse(2)/ no_outliers_betas(2,1))*((1/double(A(position_of_data,1)))+(1/no_outlier_degrees_of_freedom(2))+((experiment_distance_x_avg(2)-no_calibration_Calibration_delta_x_avg(2))^2)/((no_outliers_betas(2,1)^2 )* no_outlier_Calibration_sse_force(2)))^(1/2); %%Total error for filter 1 data
no_outlier_total_estimate_error_filter2 =  (no_outlier_rmse(3)/ no_outliers_betas(3,1))*((1/double(A(position_of_data,1)))+(1/no_outlier_degrees_of_freedom(3))+((experiment_distance_x_avg(3)-no_calibration_Calibration_delta_x_avg(3))^2)/((no_outliers_betas(3,1)^2 )* no_outlier_Calibration_sse_force(3)))^(1/2); %%Total error for filter 2 data
no_outlier_total_estimate_error(:,(position_of_data - Number_of_calibration_experiments)) = [no_outlier_total_estimate_error_raw; no_outlier_total_estimate_error_filter1; no_outlier_total_estimate_error_filter2]; % Makes the total list of erros. Each column is a different exeperiment and the rows are the different data types. Raw or filtered

no_outlier_stand_alone_estimate_error_raw(:,(position_of_data - Number_of_calibration_experiments)) = [(no_outlier_rmse(1) / no_outliers_betas(1,1))*(1+(1/no_outlier_degrees_of_freedom(1))+((Raw_distance_data(:,position_of_data)-no_calibration_Calibration_delta_x_avg(1)).^2)/((no_outliers_betas(1,1)^2 )* no_outlier_Calibration_sse_force(1))).^(1/2)]; %Error for each trial raw the next two are the erros for the filter settings
no_outlier_stand_alone_estimate_error_filter1(:,(position_of_data - Number_of_calibration_experiments)) =[(no_outlier_rmse(2) / no_outliers_betas(2,1))*(1+(1/no_outlier_degrees_of_freedom(2))+((Filtered_Mean_level1(:,position_of_data)-no_calibration_Calibration_delta_x_avg(2)).^2)/((no_outliers_betas(2,1)^2 )* no_outlier_Calibration_sse_force(2))).^(1/2)]; 
no_outlier_stand_alone_estimate_error_raw_filter2(:,(position_of_data - Number_of_calibration_experiments)) = [(no_outlier_rmse(3) / no_outliers_betas(3,1))*(1+(1/no_outlier_degrees_of_freedom(3))+((Filtered_Mean_level2(:,position_of_data)-no_calibration_Calibration_delta_x_avg(3)).^2)/((no_outliers_betas(3,1)^2 )* no_outlier_Calibration_sse_force(3))).^(1/2)]; % note you will want to come back and adjust this .You are including all the data in the thrust cacualtionsinstead of removing the outliers
    end
end



calibration_force_to_distance_data.figure_original_residual = figure('Name','Orginal Data','NumberTitle','off');

subplot(3,1,1);
plot(curve_raw_calibration,force_calibration_data, distance_calibration_raw,'residuals')
title('Residuals Raw Data');
xlabel("Force in mico newtons");
ylabel( "Errors");

subplot(3,1,2);
plot(curve_filter1_calibration,force_calibration_data, distance_calibration_filter1,'residuals') 
title('Residuals Filter1 Data');
xlabel("Force in mico newtons");
ylabel( "Errors");

subplot(3,1,3);
plot(curve_filter2_calibration,force_calibration_data, distance_calibration_filter2,'residuals')
title('Residuals Filter2 Data');
xlabel("Force in mico newtons");
ylabel( "Errors");



calibration_force_to_distance_data.figure_original_model = figure();

subplot(3,1,1);
plot(curve_raw_calibration,force_calibration_data, distance_calibration_raw)
title('Model Plot of Raw Data');
xlabel("Force in mico newtons");
ylabel( "Distance in micro meters");

subplot(3,1,2);
plot(curve_filter1_calibration,force_calibration_data, distance_calibration_filter1)
title('Model Plot of Filtered1 Data');
xlabel("Force in mico newtons");
ylabel( "Distance in micro meters");

subplot(3,1,3);
plot(curve_filter2_calibration,force_calibration_data, distance_calibration_filter2)
title('Model Plot of Filtered2 Data');
xlabel("Force in mico newtons");
ylabel( "Distance in micro meters");




if sum(outlier_raw_data_calibration) > 0 %if there are no model outliers than you do not need to run the outlier part of the code

    calibration_force_to_distance_data_no_outliers.outlier_residual = figure('Name','Without outliers','NumberTitle','off');


subplot(3,1,1);
plot(no_outlier_raw_calibration_curve,no_outliers_force_calibration_data_raw, no_outliers_distance_calibration_raw,'residuals')
title('Residuals With No Outliers Raw Data');
xlabel("Force in mico newtons");
ylabel( "Errors");

subplot(3,1,2);
plot(no_outlier_filter1_calibration_curve,no_outliers_force_calibration_data_filt1, no_outliers_distance_calibration_filter1,'residuals') 
title('Residuals With No Outliers Filter1 Data');
xlabel("Force in mico newtons");
ylabel( "Errors");

subplot(3,1,3);
plot(no_outlier_filter2_calibration_curve,no_outliers_force_calibration_data_filt2, no_outliers_distance_calibration_filter2,'residuals')
title('Residuals With No Outliers Filter2 Data');
xlabel("Force in mico newtons");
ylabel( "Errors");

calibration_force_to_distance_data_no_outliers.outlier_residual_line = figure();

subplot(3,1,1);
qqplot(output_no_outlier_raw_calibration.residuals);
title('Quadrant Plot of Residual With No Outliers verse Model Raw Data');
%xlabel("Force in mico newtons");
%ylabel( "Distance in micro meters");

subplot(3,1,2);
qqplot(output_no_outlier_filter1_calibration.residuals); 
title('Quadrant Plot of Residual With No Outliers verse Model Filtered1 Data');

subplot(3,1,3);
qqplot(output_no_outlier_filter2_calibration.residuals); 
title('Quadrant Plot of Residual With No Outliers verse Model Filtered2 Data');

calibration_force_to_distance_data_no_outliers.outlier_model = figure();

subplot(3,1,1);
plot(no_outlier_raw_calibration_curve,no_outliers_force_calibration_data_raw, no_outliers_distance_calibration_raw)
title('Model Plot With No Outliers of Raw Data');
xlabel("Force in mico newtons");
ylabel( "Distance in micro meters");

subplot(3,1,2);
plot(no_outlier_filter1_calibration_curve,no_outliers_force_calibration_data_filt1, no_outliers_distance_calibration_filter1)

title('Model Plot With No Outliers of Filtered1 Data');
xlabel("Force in mico newtons");
ylabel( "Distance in micro meters");

subplot(3,1,3);
plot(no_outlier_filter2_calibration_curve,no_outliers_force_calibration_data_filt2, no_outliers_distance_calibration_filter2)
title('Model Plot With No Outliers of Filtered2 Data');
xlabel("Force in mico newtons");
ylabel( "Distance in micro meters");


end

% this section is for the output of the function:
calibration_force_to_distance_data.curve_raw_calibration =  curve_raw_calibration;
calibration_force_to_distance_data.goodness_raw_calibration = goodness_raw_calibration;
calibration_force_to_distance_data.curve_filter1_calibration = curve_filter1_calibration;
calibration_force_to_distance_data.goodness_filter1_calibration = goodness_filter1_calibration;
calibration_force_to_distance_data.curve_filter2_calibration = curve_filter2_calibration;
calibration_force_to_distance_data.goodness_filter2_calibration = goodness_filter2_calibration;

calibration_force_to_distance_data.betas = betas;

calibration_force_to_distance_data.total_estimate_error = total_estimate_error;
calibration_force_to_distance_data.stand_alone_estimate_error_raw = stand_alone_estimate_error_raw;
calibration_force_to_distance_data.stand_alone_estimate_error_filter1 = stand_alone_estimate_error_filter1;
calibration_force_to_distance_data.stand_alone_estimate_error_raw_filter2 = stand_alone_estimate_error_raw_filter2;

% data for outlier

if sum(outlier_raw_data_calibration) > 0 %if there are no model outliers than you do not need to run the outlier part of the code
calibration_force_to_distance_data_no_outliers.outlier_list = outlier_list;

calibration_force_to_distance_data_no_outliers.curve_raw_calibration =  no_outlier_raw_calibration_curve;
calibration_force_to_distance_data_no_outliers.goodness_raw_calibration = goodness_no_outlier_raw_calibration;
calibration_force_to_distance_data_no_outliers.curve_filter1_calibration = no_outlier_filter1_calibration_curve;
calibration_force_to_distance_data_no_outliers.goodness_filter1_calibration = goodness_no_outlier_filter1_calibration;
calibration_force_to_distance_data_no_outliers.curve_filter2_calibration = no_outlier_filter2_calibration_curve;
calibration_force_to_distance_data_no_outliers.goodness_filter2_calibration = goodness_no_outlier_filter2_calibration;

calibration_force_to_distance_data_no_outliers.betas = no_outliers_betas;

calibration_force_to_distance_data_no_outliers.total_estimate_error = no_outlier_total_estimate_error;
calibration_force_to_distance_data_no_outliers.stand_alone_estimate_error_raw = no_outlier_stand_alone_estimate_error_raw;
calibration_force_to_distance_data_no_outliers.stand_alone_estimate_error_filter1 = no_outlier_stand_alone_estimate_error_filter1;
calibration_force_to_distance_data_no_outliers.stand_alone_estimate_error_raw_filter2 = no_outlier_stand_alone_estimate_error_raw_filter2;

else

    calibration_force_to_distance_data_no_outliers = 0;
   

end