% MotorBehaviorPeriodsTable.m
% Sarah West
% 4/8/22

function [parameters] = MotorBehaviorPeriodsTable(parameters)

    % Call this for each stack/trial
    
    % Get list of period names in this all_periods
    period_names = fieldnames(parameters.all_periods);

    % Establish all_periods_table as Conditions plus a field for time
    % ranges
    parameters.all_periods_table = parameters.Conditions;
    parameters.all_periods_table.time_ranges(:) = cell(size(parameters.Conditions,1), 1); 
    
    % List field names needed for information about each time range. 
    information_fields = {'speed', 'accel', 'previous_speed', 'previous_accel', 'two_speeds_ago'};

    % Announce what stack you're on.
    message = ['Finding '];
    for dispi = 1:numel(parameters.values)/2
        message = [message parameters.values{dispi} ', '];
    end
    disp(message);
    
    % For each period/condition name in all_periods,
    for periodi = 1:numel(period_names)

        % Get the information about individual occurances
        occurances_structure = getfield(parameters.all_periods, period_names{periodi});
        
        % For each instance inside occurances_structure (skip first entry,
        % is always empty
        for instancei =2:size(occurances_structure,1)
            
            % Establish logical array holder;
           % holder_logical = NaN(size(parameters.all_periods_table, 1), numel(information_fields)+1); 
            
            % Put in first logical, for the condition name;
            holder_logical = (parameters.Conditions.condition) == convertCharsToStrings(period_names{periodi});
            
            % Grab first instance of this condition (for finding NaNs)
            ind = find(holder_logical, 1);

            % Assign each information field
            for infoi = 1:numel(information_fields)
                
                 % If this condition doesn't care about this value, make the search criteria be NaN 
                 if strcmp(parameters.Conditions.(information_fields{infoi})(ind), "NaN")
                
                     holder_logical(:, infoi + 1) =  (parameters.Conditions.(information_fields{infoi})) == "NaN"; 
                    

                 else
                     % Get out relevant information.
                     value = getfield(occurances_structure, {instancei}, information_fields{infoi}); 

                     % Search and put into logical array.
                     holder_logical(:, infoi + 1) =  (parameters.Conditions.(information_fields{infoi})) == convertCharsToStrings(num2str(value)); 
                 
                    % Concatenate to holder_logical 
                 end
                 
            end

            % Get location where this instance belongs. 
            index = find(all(holder_logical,2));
            
            % If there is no matching position (can happen if it's an old data collection setup and we don't want to analyze that) 
            if isempty(index)
                
                % Skip to next instance
                continue
            end
            % Put these in the correct time range entry, concatenated with
            % any previous instances.
            parameters.all_periods_table.time_ranges{index} = [parameters.all_periods_table.time_ranges{index}; occurances_structure(instancei).time_range];

        end 
    end 

end 