
%----------------------------------------------------------------
% Endogenous
%----------------------------------------------------------------

var pop_ocup_m pop_ocup_q pea_m pea_q unemp_q unemp_m;

%----------------------------------------------------------------
% Observaveis
%----------------------------------------------------------------

varobs pop_ocup_q pea_q unemp_q;

%----------------------------------------------------------------
% Exogenous
%----------------------------------------------------------------

varexo eps_pop_ocup_q eps_pop_ocup_m eps_pea_q eps_pea_m eps_unemp_q eps_unemp_m;

%----------------------------------------------------------------
% Parameters
%----------------------------------------------------------------

parameters 

rho1 rho2 rho3

;

rho1 = 1;
rho2 = 1;
rho3 = 1;

%----------------------------------------------------------------
% Model Equations
%----------------------------------------------------------------

model(linear);

pop_ocup_q = (1/3)*(pop_ocup_m(-2) + pop_ocup_m(-1) + pop_ocup_m) + eps_pop_ocup_q;
pop_ocup_m = (1-rho1)*steady_state(pop_ocup_m) + rho1*pop_ocup_m(-1) + eps_pop_ocup_m;

pea_q = (1/3)*(pea_m(-2) + pea_m(-1) + pea_m) + eps_pea_q;
pea_m = (1-rho2)*steady_state(pea_m) + rho2*pea_m(-1) + eps_pea_m;

% Independent model for unemployment
unemp_q = (1/3)*(unemp_m(-2) + unemp_m(-1) + unemp_m) + eps_unemp_q;
unemp_m = (1-rho3)*steady_state(unemp_m) + rho3*unemp_m(-1) + eps_unemp_m;

end;


%----------------------------------------------------------------
% Steady State
%----------------------------------------------------------------

steady_state_model;

pop_ocup_q = 90000;
pop_ocup_m = 90000;

pea_q = 100000;
pea_m = 100000;

unemp_m = 8;
unemp_q = 8;

end;


%----------------------------------------------------------------
% Shocks
%----------------------------------------------------------------

shocks;

var eps_pop_ocup_q; stderr 225/3; %0.25/100*90000;
var eps_pop_ocup_m; stderr 338*2; 

var eps_pea_q; stderr 250/3; %0.25/100*100000;
var eps_pea_m; stderr 312*2; 

var eps_unemp_q; stderr 0.10/2;
var eps_unemp_m; stderr 0.16;

end;


%----------------------------------------------------------------
% Kalman Filter
%----------------------------------------------------------------

%stoch_simul;

calib_smoother(datafile = '...\Documents\Economia\Paper Replications\Mensalização PNAD Continua\Dynare\Data.xlsx',
               xls_sheet = Dynare,
               xls_range = B1:G200,
               diffuse_filter);
               
              


