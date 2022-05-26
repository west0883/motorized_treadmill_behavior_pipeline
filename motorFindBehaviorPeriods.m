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


function [] = findBehaviorPeriods(trial, possible_speeds)
    % Trial is a n x 4 cell created by extractMotorData.m
   
    % Load list of behavior periods.
    load([dir_exper 'Behavior_Conditions.mat']); 
    
    % Find the start of the trial by finding the string 'Starting Mouse
    % Runner' in the first colomn. 
    start_point = find(strcmp(trial(:,1), 'Starting Mouse Runner'));
  
    % Initialize empty behavior condition variables.
    for i = 1:size(Conditions,2)
        eval([Conditions(1).short ' = [];']);  
    end
    
    % Go through every entry after the start point, not including the last
    % 'Done' entry.
    for i = start_point + 1 : size(trial,1) - 1
       
        % Find the relevant time ranges for this stage. 
        % If two consecutive times are the same (happens when motor is
        % already stopped), skip this stage and continue next iteration
        if trial{i, 1} == trial{i + 1, 1}
            continue
        % Otherwise, pull out the time range. 
        else
            time_range = [trial{i, 1} trial{i + 1, 1} - 1]; 
        end 
        
        % Pull out the speed, previous speed, and the  "activity tag" for
        % categorizing.
        speed = trial{i, 2}; 
        activity_tag = trial{i, 3};
        
        % If it's the first stage, set previous speed to 0, just in case
        if i == start_point +1 
            
            previous_speed = 0;
            
        else 
            % Otherwise, get speed from previous stage.
            previous_speed = trial{i - 1, 2};
            
        end
        
        % First, go through each activity tag. (Will go through speeds as a
        % sub-set of each activity).
        
        if activity_tag == 1 % motor accelerating

            switch previous_speed 

                case 0

                    % Starting 


                otherwise 

                    % Accelerating

            end

        else 
         % All others can be divided with just the activity tag. 

 
        end 
           
                
    end
end 