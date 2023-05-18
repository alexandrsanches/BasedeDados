clearvars -except main_path datos_rangedata

model_path= [main_path 'Cond_Forecasts_code\Model\'];
data_path= [main_path 'IRF_code\Data\'];
results_path= [main_path 'Results\'];
code_path= [main_path 'Cond_Forecasts_code\Codes\'];

%% Put data in folders
cd(data_path)
put_data_in_folder_final;

%% Run Dynare code
cd(model_path)
dynare('calculate_condFor.mod','nointeractive','noclearall');

%% Get forecasts and build table
cd(code_path)
get_cond_forecasts

%% Export forecasts

cd(results_path)
file_out = [results_path 'cond_forecasts.xlsx'];
delete(file_out);

for k = 1:numel(scen)

    sheet = [char('Sheet') num2str(k)];
    
    try writetable(tab_final(k).tabs,file_out,'Sheet',sheet,'WriteVariableNames',true); end; pause(5);
    
end

cd(main_path)

