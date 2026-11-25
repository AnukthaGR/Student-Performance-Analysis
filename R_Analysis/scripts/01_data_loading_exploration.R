# ============================================================
# SCRIPT 01: Data Loading & Exploration (Step 1 of Analysis)
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Libraries: readr, dplyr, tidyr, summarytools
# Dataset  : UCI ML Repo – student-mat.csv (Mathematics)
# Source   : https://archive.ics.uci.edu/dataset/320/student+performance
# ============================================================

# ---- Load Libraries ----
library(readr)
library(dplyr)
library(tidyr)
library(summarytools)

# ============================================================
# STEP 1 : LOAD THE DATASET
# The UCI student-mat.csv uses semicolon (;) as separator
# ============================================================

# Build path relative to working directory (run from R_Analysis/scripts/)
data_path <- file.path("..", "..", "dataset", "student-mat.csv")

student_df <- read_delim(
  data_path,
  delim        = ";",
  col_types    = cols(
    school     = col_character(),
    sex        = col_character(),
    age        = col_integer(),
    address    = col_character(),
    famsize    = col_character(),
    Pstatus    = col_character(),
    Medu       = col_integer(),
    Fedu       = col_integer(),
    Mjob       = col_character(),
    Fjob       = col_character(),
    reason     = col_character(),
    guardian   = col_character(),
    traveltime = col_integer(),
    studytime  = col_integer(),
    failures   = col_integer(),
    schoolsup  = col_character(),
    famsup     = col_character(),
    paid       = col_character(),
    activities = col_character(),
    nursery    = col_character(),
    higher     = col_character(),
    internet   = col_character(),
    romantic   = col_character(),
    famrel     = col_integer(),
    freetime   = col_integer(),
    goout      = col_integer(),
    Dalc       = col_integer(),
    Walc       = col_integer(),
    health     = col_integer(),
    absences   = col_integer(),
    G1         = col_integer(),
    G2         = col_integer(),
    G3         = col_integer()
  ),
  show_col_types = FALSE
)

# ============================================================
# STEP 2 : INITIAL EXPLORATION
# ============================================================

cat("==========================================================\n")
cat("        STUDENT PERFORMANCE – MATHEMATICS DATASET\n")
cat("     Source: UCI Machine Learning Repository (2008)\n")
cat("==========================================================\n\n")

cat("--- Dimensions (rows × columns) ---\n")
cat("Rows:", nrow(student_df), " | Columns:", ncol(student_df), "\n\n")

cat("--- Column Names ---\n")
print(names(student_df))

cat("\n--- Data Types (glimpse) ---\n")
glimpse(student_df)

cat("\n--- First 6 Rows ---\n")
print(head(student_df, 6))

cat("\n--- Last 6 Rows ---\n")
print(tail(student_df, 6))

# ============================================================
# STEP 3 : MISSING VALUE CHECK  (using dplyr + tidyr)
# ============================================================

cat("\n==========================================================\n")
cat("               MISSING VALUE ANALYSIS\n")
cat("==========================================================\n")

missing_summary <- student_df %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(cols = everything(),
               names_to  = "Column",
               values_to = "Missing_Count") %>%
  mutate(Missing_Pct = round(Missing_Count / nrow(student_df) * 100, 2)) %>%
  arrange(desc(Missing_Count))

print(missing_summary)

total_missing <- sum(missing_summary$Missing_Count)
cat("\nTotal missing values across all columns:", total_missing, "\n")

if (total_missing == 0) {
  cat("✔ Dataset is COMPLETE – No missing values found!\n")
} else {
  cat("⚠ Missing values detected. Review and handle them before analysis.\n")
}

# ============================================================
# STEP 4 : DESCRIPTIVE STATISTICS  (summarytools::descr)
# ============================================================

cat("\n==========================================================\n")
cat("              DESCRIPTIVE STATISTICS (Numeric Columns)\n")
cat("==========================================================\n")

numeric_cols <- student_df %>% select(where(is.numeric))
print(descr(numeric_cols, stats = c("mean", "sd", "min", "q1", "med", "q3", "max", "skewness", "kurtosis"),
            transpose = TRUE))

# ============================================================
# STEP 5 : FREQUENCY TABLES FOR CATEGORICAL COLUMNS
# ============================================================

cat("\n==========================================================\n")
cat("        FREQUENCY TABLES – CATEGORICAL VARIABLES\n")
cat("==========================================================\n")

cat_cols <- c("school", "sex", "address", "famsize", "Pstatus",
              "Mjob", "Fjob", "reason", "guardian",
              "schoolsup", "famsup", "paid", "activities",
              "nursery", "higher", "internet", "romantic")

for (col in cat_cols) {
  cat(sprintf("\n--- %s ---\n", col))
  tbl <- student_df %>%
    count(!!sym(col)) %>%
    mutate(Percentage = round(n / sum(n) * 100, 1)) %>%
    rename(Value = !!sym(col), Count = n)
  print(tbl)
}

# ============================================================
# STEP 6 : GRADE DISTRIBUTION OVERVIEW
# ============================================================

cat("\n==========================================================\n")
cat("              GRADE DISTRIBUTION SUMMARY\n")
cat("==========================================================\n")

grade_summary <- student_df %>%
  summarise(
    G1_Mean = round(mean(G1), 2), G1_SD = round(sd(G1), 2),
    G2_Mean = round(mean(G2), 2), G2_SD = round(sd(G2), 2),
    G3_Mean = round(mean(G3), 2), G3_SD = round(sd(G3), 2),
    Pass_Rate = round(mean(G3 >= 10) * 100, 1),
    Fail_Rate = round(mean(G3 < 10) * 100, 1)
  )

print(grade_summary)

# ============================================================
# STEP 7 : PERFORMANCE CATEGORY CLASSIFICATION
# ============================================================

student_df <- student_df %>%
  mutate(
    performance = case_when(
      G3 >= 16 ~ "Excellent (16–20)",
      G3 >= 14 ~ "Very Good (14–15)",
      G3 >= 10 ~ "Pass (10–13)",
      G3 >= 1  ~ "Fail (1–9)",
      TRUE     ~ "Zero Grade (0)"
    ),
    performance = factor(performance,
                         levels = c("Excellent (16–20)", "Very Good (14–15)",
                                    "Pass (10–13)", "Fail (1–9)", "Zero Grade (0)"))
  )

cat("\n--- Performance Category Distribution ---\n")
student_df %>%
  count(performance) %>%
  mutate(Percentage = round(n / sum(n) * 100, 1)) %>%
  print()

# Save cleaned data for use in subsequent scripts
saveRDS(student_df, file.path("..", "output", "student_cleaned.rds"))
cat("\n✔ Cleaned dataset saved to output/student_cleaned.rds\n")
