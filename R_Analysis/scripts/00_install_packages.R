# ============================================================
# SCRIPT 00: Install & Load Required R Packages
# Project  : Student Performance Data Analysis
# Language : R (Primary)
# Author   : BTech CSE – 3rd Year Mini Project
# Dataset  : UCI ML Repository – Student Performance (Cortez, 2008)
# Source   : https://archive.ics.uci.edu/dataset/320/student+performance
# ============================================================

# ----- CRAN packages required -----
required_packages <- c(
  "tidyverse",   # Meta-package: dplyr, tidyr, ggplot2, readr, etc.
  "dplyr",       # Data manipulation (filter, mutate, summarise, group_by)
  "tidyr",       # Data tidying (pivot_longer, pivot_wider, drop_na)
  "ggplot2",     # Grammar of Graphics – publication-quality plots
  "readr",       # Fast CSV reading (read_csv / read_delim)
  "summarytools",# Descriptive statistics (dfSummary, freq, descr)
  "corrplot",    # Correlation matrix visualisation
  "scales",      # Axis label formatting helpers for ggplot2
  "gridExtra",   # Arrange multiple ggplot2 panels
  "knitr",       # Dynamic reporting
  "RColorBrewer" # Colour palettes
)

# Install any package that is not yet present
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]

if (length(new_packages) > 0) {
  cat("Installing missing packages:", paste(new_packages, collapse = ", "), "\n")
  install.packages(new_packages, repos = "https://cran.r-project.org", dependencies = TRUE)
} else {
  cat("All required packages are already installed.\n")
}

# Load all packages
invisible(lapply(required_packages, library, character.only = TRUE))
cat("\nAll packages loaded successfully!\n")
