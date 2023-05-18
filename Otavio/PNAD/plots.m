pea_m = oo_.SmoothedVariables.pea_m;
pea_q = oo_.SmoothedVariables.pea_q;
pop_ocup_m = oo_.SmoothedVariables.pop_ocup_m;
pop_ocup_q = oo_.SmoothedVariables.pop_ocup_q;
desemp_q = 100*(pea_q - pop_ocup_q)./pea_q;
desemp_m = 100*(pea_m - pop_ocup_m)./pea_m;

unemp_m = oo_.SmoothedVariables.unemp_m;
unemp_q = oo_.SmoothedVariables.unemp_q;


figure(1)
plot(pea_m,'b-')
hold on;
plot(pea_q,'r--')

figure(2)
plot(pop_ocup_m,'b-')
hold on;
plot(pop_ocup_q,'r--')

figure(3)
plot(desemp_m,'b-')
hold on;
plot(desemp_q,'r--')

figure(4)
plot(unemp_m,'b-')
hold on;
plot(unemp_q,'r--')

[desemp_m unemp_m]
