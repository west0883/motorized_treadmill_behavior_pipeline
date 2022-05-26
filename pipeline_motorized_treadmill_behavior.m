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
% If you want to change the list of stacks, use ListStacks function.
% Ex: numberVector=2:12; digitNumber=2;
% Ex cont: stackList=ListStacks(numberVector,digitNumber); 
% Ex cont: mice_all(1).stacks(1)=stackList;

parameters.mice_all(1).days = parameters.mice_all(1).days(1:6);
parameters.mice_all(2).days = parameters.mice_all(2).days(1:5);
parameters.mice_all(3).days = parameters.mice_all(3).days(1:5);
% **********************************************************************8
% Input Directories

% Establish the format of the daily/per mouse directory and file names of 
% the collected data. Will be assembled with CreateFileStrings.m Each piece 
% needs to be a separate entry in a cell  array. Put the string 'mouse 
% number', 'day', or 'stack number' where the mouse, day, or stack number 
% will be. If you concatenated this as a sigle string, it should create a 
% file name, with the correct mouse/day/stack name inserted accordingly. 
parameters.dir_dataset_name={'Y:\Sarah\Data\Random Motorized Treadmill\', 'day', '\', 'mouse number', '\Arduino output\'};
parameters.input_data_name={'0', 'stack number', '.txt' }; 

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
parameters.useAccel = false;

% Was PUTTY used for the recording? 
parameters.putty_flag = false;

% Radius of wheel, in cm.
parameters.wheel_radius = 8.5;
                                  
% Smallest time increment. All accelerations and stage times should be an
% exact whole second or half second in duration. 
parameters.smallest_time_increment = 0.5 * parameters.fps;

% Amount of time after a transition that you want to start counting as a
% "continued" behavior, in seconds. (In spontanuous locomotion paper,
% fluorescence took ~2.5 s to return to baseline after the mice stopped.)
parameters.continued_window = 3; 

%% Extract data and save as .mat file.  
extractMotorData(parameters);

%% Find behavior periods.
motor_FindBehaviorPeriods_all(parameters);

%% Make into more code-readable structure format
motor_behavior_period_structures(parameters); 
