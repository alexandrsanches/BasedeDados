clc
clear
close all

%% SET SAMPLE SIZE (LAST OBSERVATION DATE)

% Importante 1: colocar o endereço dos dados corretamente no arquivo put_data_in_folder no endereço \Dynare Codes\IRF_code\Data.
% Importante 2: cada passo irá perguntar se vc quer executar o código com amostra restrita (até dez/2019) ou completa com projeções.
%               Note: Data final da amostra completa com projs. deve ser definida abaixo.

% ESCOLHER RANGES DE DATA DA AMOSTRA COMPLETA E RESTRITA. ALTERAR SOMENTE O FINAL NA AMOSTRA, MANTENDO O INÍCIO CONSTANTE.
range_restrito = 'CP8:DQ81'; % 81 = 4q2019
range_completo = 'CP8:DQ90'; % 90 = 1q2022 

%% RUN TASKS

disp('Option 1. Generate section 4.2 results: Estimated parameters (mean)')
disp('Option 2. Generate section 5.1 results: Conditional Variance Decomposition')
disp('Option 3. Generate section 5.2 results: IRF')
disp('Option 4. Generate section 5.3 results: Forecasts')
disp('Option 5. Generate section 5.4 results: Historical Shocks Decomposition')
disp('Option 6. Added by XP Asset: Unconditional Forecasts')
disp('Option 7. Added by XP Asset: Conditional Forecasts')
 
main_path=[cd '\'];
addpath('Programas_intermedios');

cont = 1;

while cont
    
    global datos_rangedata;
    
    Sample_Size = input('Choose sample (0 = restricted; 1 = full). Choose 1 for forecasts and historical decompositions: ');
    
        if Sample_Size == 0
            datos_rangedata = range_restrito;
        elseif Sample_Size == 1
            datos_rangedata = range_completo;
        end
    
    n = input('Enter a number to choose a task: ');
        
    switch n
        
        case 1
            disp('Estimating parameters. Output —Parameters.xlsx— will be located in "Results" folder')
            Estimate 
            disp('Output —Parameters.xlsx— is located in "Results" folder')
            
        case 2
            disp('Generating Conditional Variance Decomposition. Figures —PNG files— will be located in "Results" folder')
            Decomp 
            disp('Figures —PNG files— are located in "Results" folder')
            
        case 3
            disp('Generating IRF. Output —IRF.xlsx— will be located in "Results" folder')
            IRF 
            disp('Output —IRF.xlsx— is located in "Results" folder')
            
        case 4
            disp('Generating Forecasts')
            Forecast
            disp('Figures and pdf files are located in "Results" folder')
                        
        case 5
            disp('Generating Historical Shocks Decomposition. Output —HD.xlsx— will be located in "Results" folder')
            HD 
            disp('Output —HD.xlsx— is located in "Results" folder')
            
        case 6
            disp('Generating Unconditional Forecasts and Smoothed Variables')
            UncondForecasts
            disp('Output —uncond_forecasts.xlsx.xlsx and smoothed_variables.xlsx— is located in "Results" folder')
            
        case 7    
            disp('Generating Conditional Forecasts')
            CondForecasts
            disp('Output —cond_forecasts.xlsx.xlsx— is located in "Results" folder')
            
        otherwise
            disp('Please use a number from the list {1,2,3,4,5,6,7}')
    end
    
    cont =  0;
    
    %cont =  input('Do you want to run another excercise? (1 = yes; 0 = no): ');
    
end
