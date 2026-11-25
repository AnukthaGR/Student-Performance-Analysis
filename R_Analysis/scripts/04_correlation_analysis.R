# ============================================================
# SCRIPT 04: Correlation Analysis
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Libraries: corrplot, dplyr, ggplot2
# ============================================================

library(dplyr)
library(ggplot2)
library(corrplot)

# ---- Load preprocessed data ----
df <- readRDS("../output/student_preprocessed.rds")

plot_dir <- "../plots"

cat("==========================================================\n")
cat("               CORRELATION ANALYSIS\n")
cat("==========================================================\n\n")

# ============================================================
# STEP 1 : BUILD NUMERIC CORRELATION MATRIX
# ============================================================

numeric_df <- df %>%
  mutate(
    Sex_num         = ifelse(Sex == "Male", 1, 0),
    Address_num     = ifelse(Address == "Urban", 1, 0),
    Internet_num    = ifelse(Internet == "yes", 1, 0),
    Romantic_num    = ifelse(Romantic == "yes", 1, 0),
    SchoolSup_num   = ifelse(SchoolSupport == "yes", 1, 0),
    WantsHigher_num = ifelse(WantsHigherEdu == "yes", 1, 0),
    TravelTime_num  = as.numeric(TravelTime),
    StudyTime_num   = as.numeric(StudyTime),
    FamRel_num      = as.numeric(FamilyRelation),
    FreeTime_num    = as.numeric(FreeTime),
    GoOut_num       = as.numeric(GoOut),
    Dalc_num        = as.numeric(WeekdayAlcohol),
    Walc_num        = as.numeric(WeekendAlcohol),
    Health_num      = as.numeric(Health),
    MeduNum         = as.numeric(MotherEducation),
    FeduNum         = as.numeric(FatherEducation)
  ) %>%
  select(
    Age, MeduNum, FeduNum,
    TravelTime_num, StudyTime_num, PastFailures,
    SchoolSup_num, WantsHigher_num,
    FamRel_num, FreeTime_num, GoOut_num,
    Dalc_num, Walc_num, Health_num, Absences,
    Sex_num, Address_num, Internet_num, Romantic_num,
    Grade_Period1, Grade_Period2, FinalGrade
  )

# Rename for display
colnames(numeric_df) <- c(
  "Age", "Mother Edu", "Father Edu",
  "Travel Time", "Study Time", "Past Failures",
  "School Support", "Wants Higher Edu",
  "Fam. Relation", "Free Time", "Go Out",
  "Weekday Alc.", "Weekend Alc.", "Health", "Absences",
  "Sex (Male=1)", "Urban (1)", "Internet", "Romantic",
  "Grade P1", "Grade P2", "Final Grade"
)

cor_matrix <- cor(numeric_df, use = "complete.obs", method = "pearson")

cat("Pearson Correlation Matrix computed for", ncol(numeric_df), "variables.\n\n")

# Top correlations with FinalGrade
cat("--- Top Correlations with FINAL GRADE ---\n")
final_cor <- cor_matrix["Final Grade", ] %>%
  sort(decreasing = TRUE) %>%
  round(3)
print(final_cor)


# ============================================================
# STEP 2 : CORRPLOT – FULL CORRELATION HEATMAP
# ============================================================

cat("\nGenerating full correlation heatmap...\n")

png(file.path(plot_dir, "13_correlation_heatmap_full.png"),
    width = 1400, height = 1400, res = 130, bg = "white")

corrplot(
  cor_matrix,
  method      = "color",
  type        = "upper",
  order       = "hclust",
  tl.cex      = 0.72,
  tl.col      = "black",
  tl.srt      = 45,
  addCoef.col = "black",
  number.cex  = 0.52,
  col         = colorRampPalette(c("#D73027", "#FDAE61", "#FFFFFF", "#74ADD1", "#313695"))(200),
  cl.cex      = 0.8,
  title       = "Pearson Correlation Matrix – Student Performance Variables",
  mar         = c(0, 0, 2, 0)
)

dev.off()
cat("  ✔ Saved: plots/13_correlation_heatmap_full.png\n")


# ============================================================
# STEP 3 : FOCUSED CORRELATION – GRADE VARIABLES ONLY
# ============================================================

cat("Generating focused grade correlation plot...\n")

grade_vars <- c("Study Time", "Past Failures", "Absences",
                "Mother Edu", "Father Edu", "Weekday Alc.", "Weekend Alc.",
                "Wants Higher Edu", "Internet", "School Support",
                "Go Out", "Health", "Grade P1", "Grade P2", "Final Grade")

cor_grades <- cor_matrix[grade_vars, grade_vars]

png(file.path(plot_dir, "14_correlation_grade_focused.png"),
    width = 1100, height = 1100, res = 130, bg = "white")

corrplot(
  cor_grades,
  method      = "circle",
  type        = "upper",
  order       = "hclust",
  tl.cex      = 0.85,
  tl.col      = "black",
  tl.srt      = 45,
  addCoef.col = "black",
  number.cex  = 0.70,
  col         = colorRampPalette(c("#B2182B", "#F7F7F7", "#2166AC"))(200),
  title       = "Correlation: Grade-Related Variables",
  mar         = c(0, 0, 2, 0)
)

dev.off()
cat("  ✔ Saved: plots/14_correlation_grade_focused.png\n")


# ============================================================
# STEP 4 : ggplot2 CORRELATION TILE CHART (Top 10 vs FinalGrade)
# ============================================================

cat("Generating ggplot2 correlation bar chart...\n")

final_cor_df <- data.frame(
  Variable    = names(final_cor),
  Correlation = as.numeric(final_cor)
) %>%
  filter(Variable != "Final Grade") %>%
  arrange(Correlation) %>%
  mutate(
    Variable    = factor(Variable, levels = Variable),
    Direction   = ifelse(Correlation >= 0, "Positive", "Negative")
  )

p_corr <- ggplot(final_cor_df, aes(x = Variable, y = Correlation, fill = Direction)) +
  geom_col(alpha = 0.85, width = 0.7) +
  geom_hline(yintercept = 0, linewidth = 0.6, color = "black") +
  geom_text(aes(label = round(Correlation, 2),
                hjust = ifelse(Correlation >= 0, -0.1, 1.1)),
            size = 3.2, fontface = "bold") +
  coord_flip() +
  scale_fill_manual(values = c("Positive" = "#2166AC", "Negative" = "#B2182B")) +
  scale_y_continuous(limits = c(-0.65, 1.05)) +
  labs(
    title    = "Pearson Correlation of All Variables with Final Grade",
    subtitle = "Blue = positively correlated | Red = negatively correlated",
    x        = NULL,
    y        = "Correlation Coefficient (r)",
    fill     = "Direction"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40"),
    legend.position = "bottom"
  )

ggsave(file.path(plot_dir, "15_correlation_barplot.png"),
       plot = p_corr, width = 10, height = 8, dpi = 150, bg = "white")
cat("  ✔ Saved: plots/15_correlation_barplot.png\n")


# ============================================================
# STEP 5 : KEY INSIGHTS FROM CORRELATION
# ============================================================

cat("\n==========================================================\n")
cat("              KEY CORRELATION INSIGHTS\n")
cat("==========================================================\n")

top_pos <- final_cor_df %>% filter(Direction == "Positive") %>% tail(5)
top_neg <- final_cor_df %>% filter(Direction == "Negative") %>% head(5)

cat("\nTop 5 POSITIVE correlators with Final Grade:\n")
print(top_pos %>% select(Variable, Correlation))

cat("\nTop 5 NEGATIVE correlators with Final Grade:\n")
print(top_neg %>% select(Variable, Correlation))

cat("\nInterpretation:\n")
cat("  ✔ Grade P1 & Grade P2 are the strongest predictors of Final Grade.\n")
cat("  ✔ Study Time has a moderate positive effect on grades.\n")
cat("  ✔ Past Failures is the strongest negative predictor.\n")
cat("  ✔ Alcohol consumption (Dalc/Walc) negatively impacts grades.\n")
cat("  ✔ Wanting higher education correlates positively with performance.\n")

cat("\n✔ Correlation Analysis Complete!\n")
