# ============================================================
# SCRIPT 02: Data Cleaning & Preprocessing
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Libraries: dplyr, tidyr, readr
# ============================================================

library(dplyr)
library(tidyr)
library(readr)

# ---- Load cleaned RDS (produced by Script 01) ----
student_df <- readRDS("../output/student_cleaned.rds")

cat("==========================================================\n")
cat("         DATA CLEANING & PREPROCESSING\n")
cat("==========================================================\n")

# ============================================================
# STEP 1 : DUPLICATE ROW DETECTION & REMOVAL
# ============================================================

original_rows <- nrow(student_df)
student_df    <- student_df %>% distinct()
removed_dups  <- original_rows - nrow(student_df)

cat(sprintf("\nDuplicate rows removed : %d\n", removed_dups))
cat(sprintf("Rows after dedup       : %d\n", nrow(student_df)))

# ============================================================
# STEP 2 : RENAME COLUMNS FOR READABILITY
# ============================================================

student_df <- student_df %>%
  rename(
    School            = school,
    Sex               = sex,
    Age               = age,
    Address           = address,
    FamilySize        = famsize,
    ParentStatus      = Pstatus,
    MotherEducation   = Medu,
    FatherEducation   = Fedu,
    MotherJob         = Mjob,
    FatherJob         = Fjob,
    SchoolReason      = reason,
    Guardian          = guardian,
    TravelTime        = traveltime,
    StudyTime         = studytime,
    PastFailures      = failures,
    SchoolSupport     = schoolsup,
    FamilySupport     = famsup,
    PaidClasses       = paid,
    ExtraCurricular   = activities,
    Nursery           = nursery,
    WantsHigherEdu    = higher,
    Internet          = internet,
    Romantic          = romantic,
    FamilyRelation    = famrel,
    FreeTime          = freetime,
    GoOut             = goout,
    WeekdayAlcohol    = Dalc,
    WeekendAlcohol    = Walc,
    Health            = health,
    Absences          = absences,
    Grade_Period1     = G1,
    Grade_Period2     = G2,
    FinalGrade        = G3
  )

cat("\nColumn names after renaming:\n")
print(names(student_df))

# ============================================================
# STEP 3 : CONVERT BINARY TEXT COLUMNS TO LOGICAL / FACTOR
# ============================================================

binary_cols <- c("SchoolSupport", "FamilySupport", "PaidClasses",
                 "ExtraCurricular", "Nursery", "WantsHigherEdu",
                 "Internet", "Romantic")

student_df <- student_df %>%
  mutate(across(all_of(binary_cols), ~ factor(., levels = c("no", "yes"))))

# Ordinal factor for education levels
education_levels <- c("0 – None", "1 – Primary (4th)", "2 – 5th-9th Grade",
                       "3 – Secondary", "4 – Higher Education")

student_df <- student_df %>%
  mutate(
    MotherEducation = factor(MotherEducation,
                             levels = 0:4, labels = education_levels),
    FatherEducation = factor(FatherEducation,
                             levels = 0:4, labels = education_levels)
  )

# Ordinal factors for 1–5 scale columns
likert_cols <- c("TravelTime", "StudyTime", "FamilyRelation",
                 "FreeTime", "GoOut", "WeekdayAlcohol", "WeekendAlcohol", "Health")

student_df <- student_df %>%
  mutate(across(all_of(likert_cols), as.ordered))

# School and sex as factors
student_df <- student_df %>%
  mutate(
    School     = factor(School),
    Sex        = factor(Sex, levels = c("F", "M"), labels = c("Female", "Male")),
    Address    = factor(Address, levels = c("U", "R"), labels = c("Urban", "Rural")),
    FamilySize = factor(FamilySize, levels = c("LE3", "GT3"),
                        labels = c("≤3 members", ">3 members")),
    ParentStatus = factor(ParentStatus, levels = c("T", "A"),
                          labels = c("Living Together", "Apart"))
  )

# ============================================================
# STEP 4 : DETECT & HANDLE OUTLIERS IN NUMERIC COLUMNS
#          Using IQR method – flag only, not remove
# ============================================================

cat("\n==========================================================\n")
cat("            OUTLIER DETECTION (IQR Method)\n")
cat("==========================================================\n")

numeric_vars <- c("Age", "Absences", "Grade_Period1", "Grade_Period2", "FinalGrade")

outlier_report <- lapply(numeric_vars, function(col) {
  x  <- student_df[[col]]
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  lower <- Q1 - 1.5 * IQR_val
  upper <- Q3 + 1.5 * IQR_val
  n_out <- sum(x < lower | x > upper, na.rm = TRUE)
  data.frame(
    Variable      = col,
    Q1            = Q1,
    Q3            = Q3,
    IQR           = IQR_val,
    Lower_Fence   = lower,
    Upper_Fence   = upper,
    Outlier_Count = n_out
  )
}) %>% bind_rows()

print(outlier_report)

# Flag outliers in Absences column (most skewed)
student_df <- student_df %>%
  mutate(
    Absences_Outlier = Absences > quantile(Absences, 0.75) + 1.5 * IQR(Absences)
  )

cat(sprintf("\nStudents with excessive absences (outlier flag): %d\n",
            sum(student_df$Absences_Outlier)))

# ============================================================
# STEP 5 : FEATURE ENGINEERING
# ============================================================

cat("\n==========================================================\n")
cat("              FEATURE ENGINEERING\n")
cat("==========================================================\n")

student_df <- student_df %>%
  mutate(
    # Average grade across all 3 periods
    AvgGrade = round((Grade_Period1 + Grade_Period2 + FinalGrade) / 3, 2),

    # Grade improvement from P1 → G3
    GradeImprovement = FinalGrade - Grade_Period1,

    # Pass / Fail flag
    PassFail = ifelse(FinalGrade >= 10, "Pass", "Fail"),
    PassFail = factor(PassFail, levels = c("Pass", "Fail")),

    # Alcohol risk index (average of weekday + weekend)
    AlcoholIndex = (as.numeric(WeekdayAlcohol) + as.numeric(WeekendAlcohol)) / 2,

    # Parent education average
    ParentEduAvg = (as.numeric(MotherEducation) + as.numeric(FatherEducation)) / 2
  )

cat("New engineered features added:\n")
cat("  - AvgGrade         : Mean of G1, G2, G3\n")
cat("  - GradeImprovement : G3 – G1 (progress indicator)\n")
cat("  - PassFail         : Binary pass/fail on G3 >= 10\n")
cat("  - AlcoholIndex     : Combined alcohol risk score\n")
cat("  - ParentEduAvg     : Average parental education level\n")

cat("\n--- Pass / Fail Split ---\n")
student_df %>%
  count(PassFail) %>%
  mutate(Percentage = round(n / sum(n) * 100, 1)) %>%
  print()

# ============================================================
# STEP 6 : SAVE PREPROCESSED DATASET
# ============================================================

saveRDS(student_df, "../output/student_preprocessed.rds")
write_csv(student_df %>% mutate(across(where(is.factor), as.character)),
          "../output/student_preprocessed.csv")

cat("\n✔ Preprocessed data saved to:\n")
cat("   ../output/student_preprocessed.rds\n")
cat("   ../output/student_preprocessed.csv\n")
