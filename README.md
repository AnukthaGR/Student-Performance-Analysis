# 📊 Student Performance Data Analysis

> **BTech CSE – 3rd Year Mini Project**  
> **Primary Language: R Programming** | Dataset: UCI Machine Learning Repository

---

## 📌 Dataset

| Field | Detail |
|-------|--------|
| **Source** | [UCI ML Repository – Student Performance](https://archive.ics.uci.edu/dataset/320/student+performance) |
| **Authors** | Paulo Cortez & Alice Silva (University of Minho, 2008) |
| **Subject** | Mathematics (`student-mat.csv`) |
| **Size** | 395 students × 33 attributes |

---

## 🗂️ Project Structure

```
Student-Performance-Analysis/
├── dataset/
│   ├── student-mat.csv       ← Main dataset (Math, semicolon-delimited)
│   ├── student-por.csv       ← Portuguese dataset
│   └── student.txt           ← Official column descriptions
│
├── R_Analysis/
│   ├── scripts/
│   │   ├── 00_install_packages.R        ← Install all R libraries
│   │   ├── 01_data_loading_exploration.R← readr + summarytools EDA
│   │   ├── 02_data_cleaning.R           ← dplyr + tidyr preprocessing
│   │   ├── 03_visualizations.R          ← 12 ggplot2 charts
│   │   ├── 04_correlation_analysis.R    ← corrplot heatmaps
│   │   ├── 05_statistical_tests.R       ← t-test, ANOVA, Chi-square
│   │   ├── 06_regression_analysis.R     ← Simple, Multiple, Stepwise lm()
│   │   ├── 07_segmentation_insights.R   ← Group-wise analysis
│   │   ├── 08_predictive_modeling.R     ← Logistic Regression + KNN
│   │   └── 09_master_run.R              ← Runs all scripts in sequence
│   ├── plots/                           ← 23 generated visualizations
│   └── output/                          ← CSV results & processed data
│
└── generate_outputs.py                  ← Generates plots & CSVs (no R install needed)
```

---

## 🚀 How to Run

### Option 1 — R (Primary Method)
```r
# In RStudio or R console:
setwd("path/to/R_Analysis/scripts")
source("09_master_run.R")
```

### Option 2 — Python (if R not installed)
```bash
pip install pandas numpy matplotlib seaborn scipy scikit-learn
python generate_outputs.py
```

---

## 📦 R Libraries Used

| Library | Purpose |
|---------|---------|
| `readr` | Fast CSV import |
| `dplyr` | Data manipulation |
| `tidyr` | Data reshaping & cleaning |
| `ggplot2` | Visualizations |
| `tidyverse` | Meta-package |
| `summarytools` | Descriptive statistics |
| `corrplot` | Correlation heatmaps |

---

## 📊 Analysis Performed

1. **Data Loading & Exploration** – `readr`, `summarytools::descr`, frequency tables
2. **Data Cleaning** – deduplication, type conversion, outlier detection (IQR), feature engineering
3. **Visualizations** – 23 `ggplot2` plots (histograms, violin, scatter, heatmaps, donuts)
4. **Correlation Analysis** – Pearson matrix, `corrplot` heatmaps, bar chart
5. **Hypothesis Testing** – t-test, ANOVA + Tukey HSD, Chi-square, Shapiro-Wilk
6. **Linear Regression** – Simple, Multiple (14 vars), Stepwise (AIC)
7. **Segmentation** – By school, gender, guardian, urban/rural, mother's job
8. **Predictive Modeling** – Logistic Regression (AUC=0.972) + KNN classifier

---

## 📈 Key Results

| Metric | Value |
|--------|-------|
| Dataset size | 395 students, 33 columns |
| Missing values | **0** (complete dataset) |
| Mean Final Grade | **10.42 / 20** |
| Pass Rate | **67.1%** |
| Logistic Regression Accuracy | **89.9%** |
| AUC-ROC | **0.972** |
| Strongest predictor (positive) | Grade Period 1 & 2 |
| Strongest predictor (negative) | Past Failures |

---

## 🔬 Hypothesis Test Results

| Test | Decision |
|------|---------|
| t-Test: Gender vs Grade | **Reject H0** – Significant gender difference (p=0.039) |
| ANOVA: Study Time vs Grade | Fail to Reject H0 (p=0.16) |
| Chi-Square: Internet vs Pass/Fail | Fail to Reject H0 (p=0.28) |
| Shapiro-Wilk: Normality | **Reject H0** – Grades not normally distributed |

---

## 👩‍💻 Author

**Anuktha G R** – BTech Computer Science Engineering, 3rd Year  
Mini Project | Data Analytics using R Programming
