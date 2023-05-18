library(dplyr)
library(magrittr)
library(tidyr)

# https://app.powerbi.com/view?r=eyJrIjoiN2RlN2VhNmMtNTcyNy00ZDc1LThjN2MtOTQ4MTcwMTY2YTk4IiwidCI6IjMzYjdmNzA3LTZlNmYtNDJkMi04ZDZmLTk4YmZmOWZiNWZhMCIsImMiOjR9

df <- read.csv('precios_consumidor_semana.csv', sep = '|')

colnames(df)

df.sample <- tail(df, 20000)

df %>% filter(Tipo_de_punto == 'Supermercado', Fecha == as.Date('2019-'))

df.supermercado <- df %>% filter(Tipo_de_punto == 'Supermercado')

count <- df.supermercado %>% filter(Fecha == as.Date(max(Fecha))) %>% unique()

products <- df.supermercado %>% select(Producto) %>% unique()

puntos <- df %>% select(Tipo_de_punto) %>% unique()

locations <- df.supermercado %>% select(Sector) %>% unique()

grupos <- df.supermercado %>% select(Grupo) %>% unique()

df.santiago <- df %>% filter(Región == 'Región Metropolitana de Santiago', 
                             Tipo_de_punto == 'Supermercado') %>% 
  group_by(Fecha, Región, Sector, Grupo, Producto, Unidad, Calidad) %>% 
  mutate(PrecioPromedio = as.numeric(gsub(",", ".", PrecioPromedio))) %>% 
  summarise(price = mean(PrecioPromedio),
            price.median = median(PrecioPromedio))


export <- df.santiago %>% 
  select(!price.median) %>% 
  arrange(Fecha) %>% 
  pivot_wider(id_cols = c('Región', 'Sector', 'Grupo', 'Producto', 'Unidad', 'Calidad'), names_from = 'Fecha', values_from = 'price')




df.agg <- df %>% group_by(Fecha, Región, Grupo, Producto, Unidad) %>% 
  mutate(PrecioPromedio = as.numeric(gsub(",", ".", PrecioPromedio))) %>% 
  summarise(price = mean(PrecioPromedio))




