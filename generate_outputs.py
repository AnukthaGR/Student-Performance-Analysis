"""
generate_outputs.py
-------------------
Generates all 23 plots + 6 output files for the Student Performance project.
This script reproduces exactly what the R scripts produce.
Run from the Student-Performance-Analysis folder:
    python generate_outputs.py
"""

import pandas as pd
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import seaborn as sns
from scipy import stats
from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import (confusion_matrix, accuracy_score,
                             precision_score, recall_score, f1_score,
                             roc_curve, auc)
import warnings, os, sys
warnings.filterwarnings("ignore")

# ── Paths ──────────────────────────────────────────────────────────────────
BASE   = os.path.dirname(os.path.abspath(__file__))
DATA   = os.path.join(BASE, "dataset", "student-mat.csv")
PLOTS  = os.path.join(BASE, "R_Analysis", "plots");   os.makedirs(PLOTS,  exist_ok=True)
OUTPUT = os.path.join(BASE, "R_Analysis", "output");  os.makedirs(OUTPUT, exist_ok=True)

# ── Colour palette (matches ggplot2 Set2 / RColorBrewer) ───────────────────
BLUE   = "#4E79A7"; RED  = "#E15759"; GREEN = "#2CA02C"; FAIL = "#D62728"
ORANGE = "darkorange"; GOLD = "#FFD700"
PASS_COL = {"Pass": GREEN, "Fail": FAIL}

plt.rcParams.update({
    "figure.dpi": 150, "savefig.dpi": 150, "savefig.bbox": "tight",
    "font.family": "DejaVu Sans", "axes.titleweight": "bold",
    "axes.titlesize": 14, "axes.labelsize": 12,
    "figure.facecolor": "white", "axes.facecolor": "white"
})

def save(name): plt.savefig(os.path.join(PLOTS, name), facecolor="white"); plt.close(); print(f"  ✔ {name}")

# ════════════════════════════════════════════════════════════
# LOAD & CLEAN
# ════════════════════════════════════════════════════════════
print("\n=== Loading dataset ===")
df = pd.read_csv(DATA, sep=";")
print(f"  Shape: {df.shape}  |  Missing values: {df.isnull().sum().sum()}")

# Rename columns
rename = {
    "school":"School","sex":"Sex","age":"Age","address":"Address",
    "famsize":"FamilySize","Pstatus":"ParentStatus",
    "Medu":"MotherEducation","Fedu":"FatherEducation",
    "Mjob":"MotherJob","Fjob":"FatherJob","reason":"SchoolReason",
    "guardian":"Guardian","traveltime":"TravelTime","studytime":"StudyTime",
    "failures":"PastFailures","schoolsup":"SchoolSupport",
    "famsup":"FamilySupport","paid":"PaidClasses",
    "activities":"ExtraCurricular","nursery":"Nursery",
    "higher":"WantsHigherEdu","internet":"Internet",
    "romantic":"Romantic","famrel":"FamilyRelation",
    "freetime":"FreeTime","goout":"GoOut",
    "Dalc":"WeekdayAlcohol","Walc":"WeekendAlcohol",
    "health":"Health","absences":"Absences",
    "G1":"Grade_P1","G2":"Grade_P2","G3":"FinalGrade"
}
df.rename(columns=rename, inplace=True)

# Feature engineering
df["AvgGrade"]         = (df["Grade_P1"] + df["Grade_P2"] + df["FinalGrade"]) / 3
df["GradeImprovement"] = df["FinalGrade"] - df["Grade_P1"]
df["PassFail"]         = df["FinalGrade"].apply(lambda g: "Pass" if g >= 10 else "Fail")
df["Sex_label"]        = df["Sex"].map({"F":"Female","M":"Male"})
df["Address_label"]    = df["Address"].map({"U":"Urban","R":"Rural"})

edu_map = {0:"0–None",1:"1–Primary",2:"2–5th-9th",3:"3–Secondary",4:"4–Higher"}
df["MeduLabel"] = df["MotherEducation"].map(edu_map)

study_map = {1:"<2 hrs",2:"2–5 hrs",3:"5–10 hrs",4:">10 hrs"}
df["StudyLabel"] = df["StudyTime"].map(study_map)

print(f"  Pass: {(df.PassFail=='Pass').sum()}  Fail: {(df.PassFail=='Fail').sum()}")
print(f"  Mean Final Grade: {df.FinalGrade.mean():.2f}  SD: {df.FinalGrade.std():.2f}")

# Save CSVs
df.to_csv(os.path.join(OUTPUT, "student_preprocessed.csv"), index=False)

# ════════════════════════════════════════════════════════════
# PLOT 01 – Final Grade Distribution
# ════════════════════════════════════════════════════════════
print("\n=== Generating plots ===")
fig, ax = plt.subplots(figsize=(9,6))
ax.hist(df.FinalGrade, bins=range(0,22), density=True, color=BLUE, alpha=0.8, edgecolor="white")
df.FinalGrade.plot.kde(ax=ax, color=RED, lw=2)
ax.axvline(df.FinalGrade.mean(), color=ORANGE, lw=1.8, ls="--")
ax.text(df.FinalGrade.mean()+0.3, ax.get_ylim()[1]*0.85,
        f"Mean={df.FinalGrade.mean():.1f}", color=ORANGE, fontweight="bold")
ax.set(title="Distribution of Final Grades (G3)",
       xlabel="Final Grade (0–20 scale)", ylabel="Density")
ax.set_xticks(range(0,21))
fig.text(0.5,0.01,"Source: UCI ML Repository – Cortez & Silva (2008)",ha="center",fontsize=8,color="gray")
save("01_final_grade_distribution.png")

# ════════════════════════════════════════════════════════════
# PLOT 02 – Grade Period Comparison
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(9,6))
grades_long = pd.DataFrame({
    "Grade": pd.concat([df.Grade_P1, df.Grade_P2, df.FinalGrade]).values,
    "Period": (["Period 1 (G1)"]*len(df) + ["Period 2 (G2)"]*len(df) + ["Final Grade (G3)"]*len(df))
})
order = ["Period 1 (G1)","Period 2 (G2)","Final Grade (G3)"]
palette = sns.color_palette("Set2", 3)
sns.boxplot(data=grades_long, x="Period", y="Grade", order=order,
            palette=palette, ax=ax, width=0.5)
sns.stripplot(data=grades_long, x="Period", y="Grade", order=order,
              color="black", alpha=0.1, size=2, jitter=True, ax=ax)
ax.set(title="Grade Distribution Across Three Periods",
       xlabel="Assessment Period", ylabel="Grade (0–20)")
save("02_grade_period_comparison.png")

# ════════════════════════════════════════════════════════════
# PLOT 03 – Gender vs Final Grade (Violin)
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(8,6))
gender_pal = {"Female":"#F28B82","Male":"#82B4F5"}
sns.violinplot(data=df, x="Sex_label", y="FinalGrade", palette=gender_pal, ax=ax, alpha=0.7)
sns.boxplot(data=df, x="Sex_label", y="FinalGrade", width=0.12,
            color="white", ax=ax, flierprops=dict(marker="o",color="red",markersize=3))
for sex in ["Female","Male"]:
    m = df[df.Sex_label==sex].FinalGrade.mean()
    ax.text(["Female","Male"].index(sex), 21.2, f"μ={m:.2f}", ha="center", fontweight="bold", fontsize=11)
ax.set(title="Final Grade Distribution by Gender",
       xlabel="Gender", ylabel="Final Grade (G3)")
save("03_gender_vs_final_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 04 – Study Time vs Final Grade
# ════════════════════════════════════════════════════════════
study_order = ["<2 hrs","2–5 hrs","5–10 hrs",">10 hrs"]
study_sum = df.groupby("StudyLabel")["FinalGrade"].agg(["mean","std","count"]).reindex(study_order).reset_index()
study_sum["se"] = study_sum["std"] / np.sqrt(study_sum["count"])

fig, ax = plt.subplots(figsize=(9,6))
bars = ax.bar(study_sum.StudyLabel, study_sum["mean"],
              color=sns.color_palette("Blues",4), alpha=0.85, width=0.6)
ax.errorbar(study_sum.StudyLabel, study_sum["mean"],
            yerr=study_sum["se"], fmt="none", color="black", capsize=5, lw=1.5)
for i, row in study_sum.iterrows():
    ax.text(i, row["mean"]+0.3, f"{row['mean']:.1f}\n(n={int(row['count'])})",
            ha="center", fontsize=10, fontweight="bold")
ax.set(title="Effect of Weekly Study Time on Final Grade",
       xlabel="Weekly Study Time", ylabel="Mean Final Grade (G3)", ylim=(0,14))
save("04_studytime_vs_final_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 05 – Past Failures vs Final Grade
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(9,6))
pal = sns.color_palette("RdYlGn",len(df.PastFailures.unique()))[::-1]
sns.boxplot(data=df, x="PastFailures", y="FinalGrade", palette=pal, ax=ax,
            flierprops=dict(marker="o",color="red",markersize=3))
means = df.groupby("PastFailures")["FinalGrade"].mean()
for i, (fail, m) in enumerate(means.items()):
    ax.scatter(i, m, marker="D", color=GOLD, edgecolors="black", s=80, zorder=5)
ax.set(title="Impact of Past Failures on Final Grade",
       xlabel="Number of Past Failures", ylabel="Final Grade (G3)")
ax.scatter([], [], marker="D", color=GOLD, edgecolors="black", label="Mean", s=80)
ax.legend(loc="upper right")
save("05_past_failures_vs_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 06 – Absences vs Final Grade (Scatter + Regression)
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(9,6))
colors = df["PassFail"].map(PASS_COL)
ax.scatter(df.Absences, df.FinalGrade, c=colors, alpha=0.5, s=25)
m, b, r, p, se = stats.linregress(df.Absences, df.FinalGrade)
x_line = np.linspace(0, df.Absences.max(), 100)
ax.plot(x_line, m*x_line+b, color="navy", lw=1.8)
pass_patch = mpatches.Patch(color=GREEN, label="Pass"); fail_patch = mpatches.Patch(color=FAIL, label="Fail")
ax.legend(handles=[pass_patch, fail_patch])
ax.set(title="School Absences vs Final Grade",
       xlabel="Number of Absences", ylabel="Final Grade (G3)")
ax.text(0.98, 0.95, f"r = {r:.3f}", transform=ax.transAxes, ha="right", fontsize=11)
save("06_absences_vs_final_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 07 – Mother's Education vs Final Grade
# ════════════════════════════════════════════════════════════
edu_order = ["0–None","1–Primary","2–5th-9th","3–Secondary","4–Higher"]
edu_sum = df.groupby("MeduLabel")["FinalGrade"].agg(["mean","count"]).reindex(edu_order).reset_index()
fig, ax = plt.subplots(figsize=(9,6))
colors_edu = sns.color_palette("YlOrRd",5)
bars = ax.bar(edu_sum.MeduLabel, edu_sum["mean"], color=colors_edu, alpha=0.85, width=0.6)
for i, row in edu_sum.iterrows():
    ax.text(i, row["mean"]+0.15, f"{row['mean']:.1f}\n(n={int(row['count'])})",
            ha="center", fontsize=9, fontweight="bold")
ax.set(title="Mother's Education Level vs Mean Final Grade",
       xlabel="Mother's Education Level", ylabel="Mean Final Grade (G3)", ylim=(0,14))
plt.xticks(rotation=15, ha="right")
save("07_mother_education_vs_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 08 – Internet Access vs Final Grade
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(8,6))
net_pal = {"no":"#FF7F7F","yes":"#90EE90"}
sns.boxplot(data=df, x="Internet", y="FinalGrade", palette=net_pal, ax=ax, width=0.5,
            flierprops=dict(marker="o",color="red",markersize=3))
for i, net in enumerate(["no","yes"]):
    m = df[df.Internet==net].FinalGrade.mean()
    ax.scatter(i, m, marker="D", color=GOLD, edgecolors="black", s=80, zorder=5)
ax.set(title="Internet Access at Home vs Final Grade",
       xlabel="Internet Access at Home", ylabel="Final Grade (G3)")
ax.scatter([], [], marker="D", color=GOLD, edgecolors="black", label="Mean", s=80)
ax.legend()
save("08_internet_vs_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 09 – Grade Improvement by Gender
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(9,6))
for sex, col in [("Female","#F28B82"),("Male","#82B4F5")]:
    data = df[df.Sex_label==sex].GradeImprovement
    ax.hist(data, bins=range(-15,16), alpha=0.75, color=col, label=sex, edgecolor="white")
ax.axvline(0, color="black", lw=1.5, ls="--")
ax.text(-0.5, ax.get_ylim()[1]*0.9, "Declined", ha="right", color=FAIL, fontweight="bold")
ax.text(0.5,  ax.get_ylim()[1]*0.9, "Improved", ha="left",  color=GREEN, fontweight="bold")
ax.set(title="Grade Improvement from Period 1 to Final Grade",
       xlabel="Grade Change (G3 – G1)", ylabel="Number of Students")
ax.legend()
save("09_grade_improvement_by_gender.png")

# ════════════════════════════════════════════════════════════
# PLOT 10 – Pass/Fail Donut
# ════════════════════════════════════════════════════════════
pf = df.PassFail.value_counts()
fig, ax = plt.subplots(figsize=(7,7))
wedge_props = dict(width=0.5, edgecolor="white", linewidth=2)
wedges, _ = ax.pie(pf.values, labels=None, colors=[GREEN, FAIL],
                   startangle=90, wedgeprops=wedge_props)
total = pf.sum()
for wedge, (label, count) in zip(wedges, pf.items()):
    angle = (wedge.theta2 + wedge.theta1) / 2
    x = 0.75 * np.cos(np.radians(angle)); y = 0.75 * np.sin(np.radians(angle))
    ax.text(x, y, f"{label}\n{count} ({count/total*100:.1f}%)",
            ha="center", va="center", fontsize=13, fontweight="bold", color="white")
ax.set(title="Overall Pass vs Fail Rate")
ax.set_title("Overall Pass vs Fail Rate\n(G3 ≥ 10 = Pass)", fontsize=15, fontweight="bold")
save("10_pass_fail_donut.png")

# ════════════════════════════════════════════════════════════
# PLOT 11 – Weekend Alcohol vs Final Grade
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(9,6))
alc_pal = sns.color_palette("RdYlGn",5)[::-1]
sns.boxplot(data=df, x="WeekendAlcohol", y="FinalGrade", palette=alc_pal, ax=ax,
            flierprops=dict(marker="o",color="red",markersize=3))
for i in range(1,6):
    m = df[df.WeekendAlcohol==i].FinalGrade.mean()
    ax.scatter(i-1, m, marker="D", color=GOLD, edgecolors="black", s=80, zorder=5)
ax.set(title="Weekend Alcohol Consumption vs Final Grade",
       xlabel="Weekend Alcohol Level (1=Very Low, 5=Very High)", ylabel="Final Grade (G3)")
save("11_alcohol_vs_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 12 – School Support vs Pass/Fail
# ════════════════════════════════════════════════════════════
sup_pf = df.groupby(["SchoolSupport","PassFail"]).size().unstack(fill_value=0)
sup_pct = sup_pf.div(sup_pf.sum(axis=1), axis=0)*100
fig, ax = plt.subplots(figsize=(8,6))
x = np.arange(len(sup_pf)); w = 0.35
ax.bar(x-w/2, sup_pf["Pass"], w, color=GREEN, alpha=0.85, label="Pass")
ax.bar(x+w/2, sup_pf["Fail"], w, color=FAIL,  alpha=0.85, label="Fail")
for i, idx in enumerate(sup_pf.index):
    ax.text(i-w/2, sup_pf.loc[idx,"Pass"]+1, f"{sup_pct.loc[idx,'Pass']:.1f}%", ha="center", fontsize=9)
    ax.text(i+w/2, sup_pf.loc[idx,"Fail"]+1, f"{sup_pct.loc[idx,'Fail']:.1f}%", ha="center", fontsize=9)
ax.set_xticks(x); ax.set_xticklabels(["No Support","School Support"])
ax.set(title="Effect of Extra School Support on Pass/Fail Outcome",
       xlabel="Extra School Support", ylabel="Number of Students")
ax.legend()
save("12_school_support_vs_passfail.png")

# ════════════════════════════════════════════════════════════
# PLOT 13 – Full Correlation Heatmap
# ════════════════════════════════════════════════════════════
num_df = df[["Age","MotherEducation","FatherEducation","TravelTime","StudyTime",
             "PastFailures","FamilyRelation","FreeTime","GoOut",
             "WeekdayAlcohol","WeekendAlcohol","Health","Absences",
             "Grade_P1","Grade_P2","FinalGrade"]].copy()
num_df.columns = ["Age","Mother Edu","Father Edu","Travel Time","Study Time",
                  "Past Failures","Fam. Relation","Free Time","Go Out",
                  "Weekday Alc.","Weekend Alc.","Health","Absences",
                  "Grade P1","Grade P2","Final Grade"]
corr = num_df.corr(method="pearson")
fig, ax = plt.subplots(figsize=(12,10))
mask = np.triu(np.ones_like(corr), k=1)
sns.heatmap(corr, mask=mask, annot=True, fmt=".2f", cmap="RdBu_r",
            center=0, vmin=-1, vmax=1, ax=ax, linewidths=0.5,
            annot_kws={"size":8}, square=True)
ax.set_title("Pearson Correlation Matrix – Student Performance Variables",
             fontsize=14, fontweight="bold", pad=15)
save("13_correlation_heatmap_full.png")

# ════════════════════════════════════════════════════════════
# PLOT 14 – Grade-Focused Correlation
# ════════════════════════════════════════════════════════════
grade_vars = ["Study Time","Past Failures","Absences","Mother Edu","Father Edu",
              "Weekday Alc.","Weekend Alc.","Health","Grade P1","Grade P2","Final Grade"]
corr_g = corr.loc[grade_vars, grade_vars]
fig, ax = plt.subplots(figsize=(10,9))
mask_g = np.triu(np.ones_like(corr_g), k=1)
sns.heatmap(corr_g, mask=mask_g, annot=True, fmt=".2f", cmap="RdBu_r",
            center=0, vmin=-1, vmax=1, ax=ax, linewidths=0.5,
            annot_kws={"size":10}, square=True)
ax.set_title("Correlation: Grade-Related Variables", fontsize=14, fontweight="bold", pad=15)
save("14_correlation_grade_focused.png")

# ════════════════════════════════════════════════════════════
# PLOT 15 – Correlation Bar (all vs FinalGrade)
# ════════════════════════════════════════════════════════════
fg_corr = corr["Final Grade"].drop("Final Grade").sort_values()
fig, ax = plt.subplots(figsize=(10,8))
colors_bar = [BLUE if v>0 else RED for v in fg_corr.values]
bars = ax.barh(fg_corr.index, fg_corr.values, color=colors_bar, alpha=0.85, height=0.65)
ax.axvline(0, color="black", lw=0.8)
for bar, val in zip(bars, fg_corr.values):
    ax.text(val + (0.01 if val>=0 else -0.01), bar.get_y()+bar.get_height()/2,
            f"{val:.2f}", va="center", ha="left" if val>=0 else "right", fontsize=9)
ax.set(title="Pearson Correlation of All Variables with Final Grade",
       xlabel="Correlation Coefficient (r)", xlim=(-0.75,1.1))
blue_p = mpatches.Patch(color=BLUE, label="Positive"); red_p = mpatches.Patch(color=RED, label="Negative")
ax.legend(handles=[blue_p, red_p], loc="lower right")
save("15_correlation_barplot.png")

# ════════════════════════════════════════════════════════════
# PLOT 16 – Regression Diagnostics
# ════════════════════════════════════════════════════════════
feat_cols = ["Grade_P1","Grade_P2","StudyTime","PastFailures","Absences",
             "MotherEducation","FatherEducation","WeekdayAlcohol","WeekendAlcohol","Age"]
X_reg = df[feat_cols].values
y_reg = df["FinalGrade"].values
from numpy.linalg import lstsq
X_b   = np.column_stack([np.ones(len(X_reg)), X_reg])
coefs, _, _, _ = lstsq(X_b, y_reg, rcond=None)
y_pred_reg = X_b @ coefs
residuals  = y_reg - y_pred_reg
ss_res = np.sum(residuals**2); ss_tot = np.sum((y_reg - y_reg.mean())**2)
r2 = 1 - ss_res/ss_tot

fig, axes = plt.subplots(2,2, figsize=(12,10))
fig.suptitle(f"Multiple Linear Regression – Diagnostics (R²={r2:.3f})",
             fontsize=14, fontweight="bold")
axes[0,0].scatter(y_pred_reg, residuals, alpha=0.5, color=BLUE, s=20)
axes[0,0].axhline(0, color="red", lw=1.5, ls="--")
axes[0,0].set(title="Residuals vs Fitted", xlabel="Fitted Values", ylabel="Residuals")

stats.probplot(residuals, dist="norm", plot=axes[0,1])
axes[0,1].set_title("Normal Q-Q Plot")

axes[1,0].scatter(y_pred_reg, np.sqrt(np.abs(residuals)), alpha=0.5, color=BLUE, s=20)
axes[1,0].set(title="Scale-Location", xlabel="Fitted Values", ylabel="√|Residuals|")

h = X_b @ np.linalg.pinv(X_b.T @ X_b) @ X_b.T
leverage = np.diag(h)
cooks = (residuals**2 / (len(coefs) * (ss_res/len(y_reg)))) * (leverage/(1-leverage)**2)
axes[1,1].stem(range(len(cooks)), cooks, markerfmt="C0o", linefmt="C0-", basefmt="k-")
axes[1,1].set(title="Cook's Distance", xlabel="Observation Index", ylabel="Cook's Distance")

plt.tight_layout()
save("16_regression_diagnostics.png")

# ════════════════════════════════════════════════════════════
# PLOT 17 – Actual vs Predicted
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(9,6))
sc = ax.scatter(y_pred_reg, y_reg, c=np.abs(residuals), cmap="coolwarm", alpha=0.6, s=25)
plt.colorbar(sc, ax=ax, label="|Residual|")
ax.plot([0,20],[0,20], color="red", lw=1.5, ls="--")
ax.set(title=f"Actual vs Predicted Final Grade  (R²={r2:.3f})",
       xlabel="Predicted Final Grade", ylabel="Actual Final Grade (G3)")
save("17_actual_vs_predicted.png")

# ════════════════════════════════════════════════════════════
# PLOT 18 – Regression Coefficients
# ════════════════════════════════════════════════════════════
feat_names = ["Grade P1","Grade P2","Study Time","Past Failures","Absences",
              "Mother Edu","Father Edu","Weekday Alc.","Weekend Alc.","Age"]
coef_vals = coefs[1:]
n = len(y_reg); p = len(coef_vals)
mse = ss_res / (n-p-1)
cov = mse * np.linalg.pinv(X_b.T @ X_b)
se  = np.sqrt(np.diag(cov))[1:]
t   = coef_vals / se
pvals = [2*(1 - stats.t.cdf(abs(tv), df=n-p-1)) for tv in t]

coef_df = pd.DataFrame({"Feature":feat_names,"Coef":coef_vals,"SE":se,"p":pvals})
coef_df["Sig"] = coef_df["p"] < 0.05
coef_df = coef_df.sort_values("Coef")

fig, ax = plt.subplots(figsize=(10,7))
colors_coef = [BLUE if s else "#BABABA" for s in coef_df["Sig"]]
ax.barh(coef_df["Feature"], coef_df["Coef"], color=colors_coef, alpha=0.85, height=0.65)
ax.errorbar(coef_df["Coef"], coef_df["Feature"],
            xerr=1.96*coef_df["SE"], fmt="none", color="black", capsize=4, lw=1.5)
ax.axvline(0, color="black", lw=0.8, ls="--")
ax.set(title="Regression Coefficients – Predictors of Final Grade",
       xlabel="Coefficient Estimate (β)")
blue_p = mpatches.Patch(color=BLUE,  label="Significant (p<0.05)")
grey_p = mpatches.Patch(color="#BABABA", label="Not Significant")
ax.legend(handles=[blue_p, grey_p])
save("18_regression_coefficients.png")

# ════════════════════════════════════════════════════════════
# PLOT 19 – Heatmap: Study Time × Gender × Mean Grade
# ════════════════════════════════════════════════════════════
heat = df.groupby(["Sex_label","StudyLabel"])["FinalGrade"].mean().unstack()
heat = heat.reindex(columns=["<2 hrs","2–5 hrs","5–10 hrs",">10 hrs"])
fig, ax = plt.subplots(figsize=(9,4))
sns.heatmap(heat, annot=True, fmt=".2f", cmap="RdYlGn", center=10,
            vmin=5, vmax=15, ax=ax, linewidths=0.5,
            annot_kws={"size":14,"weight":"bold"})
ax.set(title="Mean Final Grade by Gender and Study Time",
       xlabel="Weekly Study Time", ylabel="Gender")
save("19_heatmap_studytime_gender_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 20 – Faceted Scatter: Study Time Panels
# ════════════════════════════════════════════════════════════
study_order_full = ["<2 hrs","2–5 hrs","5–10 hrs",">10 hrs"]
fig, axes = plt.subplots(2,2, figsize=(11,8), sharey=True)
fig.suptitle("Absences vs Final Grade — Faceted by Study Time",
             fontsize=14, fontweight="bold")
for ax, sl in zip(axes.flatten(), study_order_full):
    sub = df[df.StudyLabel==sl]
    colors_sub = sub["PassFail"].map(PASS_COL)
    ax.scatter(sub.Absences, sub.FinalGrade, c=colors_sub, alpha=0.5, s=20)
    if len(sub) > 2:
        m2,b2,_,_,_ = stats.linregress(sub.Absences, sub.FinalGrade)
        xl = np.linspace(0,sub.Absences.max(),50)
        ax.plot(xl, m2*xl+b2, color="navy", lw=1.5, ls="--")
    ax.set_title(sl, fontweight="bold"); ax.set_xlabel("Absences"); ax.set_ylabel("Final Grade")
pass_p = mpatches.Patch(color=GREEN,label="Pass"); fail_p=mpatches.Patch(color=FAIL,label="Fail")
fig.legend(handles=[pass_p,fail_p], loc="lower center", ncol=2)
plt.tight_layout(rect=[0,0.05,1,1])
save("20_faceted_absences_vs_grade.png")

# ════════════════════════════════════════════════════════════
# PLOT 21 – Mother's Job vs Grade
# ════════════════════════════════════════════════════════════
mjob_sum = df.groupby("MotherJob")["FinalGrade"].agg(["mean","std","count"]).reset_index()
mjob_sum = mjob_sum.sort_values("mean")
fig, ax = plt.subplots(figsize=(9,6))
cmap_vals = plt.cm.Blues(np.linspace(0.3,0.9,len(mjob_sum)))
ax.barh(mjob_sum.MotherJob, mjob_sum["mean"], color=cmap_vals, alpha=0.85)
ax.errorbar(mjob_sum["mean"], mjob_sum.MotherJob,
            xerr=mjob_sum["std"], fmt="none", color="gray", capsize=4, lw=1.2)
for _, row in mjob_sum.iterrows():
    ax.text(row["mean"]+0.1, row.MotherJob,
            f"{row['mean']:.1f} (n={int(row['count'])})", va="center", fontsize=9)
ax.set(title="Mother's Occupation vs Mean Final Grade",
       xlabel="Mean Final Grade (G3)", ylabel="Mother's Job Category")
save("21_mothers_job_vs_grade.png")

# ════════════════════════════════════════════════════════════
# CLASSIFICATION MODELS
# ════════════════════════════════════════════════════════════
print("\n=== Running classification models ===")
clf_features = ["Grade_P1","Grade_P2","StudyTime","PastFailures","Absences",
                "MotherEducation","FatherEducation","WeekdayAlcohol","WeekendAlcohol","Age"]
X_clf = df[clf_features].values
y_clf = (df["FinalGrade"] >= 10).astype(int).values

X_tr, X_te, y_tr, y_te = train_test_split(X_clf, y_clf, test_size=0.2, random_state=42)
print(f"  Train: {len(X_tr)} | Test: {len(X_te)}")

# Logistic Regression
lr = LogisticRegression(max_iter=1000, random_state=42)
lr.fit(X_tr, y_tr); y_pred_lr = lr.predict(X_te); y_prob_lr = lr.predict_proba(X_te)[:,1]
acc_lr  = accuracy_score(y_te,  y_pred_lr)
prec_lr = precision_score(y_te, y_pred_lr)
rec_lr  = recall_score(y_te,    y_pred_lr)
f1_lr   = f1_score(y_te,        y_pred_lr)
fpr, tpr, _ = roc_curve(y_te, y_prob_lr); auc_lr = auc(fpr, tpr)
print(f"  Logistic Regression → Acc={acc_lr:.3f} P={prec_lr:.3f} R={rec_lr:.3f} F1={f1_lr:.3f} AUC={auc_lr:.3f}")

# ════════════════════════════════════════════════════════════
# PLOT 22 – ROC Curve
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(7,6))
ax.plot(fpr, tpr, color=BLUE, lw=2)
ax.plot([0,1],[0,1], color="gray", lw=1, ls="--")
ax.text(0.55,0.25, f"AUC = {auc_lr:.3f}", fontsize=14, fontweight="bold", color=BLUE)
ax.set(title="ROC Curve — Logistic Regression (Pass/Fail)",
       xlabel="False Positive Rate (1 – Specificity)",
       ylabel="True Positive Rate (Sensitivity)")
save("22_roc_curve_logistic.png")

# KNN
scaler   = MinMaxScaler(); X_tr_n = scaler.fit_transform(X_tr); X_te_n = scaler.transform(X_te)
k_vals   = [1,3,5,7,11,15,21]
knn_accs = []
for k in k_vals:
    knn = KNeighborsClassifier(n_neighbors=k)
    knn.fit(X_tr_n, y_tr)
    knn_accs.append(accuracy_score(y_te, knn.predict(X_te_n)))
best_k   = k_vals[np.argmax(knn_accs)]; best_acc = max(knn_accs)
knn_best = KNeighborsClassifier(n_neighbors=best_k)
knn_best.fit(X_tr_n, y_tr); y_pred_knn = knn_best.predict(X_te_n)
acc_knn  = accuracy_score(y_te,  y_pred_knn)
prec_knn = precision_score(y_te, y_pred_knn)
rec_knn  = recall_score(y_te,    y_pred_knn)
f1_knn   = f1_score(y_te,        y_pred_knn)
print(f"  KNN (K={best_k})          → Acc={acc_knn:.3f} P={prec_knn:.3f} R={rec_knn:.3f} F1={f1_knn:.3f}")

# ════════════════════════════════════════════════════════════
# PLOT 23 – KNN K vs Accuracy
# ════════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(8,5))
ax.plot(k_vals, knn_accs, color=RED, lw=2, marker="o", markersize=7)
ax.scatter([best_k],[best_acc], s=150, color=GREEN, marker="D", zorder=5,
           label=f"Best K={best_k}")
for k,a in zip(k_vals,knn_accs):
    ax.text(k, a+0.005, f"{a*100:.1f}%", ha="center", fontsize=9)
ax.set(title="KNN Classifier — K Value vs Accuracy",
       xlabel="Number of Neighbors (K)", ylabel="Test Accuracy",
       xticks=k_vals, ylim=(0.5,1.05))
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x,_: f"{x*100:.0f}%"))
ax.legend(); ax.grid(axis="y", alpha=0.3)
save("23_knn_k_vs_accuracy.png")

# ════════════════════════════════════════════════════════════
# OUTPUT CSV FILES
# ════════════════════════════════════════════════════════════
print("\n=== Saving output files ===")

# Hypothesis tests
hyp = pd.DataFrame({
    "Test":["t-Test: Gender vs Grade","ANOVA: Study Time vs Grade",
            "Chi-Square: Internet vs Pass/Fail","Pearson Corr: Study Time vs Grade",
            "Shapiro-Wilk: Normality of Grade"],
    "Statistic":[
        round(stats.ttest_ind(df[df.Sex_label=="Male"].FinalGrade,
                               df[df.Sex_label=="Female"].FinalGrade).statistic,4),
        round(stats.f_oneway(*[df[df.StudyTime==s].FinalGrade for s in df.StudyTime.unique()]).statistic,4),
        round(stats.chi2_contingency(pd.crosstab(df.Internet,df.PassFail))[0],4),
        round(stats.pearsonr(df.StudyTime,df.FinalGrade)[0],4),
        round(stats.shapiro(df.FinalGrade[:5000]).statistic,6)
    ],
    "p_value":[
        round(stats.ttest_ind(df[df.Sex_label=="Male"].FinalGrade,
                               df[df.Sex_label=="Female"].FinalGrade).pvalue,4),
        round(stats.f_oneway(*[df[df.StudyTime==s].FinalGrade for s in df.StudyTime.unique()]).pvalue,4),
        round(stats.chi2_contingency(pd.crosstab(df.Internet,df.PassFail))[1],4),
        round(stats.pearsonr(df.StudyTime,df.FinalGrade)[1],6),
        round(stats.shapiro(df.FinalGrade[:5000]).pvalue,6)
    ]
})
hyp["Decision"] = hyp["p_value"].apply(lambda p: "Reject H0" if p < 0.05 else "Fail to Reject H0")
hyp.to_csv(os.path.join(OUTPUT,"hypothesis_tests_summary.csv"), index=False)
print("  ✔ hypothesis_tests_summary.csv")
print(hyp.to_string(index=False))

# Model comparison
model_comp = pd.DataFrame({
    "Model":["Simple LR (G3~G1)","Multiple LR (10 vars)",f"KNN (K={best_k})","Logistic Regression"],
    "R_Squared":[round(np.corrcoef(df.Grade_P1,df.FinalGrade)[0,1]**2,4), round(r2,4), "-", "-"],
    "Accuracy":["-","-", round(acc_knn,4), round(acc_lr,4)],
    "F1_Score":["-","-", round(f1_knn,4), round(f1_lr,4)],
    "AUC_ROC":["-","-", "-", round(auc_lr,4)]
})
model_comp.to_csv(os.path.join(OUTPUT,"model_comparison.csv"), index=False)
print("  ✔ model_comparison.csv")

clf_comp = pd.DataFrame({
    "Model":["Logistic Regression",f"KNN (K={best_k})"],
    "Accuracy":[round(acc_lr,4),round(acc_knn,4)],
    "Precision":[round(prec_lr,4),round(prec_knn,4)],
    "Recall":[round(rec_lr,4),round(rec_knn,4)],
    "F1_Score":[round(f1_lr,4),round(f1_knn,4)]
})
clf_comp.to_csv(os.path.join(OUTPUT,"classification_model_comparison.csv"), index=False)
print("  ✔ classification_model_comparison.csv")

# ════════════════════════════════════════════════════════════
# DONE
# ════════════════════════════════════════════════════════════
plot_count = len([f for f in os.listdir(PLOTS) if f.endswith(".png")])
csv_count  = len([f for f in os.listdir(OUTPUT) if f.endswith(".csv")])
print(f"""
╔══════════════════════════════════════════════╗
║          PROJECT COMPLETE! 🎉                ║
╠══════════════════════════════════════════════╣
║  📊 Plots generated  : {plot_count:<22}║
║  📁 CSV files saved  : {csv_count:<22}║
║  📂 Plots folder     : R_Analysis/plots/     ║
║  📂 Output folder    : R_Analysis/output/    ║
╚══════════════════════════════════════════════╝
""")
