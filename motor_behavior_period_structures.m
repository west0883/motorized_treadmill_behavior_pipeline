% motor_behavior_period_structures.m
% Sarah West
% 12/9/21

% Splits the all_periods structure into a structure where each possible
% type of period is split into its own field. Is harder to read for humans,
% but will be easier for using with established code. 

function [] = motor_behavior_period_structures(parameters)
  
   % Establish base input directory
    dir_in_base=[parameters.dir_exper 'behavior\period instances\'];

    % Establish base output directory
    dir_out_base=[parameters.dir_exper 'behavior\period instances\all structure format\'];
    
    % Tell user where data is being saved
    disp(['Data saved in ' dir_out_base]); 
    
    % For each mouse 
    for mousei=1:size(parameters.mice_all,2)
        mouse=parameters.mice_all(mousei).name;
        
        % For each day
        for dayi=1:size(parameters.mice_all(mousei).days, 2)
            
            % Get the day name.
            day=parameters.mice_all(mousei).days(dayi).name; 
            
            % Find input directory and cleaner output directory. 
            parameters.dir_in = [dir_in_base  mouse '\' day '\'];
            parameters.input_data_name = {'all_periods_', 'stack number', '.mat'};
            dir_out=[dir_out_base mouse '\' day '\']; 
            mkdir(dir_out); 
            
            % Get the stack list
            [stackList]=GetStackList(mousei, dayi, parameters);
            
            % Cycle through the stack files. 
            for stacki=1:size(stackList.filenames,1)

                % Get the stack number and filename for the stack.
                stack_number = stackList.numberList(stacki, :);
                filename = stackList.filenames(stacki, :);
                
                disp(['mouse ' mouse ', day ' day ', stack ' stack_number]);
                
                % Load corresponding data
                load([parameters.dir_in filename]);
                
                
                % Re-arrange all possible periods as structures
                for condi = 1:size(paramters.Conditions,2)

                    short_name = parameters.Conditions(condi).short;
                    
                    eval(['current_type = all_periods.' short_name ';']); 
                  
                    % Only make fields for things we actually care about
                    % per condition type
                    
                    switch condi
                        
                        % For all warning cue sections, and for the two 
                        % motor maintaining types, we only care about
                        % the current speed subdivisions
                        case num2cell([8:13 18:22 3 17])
                       
                        % For all accel and decel periods, we care about the
                        % previous speed, current speed, and acceleration
                        case num2cell([1,2, 14, 15])
                            
                    end 
                    for instancei = 1:size( current_type,1)
                        
                        speed = current_type.speed;
                        
                        
                        
                        accel = current_type.speed 
                    
                    
                    
                    
                    
                    end 
                end 
                
                
                
            end 
        end 
    end
end