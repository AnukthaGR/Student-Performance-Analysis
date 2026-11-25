# ============================================================
# SCRIPT 08: Predictive Modeling — Logistic Regression + KNN
# Project  : Student Performance Data Analysis
# Language : R (Primary – 100% R)
# Libraries: dplyr, ggplot2 (base R stats + class package)
# ============================================================

library(dplyr)
library(ggplot2)
library(class)       # KNN classifier

# ---- Load preprocessed data ----
df <- readRDS("../output/student_preprocessed.rds")

plot_dir  <- "../plots"

cat("==========================================================\n")
cat("    PREDICTIVE MODELING (Logistic Regression + KNN)\n")
cat("==========================================================\n\n")

# ---- Prepare modelling data ----
model_df <- df %>%
  mutate(
    Pass_Binary     = ifelse(PassFail == "Pass", 1, 0),
    Sex_num         = ifelse(Sex == "Male", 1, 0),
    Address_num     = ifelse(Address == "Urban", 1, 0),
    Internet_num    = ifelse(Internet == "yes", 1, 0),
    Romantic_num    = ifelse(Romantic == "yes", 1, 0),
    SchoolSup_num   = ifelse(SchoolSupport == "yes", 1, 0),
    WantsHigher_num = ifelse(WantsHigherEdu == "yes", 1, 0),
    TravelTime_num  = as.numeric(TravelTime),
    StudyTime_num   = as.numeric(StudyTime),
    Dalc_num        = as.numeric(WeekdayAlcohol),
    Walc_num        = as.numeric(WeekendAlcohol),
    Health_num      = as.numeric(Health),
    MeduNum         = as.numeric(MotherEducation),
    FeduNum         = as.numeric(FatherEducation)
  ) %>%
  select(Pass_Binary, Grade_Period1, Grade_Period2,
         StudyTime_num, PastFailures, Absences,
         MeduNum, FeduNum, SchoolSup_num, WantsHigher_num,
         Internet_num, Dalc_num, Walc_num, Sex_num, Age,
         TravelTime_num, Health_num) %>%
  na.omit()


# ============================================================
# TRAIN / TEST SPLIT (80/20)
# ============================================================

set.seed(42)
n       <- nrow(model_df)
train_i <- sample(seq_len(n), size = floor(0.8 * n))
train   <- model_df[train_i, ]
test    <- model_df[-train_i, ]

cat(sprintf("Training set : %d rows\n", nrow(train)))
cat(sprintf("Test set     : %d rows\n", nrow(test)))
cat(sprintf("Positive (Pass) in test: %.1f%%\n",
            mean(test$Pass_Binary) * 100))


# ============================================================
# MODEL A : LOGISTIC REGRESSION
# ============================================================

cat("\n------------------------------------------------------------\n")
cat("MODEL A: Logistic Regression — Pass/Fail Classification\n")
cat("------------------------------------------------------------\n")

logit_model <- glm(Pass_Binary ~ .,
                   data   = train,
                   family = binomial(link = "logit"))

cat("\nModel Summary:\n")
print(summary(logit_model))

# Predictions
logit_probs <- predict(logit_model, newdata = test, type = "response")
logit_preds <- ifelse(logit_probs >= 0.5, 1, 0)

# Confusion Matrix
cm_logit <- table(Predicted = logit_preds, Actual = test$Pass_Binary)
cat("\nConfusion Matrix (Logistic Regression):\n")
print(cm_logit)

# Metrics
TP <- cm_logit["1","1"]; FP <- cm_logit["1","0"]
TN <- cm_logit["0","0"]; FN <- cm_logit["0","1"]

accuracy_lr  <- (TP + TN) / sum(cm_logit)
precision_lr <- TP / (TP + FP)
recall_lr    <- TP / (TP + FN)
f1_lr        <- 2 * precision_lr * recall_lr / (precision_lr + recall_lr)

cat(sprintf("\n  Accuracy  : %.4f (%.1f%%)\n", accuracy_lr,  accuracy_lr * 100))
cat(sprintf("  Precision : %.4f\n",             precision_lr))
cat(sprintf("  Recall    : %.4f\n",             recall_lr))
cat(sprintf("  F1-Score  : %.4f\n",             f1_lr))


# ============================================================
# ROC CURVE (manual using base R)
# ============================================================

cat("\nGenerating ROC Curve...\n")

# Sort by predicted probability descending
roc_df <- data.frame(
  actual = test$Pass_Binary,
  prob   = logit_probs
) %>%
  arrange(desc(prob)) %>%
  mutate(
    TP_cum  = cumsum(actual == 1),
    FP_cum  = cumsum(actual == 0),
    TPR     = TP_cum / sum(actual == 1),
    FPR     = FP_cum / sum(actual == 0)
  )

# AUC (trapezoidal approximation)
auc_lr <- sum(diff(roc_df$FPR) * (roc_df$TPR[-nrow(roc_df)] +
                                    roc_df$TPR[-1]) / 2)
auc_lr <- abs(auc_lr)
cat(sprintf("  AUC-ROC   : %.4f\n", auc_lr))

p_roc <- ggplot(roc_df, aes(x = FPR, y = TPR)) +
  geom_path(color = "#2166AC", linewidth = 1.1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed",
              color = "gray50", linewidth = 0.7) +
  annotate("text", x = 0.6, y = 0.3,
           label = sprintf("AUC = %.3f", auc_lr),
           size = 5, fontface = "bold", color = "#2166AC") +
  labs(
    title    = "ROC Curve — Logistic Regression (Pass/Fail)",
    subtitle = "True Positive Rate vs False Positive Rate",
    x        = "False Positive Rate (1 – Specificity)",
    y        = "True Positive Rate (Sensitivity)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40")
  )

ggsave(file.path(plot_dir, "22_roc_curve_logistic.png"),
       plot = p_roc, width = 7, height = 6, dpi = 150, bg = "white")
cat("  ✔ Saved: plots/22_roc_curve_logistic.png\n")


# ============================================================
# MODEL B : K-NEAREST NEIGHBORS (KNN)
# ============================================================

cat("\n------------------------------------------------------------\n")
cat("MODEL B: K-Nearest Neighbors (KNN)\n")
cat("------------------------------------------------------------\n")

# Normalize features for KNN
normalize <- function(x) (x - min(x)) / (max(x) - min(x) + 1e-8)

feature_cols <- c("Grade_Period1", "Grade_Period2", "StudyTime_num",
                  "PastFailures", "Absences", "MeduNum", "FeduNum",
                  "Dalc_num", "Walc_num", "Age")

train_norm <- train %>% mutate(across(all_of(feature_cols), normalize))
test_norm  <- test  %>% mutate(across(all_of(feature_cols), normalize))

train_X <- train_norm[, feature_cols]
test_X  <- test_norm[, feature_cols]
train_y <- factor(train$Pass_Binary)
test_y  <- factor(test$Pass_Binary)

# Try multiple K values
k_values   <- c(1, 3, 5, 7, 11, 15, 21)
knn_results <- lapply(k_values, function(k) {
  pred <- knn(train = train_X, test = test_X, cl = train_y, k = k)
  acc  <- mean(pred == test_y)
  data.frame(K = k, Accuracy = round(acc, 4))
}) %>% bind_rows()

cat("\nKNN Accuracy for different K values:\n")
print(knn_results)

best_k   <- knn_results$K[which.max(knn_results$Accuracy)]
best_acc <- max(knn_results$Accuracy)
cat(sprintf("\nBest K = %d  |  Best Accuracy = %.2f%%\n", best_k, best_acc * 100))

# Final KNN with best K
knn_best_preds <- knn(train = train_X, test = test_X,
                      cl = train_y, k = best_k)

cm_knn <- table(Predicted = knn_best_preds, Actual = test_y)
cat("\nConfusion Matrix (KNN, K =", best_k, "):\n")
print(cm_knn)

TP_k <- cm_knn["1","1"]; FP_k <- cm_knn["1","0"]
TN_k <- cm_knn["0","0"]; FN_k <- cm_knn["0","1"]

accuracy_knn  <- (TP_k + TN_k) / sum(cm_knn)
precision_knn <- TP_k / (TP_k + FP_k)
recall_knn    <- TP_k / (TP_k + FN_k)
f1_knn        <- 2 * precision_knn * recall_knn / (precision_knn + recall_knn)

cat(sprintf("  Accuracy  : %.4f (%.1f%%)\n", accuracy_knn,  accuracy_knn * 100))
cat(sprintf("  Precision : %.4f\n",          precision_knn))
cat(sprintf("  Recall    : %.4f\n",          recall_knn))
cat(sprintf("  F1-Score  : %.4f\n",          f1_knn))


# ============================================================
# KNN – K vs ACCURACY PLOT
# ============================================================

p_knn <- ggplot(knn_results, aes(x = K, y = Accuracy)) +
  geom_line(color = "#D62728", linewidth = 1.1) +
  geom_point(size = 3.5, color = "#D62728") +
  geom_point(data = knn_results[knn_results$K == best_k, ],
             aes(x = K, y = Accuracy), size = 6,
             color = "#2CA02C", shape = 18) +
  geom_text(aes(label = sprintf("%.1f%%", Accuracy * 100)),
            vjust = -0.8, size = 3.3) +
  annotate("text", x = best_k, y = best_acc - 0.03,
           label = paste("Best K =", best_k), color = "#2CA02C",
           fontface = "bold", size = 4) +
  scale_y_continuous(labels = scales::percent, limits = c(0.5, 1.0)) +
  scale_x_continuous(breaks = k_values) +
  labs(
    title    = "KNN Classifier — K Value vs Accuracy",
    subtitle = "Green diamond = best K",
    x        = "Number of Neighbors (K)",
    y        = "Test Accuracy"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, color = "gray40")
  )

ggsave(file.path(plot_dir, "23_knn_k_vs_accuracy.png"),
       plot = p_knn, width = 8, height = 5, dpi = 150, bg = "white")
cat("  ✔ Saved: plots/23_knn_k_vs_accuracy.png\n")


# ============================================================
# MODEL COMPARISON TABLE
# ============================================================

cat("\n==========================================================\n")
cat("        CLASSIFICATION MODEL COMPARISON\n")
cat("==========================================================\n")

model_comparison <- data.frame(
  Model     = c("Logistic Regression", sprintf("KNN (K=%d)", best_k)),
  Accuracy  = round(c(accuracy_lr,  accuracy_knn),  4),
  Precision = round(c(precision_lr, precision_knn), 4),
  Recall    = round(c(recall_lr,    recall_knn),    4),
  F1_Score  = round(c(f1_lr,        f1_knn),        4)
)
print(model_comparison, row.names = FALSE)

write.csv(model_comparison, "../output/classification_model_comparison.csv",
          row.names = FALSE)
cat("\n✔ Model Comparison saved to output/classification_model_comparison.csv\n")
cat("\n✔ Predictive Modeling Complete!\n")
