% motorFindBehaviorPeriods.m
% Sarah West
% 11/16/21

% Makes time ranges of different behavior periods output-ed by the Arduino
% program controlling the random motor stages. 

% Activity tag list of possible periods 
%  *  1 = motor accelerating
%  *  2 = motor decelerating
%  *  3 = motor maintaining
%  *  4 = motor stopping
%  *  5 = motor finished stopping // Keeping this because it quickly finds the start of a rest period.
%  *  6 = motor reached faster speed
%  *  7 = motor reached slower speed
%  *  8 = tone: starting
%  *  9 = tone: stopping
%  *  10 = tone: accelerating
%  *  11 = tone: decellerating
%  *  12 = tone: maintaining
%  *  13 = Warning cue: probe, no warning.
%  *  14 = Motor: probe, no warning tone, accelerating.
%  *  15 = Motor: probe, no warning tone, decelerating.
%  *  16 = Motor: probe, no warning tone, stopping.
%  *  17 = Motor: probe, no warning tone, maintaining.
%  *  18 = Warning cue: probe, starting cue, no change in motor.
%  *  19 = Warning cue: probe, stopping cue, no change in motor.
%  *  20 = Warning cue: probe, accerlerating cue, no change in motor.
%  *  21 = Warning cue: probe, decelerating cue, no change in motor.
%  *  22 = Warning cue: probe, maintaining cue, no change in motor.
%  *  23 = Motor probe: no change.

% Input: 
% useAccel -- a boolean. If accels weren't used, the columns will be
% different.
% trial -- an nx 4 or n x 5 cell created by extractMotorData.m. Time, speed, [accel,] activity tag, message 
% Output: 
% all_periods -- a structure that holds all the behavior periods.
function [all_periods] = findBehaviorPeriods(trial, useAccel)
    
    % Put all info per stage into a structure called behavior_period, then 
    % concatenate each field per activity tag. 
     
    % Set columns based on useAccel. 
    if useAccel 
        time_column = 1;
        speed_column = 2;
        accel_column = 3; 
        activity_column = 4; 
    else
        time_column = 1;
        speed_column = 2;
        activity_column = 3;
        
        % Set a defaul accel that was used. 
        default_accel = 800; 
    end 
    
    % Load list of behavior periods.
    load([dir_exper 'Behavior_Conditions.mat']); 
  
    % Initialize empty behavior condition variables with fields
    for condi = 1:size(Conditions,2)
        eval(['all_periods.' Conditions(condi).short '.speed = [];']); % The current speed. Is the ending speed for speed transitions
        eval(['all_periods.' Conditions(condi).short '.accel = [];']); % Needed for speed transitions
        eval(['all_periods.' Conditions(condi).short '.previos_speed = [];']); % Needed for immediately post-transition. Is the starting speed for transition periods 
        eval(['all_periods.' Conditions(condi).short '.previous_accel = [];']); % Needed for immediately post-transition
        eval(['all_periods.' Conditions(condi).short '.two_speeds_ago = [];']); % May need for immediately post-transition analysis (to know what kind of transition just happened)
    end
    
    % Find the start of the trial by finding the string 'Starting Mouse
    % Runner' in the first colomn. 
    start_point = find(strcmp(trial(:,1), 'Starting Mouse Runner'));
    
    % Go through every entry after the start point, not including the last
    % 'Done' entry.
    for i = start_point + 1 : size(trial,1) - 1
       
        % Find the relevant time ranges for this stage. 
        % If two consecutive times are the same (happens when motor is
        % already stopped), skip this stage and continue next iteration
        if trial{i, time_column} == trial{i + 1, time_column}
            continue
        % Otherwise, pull out the time range. 
        else
            behavior_period.time_range = [trial{i,  time_column} trial{i + 1,  time_column} - 1]; 
        end 
        
        % Pull out the speed, previous speed, and the  "activity tag" for
        % categorizing.
        behavior_period.speed = trial{i, speed_column}; 
        behavior_period.accel = trial{i, accel_column}; 
        behavior_period.activity_tag = trial{i, activity_column};
    
        % If it's the first stage, set previous speed to 0, just in case
        if i == start_point +1 
            behavior_period.previous_speed = 0;
            
        else 
            % Otherwise, get speed and accel from previous stage.
            behavior_period.previous_speed = trial{i - 1, speed_column};
            behavior_period.previous_accel = trial{i - 1, accel_column}; 
        end
        
        % If the stage isn't one of the first two stages, get the 2 speeds
        % ago value.
        if i > start_point + 2
            behavior_period.two_speeds_ago = trial{i - 2, speed_column};
        end 
        
        % Divide acceleration tag into actual accel and starting
        
        % Motor accelerating
        if activity_tag == 1 

            if behavior_period.previous_speed == 0

                    % Starting
                    activity_tag = 24;

            end
        
        % Motor finished accelerating     
        elseif activity_tag == 6     
             
            % Have to use the speed from 2 stages ago. If 0, is a finished
            % starting. 
            if behavior_period.two_speeds_ago == 0
                
                activity_tag = 25; 
                
            end 
 
        end 
           
        % Now concatenate fields based on activity_tag. All concatenated at
        % once. 
        eval(['all_periods.' Conditions(activity_tag).short '.speed = [' Conditions(activity_tag).short '; behavior_period];']);
                
    end
end 