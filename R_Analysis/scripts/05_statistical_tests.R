# ============================================================
# SCRIPT 05: Statistical Tests & Hypothesis Testing
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Libraries: dplyr, ggplot2 (base R stats functions used)
# ============================================================

library(dplyr)
library(ggplot2)

# ---- Load preprocessed data ----
df <- readRDS("../output/student_preprocessed.rds")

plot_dir <- "../plots"

cat("==========================================================\n")
cat("        STATISTICAL TESTS & HYPOTHESIS TESTING\n")
cat("==========================================================\n\n")

alpha <- 0.05  # Significance level

# ============================================================
# TEST 1 : INDEPENDENT SAMPLES t-TEST
#          H0: Male and Female students have the same mean final grade
#          H1: There is a significant difference between genders
# ============================================================

cat("------------------------------------------------------------\n")
cat("TEST 1: Independent Samples t-Test (Gender vs Final Grade)\n")
cat("------------------------------------------------------------\n")
cat("H0: mean(FinalGrade_Male) = mean(FinalGrade_Female)\n")
cat("H1: mean(FinalGrade_Male) ≠ mean(FinalGrade_Female) (two-sided)\n\n")

male_grades   <- df$FinalGrade[df$Sex == "Male"]
female_grades <- df$FinalGrade[df$Sex == "Female"]

t_test_gender <- t.test(male_grades, female_grades,
                         var.equal = FALSE, alternative = "two.sided")

cat(sprintf("  Male   Mean Grade : %.2f (n = %d)\n", mean(male_grades),   length(male_grades)))
cat(sprintf("  Female Mean Grade : %.2f (n = %d)\n", mean(female_grades), length(female_grades)))
cat(sprintf("  t-statistic       : %.4f\n", t_test_gender$statistic))
cat(sprintf("  Degrees of freedom: %.2f\n", t_test_gender$parameter))
cat(sprintf("  p-value           : %.4f\n", t_test_gender$p.value))
cat(sprintf("  95%% CI            : [%.4f, %.4f]\n",
            t_test_gender$conf.int[1], t_test_gender$conf.int[2]))

if (t_test_gender$p.value < alpha) {
  cat(sprintf("  → REJECT H0 (p < %.2f): Significant gender difference found.\n", alpha))
} else {
  cat(sprintf("  → FAIL TO REJECT H0 (p ≥ %.2f): No significant gender difference.\n", alpha))
}


# ============================================================
# TEST 2 : ONE-WAY ANOVA
#          H0: Mean final grade is the same across all study time groups
#          H1: At least one study time group differs
# ============================================================

cat("\n------------------------------------------------------------\n")
cat("TEST 2: One-Way ANOVA (Study Time vs Final Grade)\n")
cat("------------------------------------------------------------\n")
cat("H0: All study time groups have equal mean final grade\n")
cat("H1: At least one group mean is different\n\n")

anova_model  <- aov(FinalGrade ~ factor(StudyTime), data = df)
anova_result <- summary(anova_model)

print(anova_result)

anova_pval <- anova_result[[1]]$`Pr(>F)`[1]
if (anova_pval < alpha) {
  cat(sprintf("\n  → REJECT H0 (p < %.2f): Study time significantly affects final grade.\n", alpha))
} else {
  cat(sprintf("\n  → FAIL TO REJECT H0 (p ≥ %.2f): No significant effect of study time.\n", alpha))
}

# Post-hoc Tukey HSD (only if significant)
if (anova_pval < alpha) {
  cat("\n--- Tukey HSD Post-Hoc Test ---\n")
  tukey_result <- TukeyHSD(anova_model)
  print(tukey_result)
}


# ============================================================
# TEST 3 : CHI-SQUARE TEST OF INDEPENDENCE
#          H0: Internet access and Pass/Fail are independent
#          H1: They are associated
# ============================================================

cat("\n------------------------------------------------------------\n")
cat("TEST 3: Chi-Square Test (Internet Access vs Pass/Fail)\n")
cat("------------------------------------------------------------\n")
cat("H0: Internet access and academic outcome are independent\n")
cat("H1: Internet access and academic outcome are associated\n\n")

contingency_table <- table(df$Internet, df$PassFail)
cat("Contingency Table:\n")
print(contingency_table)
cat("\nRow Percentages:\n")
print(round(prop.table(contingency_table, margin = 1) * 100, 1))

chi_test <- chisq.test(contingency_table)
cat(sprintf("\n  Chi-Square Statistic : %.4f\n", chi_test$statistic))
cat(sprintf("  Degrees of Freedom   : %d\n", chi_test$parameter))
cat(sprintf("  p-value              : %.4f\n", chi_test$p.value))

# Effect size: Cramer's V
n_chi   <- sum(contingency_table)
cramers_v <- sqrt(chi_test$statistic / (n_chi * (min(dim(contingency_table)) - 1)))
cat(sprintf("  Cramer's V (effect)  : %.4f\n", cramers_v))

if (chi_test$p.value < alpha) {
  cat(sprintf("  → REJECT H0 (p < %.2f): Internet access is associated with pass/fail.\n", alpha))
} else {
  cat(sprintf("  → FAIL TO REJECT H0 (p ≥ %.2f): No significant association found.\n", alpha))
}


# ============================================================
# TEST 4 : PEARSON CORRELATION TEST
#          H0: No linear correlation between study time and final grade
#          H1: Significant positive correlation exists
# ============================================================

cat("\n------------------------------------------------------------\n")
cat("TEST 4: Pearson Correlation Test (Study Time vs Final Grade)\n")
cat("------------------------------------------------------------\n")
cat("H0: ρ = 0 (no linear relationship)\n")
cat("H1: ρ > 0 (positive relationship, one-sided)\n\n")

cor_test <- cor.test(as.numeric(df$StudyTime), df$FinalGrade,
                     method = "pearson", alternative = "greater")

cat(sprintf("  Pearson r   : %.4f\n",  cor_test$estimate))
cat(sprintf("  t-statistic : %.4f\n",  cor_test$statistic))
cat(sprintf("  p-value     : %.6f\n",  cor_test$p.value))
cat(sprintf("  95%% CI      : [%.4f, Inf]\n", cor_test$conf.int[1]))

if (cor_test$p.value < alpha) {
  cat(sprintf("  → REJECT H0 (p < %.2f): Significant positive correlation found.\n", alpha))
} else {
  cat(sprintf("  → FAIL TO REJECT H0 (p ≥ %.2f): No significant correlation.\n", alpha))
}


# ============================================================
# TEST 5 : SHAPIRO-WILK NORMALITY TEST on FinalGrade
# ============================================================

cat("\n------------------------------------------------------------\n")
cat("TEST 5: Shapiro-Wilk Test for Normality (Final Grade)\n")
cat("------------------------------------------------------------\n")
cat("H0: Final grade is normally distributed\n")
cat("H1: Final grade is NOT normally distributed\n\n")

# Shapiro-Wilk needs n ≤ 5000; sample if larger
set.seed(42)
sample_grades <- if (nrow(df) > 5000) sample(df$FinalGrade, 5000) else df$FinalGrade

sw_test <- shapiro.test(sample_grades)
cat(sprintf("  W statistic : %.6f\n", sw_test$statistic))
cat(sprintf("  p-value     : %.6f\n", sw_test$p.value))

if (sw_test$p.value < alpha) {
  cat(sprintf("  → REJECT H0 (p < %.2f): Grades are NOT normally distributed.\n", alpha))
} else {
  cat(sprintf("  → FAIL TO REJECT H0 (p ≥ %.2f): Grades are approximately normal.\n", alpha))
}


# ============================================================
# SUMMARY TABLE OF ALL TESTS
# ============================================================

cat("\n==========================================================\n")
cat("              HYPOTHESIS TEST SUMMARY TABLE\n")
cat("==========================================================\n")

summary_tests <- data.frame(
  Test = c(
    "t-Test: Gender vs Grade",
    "ANOVA: Study Time vs Grade",
    "Chi-Square: Internet vs Pass/Fail",
    "Pearson Corr: Study Time vs Grade",
    "Shapiro-Wilk: Normality of Grade"
  ),
  Statistic = c(
    round(t_test_gender$statistic, 4),
    round(anova_result[[1]]$`F value`[1], 4),
    round(chi_test$statistic, 4),
    round(cor_test$statistic, 4),
    round(sw_test$statistic, 4)
  ),
  p_value = c(
    round(t_test_gender$p.value, 4),
    round(anova_pval, 4),
    round(chi_test$p.value, 4),
    round(cor_test$p.value, 6),
    round(sw_test$p.value, 6)
  ),
  Decision = c(
    ifelse(t_test_gender$p.value < alpha, "Reject H0", "Fail to Reject H0"),
    ifelse(anova_pval < alpha,            "Reject H0", "Fail to Reject H0"),
    ifelse(chi_test$p.value < alpha,      "Reject H0", "Fail to Reject H0"),
    ifelse(cor_test$p.value < alpha,      "Reject H0", "Fail to Reject H0"),
    ifelse(sw_test$p.value < alpha,       "Reject H0", "Fail to Reject H0")
  )
)

print(summary_tests, row.names = FALSE)

# Save summary
write.csv(summary_tests, "../output/hypothesis_tests_summary.csv", row.names = FALSE)
cat("\n✔ Hypothesis Test Summary saved to output/hypothesis_tests_summary.csv\n")
