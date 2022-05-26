% pipeline_motorized_treadmill_behavior.m
% Sarah West
% 11/16/21 

% Use "create_mice_all.m" and "create_conditions_names.m" before using this.

%% Initial setup
% Put all needed parameters in a structure called "parameters", which you
% can then easily feed into your functions. 
clear all; 

% Output Directories

% Create the experiment name. This is used to name the output folder. 
parameters.experiment_name='Random Motorized Treadmill';

% Output directory name bases
parameters.dir_base='Y:\Sarah\Analysis\Experiments\';
parameters.dir_exper=[parameters.dir_base parameters.experiment_name '\']; 

% *********************************************************
% Data to process

% (DON'T EDIT). Load the "mice_all" variable you've created with "create_mice_all.m"
load([parameters.dir_exper 'mice_all.mat']);

% Add mice_all to parameters structure.
parameters.mice_all = mice_all; 

% Load the names of conditions from create_conditions_names.m
load([parameters.dir_exper 'Behavior_Conditions.mat']); 

% Add Conditions to parameters structure.
parameters.Conditions = Conditions; 

% ****Change here if there are specific mice, days, and/or stacks you want to work with**** 
parameters.mice_all = parameters.mice_all(1);

% **********************************************************************8
% Input Directories

% Establish the format of the daily/per mouse directory and file names of 
% the collected data. Will be assembled with CreateFileStrings.m Each piece 
% needs to be a separate entry in a cell  array. Put the string 'mouse 
% number', 'day', or 'stack number' where the mouse, day, or stack number 
% will be. If you concatenated this as a sigle string, it should create a 
% file name, with the correct mouse/day/stack name inserted accordingly. 
parameters.dir_dataset_name = {'Y:\Sarah\Data\Random Motorized Treadmill\', 'day', '\', 'mouse number', '\Arduino output\'};
%parameters.input_data_name = {'0', 'stack number', '.txt'};
parameters.input_data_name={'Motor_ArduinoOutput*.log'}; 

% Give the number of digits that should be included in each stack number.
parameters.digitNumber=2; 

% *************************************************************************
% Parameters

% Sampling frequency of serial monitor, in Hz. Arduino displays time in ms,
% so is almost always 1000 Hz.
parameters.wheel_Hz = 1000;

% Sampling frequency of collected brain data (per channel), in Hz or frames per
% second.
parameters.fps= 20; 

% Number of channels from brain data (need this to calculate correct
% "skip" time length).
parameters.channelNumber = 2;

% Number of frames you recorded from brain and want to keep (don't make chunks longer than this)  
parameters.frames=6000; 

% Number of initial brain frames to skip, allows for brightness/image
% stabilization of camera. Need this to know how much to skip in the
% behavior.
parameters.skip = 1200; 

% Using variable accelerations?
parameters.useAccel = true;

% Radius of wheel, in cm.
parameters.wheel_radius = 8.5;
                                  
% Smallest time increment. All accelerations and stage times should be an
% exact whole second or half second in duration. 
parameters.smallest_time_increment = 0.5 * parameters.fps;

% Amount of time after a transition that you want to start counting as a
% "continued" behavior, in seconds. (In spontanuous locomotion paper,
% fluorescence took ~2.5 s to return to baseline after the mice stopped.)
parameters.continued_window = 3; 

% Length of time (in seconds) you want continued behaviors to be divided
% into.
parameters.continued_chunk_length = 3; 

% Possble speeds 
parameters.speeds = [1600, 2000, 2400, 2800];

% Possible start/stop accels. Issue with 200 being used sometimes
parameters.accels_startstop = [200, 400, 600, 800];

% Possible acel/decel accels; issues with 600 being used sometimes
parameters.accels_acceldecel = [200, 400, 600, 800]; 

%% Extract data and save as .mat file -- with Putty

% Get only mice_all days with putty_for_motor = 'yes'.
for i = 1:numel(parameters.mice_all)
    putty_flags = strcmp({parameters.mice_all(i).days.putty_for_motor}, 'yes'); 
    parameters.mice_all(i).days(~putty_flags) = [];
end 

% Was PUTTY used for the recording? 
parameters.putty_flag = true;

% Iterations.
parameters.loop_list.iterators = {'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'day', {'loop_variables.mice_all(', 'mouse_iterator', ').days(:).name'}, 'day_iterator';
               'log', { 'dir("Y:\Sarah\Data\Random Motorized Treadmill\', 'day', '\', 'mouse', '\Arduino Output\Motor_ArduinoOutput*.log").name'}, 'log_iterator'; 
               'stack', {'[loop_variables.mice_all(',  'mouse_iterator', ').days(', 'day_iterator', ').stacks; loop_variables.mice_all(',  'mouse_iterator', ').days(', 'day_iterator', ').spontaneous]'}, 'stack_iterator'};

parameters.loop_variables.mice_all = parameters.mice_all;

% Input values
parameters.loop_list.things_to_load.log.dir = {'Y:\Sarah\Data\Random Motorized Treadmill\', 'day', '\', 'mouse', '\Arduino Output\'};
parameters.loop_list.things_to_load.log.filename= {'log'}; 
parameters.loop_list.things_to_load.log.variable= {}; 
parameters.loop_list.things_to_load.log.level = 'day';
parameters.loop_list.things_to_load.log.load_function = @readtext;

% Output values. 
parameters.loop_list.things_to_save.trial.dir = {[parameters.dir_exper 'behavior\extracted motor data\'], 'mouse', '\', 'day', '\'};
parameters.loop_list.things_to_save.trial.filename= {'trial', 'stack', '.mat'};
parameters.loop_list.things_to_save.trial.variable= {'trial'}; 
parameters.loop_list.things_to_save.trial.level = 'stack';

RunAnalysis({@extractMotorData}, parameters);

%% Extract data and save as .mat file -- with NO Putty
% Get only mice_all days with putty_for_motor = 'no'.
for i = 1:numel(parameters.mice_all)
    putty_flags = strcmp({parameters.mice_all(i).days.putty_for_motor}, 'no'); 
    parameters.mice_all(i).days(~putty_flags) = [];
end 


%% Find behavior periods.

% Iterators
parameters.loop_list.iterators = {'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'day', {'loop_variables.mice_all(', 'mouse_iterator', ').days(:).name'}, 'day_iterator';
               'stack', {'[loop_variables.mice_all(',  'mouse_iterator', ').days(', 'day_iterator', ').stacks; loop_variables.mice_all(',  'mouse_iterator', ').days(', 'day_iterator', ').spontaneous]'}, 'stack_iterator'};

parameters.loop_variables.mice_all = parameters.mice_all;

% Input
parameters.loop_list.things_to_load.trial.dir = {[parameters.dir_exper 'behavior\extracted motor data\'], 'mouse', '\', 'day', '\'};
parameters.loop_list.things_to_load.trial.filename= {'trial', 'stack', '.mat'};
parameters.loop_list.things_to_load.trial.variable= {'trial'}; 
parameters.loop_list.things_to_load.trial.level = 'stack';

% Output
parameters.loop_list.things_to_save.all_periods.dir = {[parameters.dir_exper 'behavior\period instances\'], 'mouse', '\', 'day', '\'};
parameters.loop_list.things_to_save.all_periods.filename= {'all_periods_', 'stack', '.mat'};
parameters.loop_list.things_to_save.all_periods.variable= {'all_periods'}; 
parameters.loop_list.things_to_save.all_periods.level = 'stack';

RunAnalysis({@motorFindBehaviorPeriods}, parameters);

%% Make into more later code-readable structure format
motor_behavior_period_structures(parameters); 
