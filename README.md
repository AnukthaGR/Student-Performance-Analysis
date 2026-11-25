# 📊 Student Performance Data Analysis
> **BTech CSE – 3rd Year Mini Project &nbsp;|&nbsp; Primary Language: R Programming**
> **Dataset:** UCI Machine Learning Repository – Student Performance (Cortez & Silva, 2008)

---

## 📈 Visualizations

### 1. Final Grade Distribution
![Final Grade Distribution](R_Analysis/plots/01_final_grade_distribution.png)

---

### 2. Grade Period Comparison (G1 → G2 → G3)
![Grade Period Comparison](R_Analysis/plots/02_grade_period_comparison.png)

---

### 3. Gender vs Final Grade
![Gender vs Final Grade](R_Analysis/plots/03_gender_vs_final_grade.png)

---

### 4. Study Time vs Final Grade
![Study Time vs Final Grade](R_Analysis/plots/04_studytime_vs_final_grade.png)

---

### 5. Past Failures vs Final Grade
![Past Failures vs Final Grade](R_Analysis/plots/05_past_failures_vs_grade.png)

---

### 6. Absences vs Final Grade
![Absences vs Final Grade](R_Analysis/plots/06_absences_vs_final_grade.png)

---

### 7. Mother's Education vs Final Grade
![Mother Education vs Grade](R_Analysis/plots/07_mother_education_vs_grade.png)

---

### 8. Internet Access vs Final Grade
![Internet vs Grade](R_Analysis/plots/08_internet_vs_grade.png)

---

### 9. Grade Improvement by Gender (G1 → G3)
![Grade Improvement](R_Analysis/plots/09_grade_improvement_by_gender.png)

---

### 10. Pass / Fail Distribution
![Pass Fail Donut](R_Analysis/plots/10_pass_fail_donut.png)

---

### 11. Alcohol Consumption vs Final Grade
![Alcohol vs Grade](R_Analysis/plots/11_alcohol_vs_grade.png)

---

### 12. School Support vs Pass/Fail
![School Support](R_Analysis/plots/12_school_support_vs_passfail.png)

---

### 13. Full Correlation Heatmap
![Correlation Heatmap Full](R_Analysis/plots/13_correlation_heatmap_full.png)

---

### 14. Grade-Focused Correlation Heatmap
![Correlation Grade Focused](R_Analysis/plots/14_correlation_grade_focused.png)

---

### 15. Correlation Bar Chart (All Variables vs G3)
![Correlation Barplot](R_Analysis/plots/15_correlation_barplot.png)

---

### 16. Regression Diagnostics (4-Panel)
![Regression Diagnostics](R_Analysis/plots/16_regression_diagnostics.png)

---

### 17. Actual vs Predicted Final Grade
![Actual vs Predicted](R_Analysis/plots/17_actual_vs_predicted.png)

---

### 18. Regression Coefficients
![Regression Coefficients](R_Analysis/plots/18_regression_coefficients.png)

---

### 19. Study Time × Gender Heatmap
![Heatmap Study Gender](R_Analysis/plots/19_heatmap_studytime_gender_grade.png)

---

### 20. Absences vs Grade — Faceted by Study Time
![Faceted Scatter](R_Analysis/plots/20_faceted_absences_vs_grade.png)

---

### 21. Mother's Job vs Final Grade
![Mothers Job](R_Analysis/plots/21_mothers_job_vs_grade.png)

---

### 22. ROC Curve — Logistic Regression
![ROC Curve](R_Analysis/plots/22_roc_curve_logistic.png)

---

### 23. KNN — K Value vs Accuracy
![KNN Accuracy](R_Analysis/plots/23_knn_k_vs_accuracy.png)

---

## 📌 Dataset

| Field | Detail |
|-------|--------|
| **Source** | [UCI ML Repository – Student Performance](https://archive.ics.uci.edu/dataset/320/student+performance) |
| **Authors** | Paulo Cortez & Alice Silva (University of Minho, 2008) |
| **Subject** | Mathematics (`student-mat.csv`) |
| **Size** | 395 students × 33 attributes |
| **Missing Values** | None (complete dataset) |

---

## 🗂️ Project Structure

```
Student-Performance-Analysis/
├── dataset/
│   ├── student-mat.csv              ← Main dataset (Math)
│   ├── student-por.csv              ← Portuguese dataset
│   └── student.txt                  ← Column descriptions
│
└── R_Analysis/
    ├── scripts/
    │   ├── 00_install_packages.R        ← Install all R libraries
    │   ├── 01_data_loading_exploration.R← readr + summarytools EDA
    │   ├── 02_data_cleaning.R           ← dplyr + tidyr preprocessing
    │   ├── 03_visualizations.R          ← 12 ggplot2 charts
    │   ├── 04_correlation_analysis.R    ← corrplot heatmaps
    │   ├── 05_statistical_tests.R       ← t-test, ANOVA, Chi-square
    │   ├── 06_regression_analysis.R     ← Simple, Multiple, Stepwise lm()
    │   ├── 07_segmentation_insights.R   ← Group-wise analysis
    │   ├── 08_predictive_modeling.R     ← Logistic Regression + KNN
    │   └── 09_master_run.R              ← Runs all scripts in sequence
    ├── plots/                           ← 23 generated visualizations ⬆️
    └── output/                          ← CSV results & processed data
```

---

## 📦 R Libraries Used

| Library | Purpose |
|---------|---------|
| `readr` | Fast CSV import |
| `dplyr` | Data manipulation |
| `tidyr` | Data reshaping & cleaning |
| `ggplot2` | All visualizations |
| `tidyverse` | Meta-package |
| `summarytools` | Descriptive statistics |
| `corrplot` | Correlation heatmaps |

---

## 🚀 How to Run

```r
# In R / RStudio:
setwd("path/to/R_Analysis/scripts")
source("09_master_run.R")
```

---

## 📈 Key Results

| Metric | Value |
|--------|-------|
| Dataset Size | 395 students, 33 columns |
| Missing Values | **0** |
| Mean Final Grade | **10.42 / 20** |
| Pass Rate | **67.1%** (265 students) |
| Fail Rate | **32.9%** (130 students) |
| Logistic Regression Accuracy | **89.9%** |
| AUC-ROC | **0.972** |
| Strongest Positive Predictor | Grade P1 & P2 |
| Strongest Negative Predictor | Past Failures |

---

## 🔬 Hypothesis Test Results

| Test | p-value | Decision |
|------|---------|---------|
| t-Test: Gender vs Grade | 0.039 | ✅ **Reject H0** – Significant gender difference |
| ANOVA: Study Time vs Grade | 0.161 | ❌ Fail to Reject H0 |
| Chi-Square: Internet vs Pass/Fail | 0.278 | ❌ Fail to Reject H0 |
| Shapiro-Wilk: Normality | ~0.000 | ✅ **Reject H0** – Grades not normal |

---

## 👩‍💻 Author

**Anuktha G R** – BTech Computer Science Engineering, 3rd Year
Mini Project | Data Analytics using R Programming
