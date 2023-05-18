
library(tidyverse)
library(sidrar)
library(seasthedata)

raw.df <- get_sidra(api = '/t/6318/n1/all/v/1641/p/all/c629/all')

colnames(raw.df)

df <- raw.df %>% select(`Trimestre Móvel (Código)`, `Condição em relação à força de trabalho e condição de ocupação (Código)`, `Condição em relação à força de trabalho e condição de ocupação`, Valor) %>% 
  mutate(dates = as.Date(paste0(as.character(`Trimestre Móvel (Código)`), '01'), format='%Y%m%d')) %>% 
  rename(Condicao = `Condição em relação à força de trabalho e condição de ocupação`,
         Cond.codigo = `Condição em relação à força de trabalho e condição de ocupação (Código)`) %>% 
  select(!`Trimestre Móvel (Código)`)



df.sa <- df %>% select(dates, Condicao, Valor) %>%  group_by(Condicao) %>% seasthedata(frequency = 'month')
  
df.wide <- df %>% select(dates, Condicao, Valor) %>% pivot_wider(id_cols = 'dates', values_from = 'Valor', names_from = 'Condicao')

df.sa.wide <- df.sa %>% select(dates, Condicao, Valor) %>% pivot_wider(id_cols = 'dates', values_from = 'Valor', names_from = 'Condicao')

