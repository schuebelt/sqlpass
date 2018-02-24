# Schritt 0: Pakete laden --------------------------------------------------------------------------------------------------
require(descr)
require(memisc)
require(caret)

options(warn=-1)
options(scipen=999)


# Schritt 1: DB-Verbindung und Lesen der Daten -----------------------------------------------------------------------------

# Kundendaten wurden zuvor in SQL Server eingelesen
# Quelle: https://www.ibm.com/communities/analytics/watson-analytics-blog/predictive-insights-in-the-telco-customer-churn-data-set/
# Bei 11 Kunden fehlender Wert bei TotalCharges, aber Wert bei MonthlyCharges. Bei diesen Kunden wurde TotalCharges=MonthlyCharges 
# gesetzt, da diese in der tenure-Spalte allesamt den Wert 0 aufweisen.

# RevoScaleR Datenobjekt definieren
customer_sql <- RxSqlServerData(sqlQuery = "SELECT * FROM dbo.Customers",
                connectionString = "Driver=SQL Server;
                Server=DESKTOP-NDTI10F; 
                Database=Telco;
                Trusted_Connection=Yes")

# RevoScaleR-Datenobjekt als R-Dataframe importieren
df <- rxImport(customer_sql)


# Schritt 2:  Operationalisierung -------------------------------------------------------------------------------------------
str(df)
summary(df)
freq(df$Churn)

# Kreuztabellen für kategoriale Merkmale
crosstab(df$gender,df$Churn,prop.r=T)  
crosstab(df$SeniorCitizen,df$Churn,prop.r=T)
crosstab(df$Partner,df$Churn,prop.r=T)
crosstab(df$Dependents,df$Churn,prop.r=T)
crosstab(df$InternetService,df$Churn,prop.r=T) 
crosstab(df$PhoneService,df$Churn,prop.r=T) 
crosstab(df$MultipleLines,df$Churn,prop.r=T)
crosstab(df$OnlineSecurity,df$Churn,prop.r=T) 
crosstab(df$OnlineBackup,df$Churn,prop.r=T) 
crosstab(df$DeviceProtection,df$Churn,prop.r=T) 
crosstab(df$TechSupport,df$Churn,prop.r=T)
crosstab(df$StreamingTV,df$Churn,prop.r=T) 
crosstab(df$StreamingMovies,df$Churn,prop.r=T) 
crosstab(df$Contract,df$Churn,prop.r=T) 
crosstab(df$PaperlessBilling,df$Churn,prop.r=T) 
crosstab(df$PaymentMethod,df$Churn,prop.r=T) 

# Rekodierungen  
df$churn <- recode(df$Churn, 0 <- "No", 1 <- "Yes")
df$Churn <- NULL

df$totalcharges <- as.numeric(df$TotalCharges)
df$TotalCharges <- NULL

# alle übrigen Prädiktoren im chr-Format werden von R automatisch in kategorialer Form in das Modell eingeführt


# Schritt 3: Train-Test-Split ----------------------------------------------------------------------------------------------
set.seed(42)
inTrain <- createDataPartition(y = df$churn, p = .80,list = FALSE)
df.train <- df[ inTrain,]
df.test  <- df[-inTrain,]


# Schritt 4: Trainieren des Prädiktiven Modells -----------------------------------------------------------------------------
fit <- train(churn ~ ., data=df.train[,-1], method="glm", family="binomial")


# Schritt 5: Modellevaluation -----------------------------------------------------------------------------------------------
df.test$prob <- predict(fit, df.test,type = "prob")[,2]
l = .5 # Default
df.test$pred<-recode(df.test$prob,0<-range(min,l), otherwise = 1) 
confusionMatrix(data = df.test$pred, df.test$churn, positive = "1")


