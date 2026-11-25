# ============================================================
# SCRIPT 06: Regression Analysis
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Libraries: dplyr, ggplot2 (base R lm() used)
# ============================================================

library(dplyr)
library(ggplot2)
library(tidyr)

# ---- Load preprocessed data ----
df <- readRDS("../output/student_preprocessed.rds")

plot_dir <- "../plots"

cat("==========================================================\n")
cat("              REGRESSION ANALYSIS\n")
cat("==========================================================\n\n")

# Prepare numeric model matrix
model_df <- df %>%
  mutate(
    Sex_num         = ifelse(Sex == "Male", 1, 0),
    Address_num     = ifelse(Address == "Urban", 1, 0),
    Internet_num    = ifelse(Internet == "yes", 1, 0),
    Romantic_num    = ifelse(Romantic == "yes", 1, 0),
    SchoolSup_num   = ifelse(SchoolSupport == "yes", 1, 0),
    WantsHigher_num = ifelse(WantsHigherEdu == "yes", 1, 0),
    TravelTime_num  = as.numeric(TravelTime),
    StudyTime_num   = as.numeric(StudyTime),
    Dalc_num        = as.numeric(WeekdayAlcohol),
    Walc_num        = as.numeric(WeekendAlcohol),
    Health_num      = as.numeric(Health),
    MeduNum         = as.numeric(MotherEducation),
    FeduNum         = as.numeric(FatherEducation)
  )


# ============================================================
# MODEL 1 : SIMPLE LINEAR REGRESSION
#           FinalGrade ~ Grade_Period1
# ============================================================

cat("------------------------------------------------------------\n")
cat("MODEL 1: Simple Linear Regression — G3 ~ G1\n")
cat("------------------------------------------------------------\n")

lm1 <- lm(FinalGrade ~ Grade_Period1, data = model_df)
cat("\nSummary:\n")
print(summary(lm1))

cat(sprintf("  Intercept (β0) : %.4f\n", coef(lm1)[1]))
cat(sprintf("  Slope     (β1) : %.4f  (each 1-pt ↑ in G1 → G3 ↑ by %.4f)\n",
            coef(lm1)[2], coef(lm1)[2]))
cat(sprintf("  R-Squared      : %.4f  (%.1f%% variance explained)\n",
            summary(lm1)$r.squared, summary(lm1)$r.squared * 100))


# ============================================================
# MODEL 2 : MULTIPLE LINEAR REGRESSION (Key Predictors)
# ============================================================

cat("\n------------------------------------------------------------\n")
cat("MODEL 2: Multiple Linear Regression (Key Predictors)\n")
cat("------------------------------------------------------------\n")

lm2 <- lm(FinalGrade ~ Grade_Period1 + Grade_Period2 +
             StudyTime_num + PastFailures + Absences +
             MeduNum + FeduNum + SchoolSup_num +
             WantsHigher_num + Internet_num +
             Dalc_num + Walc_num + Sex_num + Age,
           data = model_df)

cat("\nSummary:\n")
print(summary(lm2))

cat(sprintf("\n  Adj. R-Squared   : %.4f\n", summary(lm2)$adj.r.squared))
cat(sprintf("  F-statistic      : %.4f (p < 2.2e-16)\n", summary(lm2)$fstatistic[1]))
cat(sprintf("  Residual Std Err : %.4f\n", summary(lm2)$sigma))


# ============================================================
# MODEL 3 : STEPWISE REGRESSION (best subset selection)
# ============================================================

cat("\n------------------------------------------------------------\n")
cat("MODEL 3: Stepwise Regression (AIC-based selection)\n")
cat("------------------------------------------------------------\n")

full_model <- lm(FinalGrade ~ Grade_Period1 + Grade_Period2 +
                   StudyTime_num + PastFailures + Absences +
                   MeduNum + FeduNum + SchoolSup_num +
                   WantsHigher_num + Internet_num +
                   Dalc_num + Walc_num + Sex_num + Age +
                   TravelTime_num + Romantic_num + Health_num +
                   Address_num,
                 data = model_df)

step_model <- step(full_model, direction = "both", trace = 0)

cat("\nStepwise Selected Model Summary:\n")
print(summary(step_model))

cat("\nFinal Variables in Stepwise Model:\n")
print(names(coef(step_model)))


# ============================================================
# REGRESSION DIAGNOSTICS PLOTS
# ============================================================

cat("\nGenerating Regression Diagnostics plots...\n")

png(file.path(plot_dir, "16_regression_diagnostics.png"),
    width = 1400, height = 1200, res = 130, bg = "white")

par(mfrow = c(2, 2), oma = c(0, 0, 3, 0))
plot(lm2, which = 1:4, col = "#4E79A7", pch = 20, cex = 0.6)
mtext("Multiple Linear Regression – Model Diagnostics",
      outer = TRUE, cex = 1.2, font = 2, line = 1)

dev.off()
cat("  ✔ Saved: plots/16_regression_diagnostics.png\n")


# ============================================================
# ACTUAL vs PREDICTED PLOT
# ============================================================

cat("Generating Actual vs Predicted plot...\n")

pred_df <- model_df %>%
  mutate(
    Predicted = predict(lm2),
    Residual  = FinalGrade - Predicted
  )

p_pred <- ggplot(pred_df, aes(x = Predicted, y = FinalGrade)) +
  geom_point(aes(color = abs(Residual)), alpha = 0.65, size = 2) +
  geom_abline(slope = 1, intercept = 0, color = "red",
              linetype = "dashed", linewidth = 1.1) +
  scale_color_gradient(low = "#74ADD1", high = "#D73027", name = "|Residual|") +
  labs(
    title    = "Actual vs Predicted Final Grade",
    subtitle = sprintf("Multiple Linear Regression | Adj. R² = %.3f",
                       summary(lm2)$adj.r.squared),
    x        = "Predicted Final Grade (Ĝ3)",
    y        = "Actual Final Grade (G3)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40")
  )

ggsave(file.path(plot_dir, "17_actual_vs_predicted.png"),
       plot = p_pred, width = 9, height = 6, dpi = 150, bg = "white")
cat("  ✔ Saved: plots/17_actual_vs_predicted.png\n")


# ============================================================
# COEFFICIENT PLOT
# ============================================================

cat("Generating Coefficient importance plot...\n")

coef_df <- as.data.frame(summary(lm2)$coefficients) %>%
  tibble::rownames_to_column("Variable") %>%
  rename(Estimate = Estimate, SE = `Std. Error`, tval = `t value`, pval = `Pr(>|t|)`) %>%
  filter(Variable != "(Intercept)") %>%
  mutate(
    Significant = ifelse(pval < 0.05, "Yes (p < 0.05)", "No (p ≥ 0.05)"),
    Variable = c("Grade P1", "Grade P2", "Study Time", "Past Failures",
                 "Absences", "Mother Edu", "Father Edu", "School Support",
                 "Wants Higher", "Internet", "Weekday Alc.", "Weekend Alc.",
                 "Male (1=Yes)", "Age")
  ) %>%
  arrange(Estimate) %>%
  mutate(Variable = factor(Variable, levels = Variable))

p_coef <- ggplot(coef_df,
                 aes(x = Variable, y = Estimate, fill = Significant)) +
  geom_col(alpha = 0.85, width = 0.65) +
  geom_errorbar(aes(ymin = Estimate - 1.96 * SE,
                    ymax = Estimate + 1.96 * SE),
                width = 0.3, linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  coord_flip() +
  scale_fill_manual(values = c("Yes (p < 0.05)" = "#2166AC",
                               "No (p ≥ 0.05)"  = "#BABABA")) +
  labs(
    title    = "Regression Coefficients — Predictors of Final Grade",
    subtitle = "Error bars = 95% CI | Blue = statistically significant",
    x        = NULL,
    y        = "Coefficient Estimate (β)",
    fill     = "Significant?"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40"),
    legend.position = "bottom"
  )

ggsave(file.path(plot_dir, "18_regression_coefficients.png"),
       plot = p_coef, width = 10, height = 7, dpi = 150, bg = "white")
cat("  ✔ Saved: plots/18_regression_coefficients.png\n")


# ============================================================
# MODEL COMPARISON TABLE
# ============================================================

cat("\n==========================================================\n")
cat("               MODEL COMPARISON SUMMARY\n")
cat("==========================================================\n")

model_compare <- data.frame(
  Model     = c("Simple LR (G3 ~ G1)", "Multiple LR (14 vars)", "Stepwise LR"),
  R_Squared = round(c(
    summary(lm1)$r.squared,
    summary(lm2)$r.squared,
    summary(step_model)$r.squared
  ), 4),
  Adj_R_Squared = round(c(
    summary(lm1)$adj.r.squared,
    summary(lm2)$adj.r.squared,
    summary(step_model)$adj.r.squared
  ), 4),
  RMSE = round(c(
    sqrt(mean(residuals(lm1)^2)),
    sqrt(mean(residuals(lm2)^2)),
    sqrt(mean(residuals(step_model)^2))
  ), 4),
  AIC = round(c(AIC(lm1), AIC(lm2), AIC(step_model)), 2)
)

print(model_compare, row.names = FALSE)
write.csv(model_compare, "../output/model_comparison.csv", row.names = FALSE)

cat("\n✔ Model Comparison saved to output/model_comparison.csv\n")
cat("\n✔ Regression Analysis Complete!\n")
