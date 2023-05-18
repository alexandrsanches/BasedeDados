clearvars -except main_path datos_rangedata

model_path= [main_path 'Uncond_Forecasts_code\Model\'];
data_path= [main_path 'IRF_code\Data\'];
results_path= [main_path 'Results\'];
code_path= [main_path 'Uncond_Forecasts_code\Codes\'];

%% Put data in folders
cd(data_path)
put_data_in_folder_final;

%% Run Dynare code
cd(model_path)
dynare('calculate_uncondFor.mod','nointeractive','noclearall');

%% Get forecasts and build table
cd(code_path)
get_uncond_forecasts

%% Export forecasts
cd(results_path)
file_out = [results_path 'uncond_forecasts_and_smoothed.xlsx'];
delete(file_out);
try writetable(tab_final,file_out,'Sheet','Sheet1','WriteVariableNames',true); end; pause(5);
try writetable(tab_final_UPPER,file_out,'Sheet','Sheet2','WriteVariableNames',true); end; pause(5);
try writetable(tab_final_LOWER,file_out,'Sheet','Sheet3','WriteVariableNames',true); end; pause(5);

cd(main_path)
