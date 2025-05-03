clear

 %--------This section requires YOUR INPUT--------------
 %This program will take in the raw experiment data and output an excel and
 %a pdf file. The excel will have the numeric data and the pdf will have
 %the charts. 
 
%do you want to publish the data with thrust values or are you just checking the calibration? Enter true for publishing all the data 
% Enter false if you only want to 
% runt he calibration.  
 

inputs.Publish_data = true;  

%If you want to produce graphs of the original trials of the experiments.
%
% 
%  PREFORMATTED
%  TEXT
% 
%Note this takes longer to run, but also show the most details. Set it to
%false if you don't want it and true if you do. 
inputs.show_graphs_of_original_experiments = true;
 
inputs.Output_file = '111120 no Mag field';  %Do not add an extension and keep it with single quotes. This sets the name of the ouput files excel that will be saved
inputs.FolderDirectory = "/Users/keirdaniels/Documents/MATLAB/thrust_bar_review/After balance/111120 no mag/Thrust"; %Keep this in quotes! points to the folder that has the raw sensor data. 
%The pdf will also be saved in this folder, but  with the name this command
%tuns_thrust_exp. 
%The excel file will be saved in folder the user is currently in. 

%The above  contains the name of the directory that houses the files. 
%The files in the directory should be named as the following:
%Thrust or calibration "_" Experiment name "_" trial number ".txt"
% For the calibration files, the experiment name should be: volt#value"V"
%Example of calibration experiment file names:
%Calibration_0V_1.txt ,Calibration_60V_1.txt, Calibration_100V_1.txt Do not
%write out volts completly
% Example of thurst experiment file name: thrust_10hzCathodPlate_1.txt




inputs.Gap = 3; %This sets the gap length in terms of seconds. This is the length of time that you want to ignore before averaging the distance data output by the sensor
%The gap helps to ignore the rise or fall period of the data which would
%skew the average.
inputs.run_time = 30; %This is the total time that each section of the thrust experiment runs


%The following is an option to override values when needed because part othe expeirment was
%different. Did this for Denis when his thruster was starting to die when
%we were running it for 30 seconds. Right not it is only able to override
%one experiement. Future enhancments can allow for more. 
inputs.overide = 'thurst_30htz_accel_off_'; %Name of the experiment ignoring the trial and txt part of the name
inputs.Overide_Gap = 3; 
inputs.Override_run_time = 20;

%The variable Cpath identifies where the raw data for the calibrators force
%to voltage data is stored. This is the data that was collected by the
%scale outside of the chamber
inputs.Cpath = '/Users/keirdaniels/Documents/MATLAB/Examples/For Denis/inital_calibration_dataB.txt';



%---------------------------
%The overall algo is as follows:
%1. Format and organize the files and count the experiments
%2. Calculate the distance calculations for the
%experiments including the calibrator. 
%3. Make a force to volts curve from the calibrator scale data. 
%4. Take the output from 3 and calculate the force for each calibration voltage used during the calibration in the chamber
%5. Run a linear regression on the calibration force to distance (delta x)
%data and output the errors from the calibration using both the calibration
%data and the data from each thrust exeperiment
%6.Using the calibration force to distance output, calculate the force on the thrust exeperiments
%output the data into a file. 


%Debug recomendations---- Check the trial numbers are sequentail.
%Check the files have each run for lon enough. If there is not enough data
%the file will fail
%Check that thhe file names are setup right, There should not be more than
%two _ characters
%To complete the calibration curves, there mus tbe at least two different
%calibration experiments otherswise a line curve cannot b estimater using
%lse, so the code will fail.


%------DO NOT ADJUST ANYTHING BEYOND THIS POINT---------------

inputs.Output_file = [inputs.Output_file, '.xls']  %makes the file into an xls file

[inputs.A, inputs.file_ordered] =  files_organizer(inputs.FolderDirectory,"/*.txt")

if exist(inputs.Output_file, 'file')==2 %removes the old excel files if they were in the directory already. 
    %This could be the case if you ran calibration tests first. The
    %writetabl function in matlab writes data in the same file instead of
    %erasing, which is why we delete the file. 
  delete(inputs.Output_file);
end


if inputs.Publish_data == false
   
    organize_experiment_and_sensor_data(inputs)
    
else




inputs.Output_file = [inputs.Output_file, '.xls']    
inputs.file_directory_for_pdf_output = convertStringsToChars(inputs.FolderDirectory); %the name of the directory needs to be a char
assignin('base', 'inputs', inputs); 
pubopt.codeToEvaluate = ['inputs',char(10),'thrust_data_analysis(inputs)',char(10)];
pubopt.format = 'pdf';
pubopt.showCode = false;
pubopt.catchError = false;
pubopt.useNewFigure = true;
pubopt.outputDir = inputs.file_directory_for_pdf_output
publish('thrust_data_analysis.m', pubopt)

end 

close all %this closes all of the plots

    