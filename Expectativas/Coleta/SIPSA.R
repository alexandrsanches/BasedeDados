library(httr)
library(openxlsx)
library(magrittr)
library(dplyr)
library(lubridate)
library(tidyr)
library(ggplot2)
library(zoo)

URL = 'https://www.dane.gov.co/files/investigaciones/agropecuario/sipsa/anex_06may_al_12may_2023.xlsx'; fecha = '2023-05-12'

# alternative 1
raw_xlsx <- GET(URL)$content
tmp <- tempfile(fileext = '.xlsx')
writeBin(raw_xlsx, tmp)

s2 <- read.xlsx(tmp, sheet = 2)
s3 <- read.xlsx(tmp, sheet = 3)
s4 <- read.xlsx(tmp, sheet = 4)
s5 <- read.xlsx(tmp, sheet = 5)
s6 <- read.xlsx(tmp, sheet = 6)
s7 <- read.xlsx(tmp, sheet = 7)
s8 <- read.xlsx(tmp, sheet = 8)
s9 <- read.xlsx(tmp, sheet = 9)
#s10 <- read.xlsx(tmp, sheet = 10)

df <- rbind(s2, s3, s4, s5, s6, s7, s8, s9)
df <- df[,1:(ncol(df)-2)] %>% na.omit()
colnames(df) <- c('X1', 'X2', 'X3', 'X4', 'X5')
df$Fecha <- as.Date(fecha)

write.csv(df, paste0("Coleta/2023/Coleta - ", fecha,".csv"), row.names=FALSE)
#write.csv(df, paste0("Coleta/Coleta 2018.csv"), row.names=FALSE)
full.df <- read.csv("Coleta/Coleta 2018.csv")
full.df <- rbind(full.df, df)
write.csv(full.df, paste0("Coleta/Coleta 2018.csv"), row.names=FALSE)

# alternative 2
raw_xlsx <- GET(URL)$content
tmp <- tempfile(fileext = '.xls')
writeBin(raw_xlsx, tmp)

s2 <- readxl::read_excel(tmp, sheet = 2)
s3 <- readxl::read_excel(tmp, sheet = 3)
s4 <- readxl::read_excel(tmp, sheet = 4)
s5 <- readxl::read_excel(tmp, sheet = 5)
s6 <- readxl::read_excel(tmp, sheet = 6)
s7 <- readxl::read_excel(tmp, sheet = 7)
s8 <- readxl::read_excel(tmp, sheet = 8)
s9 <- readxl::read_excel(tmp, sheet = 9)
#s10 <- readxl::read_excel(tmp, sheet = 10)



# Append a specific year
# setwd('Coleta/2023/')
# lst_of_frames <- lapply(list.files(), read.csv)
# df.aux <- do.call(rbind, lst_of_frames)
# write.csv(df.aux, paste0("Coleta 2023.csv"), row.names=FALSE)

# append all
setwd('Coleta/Consolidado/')
lst_of_frames <- lapply(list.files(), read.csv)
df.aux <- do.call(rbind, lst_of_frames)
write.csv(df.aux, paste0("Consolidado.csv"), row.names=FALSE)

dates <- df.aux %>% na.omit() %>% select(Fecha) %>% unique()

df.aux <- df.aux %>% na.omit() %>% mutate(Fecha = as.Date(Fecha))

# df.aux %>% glimpse()
# products <- df.aux %>% select(X1, Fecha) %>% group_by(X1, Fecha) %>% summarise(n()) %>% pivot_wider(id_cols = 'X1', names_from = 'Fecha', values_from = 'n()')
# ciudads <- df.aux %>% select(X2) %>% unique()
# products <- df.aux %>% select(X1, X2) %>% filter(X2 %in% selected.locations) %>% group_by(X1, X2) %>% summarise(n()) %>% pivot_wider(id_cols = 'X1', names_from = 'X2', values_from = 'n()')

# filter and add city weights
selected.locations <- c('Barranquilla, Barranquillita',
                        'Cartagena, Bazurto',
                        'Medellín, Central Mayorista de Antioquia',
                        'Bogotá, D.C., Corabastos',
                        'Armenia, Mercar',
                        'Bucaramanga, Centroabastos',
                        'Neiva, Surabastos',
                        'Pasto, El Potrerillo',
                        'Pereira, Mercasa',
                        'Cúcuta, Cenabastos',
                        'Cali, Cavasa')


weights <- c(5.30689,
             3.15112,
             15.02651,
             40.44639,
             1.0506,
             4.62987,
             1.08267,
             1.19916,
             2.0589,
             2.30764,
             9.1536)


aux <- df.aux %>% filter(X2 == 'Cali, Santa Helena', X1 == 'Salmón, filete congelado')

aux %>% ggplot(aes(x = Fecha, y = X5)) +
  geom_line()

# wieghts
weight.df <- data.frame(X2 = selected.locations, Weights = weights)

df.filtered <- df.aux %>% filter(X2 %in% selected.locations) %>% left_join(weight.df)

product.selector <- df.filtered %>% group_by(X1, X2) %>% filter(Fecha > as.Date('2022-12-01')) %>% summarise(n()) %>% mutate(prod.select = ifelse(`n()`>60,1,0))

# fill implicit missing dates of dates
complete.df <- complete(df.filtered, X1, X2, Fecha) %>% distinct()

# filter products with many missing and repeat previous for few missing
df.filtered <- complete.df %>% ungroup() %>% 
  left_join(product.selector, by = join_by(X1, X2)) %>% 
  filter(prod.select == 1) %>% 
  select(!prod.select, !`n()`) %>% 
  group_by(X1, X2) %>% 
  mutate(Weights = ifelse(is.na(X5), 0, Weights)) %>% 
  tidyr::fill(X5)

# weight zero if missing
df.filtered <- df.filtered %>% mutate(Weights = ifelse(is.na(X5), 0, Weights),
                                      X5 = ifelse(is.na(X5), NA, X5))
# export prices
export <- df.filtered %>% ungroup() %>% 
  select(X1, X2, X5, Fecha) %>% 
  pivot_wider(id_cols = c('X1','X2'), values_from = 'X5', names_from = 'Fecha', values_fn = mean)

  
# AGREGACAO, deprecated
# df.agg <- df.filtered %>% group_by(X1, X2) %>% arrange(Fecha) %>% 
#   mutate(ma4w = rollmean(X5, k=3, fill=NA, align='right'),
#          mom = -100 + 100*ma4w/dplyr::lag(ma4w, n = 4L),
#          ponta = -100 + 100*X5/dplyr::lag(X5, n = 4L)) %>% 
#   group_by(X1, Fecha) %>% 
#   summarise(mom = weighted.mean(mom, Weights, na.rm = T),
#             ponta = weighted.mean(ponta, Weights, na.rm = T)) %>% 
#   mutate(mom = ifelse(is.infinite(mom),NA,mom),
#          ponta = ifelse(is.infinite(ponta),NA,ponta))
# 
# 
# df.agg %>% filter(X1 == 'Sal yodada') %>% 
#   ggplot() +
#   geom_line(aes(x = Fecha, y = mom)) +
#   geom_line(aes(x = Fecha, y = ponta), color = 'gray') +
#   theme_bw()

