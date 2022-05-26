% create_conditions_names.m
% Sarah West

%% Parameters for directories
clear all;

experiment_name='Random Motorized Treadmill';

dir_base='Y:\Sarah\Analysis\Experiments\';
dir_exper=[dir_base experiment_name '\']; 

dir_out=dir_exper; 
mkdir(dir_out);

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

Conditions(1).name = 'motor accelerating';
Conditions(1).short = 'm_accel';
Conditions(2).name = 'motor decelerating';
Conditions(2).short = 'm_decel';
Conditions(3).name = 'motor maintaining';
Conditions(3).short = 'm_maint';
Conditions(4).name = 'motor stopping';
Conditions(4).short = 'm_stop';
Conditions(5).name = 'motor finished stopping';
Conditions(5).short = 'm_fstop';
Conditions(6).name = 'motor finished accelerating';
Conditions(6).short = 'm_faccel';
Conditions(7).name = 'motor finished decelerating';
Conditions(7).short = 'm_fdecel';
Conditions(8).name = 'warning cue: starting';
Conditions(8).short = 'w_start';
Conditions(9).name = 'warning cue: stopping';
Conditions(9).short = 'w_stop';
Conditions(10).name = 'warning cue: accelerating';
Conditions(10).short = 'w_accel';
Conditions(11).name = 'warning cue: decelerating';
Conditions(11).short = 'w_decel';
Conditions(12).name = 'warning cue: maintaining';
Conditions(12).short = 'w_maint';
Conditions(13).name = 'warning cue: probe, no warning';
Conditions(13).short = 'w_p_nowarn';
Conditions(14).name = 'motor: probe, no warning, accelerating';
Conditions(14).short = 'm_p_nowarn_accel';
Conditions(15).name = 'motor: probe, no warning, decelerating';
Conditions(15).short = 'm_p_nowarn_decel';
Conditions(16).name = 'motor: probe, no warning, stopping';
Conditions(16).short = 'm_p_nowarn_stop';
Conditions(17).name = 'motor: probe, no warning, maintaining';
Conditions(17).short = 'm_p_nowarn_maint';
Conditions(18).name = 'warning cue: probe, starting cue, no change in motor.';
Conditions(18).short = 'w_p_nochange_start';
Conditions(19).name = 'warning cue: probe, stopping cue, no change in motor.';
Conditions(19).short = 'w_p_nochange_stop';
Conditions(20).name = 'warning cue: probe, accelerating cue, no change in motor.';
Conditions(20).short = 'w_p_nochange_accel';
Conditions(21).name = 'warning cue: probe, decelerating cue, no change in motor.';
Conditions(21).short = 'w_p_nochange_decel';
Conditions(22).name = 'warning cue: probe, maintaining cue, no change in motor.';
Conditions(22).short = 'w_p_nochange_maint';
Conditions(23).name = 'motor: probe, no change';
Conditions(23).short = 'm_p_nochange';

% Extras to sort.
Conditions(24).name = 'motor: starting';
Conditions(24).short = 'm_start'; 
Conditions(25).name = 'motor: finished starting';
Conditions(25).short = 'm_fstart'; 

save([dir_out 'Behavior_Conditions.mat'], 'Conditions');