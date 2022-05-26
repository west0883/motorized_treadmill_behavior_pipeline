% extractMotorData.m
% Sarah West
% 11/16/21

% Function that takes the output files from the Arduino serial monitor
% during motorized treadmill experiements and saves data as .mat files.

function [] = extractMotorData(parameters)

    mice_all = parameters.mice_all;
    dir_dataset_name = parameters.dir_dataset_name;
    input_data_name = parameters.input_data_name;
    dir_exper = parameters.dir_exper; 
    digitNumber = parameters.digitNumber; 
    putty_flag = parameters.putty_flag;
    
    % Establish base output directory
    dir_out_base=[dir_exper 'behavior\extracted motor data\'];
    
    % Tell user where data is being saved
    disp(['Data saved in ' dir_out_base]); 
    
    % For each mouse 
    for mousei=1:size(mice_all,2)
        mouse=mice_all(mousei).name;
        
        % For each day
        for dayi=1:size(mice_all(mousei).days, 2)
            
            % Get the day name.
            day=mice_all(mousei).days(dayi).name; 
            
            % Create data input directory and cleaner output directory. 
            parameters.dir_in=CreateFileStrings(dir_dataset_name, mouse, day, [], [], false);
            dir_out=[dir_out_base mouse '\' day '\']; 
            mkdir(dir_out); 
            
            % Get the stack list
            [stackList]=GetStackList(mousei, dayi, parameters);
            
            % If not using PUTTY
            if ~putty_flag 
                
                % Cycle through the stack files. 
                for stacki=1:size(stackList.filenames,1)

                    % Get the stack number and filename for the stack.
                    stack_number = stackList.numberList(stacki, :);
                    filename = stackList.filenames(stacki, :);
                    
                    % Import. The readtext function is amazing.
                    trial = readtext([parameters.dir_in filename]);
                    
                    % Save
                    save([dir_out 'trial' stack_number '.mat'], 'trial', '-v7.3');

                end
                
            % If using Putty,          
            else

                % Get a list of log names.
                filelist = dir([parameters.dir_in parameters.input_data_name{1}]);
                
                % For each matching log name,
                for logi = 1:size(filelist,1)
                    
                    disp(['Checking log ' num2str(logi)]);
                   
                    filename = [parameters.dir_in filelist(logi).name];
                   
                    trial_all = readtext(filename);

                    % Cycle through the stack files. 
                    for stacki=1:size(stackList.filenames,1)

                        % Get the stack number and filename for the stack.
                        stack_number = stackList.numberList(stacki, :); 

                        % Make default NaN values for start_point and end_point 
                        % so you get an error if the real start point wasn't found,
                        % instead of using the wrong data.
                        start_point = NaN;
                        end_point = NaN;

                        % Find trial starting point by looking for 'Trial ...' string at
                        % beginning of each trial.
                        for i = 1:size(trial_all, 1)

                            % Look for the trial number, have to convert to a
                            % number and back to remove the leading 0s.
                            if strcmp(trial_all{i,1}, ['Trial ' num2str(str2num(stack_number))])

                                % mark the start point, break the loop
                                start_point = i; 
                                
                                disp(['Found trial ' stack_number ]);
                                break
                            end 
                        end 
                        
                        % If start point didn't get a value, skip to next
                        % trial
                        if isnan(start_point)
                           disp(['Start of trial ' stack_number ' not found']);
                           continue 
                        end
                        
                        % Now look for the end point
                        
                        % If this isn't the last stack,
                        if stacki < size(stackList.filenames,1)
                            next_stacknum = stackList.numberList(stacki + 1, :); 
                            for i = start_point:size(trial_all,1)
                                if strcmp(trial_all{i,1}, ['Trial ' num2str(str2num(next_stacknum))])

                                    % mark the end point as the last row before the new Trial label, break the loop
                                    end_point = i-1; 
                                    break
                                end 
                            end
                        else
                            % If this is the last stack, assign end to end
                            % of log.
                            end_point = size(trial_all,1);
                        end
                        
                        
                        % If end point not found, assign the last value of
                        % matrix and skip
                        if isnan(end_point)
                           disp(['End of trial ' stack_number ' not found, assigning to end of log.']);
                           end_point = size(trial_all,1);
                        end
                        
                        % Assign range of this trial.
                        trial = trial_all(start_point:end_point, :);

                        % Save
                        save([dir_out 'trial' stack_number '.mat'], 'trial', '-v7.3');
                    end  
                end
            end
        end
    end
end 