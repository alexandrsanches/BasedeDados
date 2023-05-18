
library(tsm)
library(mFilter)
library(sidrar)
library(openxlsx)

getwd()

GDP <- openxlsx::read.xlsx(xlsxFile = 'Output Gap.xlsx', sheet = 'HU - Output Gap', rows = 6:300, cols = 4:6, detectDates = T)
gdp <- ts(log(GDP$SA), start=c(1995, 1), end=c(2025, 4), frequency = 4)

GDP <- openxlsx::read.xlsx(xlsxFile = 'Output Gap.xlsx', sheet = 'CZ - Output Gap', rows = 4:300, cols = 4:6, detectDates = T)
gdp <- ts(log(GDP$SA), start=c(1996, 1), end=c(2025, 4), frequency = 4)

# get gdp dessaz
PIB.sa <- get_sidra(api = "/t/1621/n1/all/v/all/p/all/c11255/90707/d/v584%201")
PIB.sa <- PIB.sa[,c("Trimestre","Valor")]
gdp <- ts(log(PIB.sa$Valor), start=c(1996, 1), end=c(2022, 4), frequency = 4)

plot(gdp)

# HP Filter
hp.decom <- hpfilter(gdp, freq = 1600, type = "lambda")

par(mfrow = c(1, 2), mar = c(2.2, 2.2, 1, 1), cex = 0.8)
plot.ts(gdp, ylab = "")  # plot time series
lines(hp.decom$trend, col = "red")  # include HP trend
legend("topleft", legend = c("data", "HPtrend"), lty = 1, 
       col = c("black", "red"), bty = "n")
plot.ts(hp.decom$cycle, ylab = "")  # plot cycle
legend("topleft", legend = c("HPcycle"), lty = 1, col = c("black"), 
       bty = "n")

# Christiano-Fitzgerald filter
cf.decom <- cffilter(gdp, pl = 6, pu = 32, root = TRUE)

par(mfrow = c(1, 2), mar = c(2.2, 2.2, 1, 1), cex = 0.8)
plot.ts(gdp, ylab = "")
lines(cf.decom$trend, col = "red")
legend("topleft", legend = c("data", "CFtrend"), lty = 1, 
       col = c("black", "red"), bty = "n")
plot.ts(cf.decom$cycle, ylab = "")
legend("topleft", legend = c("CFcycle"), lty = 1, col = c("black"), 
       bty = "n")

# Compare
comb <- ts.union(hp.decom$cycle, 
                 cf.decom$cycle)

par(mfrow = c(1, 1), mar = c(2.2, 2.2, 2, 1), cex = 0.8)
plot.ts(comb, ylab = "", plot.type = "single", col = c("red", "darkgrey"))
legend("topleft", legend = c("hp-filter", "cf-filter"), lty = 1, col = c("red", "darkgrey"), bty = "n")


export <- ts.union(100*hp.decom$cycle, hp.decom$trend, 100*cf.decom$cycle, cf.decom$trend)
export.df <- as.data.frame(export)
