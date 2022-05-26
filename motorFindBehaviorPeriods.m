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
%  *  26 = Continued walking.
%  *  27 = Continued rest.

% Input: 
% useAccel -- a boolean. If accels weren't used, the columns will be
% different.
% trial -- an nx 4 or n x 5 cell created by extractMotorData.m. Time, speed, [accel,] activity tag, message 
% Output: 
% all_periods -- a structure that holds all the behavior periods.
function [all_periods] = motorFindBehaviorPeriods(trial, parameters)
    
    % Put all info per stage into a structure called behavior_period, then 
    % concatenate each field per activity tag. 
     
    % Set columns based on useAccel. 
    if parameters.useAccel 
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
  
    % Initialize empty behavior condition variables with fields
    for condi = 1:size(parameters.Conditions,2)
        eval(['all_periods.' parameters.Conditions(condi).short '.time_range = [];']);
        eval(['all_periods.' parameters.Conditions(condi).short '.speed = [];']); % The current speed. Is the ending speed for speed transitions
        eval(['all_periods.' parameters.Conditions(condi).short '.accel = [];']); % Needed for speed transitions
        eval(['all_periods.' parameters.Conditions(condi).short '.previous_speed = [];']); % Needed for immediately post-transition. Is the starting speed for transition periods 
        eval(['all_periods.' parameters.Conditions(condi).short '.previous_accel = [];']); % Needed for immediately post-transition
        eval(['all_periods.' parameters.Conditions(condi).short '.two_speeds_ago = [];']); % May need for immediately post-transition analysis (to know what kind of transition just happened)
    end
    
    % Find the start of the trial by finding the string 'Starting Mouse
    % Runner' in the first colomn. 
    for i = 1:size(trial, 1)
        if strcmp(trial{i,1}, 'Starting Mouse Runner')
            
            % When you find it, get the index and break out of the loop
            start_point = i; % find(strcmp(trial{:,1}, 'Starting Mouse Runner'));
            
            break
        end 
    end 
    
    % Go through every entry after the start point, not including the last
    % 'finished stopping' or 'Done' entries
    for i = start_point + 1 : size(trial,1) - 2
        
        % Pull out the time range of this stage. Need to subtract out the
        % first reported time.
        behavior_period.time_range = [trial{i,  time_column} - trial{start_point +1 , time_column},  trial{i + 1,  time_column} - trial{start_point +1 , time_column} - 1]; 
        
        % Convert the time range to hemo-corrected frame range. (Convert to 
        % seconds, then multiply by brain sampling rate & round to nearest integer.) 
        behavior_period.time_range = round(behavior_period.time_range ./ parameters.wheel_Hz .* parameters.fps);
     
        % If the END of the time range falls within the skipped time range, don't
        % record it.
        if behavior_period.time_range(2) <= parameters.skip/parameters.channelNumber
            continue 
        % If only the beginning of the time range falls before the skipped 
        % time range, truncate that period to not include the skip, make the activity tag be the continued rest    
        elseif behavior_period.time_range(1) <= parameters.skip/parameters.channelNumber
             behavior_period.time_range(1) = parameters.skip/parameters.channelNumber + 1; 
             trial{i, activity_column} = 27;
        end 
         
        % If two consecutive times are the same (happens when motor is
        % already stopped), skip this stage and continue next iteration
        if trial{i, time_column} == trial{i + 1, time_column}
            continue
        end 
        
        % Round to nearest multiple of parameters.smallest_time_increment.
        behavior_period.time_range = parameters.smallest_time_increment .* round(behavior_period.time_range ./ parameters.smallest_time_increment); 
        
        % Add + 1 to start of time range, so each time point belongs to exactly one period 
        behavior_period.time_range(1) = behavior_period.time_range(1) + 1;
        
        % Subtract out the skip from the time range.
        behavior_period.time_range = behavior_period.time_range - parameters.skip/parameters.channelNumber; 
        
        % Pull out the speed, previous speed, and the  "activity tag" for
        % categorizing.
        behavior_period.speed = trial{i, speed_column}; 
        if parameters.useAccel == 1
            behavior_period.accel = trial{i, accel_column}; 
        else
            behavior_period.accel = default_accel;
        end
        activity_tag = trial{i, activity_column};
    
        % If it's the first stage, set previous speed to 0, just in case
        if i == start_point +1 
            behavior_period.previous_speed = 0;
            behavior_period.previous_accel = 0;
        else 
            % Otherwise, get speed and accel from previous stage.
            behavior_period.previous_speed = trial{i - 1, speed_column};
            if parameters.useAccel == 1 
                behavior_period.previous_accel = trial{i - 1, accel_column};
            else
                behavior_period.previous_accel = default_accel;
            end
        end
        
        % If the stage isn't one of the first two stages, get the 2 speeds
        % ago value.
        if i > start_point + 2
            behavior_period.two_speeds_ago = trial{i - 2, speed_column};
        else
            % Make it empty so you don't get yelled at by Matlab field
            % concatenation sizes.
            behavior_period.two_speeds_ago = []; 
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
        
        % No warning, motor accelerating    
        elseif activity_tag == 14
            if behavior_period.previous_speed == 0

                    % Starting
                    activity_tag = 28;

            end
        end 
         
        % Now concatenate fields based on activity_tag. All concatenated at
        % once. Must divide the "motor: finished ... " periods into recently
        % finished (< 3 seconds) and the "continued" periods-- have to do 
        % this here because otherwise you're increasing the size of your
        % trial list.
        switch activity_tag
            
            % Walking periods
            case num2cell([5, 6, 7, 25]) 
                
                % If the available time range is above the specified
                % continued window, divide them and concatenat separately
                if (behavior_period.time_range(2) - behavior_period.time_range(1)) > (parameters.continued_window * parameters.fps -1)
                   
                   % Get all the associated parameters
                   finished_behavior_period = behavior_period;
                   continued_behavior_period = behavior_period;
                   
                   % Divide
                   finished_behavior_period.time_range = [behavior_period.time_range(1), [behavior_period.time_range(1)+parameters.continued_window*parameters.fps-1]];
                   continued_behavior_period.time_range = [[behavior_period.time_range(1) + parameters.continued_window * parameters.fps], behavior_period.time_range(2)]; 
                   
                   % Concatenate finished period
                   eval(['all_periods.' parameters.Conditions(activity_tag).short '= [all_periods.' parameters.Conditions(activity_tag).short '; finished_behavior_period];']);
                   
                   % Concatenate continued period, depending on if rest or not
                   if activity_tag == 5
                       % Put in continued rest
                       eval(['all_periods.' parameters.Conditions(27).short '= [all_periods.' parameters.Conditions(27).short '; continued_behavior_period];']);
                   else
                       % Put in continued walking
                       eval(['all_periods.' parameters.Conditions(26).short '= [all_periods.' parameters.Conditions(26).short '; continued_behavior_period];']);
                   end
                   
                % If time range isn't long enough, concatenate just as the "finished"
                else    
                     eval(['all_periods.' parameters.Conditions(activity_tag).short '= [all_periods.' parameters.Conditions(activity_tag).short '; behavior_period];']);
                end 
            
            % If periods don't need to be divided, concatenate normally     
            otherwise     
                eval(['all_periods.' parameters.Conditions(activity_tag).short '= [all_periods.' parameters.Conditions(activity_tag).short '; behavior_period];']);
        end 
   
    end
end 