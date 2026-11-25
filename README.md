# Student Performance Data Analysis

> **Data Analytics Mini Project | 3rd Year BTech Computer Science**

---

## 📌 Project Title
**Exploratory Data Analysis of Student Performance in Secondary School**

---

## 📖 Introduction
Academic performance is one of the most important indicators of a student's future success. Understanding what factors influence student grades helps educators, parents, and policymakers make better decisions. This project uses real-world student data collected from two Portuguese secondary schools and performs a thorough Exploratory Data Analysis (EDA) to uncover patterns and insights.

---

## 🎯 Problem Statement
Can we identify key factors — such as study time, parental education, school attendance, and access to resources — that significantly affect a student's academic performance in Mathematics?

---

## 🏆 Objectives
1. Load and explore a real student performance dataset.
2. Clean and preprocess the data to ensure accuracy.
3. Calculate key statistical measures (mean, median, standard deviation).
4. Identify patterns and relationships between student background and academic grades.
5. Create meaningful visualizations to communicate findings clearly.
6. Draw actionable conclusions from the data.

---

## 📂 Dataset Description and Source

| Detail | Information |
|---|---|
| **Dataset Name** | Student Performance Data Set |
| **Source** | UCI Machine Learning Repository |
| **URL** | https://archive.ics.uci.edu/dataset/320/student+performance |
| **Subject** | Mathematics (student-mat.csv) |
| **Records** | 395 students |
| **Features** | 33 columns |
| **File Used** | `dataset/student_data.csv` |

### Column Descriptions

| Column | Description |
|---|---|
| `school` | Student's school (GP – Gabriel Pereira, MS – Mousinho da Silveira) |
| `sex` | Student's gender (F – Female, M – Male) |
| `age` | Student's age (15 to 22) |
| `address` | Home address type (U – Urban, R – Rural) |
| `famsize` | Family size (LE3 – ≤3, GT3 – >3) |
| `Pstatus` | Parent's cohabitation status (T – Together, A – Apart) |
| `Medu` | Mother's education level (0=None, 1=4th grade, 2=5th–9th, 3=Secondary, 4=Higher) |
| `Fedu` | Father's education level (same scale as Medu) |
| `Mjob` | Mother's job |
| `Fjob` | Father's job |
| `reason` | Reason to choose this school |
| `guardian` | Student's guardian (mother/father/other) |
| `traveltime` | Home-to-school travel time (1=<15 min to 4=>1 hr) |
| `studytime` | Weekly study time (1=<2 hrs to 4=>10 hrs) |
| `failures` | Number of past class failures |
| `schoolsup` | Extra educational support from school (yes/no) |
| `famsup` | Family educational support (yes/no) |
| `paid` | Extra paid classes in subject (yes/no) |
| `activities` | Extra-curricular activities (yes/no) |
| `nursery` | Attended nursery school (yes/no) |
| `higher` | Wants higher education (yes/no) |
| `internet` | Internet access at home (yes/no) |
| `romantic` | In a romantic relationship (yes/no) |
| `famrel` | Quality of family relationships (1=very bad to 5=excellent) |
| `freetime` | Free time after school (1=very low to 5=very high) |
| `goout` | Going out with friends (1=very low to 5=very high) |
| `Dalc` | Workday alcohol consumption (1=very low to 5=very high) |
| `Walc` | Weekend alcohol consumption (1=very low to 5=very high) |
| `health` | Current health status (1=very bad to 5=very good) |
| `absences` | Number of school absences (0 to 93) |
| `G1` | First period grade (0 to 20) |
| `G2` | Second period grade (0 to 20) |
| `G3` | Final grade / target variable (0 to 20) |

---

## 🛠️ Technologies Used

| Tool / Library | Purpose |
|---|---|
| **Python 3.x** | Core programming language |
| **Pandas** | Data loading, cleaning, and manipulation |
| **NumPy** | Numerical computations and statistics |
| **Matplotlib** | Creating base plots and charts |
| **Seaborn** | Statistical and aesthetic visualizations |
| **Jupyter Notebook** | Interactive development environment |

---

## 🔬 Methodology

```
1. Data Collection   → Download dataset from UCI ML Repository
2. Data Loading      → Load CSV into Pandas DataFrame
3. Data Exploration  → Shape, dtypes, preview rows
4. Data Cleaning     → Handle missing values, duplicates
5. Feature Engineering → Create 'performance' and 'final_grade' columns
6. EDA               → Statistical analysis, group comparisons
7. Visualization     → 7 graphs covering different analysis angles
8. Insights          → Document findings from each visualization
9. Conclusion        → Summarize key factors affecting performance
```

---

## 📊 Data Analysis and Visualizations

| Graph | Title | Key Finding |
|---|---|---|
| Graph 1 | Grade Distribution | Most students score between 10–14; spike at 0 for dropouts |
| Graph 2 | Study Time vs Grade | More study hours = higher average grade |
| Graph 3 | Gender Performance | Minimal gender difference in grades |
| Graph 4 | Parental Education | Higher parental education → better student grades |
| Graph 5 | Absences vs Grade | More absences correlate with lower grades |
| Graph 6 | Grade Progression & Heatmap | G1 is a strong predictor of G3; failures hurt most |
| Graph 7 | Internet & School Support | Internet access helps; support targets struggling students |

All visualizations are saved in the `visualizations/` folder.

---

## 🔑 Key Findings

1. **Study Time Matters**: Students who study more than 10 hours per week score significantly higher.
2. **Early Performance Predicts Final Grade**: G1 and G2 have ~0.9 correlation with G3.
3. **Past Failures Are the Biggest Negative Factor**: Strongly negatively correlated with G3.
4. **Parental Education Helps**: Students from educated families perform better.
5. **Attendance Is Important**: Students with zero absences have the best average grades.
6. **Internet Access Is Beneficial**: Students with home internet access score slightly higher.
7. **Gender Has Minimal Impact**: Male and female students perform similarly on average.

---

## 📝 Conclusion
This analysis demonstrates that **student academic performance** is influenced by multiple interconnected factors beyond just intelligence or effort. Regular attendance, adequate study time, supportive family background, and access to resources like the internet all play important roles. Interestingly, early grades (G1, G2) are the best predictors of final performance, suggesting that early intervention for struggling students could significantly improve outcomes.

---

## ▶️ Instructions to Run the Project

### Prerequisites
Make sure you have Python installed. Then install the required libraries:

```bash
pip install -r requirements.txt
```

### Steps to Run

1. **Clone or download** the project folder.

2. **Open terminal** in the project root folder (`Student-Performance-Analysis/`).

3. **Launch Jupyter Notebook**:
   ```bash
   jupyter notebook
   ```

4. **Open the notebook**: In the browser, navigate to `notebooks/student_analysis.ipynb`.

5. **Run all cells**: Click **Kernel → Restart & Run All** to execute the entire notebook.

6. **View visualizations**: Graphs are displayed in the notebook and also saved in the `visualizations/` folder.

### Project Structure
```
Student-Performance-Analysis/
│
├── dataset/
│   └── student_data.csv         ← Real dataset from UCI ML Repository
│
├── notebooks/
│   └── student_analysis.ipynb   ← Main analysis notebook
│
├── visualizations/
│   ├── graph1_grade_distribution.png
│   ├── graph2_studytime_vs_grade.png
│   ├── graph3_gender_performance.png
│   ├── graph4_parental_education.png
│   ├── graph5_absences_vs_grade.png
│   ├── graph6_grade_progression_heatmap.png
│   └── graph7_internet_support.png
│
├── README.md                    ← This file
└── requirements.txt             ← Python dependencies
```

---

## 📚 References
- P. Cortez and A. Silva. *Using Data Mining to Predict Secondary School Student Performance.* In A. Brito and J. Teixeira Eds., Proceedings of 5th FUture BUsiness TEChnology Conference (FUBUTEC 2008), pp. 5-12, Porto, Portugal, April 2008.
- Dataset: https://archive.ics.uci.edu/dataset/320/student+performance

---

*Project completed as part of Data Analytics coursework — BTech CSE, 3rd Year*
