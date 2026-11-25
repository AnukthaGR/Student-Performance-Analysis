# ============================================================
# SCRIPT 07: Segmentation & Groupwise Insights
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Libraries: dplyr, ggplot2, tidyr
# ============================================================

library(dplyr)
library(ggplot2)
library(tidyr)

# ---- Load preprocessed data ----
df <- readRDS("../output/student_preprocessed.rds")

plot_dir <- "../plots"

cat("==========================================================\n")
cat("        SEGMENTATION & GROUPWISE INSIGHTS\n")
cat("==========================================================\n\n")


# ============================================================
# ANALYSIS 1 : SCHOOL-WISE PERFORMANCE
# ============================================================

cat("--- 1. School-wise Performance ---\n")

school_summary <- df %>%
  group_by(School) %>%
  summarise(
    Students  = n(),
    Mean_G3   = round(mean(FinalGrade), 2),
    Median_G3 = round(median(FinalGrade), 2),
    SD_G3     = round(sd(FinalGrade), 2),
    Pass_Rate = round(mean(PassFail == "Pass") * 100, 1),
    Fail_Rate = round(mean(PassFail == "Fail") * 100, 1),
    .groups   = "drop"
  )
print(school_summary)


# ============================================================
# ANALYSIS 2 : GENDER × STUDYTIME CROSS-TABLE
# ============================================================

cat("\n--- 2. Gender × Study Time → Mean Final Grade ---\n")

gender_study <- df %>%
  mutate(StudyTime_Lbl = recode(as.character(StudyTime),
    "1" = "<2 hrs", "2" = "2-5 hrs", "3" = "5-10 hrs", "4" = ">10 hrs")) %>%
  group_by(Sex, StudyTime_Lbl) %>%
  summarise(Mean_G3 = round(mean(FinalGrade), 2),
            Count   = n(), .groups = "drop") %>%
  arrange(Sex, StudyTime_Lbl)
print(gender_study)


# ============================================================
# ANALYSIS 3 : GUARDIAN TYPE vs PERFORMANCE
# ============================================================

cat("\n--- 3. Guardian Type vs Academic Performance ---\n")

guardian_summary <- df %>%
  group_by(Guardian) %>%
  summarise(
    Count    = n(),
    Mean_G3  = round(mean(FinalGrade), 2),
    SD_G3    = round(sd(FinalGrade), 2),
    Pass_Pct = round(mean(PassFail == "Pass") * 100, 1),
    .groups  = "drop"
  ) %>%
  arrange(desc(Mean_G3))
print(guardian_summary)


# ============================================================
# ANALYSIS 4 : URBAN vs RURAL PERFORMANCE
# ============================================================

cat("\n--- 4. Urban vs Rural Student Performance ---\n")

address_summary <- df %>%
  group_by(Address) %>%
  summarise(
    Count        = n(),
    Mean_G3      = round(mean(FinalGrade), 2),
    Pass_Rate    = round(mean(PassFail == "Pass") * 100, 1),
    Mean_Absences = round(mean(Absences), 2),
    Mean_StudyTime = round(mean(as.numeric(StudyTime)), 2),
    .groups      = "drop"
  )
print(address_summary)


# ============================================================
# ANALYSIS 5 : PERFORMANCE BY PARENTAL JOB
# ============================================================

cat("\n--- 5. Mother's Job vs Mean Final Grade ---\n")

mjob_summary <- df %>%
  group_by(MotherJob) %>%
  summarise(
    Count   = n(),
    Mean_G3 = round(mean(FinalGrade), 2),
    SD      = round(sd(FinalGrade), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(Mean_G3))
print(mjob_summary)


# ============================================================
# PLOT 19 – HEATMAP: STUDY TIME × GENDER × MEAN GRADE
# ============================================================

cat("\nGenerating Heatmap: Study Time × Gender × Mean Grade...\n")

heat_data <- df %>%
  mutate(
    StudyTime_Lbl = recode(as.character(StudyTime),
      "1" = "<2 hrs", "2" = "2-5 hrs", "3" = "5-10 hrs", "4" = ">10 hrs"),
    StudyTime_Lbl = factor(StudyTime_Lbl,
      levels = c("<2 hrs", "2-5 hrs", "5-10 hrs", ">10 hrs"))
  ) %>%
  group_by(Sex, StudyTime_Lbl) %>%
  summarise(Mean_G3 = round(mean(FinalGrade), 2), .groups = "drop")

p19 <- ggplot(heat_data, aes(x = StudyTime_Lbl, y = Sex, fill = Mean_G3)) +
  geom_tile(color = "white", linewidth = 0.8) +
  geom_text(aes(label = Mean_G3), size = 5, fontface = "bold", color = "white") +
  scale_fill_gradient2(
    low      = "#D73027",
    mid      = "#FEE08B",
    high     = "#1A9850",
    midpoint = 10,
    name     = "Mean Grade"
  ) +
  labs(
    title    = "Mean Final Grade by Gender and Study Time",
    subtitle = "Heatmap: darker green = higher performance",
    x        = "Weekly Study Time Category",
    y        = "Gender"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40"),
    legend.position = "right"
  )

ggsave(file.path(plot_dir, "19_heatmap_studytime_gender_grade.png"),
       plot = p19, width = 9, height = 5, dpi = 150, bg = "white")
cat("  ✔ Saved: plots/19_heatmap_studytime_gender_grade.png\n")


# ============================================================
# PLOT 20 – FACETED SCATTER: STUDY TIME × ABSENCES → GRADE
# ============================================================

cat("Generating Faceted Scatter Plot...\n")

facet_data <- df %>%
  mutate(StudyTime_Lbl = recode(as.character(StudyTime),
    "1" = "1: <2 hrs", "2" = "2: 2-5 hrs",
    "3" = "3: 5-10 hrs", "4" = "4: >10 hrs"))

p20 <- ggplot(facet_data, aes(x = Absences, y = FinalGrade, color = PassFail)) +
  geom_point(alpha = 0.5, size = 1.8) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed",
              color = "navy", linewidth = 0.8) +
  facet_wrap(~ StudyTime_Lbl, nrow = 2) +
  scale_color_manual(values = c("Pass" = "#2CA02C", "Fail" = "#D62728")) +
  labs(
    title    = "Absences vs Final Grade — Faceted by Study Time",
    subtitle = "Each panel represents a weekly study time group",
    x        = "Number of Absences",
    y        = "Final Grade (G3)",
    color    = "Outcome"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40"),
    strip.text    = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave(file.path(plot_dir, "20_faceted_absences_vs_grade.png"),
       plot = p20, width = 10, height = 7, dpi = 150, bg = "white")
cat("  ✔ Saved: plots/20_faceted_absences_vs_grade.png\n")


# ============================================================
# PLOT 21 – GROUPED BAR: MOTHER'S JOB vs MEAN GRADE
# ============================================================

cat("Generating Mother's Job vs Grade bar chart...\n")

p21 <- ggplot(mjob_summary, aes(x = reorder(MotherJob, Mean_G3),
                                y = Mean_G3, fill = Mean_G3)) +
  geom_col(alpha = 0.85, show.legend = FALSE) +
  geom_errorbar(aes(ymin = Mean_G3 - SD, ymax = Mean_G3 + SD),
                width = 0.3, linewidth = 0.7, color = "gray40") +
  geom_text(aes(label = sprintf("%.1f\n(n=%d)", Mean_G3, Count)),
            hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_fill_gradient(low = "#F7FBFF", high = "#08306B") +
  scale_y_continuous(limits = c(0, 15)) +
  labs(
    title    = "Mother's Occupation vs Mean Final Grade",
    subtitle = "Error bars show ± 1 SD",
    x        = "Mother's Job Category",
    y        = "Mean Final Grade (G3)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40")
  )

ggsave(file.path(plot_dir, "21_mothers_job_vs_grade.png"),
       plot = p21, width = 9, height = 6, dpi = 150, bg = "white")
cat("  ✔ Saved: plots/21_mothers_job_vs_grade.png\n")

cat("\n✔ Segmentation & Groupwise Analysis Complete!\n")
