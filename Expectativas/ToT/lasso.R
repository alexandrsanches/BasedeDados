library(glmnet)
library(ggplot2)
library(openxlsx)
library(tidyr)
library(dplyr)
library(magrittr)
library(progress)
library(forecast)
library(strucchange)

df <- openxlsx::read.xlsx('ToT/Terms of Trade Monitor.xlsx', rows = 1:500, sheet = 'Test')

# Create predictors
X <- as.matrix(df[,3:ncol(df)])

# number of included max lags:
n.lags <- 0

# add lags
#X.lag.1 <- dplyr::lag(X, n = 1L)
#X.lag.2 <- dplyr::lag(X, n = 2L)
#colnames(X.lag.1) <- paste0(colnames(X),'.L1')
#colnames(X.lag.2) <- paste0(colnames(X),'.L2')
#X <- na.omit(cbind(X, X.lag.1, X.lag.2))

p <- ncol(X)
n <- nrow(X)

# target
y <- na.omit(df[(n.lags+1):nrow(df),2])

# check
nrow(X) - horizons == length(y)

# Specify rolling window settings
window_size <- 36   
nobs <- length(y)   # number of observations in-sample
horizons <- 12       # Forecast horizonss

# Matrix to store objects for lasso
coef_mat <- matrix(0, nrow = nobs - window_size + 1, ncol = p + 1) # include intercept
pred_mat <- matrix(0, nrow = nobs - window_size + 1, ncol = horizons)
resid_mat <- matrix(0, nrow = nobs - window_size + 1, ncol = horizons)
obs_mat <- matrix(0, nrow = nobs - window_size + 1, ncol = horizons)
r_sq_mat <- matrix(0, nrow = nobs - window_size + 1, ncol = 1)

# Matrix to store objects for OLS
coef_mat_ols <- matrix(0, nrow = nobs - window_size + 1, ncol = p + 1) # include intercept
pred_mat_ols <- matrix(0, nrow = nobs - window_size + 1, ncol = horizons)
resid_mat_ols <- matrix(0, nrow = nobs - window_size + 1, ncol = horizons)
r_sq_mat_ols <- matrix(0, nrow = nobs - window_size + 1, ncol = 1)

# progress bar
pb <- progress_bar$new(total = nobs - window_size + 1, format = "[:bar] :percent :eta")


for (i in 1:(nobs - window_size + 1)) {
  
  # Define training data for the current window
  train_start <- i
  train_end <- i + window_size - 1

  train_x <- X[train_start:train_end, ]
  train_y <- y[train_start:train_end]
  
  # Define testing data for the forecast horizons
  test_start <- train_end + 1
  test_end <- test_start + horizons - 1
  
  test_x <- X[test_start:test_end, ]
  test_y <- y[test_start:test_end]
  
  # ***********************************************
  # LASSO ----
  # ***********************************************
  
  fit <- cv.glmnet(train_x, train_y, alpha = 1)
  
  # R-squared
  r_sq_mat[i] <- fit$glmnet.fit$dev.ratio[which(fit$glmnet.fit$lambda == fit$lambda.min)]
  
  # store residuals
  pred <- predict(fit, newx = test_x)
  pred_mat[i,] <- t(pred)
  obs_mat[i,] <- t(test_y)
  resid_mat[i,] <- t(test_y) - t(pred) 
  
  # Store rolling coefficients
  coef_mat[i, ] <- coef(fit, s = 'lambda.min')[,]
  
  # ***********************************************
  # OLS ----
  # ***********************************************
  
  selected_coeffs <- coef(fit)
  selected_coeffs <- selected_coeffs[-1, ]  # Exclude the intercept
  selector <- which(selected_coeffs != 0)
  names(selected_coeffs)[selector]
  
  # Create a formula using the selected coefficients
  formula <- as.formula(paste("X1 ~", paste(names(selected_coeffs)[selector], collapse = "+")))
  
  # Fit the OLS model using the lm() function
  ols_model <- lm(formula, data = data.frame(X1 = train_y, train_x))
  
  coef_mat_ols[i,c(1,selector)] <- coef(ols_model)[]
  
  # store residuals
  pred <- predict(ols_model, newx = test_x[,selector])
  aux.pred <- pred[(length(pred)-horizons+1):length(pred)]
  pred_mat_ols[i,] <- t(aux.pred)
  resid_mat_ols[i,] <-  t(test_y) - t(aux.pred)
  
  r_sq_mat_ols[i] <- summary(ols_model)$r.squared
  
  # Update progress bar
  pb$tick()
  
}

# analyse last OLS model
forecast::ggAcf(ols_model$residuals)
forecast::ggPacf(ols_model$residuals)
checkresiduals(ols_model)

autoplot(ts(train_y), series="Data") +
  autolayer(ts(fitted(ols_model)), series="Fitted") +
  xlab("Index") + ylab("") +
  ggtitle("In-sample Fit") + theme_bw()

# plot out-of-sample residuals for each horizon
resid_df <- as.data.frame(resid_mat)
resid_df$Date <- 1:nrow(resid_df)
resid_df %>%
  pivot_longer(!Date) %>% 
  ggplot(aes(x = Date, y = value)) +
  geom_hline(yintercept = 0, color = 'red') +
  geom_line() +
  facet_wrap( ~ name) + theme_bw()

# plot forecast vs actual
pred.df <- as.data.frame(pred_mat)
obs.df <- as.data.frame(obs_mat)
forecast <- pred.df$V1
actual <- obs.df$V1
df.plot <- data.frame(Date = 1:length(actual), forecast, actual)

ggplot(df.plot) +
  geom_line(aes(x = Date, y = actual)) +
  geom_point(aes(x = Date, y = actual)) +
  geom_line(aes(x = Date, y = forecast), color = 'red') +
  geom_point(aes(x = Date, y = forecast), color = 'red') +
  labs(x = "Horizon", y = "MSE and MAE") +
  theme_bw()

# test out-of-sample residuals for autocorrel
forecast::ggAcf(resid_df$V1)
forecast::ggPacf(resid_df$V1)


# stability tests
cusum.ols <- efp(ols_model, type = "OLS-CUSUM", data = data.frame(X1 = train_y, train_x))
cusum.rec <- efp(ols_model, type = "Rec-CUSUM", data = data.frame(X1 = train_y, train_x))
mosum.ols <- efp(ols_model, type = "Rec-MOSUM", data = data.frame(X1 = train_y, train_x))
mosum.rec <- efp(ols_model, type = "OLS-MOSUM", data = data.frame(X1 = train_y, train_x))
par(mfrow=c(2,2))
plot(cusum.ols)
plot(cusum.rec)
plot(mosum.ols)
plot(mosum.rec)
stab.tests <- recordPlot()

# Compute
mse_vec <- sqrt(colMeans((resid_mat^2), na.rm = T))
mae_vec <- colMeans(abs(resid_mat), na.rm = T)

# Plotting the performance metrics
data_plot <- data.frame(Horizon = 1:horizons, MSE = mse_vec, MAE = mae_vec)

mse_plot <- ggplot(data_plot) +
  geom_line(aes(x = Horizon, y = MSE)) +
  geom_point(aes(x = Horizon, y = MSE), size = 2) +
  geom_line(aes(x = Horizon, y = MAE), color = 'red') +
  geom_point(aes(x = Horizon, y = MAE), color = 'red', size = 2) +
  labs(x = "Horizon", y = "MSE and MAE") +
  theme_bw()

# Plotting the rolling coefficients: OLS
iteration <- 1:(nobs - window_size + 1)
coef_data <- data.frame(Iteration = iteration, coef_mat_ols)
coef_data <- reshape2::melt(coef_data, id.vars = "Iteration", variable.name = "Coefficient", value.name = "Value")

coef_plot <- ggplot(coef_data %>% filter(Coefficient != 'X1'), aes(x = Iteration, y = Value, color = Coefficient)) +
  geom_line() +
  labs(x = "Iteration", y = "Value", color = "Coefficient") +
  theme_minimal()

# Plotting the rolling coefficients: LASSO
iteration <- 1:(nobs - window_size + 1)
coef_data <- data.frame(Iteration = iteration, coef_mat)
coef_data <- reshape2::melt(coef_data, id.vars = "Iteration", variable.name = "Coefficient", value.name = "Value")

coef_plot <- ggplot(coef_data %>% filter(Coefficient != 'X1'), aes(x = Iteration, y = Value, color = Coefficient)) +
  geom_line() +
  labs(x = "Iteration", y = "Value", color = "Coefficient") +
  theme_minimal()

