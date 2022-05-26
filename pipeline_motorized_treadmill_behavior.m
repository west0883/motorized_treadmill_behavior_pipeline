% pipeline_motorized_treadmill_behavior.m
% Sarah West
% 11/16/21 

% Use "create_mice_all.m" before using this.

%% Initial setup
% Put all needed paramters in a structure called "parameters", which you
% can then easily feed into your functions. 
clear all; 

% Output Directories

% Create the experiment name. This is used to name the output folder. 
parameters.experiment_name='Random Motorized Treadmill\test data';

% Output directory name bases
parameters.dir_base='Y:\Sarah\Analysis\Experiments\';
parameters.dir_exper=[parameters.dir_base parameters.experiment_name '\']; 

% *********************************************************
% Data to preprocess

% (DON'T EDIT). Load the "mice_all" variable you've created with "create_mice_all.m"
load([parameters.dir_exper 'mice_all.mat']);

% Add mice_all to parameters structure.
parameters.mice_all = mice_all; 

% ****Change here if there are specific mice, days, and/or stacks you want to work with**** 
% If you want to change the list of stacks, use ListStacks function.
% Ex: numberVector=2:12; digitNumber=2;
% Ex cont: stackList=ListStacks(numberVector,digitNumber); 
% Ex cont: mice_all(1).stacks(1)=stackList;

%parameters.mice_all(1).days = mice_all(1).days(2:5); 

% **********************************************************************8
% Input Directories

% Establish the format of the daily/per mouse directory and file names of 
% the collected data. Will be assembled with CreateFileStrings.m Each piece 
% needs to be a separate entry in a cell  array. Put the string 'mouse 
% number', 'day', or 'stack number' where the mouse, day, or stack number 
% will be. If you concatenated this as a sigle string, it should create a 
% file name, with the correct mouse/day/stack name inserted accordingly. 
parameters.dir_dataset_name={['Y:\Sarah\Data\Motorized Treadmill'], '\', 'day', '\', 'mouse number', '\Arduino output\'};
parameters.input_data_name={'stack number', '.txt' }; 

% Give the number of digits that should be included in each stack number.
parameters.digitNumber=3; 

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

% Was PUTTY used for the recording? 
parameters.putty_flag = false;

% Radius of wheel, in cm.
parameters.wheel_radius = 8.5;
                                  
             
%% Extract data and save as .mat file.  (Can take awhile).
% From .log if PUTTY was used, from .txt files if it wasn't. 
extractMotorData(parameters);

%% Find behavior periods.

% For now, change the input data name--> might do something different later
parameters.input_data_name={'vel', 'stack number', '.mat'}; 

motorFindBehaviorPeriods(parameters);

%% Segment velocities.
segmentVelocities(parameters); 

%% Concatenate velocities per behavior period per mouse. 
% Also finds the average and std.
concatenateVelocities(parameters);

%% Concatenate velocities per behavior periods across mice.
% Also finds the average and std.
averageVelocitiesAcrossMice(parameters);

%% Plot average velocities. 

