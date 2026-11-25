# ============================================================
# MASTER RUNNER — Sets working dir and runs all scripts
# Run this from ANYWHERE with:
#   Rscript "path/to/R_Analysis/RUN_PROJECT.R"
# ============================================================

# Auto-detect and set working dir to scripts folder
this_file <- normalizePath(sys.frames()[[1]]$ofile, mustWork = FALSE)
if (is.null(this_file) || this_file == "") {
  # Fallback: set manually
  script_dir <- file.path(
    "C:/Users/Anuktha G R/OneDrive/Desktop/solo project",
    "Student-Performance-Analysis/R_Analysis/scripts"
  )
} else {
  script_dir <- file.path(dirname(this_file), "scripts")
}

setwd(script_dir)
cat("Working directory set to:", getwd(), "\n\n")

# ---- Install required packages ----
required_packages <- c(
  "tidyverse", "dplyr", "tidyr", "ggplot2", "readr",
  "summarytools", "corrplot", "scales", "gridExtra",
  "knitr", "RColorBrewer", "class"
)
new_pkgs <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if (length(new_pkgs) > 0) {
  cat("Installing packages:", paste(new_pkgs, collapse = ", "), "\n")
  install.packages(new_pkgs, repos = "https://cloud.r-project.org", dependencies = TRUE, quiet = TRUE)
}
invisible(lapply(required_packages, library, character.only = TRUE))
cat("All packages loaded!\n\n")

# ---- Create output directories if missing ----
dir.create("../plots",  showWarnings = FALSE, recursive = TRUE)
dir.create("../output", showWarnings = FALSE, recursive = TRUE)

# ---- Run all scripts ----
scripts <- c(
  "01_data_loading_exploration.R",
  "02_data_cleaning.R",
  "03_visualizations.R",
  "04_correlation_analysis.R",
  "05_statistical_tests.R",
  "06_regression_analysis.R",
  "07_segmentation_insights.R",
  "08_predictive_modeling.R"
)

start_time <- Sys.time()

for (i in seq_along(scripts)) {
  s <- scripts[i]
  cat(sprintf("\n========== [%d/%d] %s ==========\n", i, length(scripts), s))
  tryCatch(
    source(s, local = new.env()),
    error = function(e) cat("  ERROR:", conditionMessage(e), "\n")
  )
  cat(sprintf("  Done: %s\n", s))
}

elapsed <- round(difftime(Sys.time(), start_time, units = "secs"), 1)

cat("\n╔══════════════════════════════════╗\n")
cat("║   PROJECT COMPLETE!              ║\n")
cat(sprintf("║   Time taken: %-18s║\n", paste0(elapsed, "s")))
cat("╚══════════════════════════════════╝\n")
cat("\nPlots saved in:  R_Analysis/plots/\n")
cat("Data saved in:   R_Analysis/output/\n")
