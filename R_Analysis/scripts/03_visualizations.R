# ============================================================
# SCRIPT 03: Exploratory Data Analysis (EDA) & Visualizations
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Libraries: ggplot2, dplyr, RColorBrewer, gridExtra, scales
# ============================================================

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(gridExtra)
library(RColorBrewer)

# ---- Set global theme ----
theme_set(
  theme_minimal(base_size = 13) +
    theme(
      plot.title    = element_text(face = "bold", size = 15, hjust = 0.5),
      plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
      plot.caption  = element_text(size = 9, color = "gray50"),
      axis.title    = element_text(face = "bold"),
      legend.position = "bottom"
    )
)

# ---- Load preprocessed data ----
df <- readRDS("../output/student_preprocessed.rds")

# Output plot directory
plot_dir <- "../plots"
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

# Helper: save plot
save_plot <- function(p, filename, w = 9, h = 6) {
  ggsave(file.path(plot_dir, filename), plot = p,
         width = w, height = h, dpi = 150, bg = "white")
  cat(sprintf("  ✔ Saved: plots/%s\n", filename))
}

cat("==========================================================\n")
cat("   EXPLORATORY DATA ANALYSIS – VISUALIZATIONS (ggplot2)\n")
cat("==========================================================\n\n")


# ===========================================================
# PLOT 01 – FINAL GRADE DISTRIBUTION (Histogram + Density)
# ===========================================================

cat("Creating Plot 01: Final Grade Distribution...\n")

p01 <- ggplot(df, aes(x = FinalGrade)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 1,
                 fill = "#4E79A7", color = "white", alpha = 0.85) +
  geom_density(color = "#E15759", linewidth = 1.1, fill = "#E15759", alpha = 0.08) +
  geom_vline(xintercept = mean(df$FinalGrade), linetype = "dashed",
             color = "darkorange", linewidth = 0.9) +
  annotate("text", x = mean(df$FinalGrade) + 0.6, y = 0.1,
           label = sprintf("Mean=%.1f", mean(df$FinalGrade)),
           color = "darkorange", size = 4, fontface = "bold") +
  scale_x_continuous(breaks = 0:20) +
  labs(
    title    = "Distribution of Final Grades (G3)",
    subtitle = "Mathematics course | UCI Student Performance Dataset",
    x        = "Final Grade (0–20 scale)",
    y        = "Density",
    caption  = "Source: UCI ML Repository – Cortez & Silva (2008)"
  )

save_plot(p01, "01_final_grade_distribution.png")


# ===========================================================
# PLOT 02 – GRADE PERIODS COMPARISON (Boxplot: G1, G2, G3)
# ===========================================================

cat("Creating Plot 02: Grade Period Comparison...\n")

grade_long <- df %>%
  select(Grade_Period1, Grade_Period2, FinalGrade) %>%
  pivot_longer(cols = everything(),
               names_to  = "Period",
               values_to = "Grade") %>%
  mutate(Period = recode(Period,
    "Grade_Period1" = "Period 1 (G1)",
    "Grade_Period2" = "Period 2 (G2)",
    "FinalGrade"    = "Final Grade (G3)"
  ))

p02 <- ggplot(grade_long, aes(x = Period, y = Grade, fill = Period)) +
  geom_boxplot(outlier.color = "red", outlier.size = 1.5, alpha = 0.8) +
  geom_jitter(width = 0.12, alpha = 0.15, size = 1) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title    = "Grade Distribution Across Three Periods",
    subtitle = "Comparing G1, G2 and Final Grade (G3)",
    x        = "Assessment Period",
    y        = "Grade (0–20)",
    fill     = ""
  ) +
  theme(legend.position = "none")

save_plot(p02, "02_grade_period_comparison.png")


# ===========================================================
# PLOT 03 – GENDER vs FINAL GRADE (Violin + Boxplot)
# ===========================================================

cat("Creating Plot 03: Gender vs Final Grade...\n")

gender_stats <- df %>%
  group_by(Sex) %>%
  summarise(Mean = round(mean(FinalGrade), 2), .groups = "drop")

p03 <- ggplot(df, aes(x = Sex, y = FinalGrade, fill = Sex)) +
  geom_violin(alpha = 0.6, trim = FALSE) +
  geom_boxplot(width = 0.12, fill = "white", outlier.color = "red", outlier.size = 1.5) +
  geom_text(data = gender_stats, aes(y = 21, label = paste("μ =", Mean)),
            vjust = 0, fontface = "bold", size = 4.5) +
  scale_fill_manual(values = c("Female" = "#F28B82", "Male" = "#82B4F5")) +
  labs(
    title    = "Final Grade Distribution by Gender",
    subtitle = "Violin plot with embedded boxplot",
    x        = "Gender",
    y        = "Final Grade (G3)",
    fill     = "Gender"
  )

save_plot(p03, "03_gender_vs_final_grade.png")


# ===========================================================
# PLOT 04 – STUDY TIME vs FINAL GRADE (Bar + Error Bars)
# ===========================================================

cat("Creating Plot 04: Study Time vs Final Grade...\n")

study_summary <- df %>%
  mutate(StudyTime_Label = recode(as.character(StudyTime),
    "1" = "<2 hrs", "2" = "2–5 hrs", "3" = "5–10 hrs", "4" = ">10 hrs")) %>%
  mutate(StudyTime_Label = factor(StudyTime_Label,
    levels = c("<2 hrs", "2–5 hrs", "5–10 hrs", ">10 hrs"))) %>%
  group_by(StudyTime_Label) %>%
  summarise(
    Mean_Grade = mean(FinalGrade),
    SD_Grade   = sd(FinalGrade),
    Count      = n(),
    SE         = SD_Grade / sqrt(Count),
    .groups    = "drop"
  )

p04 <- ggplot(study_summary,
              aes(x = StudyTime_Label, y = Mean_Grade, fill = StudyTime_Label)) +
  geom_col(alpha = 0.85, width = 0.6) +
  geom_errorbar(aes(ymin = Mean_Grade - SE, ymax = Mean_Grade + SE),
                width = 0.2, linewidth = 0.8) +
  geom_text(aes(label = sprintf("%.1f\n(n=%d)", Mean_Grade, Count)),
            vjust = -0.5, size = 3.8, fontface = "bold") +
  scale_fill_brewer(palette = "Blues") +
  scale_y_continuous(limits = c(0, 15), expand = expansion(mult = c(0, 0.15))) +
  labs(
    title    = "Effect of Weekly Study Time on Final Grade",
    subtitle = "Mean final grade ± standard error per study time category",
    x        = "Weekly Study Time",
    y        = "Mean Final Grade (G3)",
    fill     = ""
  ) +
  theme(legend.position = "none")

save_plot(p04, "04_studytime_vs_final_grade.png")


# ===========================================================
# PLOT 05 – PAST FAILURES vs FINAL GRADE
# ===========================================================

cat("Creating Plot 05: Past Failures vs Final Grade...\n")

fail_summary <- df %>%
  mutate(Failures_Label = paste0(PastFailures, " failure(s)")) %>%
  group_by(Failures_Label) %>%
  summarise(Mean_G3 = mean(FinalGrade), Count = n(), .groups = "drop")

p05 <- ggplot(df, aes(x = factor(PastFailures), y = FinalGrade)) +
  geom_boxplot(aes(fill = factor(PastFailures)), alpha = 0.75,
               outlier.color = "red", outlier.size = 1.5) +
  stat_summary(fun = mean, geom = "point", shape = 23,
               size = 4, fill = "gold", color = "black") +
  scale_fill_brewer(palette = "RdYlGn", direction = -1) +
  labs(
    title    = "Impact of Past Failures on Final Grade",
    subtitle = "Diamond (◆) = mean grade | Box = IQR",
    x        = "Number of Past Failures",
    y        = "Final Grade (G3)",
    fill     = "Failures"
  )

save_plot(p05, "05_past_failures_vs_grade.png")


# ===========================================================
# PLOT 06 – ABSENCES vs FINAL GRADE (Scatter + Regression)
# ===========================================================

cat("Creating Plot 06: Absences vs Final Grade...\n")

p06 <- ggplot(df, aes(x = Absences, y = FinalGrade)) +
  geom_point(aes(color = PassFail), alpha = 0.55, size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "navy", linewidth = 1.1,
              fill = "lightblue", alpha = 0.3) +
  scale_color_manual(values = c("Pass" = "#2CA02C", "Fail" = "#D62728")) +
  labs(
    title    = "School Absences vs Final Grade",
    subtitle = "Linear regression line with 95% confidence interval",
    x        = "Number of Absences",
    y        = "Final Grade (G3)",
    color    = "Pass/Fail"
  )

save_plot(p06, "06_absences_vs_final_grade.png")


# ===========================================================
# PLOT 07 – PARENTAL EDUCATION vs FINAL GRADE
# ===========================================================

cat("Creating Plot 07: Mother's Education vs Final Grade...\n")

edu_labels <- c("0 – None", "1 – Primary (4th)", "2 – 5th-9th Grade",
                "3 – Secondary", "4 – Higher Education")

edu_summary <- df %>%
  group_by(MotherEducation) %>%
  summarise(Mean_G3 = round(mean(FinalGrade), 2),
            Count   = n(), .groups = "drop")

p07 <- ggplot(edu_summary, aes(x = MotherEducation, y = Mean_G3, fill = MotherEducation)) +
  geom_col(alpha = 0.85, width = 0.65, show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.1f\n(n=%d)", Mean_G3, Count)),
            vjust = -0.4, size = 3.5, fontface = "bold") +
  scale_fill_brewer(palette = "YlOrRd") +
  scale_y_continuous(limits = c(0, 14), expand = expansion(mult = c(0, 0.15))) +
  labs(
    title    = "Mother's Education Level vs Mean Final Grade",
    subtitle = "Higher parental education tends to correlate with better grades",
    x        = "Mother's Education Level",
    y        = "Mean Final Grade (G3)"
  ) +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))

save_plot(p07, "07_mother_education_vs_grade.png")


# ===========================================================
# PLOT 08 – INTERNET ACCESS vs FINAL GRADE
# ===========================================================

cat("Creating Plot 08: Internet Access vs Final Grade...\n")

p08 <- ggplot(df, aes(x = Internet, y = FinalGrade, fill = Internet)) +
  geom_boxplot(alpha = 0.75, outlier.color = "red", outlier.size = 1.5) +
  stat_summary(fun = mean, geom = "point", shape = 23,
               size = 4, fill = "gold", color = "black") +
  scale_fill_manual(values = c("no" = "#FF7F7F", "yes" = "#90EE90")) +
  labs(
    title    = "Internet Access at Home vs Final Grade",
    subtitle = "Does internet access improve academic performance?",
    x        = "Internet Access at Home",
    y        = "Final Grade (G3)",
    fill     = "Internet Access"
  )

save_plot(p08, "08_internet_vs_grade.png")


# ===========================================================
# PLOT 09 – GRADE IMPROVEMENT (G1 → G3) by SEX
# ===========================================================

cat("Creating Plot 09: Grade Improvement by Gender...\n")

p09 <- ggplot(df, aes(x = GradeImprovement, fill = Sex)) +
  geom_histogram(binwidth = 1, position = "dodge", alpha = 0.8, color = "white") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", linewidth = 0.8) +
  annotate("text", x = -0.5, y = Inf, label = "Declined",
           vjust = 2, hjust = 1.1, color = "red", fontface = "bold") +
  annotate("text", x = 0.5, y = Inf, label = "Improved",
           vjust = 2, hjust = -0.1, color = "darkgreen", fontface = "bold") +
  scale_fill_manual(values = c("Female" = "#F28B82", "Male" = "#82B4F5")) +
  labs(
    title    = "Grade Improvement from Period 1 to Final Grade",
    subtitle = "Positive = improved | Negative = declined",
    x        = "Grade Change (G3 – G1)",
    y        = "Number of Students",
    fill     = "Gender"
  )

save_plot(p09, "09_grade_improvement_by_gender.png")


# ===========================================================
# PLOT 10 – PASS/FAIL PIE CHART + DONUT
# ===========================================================

cat("Creating Plot 10: Pass/Fail Distribution (Pie/Donut)...\n")

pf_data <- df %>%
  count(PassFail) %>%
  mutate(
    Pct   = round(n / sum(n) * 100, 1),
    Label = paste0(PassFail, "\n", n, " (", Pct, "%)")
  )

p10 <- ggplot(pf_data, aes(x = 2, y = n, fill = PassFail)) +
  geom_col(width = 1, color = "white", linewidth = 0.5) +
  coord_polar(theta = "y", start = 0) +
  xlim(0.5, 2.5) +  # Donut hole
  geom_text(aes(label = Label), position = position_stack(vjust = 0.5),
            size = 5, fontface = "bold", color = "white") +
  scale_fill_manual(values = c("Pass" = "#2CA02C", "Fail" = "#D62728")) +
  labs(
    title    = "Overall Pass vs Fail Rate",
    subtitle = "Based on Final Grade (G3 ≥ 10 = Pass)",
    fill     = ""
  ) +
  theme_void(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 15, hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
    legend.position = "bottom"
  )

save_plot(p10, "10_pass_fail_donut.png", w = 7, h = 7)


# ===========================================================
# PLOT 11 – ALCOHOL CONSUMPTION vs FINAL GRADE
# ===========================================================

cat("Creating Plot 11: Alcohol Consumption vs Final Grade...\n")

alc_data <- df %>%
  mutate(
    Walc_num = as.numeric(WeekendAlcohol),
    Dalc_num = as.numeric(WeekdayAlcohol)
  ) %>%
  group_by(Walc_num) %>%
  summarise(Mean_G3 = round(mean(FinalGrade), 2),
            Count   = n(), .groups = "drop") %>%
  rename(AlcLevel = Walc_num)

p11 <- ggplot(df %>% mutate(Walc_num = as.numeric(WeekendAlcohol)),
              aes(x = factor(Walc_num), y = FinalGrade, fill = factor(Walc_num))) +
  geom_boxplot(alpha = 0.75, outlier.color = "red", outlier.size = 1.5) +
  stat_summary(fun = mean, geom = "point", shape = 23,
               size = 4, fill = "gold", color = "black") +
  scale_fill_brewer(palette = "RdYlGn", direction = -1) +
  labs(
    title    = "Weekend Alcohol Consumption vs Final Grade",
    subtitle = "1 = Very Low, 5 = Very High | Diamond = Mean",
    x        = "Weekend Alcohol Consumption Level",
    y        = "Final Grade (G3)",
    fill     = "Alcohol Level"
  )

save_plot(p11, "11_alcohol_vs_grade.png")


# ===========================================================
# PLOT 12 – SCHOOL SUPPORT vs GRADE (Grouped Bar)
# ===========================================================

cat("Creating Plot 12: School Support vs Grade...\n")

support_data <- df %>%
  group_by(SchoolSupport, PassFail) %>%
  summarise(Count = n(), .groups = "drop") %>%
  group_by(SchoolSupport) %>%
  mutate(Pct = round(Count / sum(Count) * 100, 1))

p12 <- ggplot(support_data,
              aes(x = SchoolSupport, y = Count, fill = PassFail)) +
  geom_col(position = "dodge", alpha = 0.85, width = 0.6) +
  geom_text(aes(label = paste0(Pct, "%")),
            position = position_dodge(width = 0.6), vjust = -0.4, size = 3.5) +
  scale_fill_manual(values = c("Pass" = "#2CA02C", "Fail" = "#D62728")) +
  labs(
    title    = "Effect of Extra School Support on Pass/Fail Outcome",
    subtitle = "Does receiving school support influence academic success?",
    x        = "Extra School Support",
    y        = "Number of Students",
    fill     = "Outcome"
  )

save_plot(p12, "12_school_support_vs_passfail.png")

cat("\n==========================================================\n")
cat("   ALL 12 VISUALIZATIONS CREATED AND SAVED SUCCESSFULLY!\n")
cat("==========================================================\n")
