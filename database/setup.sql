-- DROP OLD TABLES IF ANY
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Symptom;
DROP TABLE IF EXISTS Condition;
DROP TABLE IF EXISTS SymptomCheckResult;
DROP TABLE IF EXISTS KnowledgeBase;
DROP TABLE IF EXISTS Feedback;
DROP TABLE IF EXISTS AlModel;
DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS Admin;
DROP TABLE IF EXISTS SessionHistory;

-- USER TABLE
CREATE TABLE User (
    UserID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT,
    Email TEXT UNIQUE,
    Password TEXT,
    Age INTEGER,
    Gender TEXT,
    Address TEXT,
    PhoneNumber TEXT,
    PreferredLanguage TEXT,
    RegistrationDate TEXT,
    LastLogin TEXT,
    IsVerified INTEGER,
    Role TEXT,
    MedicalHistory TEXT
);

-- SYMPTOM TABLE
CREATE TABLE Symptom (
    SymptomID INTEGER PRIMARY KEY AUTOINCREMENT,
    SymptomName TEXT,
    SymptomCategory TEXT,
    Description TEXT,
    SeverityLevel TEXT,
    CommonAssociatedConditions TEXT,
    CreatedDate TEXT,
    LastUpdated TEXT,
    PopularityIndex INTEGER
);

-- CONDITION TABLE
CREATE TABLE Condition (
    ConditionID INTEGER PRIMARY KEY AUTOINCREMENT,
    ConditionName TEXT,
    Description TEXT,
    Category TEXT,
    RiskFactors TEXT,
    CommonSymptoms TEXT,
    DiagnosticTests TEXT,
    RecommendedActions TEXT,
    SeverityLevel TEXT,
    PreventionTips TEXT,
    TreatmentOptions TEXT
);

-- SYMPTOM CHECK RESULT
CREATE TABLE SymptomCheckResult (
    ResultID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    ConditionID INTEGER,
    ReportedSymptoms TEXT,
    PredictedCondition TEXT,
    ConfidenceScore REAL,
    DateChecked TEXT,
    SuggestedNextSteps TEXT,
    Notes TEXT,
    FollowUpDate TEXT,
    RiskLevel TEXT,
    FOREIGN KEY(UserID) REFERENCES User(UserID),
    FOREIGN KEY(ConditionID) REFERENCES Condition(ConditionID)
);

-- KNOWLEDGE BASE
CREATE TABLE KnowledgeBase (
    EntryID INTEGER PRIMARY KEY AUTOINCREMENT,
    SymptomID INTEGER,
    ConditionID INTEGER,
    CorrelationStrength REAL,
    CreatedBy TEXT,
    LastUpdatedBy TEXT,
    EvidenceSource TEXT,
    Notes TEXT,
    FOREIGN KEY(SymptomID) REFERENCES Symptom(SymptomID),
    FOREIGN KEY(ConditionID) REFERENCES Condition(ConditionID)
);

-- FEEDBACK
CREATE TABLE Feedback (
    FeedbackID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    ResultID INTEGER,
    FeedbackText TEXT,
    Rating INTEGER,
    SuggestionType TEXT,
    FeedbackDate TEXT,
    Status TEXT,
    FOREIGN KEY(UserID) REFERENCES User(UserID),
    FOREIGN KEY(ResultID) REFERENCES SymptomCheckResult(ResultID)
);

-- AI MODEL
CREATE TABLE AlModel (
    ModelID INTEGER PRIMARY KEY AUTOINCREMENT,
    ModelName TEXT,
    ModelType TEXT,
    TrainingDataSource TEXT,
    LastTrainedDate TEXT,
    ModelAccuracy REAL,
    Version TEXT,
    PerformanceMetrics TEXT,
    IsActive INTEGER,
    LastDeployedDate TEXT
);

-- NOTIFICATION
CREATE TABLE Notification (
    NotificationID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    Title TEXT,
    Message TEXT,
    NotificationType TEXT,
    SentDateTime TEXT,
    IsRead INTEGER,
    ActionLink TEXT,
    FOREIGN KEY(UserID) REFERENCES User(UserID)
);

-- ADMIN TABLE
CREATE TABLE Admin (
    AdminID INTEGER PRIMARY KEY AUTOINCREMENT,
    Username TEXT,
    Password TEXT,
    Email TEXT,
    Role TEXT,
    Permissions TEXT,
    CreatedDate TEXT,
    LastLogin TEXT,
    IsActive INTEGER
);

-- SESSION HISTORY
CREATE TABLE SessionHistory (
    SessionID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    SessionDate TEXT,
    SymptomsEntered TEXT,
    PredictedConditions TEXT,
    ConfidenceScores TEXT,
    Duration TEXT,
    FollowUpRecommendations TEXT,
    ActionsTaken TEXT,
    FOREIGN KEY(UserID) REFERENCES User(UserID)
);

-- INSERT DUMMY USERS
INSERT INTO User (Name, Email, Password, Age, Gender, Address, PhoneNumber, PreferredLanguage, RegistrationDate, LastLogin, IsVerified, Role, MedicalHistory)
VALUES 
('Alice Smith', 'alice@example.com', 'pbkdf2:sha256:260000$test123', 28, 'Female', '123 Main St', '1234567890', 'English', '2024-01-01', NULL, 1, 'Patient', 'Asthma'),
('Bob Johnson', 'bob@example.com', 'pbkdf2:sha256:260000$test123', 35, 'Male', '456 Elm St', '9876543210', 'English', '2024-01-02', NULL, 1, 'Admin', '');

-- INSERT SYMPTOMS
INSERT INTO Symptom (SymptomName, SymptomCategory, Description, SeverityLevel, CommonAssociatedConditions, CreatedDate, LastUpdated, PopularityIndex)
VALUES 
('Fever', 'General', 'High body temperature', 'Moderate', 'Flu, COVID-19', '2024-01-01', '2024-01-01', 90),
('Cough', 'Respiratory', 'Dry or wet cough', 'Low', 'Flu, Asthma', '2024-01-01', '2024-01-01', 85),
('Headache', 'General', 'Pain in the head', 'Low', 'Migraine, Cold', '2024-01-01', '2024-01-01', 80);

-- INSERT CONDITIONS
INSERT INTO Condition (ConditionName, Description, Category, RiskFactors, CommonSymptoms, DiagnosticTests, RecommendedActions, SeverityLevel, PreventionTips, TreatmentOptions)
VALUES 
('Flu', 'Influenza virus infection', 'Infectious', 'Cold weather, weak immunity', 'Fever, Cough', 'Nasal swab', 'Rest, hydrate', 'Moderate', 'Vaccination', 'Paracetamol'),
('Migraine', 'Neurological headache', 'Neurological', 'Stress, light', 'Headache', 'Brain scan', 'Painkillers, dark room', 'Low', 'Avoid triggers', 'Ibuprofen');

-- INSERT FEEDBACK
INSERT INTO Feedback (UserID, ResultID, FeedbackText, Rating, SuggestionType, FeedbackDate, Status)
VALUES 
(1, 1, 'Helpful diagnosis', 5, 'Improvement', '2024-01-10', 'Pending');

-- INSERT AI MODEL
INSERT INTO AlModel (ModelName, ModelType, TrainingDataSource, LastTrainedDate, ModelAccuracy, Version, PerformanceMetrics, IsActive, LastDeployedDate)
VALUES 
('DecisionTreeV1', 'Classification', 'Symptom-Condition Dataset', '2024-01-01', 92.5, 'v1.0', 'Precision: 91, Recall: 93', 1, '2024-01-01');
