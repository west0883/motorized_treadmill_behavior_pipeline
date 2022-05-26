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
            end
        end
    end
end 