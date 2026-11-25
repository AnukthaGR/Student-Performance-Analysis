# ============================================================
# SCRIPT 09: Master Run Script
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Description: Runs all analysis scripts in sequence.
#              Set your working directory to R_Analysis/scripts/
#              before running this master script.
# ============================================================

cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║   STUDENT PERFORMANCE DATA ANALYSIS — MASTER RUNNER     ║\n")
cat("║   Language: R | Dataset: UCI ML Repository (2008)       ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")

start_time <- Sys.time()

# ---- Set working directory to scripts folder ----
# Adjust this path if running from a different location
# setwd("path/to/R_Analysis/scripts")

scripts <- c(
  "00_install_packages.R",
  "01_data_loading_exploration.R",
  "02_data_cleaning.R",
  "03_visualizations.R",
  "04_correlation_analysis.R",
  "05_statistical_tests.R",
  "06_regression_analysis.R",
  "07_segmentation_insights.R",
  "08_predictive_modeling.R"
)

for (i in seq_along(scripts)) {
  s <- scripts[i]
  cat(sprintf("\n[%d/%d] Running: %s\n", i, length(scripts), s))
  cat(strrep("─", 55), "\n")
  tryCatch(
    source(s, local = TRUE),
    error = function(e) {
      cat(sprintf("  ✗ ERROR in %s:\n  %s\n", s, conditionMessage(e)))
    }
  )
  cat(sprintf("[%d/%d] ✔ Completed: %s\n", i, length(scripts), s))
}

end_time <- Sys.time()

cat("\n╔══════════════════════════════════════════════════════════╗\n")
cat("║               ALL SCRIPTS COMPLETED!                    ║\n")
cat(sprintf("║  Total Time: %-40s║\n",
            format(round(difftime(end_time, start_time, units = "secs"), 1))))
cat("╚══════════════════════════════════════════════════════════╝\n\n")

cat("Output files generated:\n")
cat("  📁 R_Analysis/output/\n")
cat("     ├── student_cleaned.rds\n")
cat("     ├── student_preprocessed.rds\n")
cat("     ├── student_preprocessed.csv\n")
cat("     ├── hypothesis_tests_summary.csv\n")
cat("     ├── model_comparison.csv\n")
cat("     └── classification_model_comparison.csv\n\n")
cat("  📁 R_Analysis/plots/\n")
cat("     ├── 01_final_grade_distribution.png\n")
cat("     ├── 02_grade_period_comparison.png\n")
cat("     ├── 03_gender_vs_final_grade.png\n")
cat("     ├── 04_studytime_vs_final_grade.png\n")
cat("     ├── 05_past_failures_vs_grade.png\n")
cat("     ├── 06_absences_vs_final_grade.png\n")
cat("     ├── 07_mother_education_vs_grade.png\n")
cat("     ├── 08_internet_vs_grade.png\n")
cat("     ├── 09_grade_improvement_by_gender.png\n")
cat("     ├── 10_pass_fail_donut.png\n")
cat("     ├── 11_alcohol_vs_grade.png\n")
cat("     ├── 12_school_support_vs_passfail.png\n")
cat("     ├── 13_correlation_heatmap_full.png\n")
cat("     ├── 14_correlation_grade_focused.png\n")
cat("     ├── 15_correlation_barplot.png\n")
cat("     ├── 16_regression_diagnostics.png\n")
cat("     ├── 17_actual_vs_predicted.png\n")
cat("     ├── 18_regression_coefficients.png\n")
cat("     ├── 19_heatmap_studytime_gender_grade.png\n")
cat("     ├── 20_faceted_absences_vs_grade.png\n")
cat("     ├── 21_mothers_job_vs_grade.png\n")
cat("     ├── 22_roc_curve_logistic.png\n")
cat("     └── 23_knn_k_vs_accuracy.png\n")
