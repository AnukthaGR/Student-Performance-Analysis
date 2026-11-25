"""
Standalone script to generate all 7 visualizations.
Run this once to verify the analysis works correctly.
"""
import os
import warnings
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings('ignore')
sns.set_theme(style='whitegrid', palette='muted')
plt.rcParams['figure.figsize'] = (10, 6)
plt.rcParams['font.size'] = 12

BASE = os.path.dirname(os.path.abspath(__file__))
VIZ  = os.path.join(BASE, 'visualizations')
DATA = os.path.join(BASE, 'dataset', 'student_data.csv')

# ── Load dataset ────────────────────────────────────────────────────────────────
df = pd.read_csv(DATA, sep=';')
print(f"Dataset loaded: {df.shape[0]} rows, {df.shape[1]} columns")

# ── Feature engineering ─────────────────────────────────────────────────────────
df['final_grade'] = ((df['G1'] + df['G2'] + df['G3']) / 3).round(2)

def classify(g3):
    if   g3 >= 16: return 'Excellent'
    elif g3 >= 12: return 'Good'
    elif g3 >= 8:  return 'Average'
    else:          return 'Poor'

df['performance']    = df['G3'].apply(classify)
df['studytime_label']= df['studytime'].map({1:'<2 hrs',2:'2-5 hrs',3:'5-10 hrs',4:'>10 hrs'})

# ── Graph 1: Grade Distribution ─────────────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

axes[0].hist(df['G3'], bins=20, color='steelblue', edgecolor='white', linewidth=0.8)
axes[0].axvline(df['G3'].mean(),   color='red',    linestyle='--', linewidth=2,
                label='Mean = {:.2f}'.format(df['G3'].mean()))
axes[0].axvline(df['G3'].median(), color='orange', linestyle='--', linewidth=2,
                label='Median = {:.2f}'.format(df['G3'].median()))
axes[0].set_title('Distribution of Final Grades (G3)', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Final Grade (G3) out of 20')
axes[0].set_ylabel('Number of Students')
axes[0].legend()

perf_counts = df['performance'].value_counts()
axes[1].pie(perf_counts, labels=perf_counts.index, autopct='%1.1f%%',
            colors=['#2ecc71','#3498db','#f39c12','#e74c3c'], startangle=90,
            explode=[0.05]*len(perf_counts))
axes[1].set_title('Student Performance Categories', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig(os.path.join(VIZ, 'graph1_grade_distribution.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Graph 1 saved")

# ── Graph 2: Study Time vs Grade ─────────────────────────────────────────────────
order = ['<2 hrs', '2-5 hrs', '5-10 hrs', '>10 hrs']
study_avg = df.groupby('studytime_label')['G3'].mean().reindex(order)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

bar_colors = ['#e74c3c','#f39c12','#2ecc71','#3498db']
bars = axes[0].bar(study_avg.index, study_avg.values, color=bar_colors, edgecolor='white', linewidth=0.8)
axes[0].set_title('Average Final Grade by Study Time', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Weekly Study Time')
axes[0].set_ylabel('Average Final Grade (G3)')
axes[0].set_ylim(0, 20)
for bar, val in zip(bars, study_avg.values):
    axes[0].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
                 '{:.1f}'.format(val), ha='center', fontsize=11, fontweight='bold')

sns.boxplot(data=df, x='studytime_label', y='G3', order=order, palette='RdYlGn', ax=axes[1])
axes[1].set_title('Grade Spread by Study Time (Box Plot)', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Weekly Study Time')
axes[1].set_ylabel('Final Grade (G3)')

plt.tight_layout()
plt.savefig(os.path.join(VIZ, 'graph2_studytime_vs_grade.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Graph 2 saved")

# ── Graph 3: Gender Performance ───────────────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

gender_counts = df['sex'].value_counts()
axes[0].bar(gender_counts.index, gender_counts.values,
            color=['#9b59b6','#1abc9c'], edgecolor='white', width=0.5)
axes[0].set_title('Number of Students by Gender', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Gender (F=Female, M=Male)')
axes[0].set_ylabel('Number of Students')
for i, (idx, val) in enumerate(gender_counts.items()):
    axes[0].text(i, val+1, str(val), ha='center', fontweight='bold')

gender_grades = df.groupby('sex')[['G1','G2','G3']].mean()
x  = np.arange(3)
w  = 0.35
axes[1].bar(x - w/2, gender_grades.loc['F'], w, label='Female', color='#9b59b6', edgecolor='white')
axes[1].bar(x + w/2, gender_grades.loc['M'], w, label='Male',   color='#1abc9c', edgecolor='white')
axes[1].set_title('Average Grades by Gender', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Grade Period')
axes[1].set_ylabel('Average Grade (out of 20)')
axes[1].set_xticks(x)
axes[1].set_xticklabels(['Period 1 (G1)','Period 2 (G2)','Final (G3)'])
axes[1].legend()
axes[1].set_ylim(0, 15)

plt.tight_layout()
plt.savefig(os.path.join(VIZ, 'graph3_gender_performance.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Graph 3 saved")

# ── Graph 4: Parental Education ───────────────────────────────────────────────────
edu_labels = {0:'None',1:'Primary (4th)',2:'Primary (5th-9th)',3:'Secondary',4:'Higher'}
df['Medu_label'] = df['Medu'].map(edu_labels)
df['Fedu_label'] = df['Fedu'].map(edu_labels)
edu_order = ['None','Primary (4th)','Primary (5th-9th)','Secondary','Higher']

mother_avg = df.groupby('Medu_label')['G3'].mean().reindex(edu_order).dropna()
father_avg = df.groupby('Fedu_label')['G3'].mean().reindex(edu_order).dropna()

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

sns.barplot(x=mother_avg.index, y=mother_avg.values, palette='Blues_d', ax=axes[0])
axes[0].set_title("Mother's Education vs Avg Final Grade", fontsize=14, fontweight='bold')
axes[0].set_xlabel("Mother's Education Level")
axes[0].set_ylabel('Average Final Grade (G3)')
axes[0].set_xticklabels(axes[0].get_xticklabels(), rotation=20, ha='right')
axes[0].set_ylim(0, 15)

sns.barplot(x=father_avg.index, y=father_avg.values, palette='Greens_d', ax=axes[1])
axes[1].set_title("Father's Education vs Avg Final Grade", fontsize=14, fontweight='bold')
axes[1].set_xlabel("Father's Education Level")
axes[1].set_ylabel('Average Final Grade (G3)')
axes[1].set_xticklabels(axes[1].get_xticklabels(), rotation=20, ha='right')
axes[1].set_ylim(0, 15)

plt.tight_layout()
plt.savefig(os.path.join(VIZ, 'graph4_parental_education.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Graph 4 saved")

# ── Graph 5: Absences vs Grade ────────────────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

axes[0].scatter(df['absences'], df['G3'], alpha=0.5, color='coral',
                edgecolors='darkred', linewidths=0.5)
z = np.polyfit(df['absences'], df['G3'], 1)
p = np.poly1d(z)
x_line = np.linspace(df['absences'].min(), df['absences'].max(), 100)
axes[0].plot(x_line, p(x_line), color='black', linewidth=2, linestyle='--', label='Trend Line')
axes[0].set_title('School Absences vs Final Grade', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Number of School Absences')
axes[0].set_ylabel('Final Grade (G3)')
axes[0].legend()

df['absence_group'] = pd.cut(df['absences'], bins=[-1,0,5,10,20,100],
                              labels=['0 (None)','1-5','6-10','11-20','>20'])
ag = df.groupby('absence_group', observed=True)['G3'].mean()
sns.barplot(x=ag.index, y=ag.values, palette='Reds_r', ax=axes[1])
axes[1].set_title('Average Grade by Absence Group', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Number of Absences')
axes[1].set_ylabel('Average Final Grade (G3)')
axes[1].set_ylim(0, 15)

plt.tight_layout()
plt.savefig(os.path.join(VIZ, 'graph5_absences_vs_grade.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Graph 5 saved")

# ── Graph 6: Grade Progression + Heatmap ─────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

avg_g = [df['G1'].mean(), df['G2'].mean(), df['G3'].mean()]
periods = ['Period 1 (G1)', 'Period 2 (G2)', 'Final (G3)']

axes[0].plot(periods, avg_g, marker='o', markersize=12, linewidth=3,
             color='#3498db', markerfacecolor='#e74c3c')
for period, val in zip(periods, avg_g):
    axes[0].annotate('{:.2f}'.format(val), (period, val),
                     textcoords='offset points', xytext=(0, 12),
                     ha='center', fontsize=12, fontweight='bold')
axes[0].set_title('Average Grade Progression (All Students)', fontsize=14, fontweight='bold')
axes[0].set_ylabel('Average Grade (out of 20)')
axes[0].set_ylim(0, 15)
axes[0].grid(True, alpha=0.5)

grade_corr = df[['G1','G2','G3','studytime','absences','failures']].corr()
sns.heatmap(grade_corr, annot=True, fmt='.2f', cmap='coolwarm',
            linewidths=0.5, ax=axes[1], vmin=-1, vmax=1)
axes[1].set_title('Correlation Heatmap — Grades & Key Factors', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig(os.path.join(VIZ, 'graph6_grade_progression_heatmap.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Graph 6 saved")

# ── Graph 7: Internet & School Support ───────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

internet_avg = df.groupby('internet')['G3'].mean()
axes[0].bar(internet_avg.index, internet_avg.values,
            color=['#e74c3c','#2ecc71'], edgecolor='white', width=0.4)
axes[0].set_title('Internet Access vs Average Final Grade', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Internet Access at Home (no / yes)')
axes[0].set_ylabel('Average Final Grade (G3)')
axes[0].set_ylim(0, 15)
for i, (idx, val) in enumerate(internet_avg.items()):
    axes[0].text(i, val+0.2, '{:.2f}'.format(val), ha='center', fontweight='bold')

support_avg = df.groupby('schoolsup')['G3'].mean()
axes[1].bar(support_avg.index, support_avg.values,
            color=['#3498db','#f39c12'], edgecolor='white', width=0.4)
axes[1].set_title('Extra School Support vs Average Final Grade', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Extra Educational Support (no / yes)')
axes[1].set_ylabel('Average Final Grade (G3)')
axes[1].set_ylim(0, 15)
for i, (idx, val) in enumerate(support_avg.items()):
    axes[1].text(i, val+0.2, '{:.2f}'.format(val), ha='center', fontweight='bold')

plt.tight_layout()
plt.savefig(os.path.join(VIZ, 'graph7_internet_support.png'), dpi=150, bbox_inches='tight')
plt.close()
print("Graph 7 saved")

# ── Summary ───────────────────────────────────────────────────────────────────────
print()
print("=" * 50)
print("  ALL 7 VISUALIZATIONS GENERATED SUCCESSFULLY")
print("=" * 50)
print("Dataset rows   :", df.shape[0])
print("Avg G3 grade   : {:.2f} / 20".format(df['G3'].mean()))
print("Corr absences/G3: {:.4f}".format(df['absences'].corr(df['G3'])))
print("Files saved    :", sorted(os.listdir(VIZ)))
