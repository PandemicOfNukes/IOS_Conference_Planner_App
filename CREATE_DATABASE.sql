CREATE DATABASE ProjetoP3
CREATE TABLE Users (
    UserID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Email VARCHAR(255),
    NomeCompleto VARCHAR(255),
    Username VARCHAR(255),
    Passwd VARCHAR(255),
    IsAdmin TINYINT(1),
    CanSpeak TINYINT(1)
);

CREATE TABLE Articles (
    ArticleID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255),
    Author VARCHAR(255),
    Content VARCHAR(255),
    PDF VARCHAR(255)
);

CREATE TABLE Schedules (
    ScheduleID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    TrackName VARCHAR(255),
    ContentResumo VARCHAR(255),
    SchedDay DATE,
    StartTime TIME,
    EndTime TIME,
    Room VARCHAR(255),
    ArticleID INT NOT NULL,
    CONSTRAINT FK_Schedules_Article FOREIGN KEY (ArticleID) REFERENCES Articles(ArticleID)
);

CREATE TABLE Perguntas (
    PerguntaID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    ArticleID INT,
    UserID INT,
    Pergunta VARCHAR(255),
    CONSTRAINT FK_Perguntas_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Perguntas_Article FOREIGN KEY (ArticleID) REFERENCES Articles(ArticleID)
);