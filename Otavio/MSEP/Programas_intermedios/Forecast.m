clearvars -except main_path datos_rangedata

results_path= [main_path 'Results\'];
recursive_path= [main_path 'Programas_intermedios\'];

cd(recursive_path)
graph_forecasts

cd(main_path)
