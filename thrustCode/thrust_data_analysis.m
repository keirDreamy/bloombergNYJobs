
function thrust_data_analysis(inputs)
%clear %this is needed to make sure all the varibles have been cleared before each run

 
%------DO NOT ADJUST ANYTHING BEYOND THIS POINT---------------

%This following section goes through the directory and makes a list of
%the experiments and the number of trial for each experiment
Output_file = inputs.Output_file;


[exp_list_sensor_stats] = organize_experiment_and_sensor_data(inputs);

 %The following is the external function that runs on the calibration force to voltage data
 %This external function outputs the curve data for the force to voltage
 %curve
 
[cal_stats, Cal_cof, results, calib] = Calibration_of_force(inputs.Cpath); %Calibration_calc(Cpath);


%NOTE THE ABOVE FORCE CALCULATION USES A SECOND ORDER CURVE, WE BELIEVE THE
%ERROR TERMS FROM THESE ESTIMATES SHOULD BE LOW COMPARED TO THE DISTANCE
%CALCULATIONS IN THE CALIBRATION SO THESE ERROR TERMS WERE EXCLUDED FOR THE
%PURPOSE OF THE THRUST CALCULATIONS
 
% The next function creates the force to distance calibration curve and the
% errors assocaited with them
 
[calibration_force_to_distance_data, calibration_force_to_distance_data_no_outliers] = calibration_Force_distance(exp_list_sensor_stats, Cal_cof);

if inputs.Publish_data == false %this is just used to output to the compand window when that data does not need to be published
organize_output_data(Output_file,exp_list_sensor_stats,calibration_force_to_distance_data,1,cal_stats,0,false);%this function organizes the data for output
return
end

%Plots of calibration data:
%force calc
figure_title1 = 'Original Force Data';
disp('Original Force Data');
[force_estimate] = force_estimate_function(calibration_force_to_distance_data, exp_list_sensor_stats,figure_title1);
%output section
organize_output_data(Output_file,exp_list_sensor_stats,calibration_force_to_distance_data,1,cal_stats,force_estimate,true);

if isstruct(calibration_force_to_distance_data_no_outliers) == 0 %if there is no outlier relative to the model
return

else%If there are calibration outliers add this section to the output
    
figure_title2 = 'Force Data without outliers';
disp('Force Data without outliers');
%force calc
[force_estimate_no_outliers] = force_estimate_function(calibration_force_to_distance_data_no_outliers, exp_list_sensor_stats,figure_title2);
%output section
organize_output_data(Output_file,exp_list_sensor_stats,calibration_force_to_distance_data_no_outliers,2,cal_stats,force_estimate_no_outliers,true);

end
end



