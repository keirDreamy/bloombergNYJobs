
function [for_output] =  organize_exp_power_data(A, probe_mult,FolderDirectory)

%------------debug section if you need it-----


debug = false;
if debug == true
    clear
probe1_mult = 10;
probe2_mult = 1000;
probe3_mult = 1; %if these are not being used, set them to 0. The code will reconize the number of porbes, so even if it is not set to 0, it will not cause a problem


FolderDirectory = "/Users/keirdaniels/Documents/MATLAB/Final thrust Exp./Dimitri oscilloscope thrust data summer 2019/thrust test 6_26_19 thruster 7 /Power"
probe_mult = [probe1_mult,probe2_mult,probe3_mult];
[A] =  files_organizer(FolderDirectory,"/*.csv");

end
    
    
%------------end of debug section----------





B = size(A(:,1));
B = B(1,1);

trials_array = str2double(convertStringsToChars(A(:,1)));
max_trials_for_for_storing_data = max((trials_array)); % this is for storing the data in case the number of trial are differnt 

commulative_entries = 0; %setting this to 0 
error =  int16.empty(5,0);% this is for the stats


for exp_number = 1:B
    
Current_path = strcat(FolderDirectory,"/",A(exp_number,2)); %this is the current experiment that the code is running through
count = str2num(A(exp_number,1)); %I believe this is the number of trials for the experiment


for  trial = 1:max_trials_for_for_storing_data %The trial will be just the number of trials that are available, not the actually value
    
   This_Trialstring =  num2str(trial);
    current_file_for_data =  strcat(Current_path,This_Trialstring,'.csv') ;
   
    if exist(current_file_for_data, 'file') ~= 2 %determines if there is a file. To help catch cases when not every thurst trial had a power value
    
    real_file = false;
    [power_values(trial)] = power_calculations(current_file_for_data,probe_mult,A(exp_number,2),This_Trialstring,real_file);
    
 
    else
    real_file = true;
    [power_values(trial)] = power_calculations(current_file_for_data,probe_mult,A(exp_number,2),This_Trialstring,real_file,resitor);
    end
    
end

    volt_avg(:,exp_number) = [power_values.volt_avg,nan(1 , max_trials_for_for_storing_data-trial)]';
    current_avg(:,exp_number) = [power_values.current_avg, nan(1 , max_trials_for_for_storing_data-trial)]';
    power_avg(:,exp_number) = [power_values.power_avg, nan(1 , max_trials_for_for_storing_data-trial)]';
    %probe3_avg(:,exp_number) = [power_values.volt_avgProbe3, nan(1 , max_trials_for_for_storing_data-trial)]';
    volt_max(:,exp_number) = [power_values.volt_max, nan(1 , max_trials_for_for_storing_data-trial)]';
    current_max(:,exp_number) = [power_values.current_max, nan(1 , max_trials_for_for_storing_data-trial)]';
    power_max(:,exp_number) = [power_values.power_max, nan(1 , max_trials_for_for_storing_data-trial)]';
    %prob3_max(:exp_number) = [power_values.power_max, nan(1 , max_trials_for_for_storing_data-trial)]';
    pulse_width_in_time(:,exp_number) = [power_values.pulse_width_in_time, nan(1 , max_trials_for_for_storing_data-trial)]';
    total_energy_in_pulse(:,exp_number) = [power_values.total_energy_in_pulse, nan(1 , max_trials_for_for_storing_data-trial)];
    
   
  
    for_output.data(commulative_entries + 1:commulative_entries + trial) = power_values;
  
 commulative_entries = commulative_entries + trial;
 
 
 

end

[for_output.stats_volt_avg, for_output.stats_Names] = summary_of_stats(volt_avg, error);
[for_output.stats_current_avg] = summary_of_stats(current_avg, error);
[for_output.stats_power_avg] = summary_of_stats(power_avg, error);
[for_output.stats_volt_max] = summary_of_stats(volt_max, error);
[for_output.stats_current_max] = summary_of_stats(current_max, error);
[for_output.stats_power_max] = summary_of_stats(power_max, error);
[for_output.stats_pulse_width_in_time] = summary_of_stats(pulse_width_in_time, error);
[for_output.total_energy_in_pulse] = summary_of_stats(total_energy_in_pulse, error);


for_output.exp_list = [A(:,1),A(:,2)]
for_output.max_trials_for_for_storing_data = max_trials_for_for_storing_data;

end


