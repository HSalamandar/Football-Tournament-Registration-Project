Create Database Mile2

GO

CREATE PROCEDURE createALLTables
AS
BEGIN
CREATE TABLE SystemUser(
Username varchar(20),
Syspassword varchar(20),                
PRIMARY KEY (Username),
);

CREATE TABLE Stadium(
StadID int IDENTITY(1,1) PRIMARY KEY,
StadName varchar(20),
StadLocation varchar(20),
StadCapacity int,                                   
StadStatus INT DEFAULT 1
);

CREATE TABLE Club(
ClubID int IDENTITY(1,1) PRIMARY KEY,
ClubName varchar(20),
ClubLocation varchar(20),
);

CREATE TABLE SystemAdmin(
Sysid int IDENTITY(1,1) PRIMARY KEY,                           
Adminname varchar(20),
Username varchar(20),
FOREIGN KEY (Username) REFERENCES SystemUser(Username)
ON UPDATE CASCADE ON DELETE CASCADE,
);

CREATE TABLE SportsAssociationManager(
SAM_ID int IDENTITY(1,1) PRIMARY KEY,
SAM_name varchar(20),
Username varchar(20),
FOREIGN KEY (Username) REFERENCES SystemUser(Username)
ON UPDATE CASCADE
ON DELETE CASCADE,
);

CREATE TABLE Match(                 
MatchID int IDENTITY(1,1) PRIMARY KEY,
Start_Time DATETIME,                                     
End_Time DATETIME,						         
Host_club_ID int,
Guest_club_ID int,
Stadium_ID int,
FOREIGN KEY (Stadium_ID) REFERENCES Stadium(StadID),
FOREIGN KEY (Guest_club_ID) REFERENCES Club(ClubID), 
FOREIGN KEY (Host_club_ID) REFERENCES Club(ClubID)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ClubRepresentative(
RepID int IDENTITY(1,1) PRIMARY KEY,
RepName varchar(20),
Rep_club_ID int,
Username varchar(20),
FOREIGN KEY (Username) REFERENCES SystemUser(Username)
ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (Rep_club_ID) REFERENCES Club(ClubID)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE StadiumManager(
ManagerID int IDENTITY(1,1) PRIMARY KEY,
ManagerName varchar(20),
Stad_id int,
Manusername varchar(20),
FOREIGN KEY (Stad_id) REFERENCES Stadium(StadID)
ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (Manusername) REFERENCES SystemUser(Username)
ON UPDATE CASCADE ON DELETE CASCADE,
);


CREATE TABLE Ticket(
TicketID int IDENTITY(1,1) PRIMARY KEY,
TicketStatus INT DEFAULT 1,
MatchID int,
FOREIGN KEY (MatchID) REFERENCES Match(MatchID)
ON UPDATE CASCADE ON DELETE CASCADE,
);


CREATE TABLE Fan(
NationalID int NOT NULL,
FanName varchar(20),
FanBirthDate DATETIME,
FanAddress varchar(20),
FanPhone int,
Fanusername varchar(20),
status INT DEFAULT 1,
PRIMARY KEY (NationalID),
FOREIGN KEY (Fanusername) REFERENCES SystemUser(Username)
ON UPDATE CASCADE ON DELETE CASCADE,
);

CREATE TABLE TicketBuyingTransactions(
Fan_nationalID int,
Ticketid int,
FOREIGN KEY (Fan_nationalID) REFERENCES Fan(NationalID)
ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (Ticketid) REFERENCES Ticket(TicketID)
ON UPDATE CASCADE ON DELETE CASCADE,
);

CREATE TABLE HostRequest(
ID int IDENTITY(1,1) PRIMARY KEY,
Representative_ID int,
Manager_ID int,
Match_ID int,
Hoststatus varchar(20) DEFAULT 'Unhandled',
FOREIGN KEY (Representative_ID) REFERENCES ClubRepresentative(RepID),
FOREIGN KEY (Manager_ID) REFERENCES StadiumManager(ManagerID),
FOREIGN KEY (Match_ID) REFERENCES Match(MatchID)
ON UPDATE CASCADE ON DELETE CASCADE
);
END


SELECT * FROM Club
GO

CREATE PROCEDURE dropAllTables
AS
BEGIN
DROP TABLE TicketBuyingTransactions
DROP TABLE Ticket
DROP TABLE SystemAdmin
DROP TABLE SportsAssociationManager
DROP TABLE HostRequest
DROP TABLE Fan
DROP TABLE ClubRepresentative
DROP TABLE StadiumManager
DROP TABLE Match
DROP TABLE Club
DROP TABLE SystemUser
DROP TABLE Stadium
END

GO

CREATE PROCEDURE  dropAllProceduresFunctionsViews
AS 
BEGIN
DROP PROCEDURE createAllTables
DROP PROCEDURE dropAllTables
DROP PROCEDURE clearAllTables
DROP VIEW allAssocManagers
DROP VIEW allClubRepresentatives
DROP VIEW allStadiumManagers
DROP VIEW allFans
DROP VIEW allMatches
DROP VIEW allTickets
DROP VIEW allCLubs
DROP VIEW allStadiums
DROP VIEW allRequests
DROP PROCEDURE addAssociationManager
DROP PROCEDURE addNewMatch
DROP PROCEDURE clubsWithNoMatches
DROP PROCEDURE deleteMatch
DROP PROCEDURE deleteMatchesOnStadium
DROP PROCEDURE addClub
DROP PROCEDURE addTicket
DROP PROCEDURE deleteClub
DROP PROCEDURE addStadium
DROP PROCEDURE deleteStadium
DROP PROCEDURE blockFan
DROP PROCEDURE unblockFan
DROP PROCEDURE addRepresentative
DROP FUNCTION viewAvailableStadiumsOn
DROP PROCEDURE addHostRequest
DROP FUNCTION allUnassignedMatches 
DROP PROCEDURE addStadiumManager
DROP FUNCTION allPendingRequests
DROP PROCEDURE acceptRequest
DROP PROCEDURE rejectRequest
DROP PROCEDURE addFan
DROP FUNCTION upcomingMatchesOfClub
DROP FUNCTION availableMatchesToAttend
DROP PROCEDURE purchaseTicket
DROP PROCEDURE updateMatchHost
DROP VIEW matchesPerTeam
DROP VIEW clubsNeverMatched
DROP FUNCTION clubsNeverPlayed
DROP FUNCTION matchWithHighestAttendance
DROP FUNCTION matchesRankedByAttendance
DROP FUNCTION requestsFromClub

END

GO
CREATE PROCEDURE clearAllTables
AS 
BEGIN
DELETE FROM TicketBuyingTransactions
DELETE FROM Ticket
DELETE FROM Match
DELETE FROM Stadium
DELETE FROM StadiumManager
DELETE FROM Fan
DELETE FROM ClubRepresentative
DELETE FROM HostRequest
DELETE FROM SportsAssociationManager
DELETE FROM SystemAdmin
DELETE FROM Club
DELETE FROM SystemUser

END

SELECT * FROM viewAvailableStadiumsOn('2023-01-10 10:00:00')

GO
CREATE VIEW allAssocManagers AS ------------ (A)
SELECT Username, SAM_name
FROM SportsAssociationManager

GO
CREATE VIEW allClubRepresentatives AS -------------- (B)
SELECT Username, RepName, ClubName
FROM ClubRepresentative, Club

GO 
CREATE VIEW allStadiumManagers AS ----------------- (C)
SELECT Manusername, ManagerName, StadName
FROM StadiumManager SM, Stadium S
WHERE S.StadID = SM.Stad_id

GO 
CREATE VIEW allFans AS ------------------- (D)
SELECT FanName, NationalID, FanBirthDate
FROM Fan

GO

CREATE VIEW allMatches AS  ----------(E) 
SELECT Match.MatchID,HostClub.ClubName AS hostClubName, Match.start_time, GuestClub.ClubName AS guestClubName
FROM Match
INNER JOIN Club AS HostClub ON HostClub.ClubID = Match.Host_club_ID
INNER JOIN Club AS GuestClub ON GuestClub.ClubID = Match.Guest_club_ID


GO

CREATE VIEW allTickets AS ---------(F)
SELECT Ticket.TicketID, HostClub.ClubName AS hostClubName, Match.start_time, GuestClub.ClubName AS guestClubName
FROM Ticket
INNER JOIN Match ON Ticket.MatchID = Match.MatchID
INNER JOIN Club AS HostClub ON HostClub.ClubID = Match.Host_club_ID
INNER JOIN Club AS GuestClub ON GuestClub.ClubID = Match.Guest_club_ID

GO 

CREATE VIEW allClubs AS ----------(G)
SELECT ClubName ,ClubLocation
FROM Club

GO    
CREATE VIEW allStadiums AS --------(h)
SELECT StadName,StadLocation,StadCapacity,StadStatus
FROM Stadium

GO
CREATE VIEW allRequests AS --------------(I)
SELECT r.RepName, m.ManagerName, h.Hoststatus, r.Username
FROM ClubRepresentative r
INNER JOIN HostRequest h ON r.RepID = h.Representative_ID
INNER JOIN StadiumManager m ON m.ManagerID = h.Manager_ID

go
SELECT * FROM allRequests

SELECT * FROM HostRequest

SELECT * FROM allStadiumManagers

SELECT * FROM ClubRepresentative

DROP VIEW allRequests
---------------------------------------------------- 2.3

GO
CREATE PROCEDURE addAssociationManager ----- (i)
(
@name varchar(20),
@username varchar(20),
@password varchar(20)
)
AS
BEGIN

IF @username = ( SELECT Username FROM SystemUser WHERE Username = @username)
    PRINT 'Username alrady exists'

ELSE

INSERT INTO SystemUser(Username, Syspassword) VALUES (@username, @password);
INSERT INTO SportsAssociationManager(SAM_name, Username) VALUES (@name, @username);

END

Drop PROCEDURE addAssociationManager
SELECT * FROM SportsAssociationManager


GO

CREATE PROCEDURE addNewMatch ------ (ii)
(
@host VARCHAR(20),
@guest VARCHAR(20),
@start DATETIME,
@end DATETIME
)
AS
BEGIN
declare @guest_Club_ID int;
declare @host_club_ID int;
set @guest_Club_ID = (select c.ClubID from Club c where c.ClubName = @guest);
set @host_club_ID = (select c.ClubID from Club c where c.ClubName = @host); 
Insert into Match (Host_club_ID, Guest_club_ID, start_time, end_time) values(@host_club_ID, @guest_Club_ID, @start, @end);
END

Drop PROCEDURE addNewMatch

SELECT * FROM  Club



 GO
 CREATE VIEW clubsWithNoMatches AS -------------(iii)
 SELECT Club.ClubName
 FROM Club
 WHERE Club.ClubID NOT IN(SELECT ClubID FROM Match)



 GO
 CREATE PROCEDURE deleteMatch ------- (iv)
(
@host_club_name varchar(20), 
@guest_club_name varchar(20)
)
AS
BEGIN
    DELETE FROM Match
    WHERE host_club_id IN (SELECT ClubID FROM Club WHERE ClubName = @host_club_name)
    AND guest_club_id IN (SELECT ClubID FROM Club WHERE ClubName = @guest_club_name);

 END

 GO

CREATE PROCEDURE deleteMatchesOnStadium --------(V)
@stadium_name varchar(20)
AS
BEGIN
    DELETE FROM Match
    WHERE Stadium_ID IN (SELECT StadID FROM Stadium WHERE StadName = @stadium_name)
    AND Start_Time > CURRENT_TIMESTAMP;
END




GO
CREATE PROCEDURE addClub -------------(VI)
(
@clubname varchar(20),
@clublocation varchar(20)
)
AS
BEGIN

INSERT INTO Club(ClubName, ClubLocation) VALUES (@clubname, @clublocation);

END

SELECT * FROM Club

GO
CREATE PROCEDURE addTicket ------------(VII)
(
@hostclub varchar(20),
@competingclub varchar(20),
@matchtime datetime
)
AS
BEGIN
INSERT INTO Ticket(ClubName, ClubLocation) VALUES (@clubname, @clublocation);

END

GO
CREATE PROCEDURE deleteCLub -----------(Viii)
(
@clubname varchar(20)

)
AS
BEGIN

DELETE FROM Club
WHERE Club.ClubName = @clubname

END

GO
CREATE PROCEDURE addStadium --------(ix)
(
@name varchar(20),
@location varchar(20),
@capacity INT
)
AS 
BEGIN 

INSERT INTO Stadium( StadName, StadLocation, StadCapacity) VALUES (@name,@location,@capacity)

END




GO
CREATE PROCEDURE deleteStadium ------------(X)
(
@name varchar(20)
)
AS
BEGIN

DELETE FROM Stadium WHERE Stadium.StadName=@name

END

GO
CREATE PROCEDURE blockFan -------(xi)
(
@NID INT
)
AS 
BEGIN

UPDATE Fan
SET status = 0
WHERE @NID = Fan.NationalID

END

GO
CREATE PROCEDURE unBlockFan ------(xii)
(
@NID INT
)
AS 
BEGIN

UPDATE Fan
SET status = 1
WHERE @NID = Fan.NationalID
END

GO
CREATE PROCEDURE addRepresentative ---------(xiii)
(
@name VARCHAR(20),
@club VARCHAR(20),
@username VARCHAR(20),
@password VARCHAR(20)
)
AS
BEGIN

DECLARE @CID INT

    SELECT @CID = C.ClubID 
    FROM Club C
    WHERE C.ClubName = @club

IF @username = ( SELECT Username FROM SystemUser WHERE Username = @username)
    PRINT 'Username alrady exists'

ELSE

INSERT INTO SystemUser(Username,Syspassword) VALUES (@username,@password)
INSERT INTO ClubRepresentative (Username,RepName,Rep_club_ID) VALUES (@username,@name,@CID)

END



GO
CREATE FUNCTION viewAvailableStadiumsOn(@dt datetime) ---- (XIV)
RETURNS TABLE
AS
return
    SELECT Stadium.StadName, Stadium.StadLocation, Stadium.StadCapacity
    FROM Stadium
    WHERE Stadium.StadID NOT IN (SELECT Match.Stadium_ID
                                FROM Match
                                WHERE Match.start_time = @dt)
                                AND Stadium.StadStatus = 1;


GO
CREATE PROCEDURE addHostRequest --------(xv)
(
@repCN VARCHAR(20),
@Stadname VARCHAR(20),
@startt DATETIME
)
AS
BEGIN
DECLARE @CID INT
DECLARE @SID INT
DECLARE @MID INT

SET @CID = (SELECT CR.RepID FROM ClubRepresentative CR INNER JOIN Club ON CR.Rep_club_ID = Club.ClubID WHERE Club.ClubName = @repCN)
SET @SID = (SELECT StadiumManager.ManagerID FROM StadiumManager INNER JOIN Stadium ON StadiumManager.Stad_id = Stadium.StadID WHERE Stadium.StadName = @Stadname)
SET @MID = (SELECT Match.MatchID FROM Match WHERE Match.start_time = @startt)

INSERT INTO HostRequest(Representative_ID, Manager_ID, Match_ID) VALUES (@CID, @SID, @MID)

END
DROP PROCEDURE addHostRequest

Exec addHostRequest 'Marco', 'yes', '2023-01-08 10:00:00'

GO
CREATE FUNCTION allUnassignedMatches(@clubname varchar(20)) --------------(xvi)
RETURNS TABLE
AS
RETURN
    SELECT c.ClubName AS 'Guest Club Name', m.Start_Time
    FROM Club AS c
    INNER JOIN Match AS m
        ON c.ClubID = m.Guest_club_ID
    WHERE m.Host_club_ID = (SELECT ClubID FROM Club WHERE ClubName = @clubName)
    AND m.Stadium_ID IS NULL;


GO
CREATE PROCEDURE addStadiumManager ----------(xvii)
(
@Mname VARCHAR(20),
@Sname VARCHAR(20),
@username VARCHAR(20),
@password VARCHAR(20)
)
AS
BEGIN

DECLARE @SMID INT

    SELECT @SMID = S.StadID
    FROM Stadium S
    WHERE S.StadName = @Sname

IF @username = ( SELECT Username FROM SystemUser WHERE Username = @username)
    PRINT 'Username alrady exists'

ELSE
    INSERT INTO SystemUser(Username,Syspassword) VALUES (@username,@password)
    INSERT INTO StadiumManager(Manusername,ManagerName,Stad_id) VALUES (@username,@Mname,@SMID)


END

DROP PROCEDURE addStadiumManager

GO
CREATE FUNCTION allPendingRequests(@username varchar(20)) ------------(XViii)
RETURNS TABLE
AS
RETURN
    SELECT
        ClubRepresentative.RepName,
        Club.ClubName,
        Match.Start_Time
    FROM HostRequest
    INNER JOIN ClubRepresentative ON HostRequest.Representative_ID = ClubRepresentative.RepID
    INNER JOIN Club ON HostRequest.Match_ID = Club.ClubID
    INNER JOIN Match ON HostRequest.Match_ID = Match.MatchID
    INNER JOIN StadiumManager ON HostRequest.Manager_ID = StadiumManager.ManagerID
    WHERE StadiumManager.Manusername = @username
    AND HostRequest.Hoststatus = 'pending';


GO
CREATE PROCEDURE acceptRequest --------(xix)
(
@username varchar(20),
@HCN varchar(20),
@GCN varchar(20),
@Starttime datetime
)
AS
BEGIN

UPDATE HostRequest
SET Hoststatus = 'Accepted'


INSERT INTO StadiumManager (ManagerName)
VALUES (@username);
INSERT INTO Club (ClubName)
VALUES (@HCN);
INSERT INTO Club (ClubName)
VALUES (@GCN);
INSERT INTO Match (Start_Time)values (@Starttime)
END


GO
CREATE PROCEDURE rejectRequest ---------(xx)
(
@username varchar(20),
@HCN varchar(20),
@GCN varchar(20),
@Starttime datetime
)
AS
BEGIN

UPDATE HostRequest
SET Hoststatus = 'Rejected'

INSERT INTO StadiumManager (ManagerName)
VALUES (@username);
INSERT INTO Club (ClubName)
VALUES (@HCN);
INSERT INTO Club (ClubName)
VALUES (@GCN);
INSERT INTO Match (Start_Time)values (@Starttime)
END

SELECT * FROM HostRequest

GO
CREATE PROCEDURE addFan --------------(xxi)
(
@NID int,
@FanN varchar(20),
@Fusername varchar(20),
@Fpass varchar(20),
@FanBirt DATETIME,
@FanAd varchar(20),
@FanP int
)
AS
BEGIN

IF @Fusername = ( SELECT Username FROM SystemUser WHERE Username = @Fusername)
	PRINT 'Username alrady exists'

ELSE
	INSERT INTO SystemUser(Username,Syspassword) VALUES (@Fusername,@Fpass)
	INSERT INTO Fan(FanName,NationalID,FanBirthDate,FanAddress,FanPhone, Fanusername) VALUES (@FanN,@NID,@FanBirt,@FanAd,@FanP, @Fusername)

END

DROP PROCEDURE addFan

SELECT * FROM Fan

GO

CREATE FUNCTION upcomingMatchesOfClub ----------------------(xxii)

(@CName VARCHAR(20))
RETURNS TABLE AS RETURN (SELECT c.ClubName AS HostClub, c1.ClubName AS GuestClub , m.Start_Time , m.End_Time, s.StadName 
FROM Match m 
INNER JOIN Club c ON m.Host_club_ID = c.ClubID
INNER JOIN Club c1 ON m.Guest_Club_ID = c1.ClubID
INNER JOIN Stadium s ON m.Stadium_ID = s.StadID 
WHERE m.Start_Time >= CURRENT_TIMESTAMP AND c.ClubName <> c1.ClubName AND (c.ClubName = @CName OR c1.ClubName = @CName)
)
go
SELECT * FROM upcomingMatchesOfClub('Marco')

INSERT INTO Match ( Start_Time, End_Time, Host_club_ID, Guest_club_ID, Stadium_ID) VALUES (	'2023-01-10 10:00:00.000',	'2023-01-10 10:30:00.000',	6,	7,	2);

GO
CREATE FUNCTION availableMatchesToAttend(@date DATETIME) ------------(xxiii)
RETURNS TABLE
AS
RETURN (
    SELECT m.MatchID, m.Start_Time, m.End_Time, m.Host_club_ID,
           c.ClubName AS HostClubName, c1.ClubName AS GuestClubName,  t.TicketID
    FROM Match m
    INNER JOIN Club c ON m.Host_club_ID = c.ClubID
    INNER JOIN Club c1 ON m.Guest_Club_ID = c1.ClubID
    INNER JOIN Ticket t ON m.MatchID = t.MatchID
    WHERE m.Start_Time >= @date
    AND t.TicketStatus = 1
)
go
SELECT * FROM availableMatchesToAttend('2023-01-10 10:00:00.000')


GO
 ------------(xxiv)    
CREATE PROCEDURE purchaseTicket
@nationalId varchar(20),
@hostClubName varchar(20),
@guestClubName varchar(20),
@startTime datetime
AS
BEGIN
    DECLARE @hostClubId int
    DECLARE @guestClubId int
    DECLARE @matchId int
    DECLARE @ticketId int

    SET @hostClubId = (SELECT Club.ClubID FROM Club WHERE Club.ClubName = @hostClubName);
    SET @guestClubId = (SELECT Club.ClubID FROM Club WHERE Club.ClubName = @guestClubName);
    SET @matchId = (SELECT Match.MatchID FROM Match
    WHERE Match.Guest_club_ID = @guestClubId AND Match.Host_club_ID = @hostClubId AND Match.Start_Time = @startTime); 


    SET @ticketId = (SELECT TOP 1 Ticket.TicketID FROM Ticket WHERE Ticket.MatchID = @matchId AND Ticket.TicketStatus = 1);

    UPDATE Ticket
    SET TicketStatus = 0
    WHERE TicketID = @ticketId

    
    INSERT INTO TicketBuyingTransactions (Fan_nationalID, TicketID)
    VALUES (@nationalId, @ticketId)
END

DROP PROCEDURE purchaseTicket

SELECT * FROM Ticket;

SELECT * FROM TicketBuyingTransactions;

INSERT INTO Ticket (MatchID, TicketStatus) VALUES (35, 1);

SELECT * FROM Match

GO
CREATE PROCEDURE updateMatchHost ------------(xxv)
(
@hostname VARCHAR(20),
@guestname VARCHAR(20),
@time DATETIME
)
AS
BEGIN
DECLARE @hostid INT
DECLARE @guestid INT

SELECT @hostid = c.ClubID,@guestid = c2.ClubID
FROM Club c,Club c2
WHERE @hostname = c.ClubName AND @guestname = c2.ClubName 

UPDATE Match
SET Host_club_ID = Guest_club_ID
WHERE @hostid = Host_club_ID AND @guestid = Guest_club_ID AND @time = Start_Time

UPDATE Match
SET Guest_club_ID = @hostid
WHERE Host_club_ID = Guest_club_ID AND Start_Time = @time
END


GO
CREATE VIEW matchesPerTeam AS ------------(xxvi)
SELECT Club.ClubName, COUNT(Match.MatchID) AS MatchesPlayed
FROM Club
INNER JOIN Match ON Club.ClubID = Match.Host_club_ID OR Club.ClubID = Match.Guest_club_ID
GROUP BY Club.ClubName;

GO


CREATE VIEW clubsNeverMatched AS ------------(xxvii)
SELECT c1.ClubName AS firstClubName, c2.ClubName AS secondClubName
FROM Club c1
CROSS JOIN Club c2
WHERE c1.ClubName != c2.ClubName
AND NOT EXISTS (
    SELECT *
    FROM Match
    WHERE (Host_club_ID = c1.ClubID AND Guest_club_ID = c2.ClubID)
    OR (Host_club_ID = c2.ClubID AND Guest_club_ID = c1.ClubID)
);

go
SELECT * FROM Stadium
SELECT * FROM Match
GO

CREATE FUNCTION clubsNeverPlayed(@clubName varchar(20)) ----------(xxviii)
RETURNS TABLE AS
RETURN
    SELECT c.ClubName
    FROM Club c
    WHERE c.ClubName NOT IN (
        SELECT c.ClubName FROM Club c WHERE c.ClubName = @clubName
        UNION
        SELECT c.ClubName FROM Club c WHERE c.ClubName = @clubName
    )


GO
CREATE FUNCTION matchWithHighestAttendance()  ------------(xxix) 
RETURNS TABLE
AS
RETURN
  SELECT HostClub.ClubName AS HostClub, GuestClub.ClubName AS GuestClub
  FROM Match
  INNER JOIN Club AS HostClub ON HostClub.ClubID = Match.Host_club_ID
  INNER JOIN Club AS GuestClub ON GuestClub.ClubID = Match.Guest_club_ID
  WHERE Match.MatchID IN (
    SELECT TOP 10 Ticket.MatchID
    FROM Ticket
    GROUP BY Ticket.MatchID
    ORDER BY COUNT(*) DESC
  )



GO
CREATE FUNCTION matchesRankedByAttendance() -------------(xxx)
RETURNS @rankedMatches TABLE (
    HostClubName VARCHAR(20),
    GuestClubName VARCHAR(20)
)
AS
BEGIN
    INSERT INTO @rankedMatches
    SELECT c1.ClubName AS HostClubName, c2.ClubName AS GuestClubName
    FROM Match m
    INNER JOIN Club c1 ON m.Host_club_ID = c1.ClubID
    INNER JOIN Club c2 ON m.Guest_club_ID = c2.ClubID
    INNER JOIN TicketBuyingTransactions tbt ON m.MatchID = tbt.Ticketid
    GROUP BY c1.ClubName, c2.ClubName
    ORDER BY COUNT(tbt.Ticketid) DESC

    RETURN
END

GO

CREATE FUNCTION requestsFromClub(@stadiumName varchar(20), @clubName varchar(20)) ------------(xxxi)
RETURNS TABLE
AS
RETURN
SELECT h.ClubName AS HostClub, g.ClubName AS GuestClub
FROM Club h
INNER JOIN ClubRepresentative r ON h.ClubID = r.Rep_club_ID
INNER JOIN Match m ON m.Host_club_ID = h.ClubID
INNER JOIN Club g ON g.ClubID = m.Guest_club_ID
INNER JOIN Stadium s ON s.StadID = m.Stadium_ID
WHERE s.StadName = @stadiumName AND h.ClubName = @clubName

go
CREATE VIEW playedMatches AS
SELECT h.ClubName AS HostClub, g.ClubName AS GuestClub, m.Start_Time, m.End_Time
FROM Club h
INNER JOIN Match m ON m.Host_club_ID = h.ClubID
INNER JOIN Club g ON g.ClubID = m.Guest_club_ID
WHERE m.Start_Time < CURRENT_TIMESTAMP




go
CREATE PROCEDURE clubRepresentativeInfo(@repName varchar(20))
AS
BEGIN
SELECT c.ClubName, c.ClubID, c.ClubLocation
FROM ClubRepresentative r
INNER JOIN Club c ON r.Rep_club_ID = c.ClubID
WHERE r.RepName = @repName
END

SELECT * FROM clubRepresentativeInfo
EXEC  clubRepresentativeInfo @repName = 'retro'





go
CREATE PROCEDURE requestStadium(@repName varchar(20), @stadiumName varchar(20))
AS
BEGIN
SELECT h.ClubName AS HostClub, g.ClubName AS GuestClub, m.Start_Time, m.End_Time, s.StadName
FROM ClubRepresentative r
INNER JOIN Club c ON r.Rep_club_ID = c.ClubID
INNER JOIN Match m ON m.Host_club_ID = c.ClubID
INNER JOIN Club h ON h.ClubID = m.Host_club_ID
INNER JOIN Club g ON g.ClubID = m.Guest_club_ID
INNER JOIN Stadium s ON s.StadID = m.Stadium_ID
WHERE m.Start_Time > CURRENT_TIMESTAMP AND r.RepName = @repName AND s.StadName = @stadiumName
END



SELECT * FROM HostRequest


DROP PROCEDURE upcomingMatches




go
CREATE PROCEDURE upcomingMatches(@repName varchar(20))
AS
BEGIN
SELECT h.ClubName AS HostClub, g.ClubName AS GuestClub, m.Start_Time, m.End_Time
FROM ClubRepresentative r
INNER JOIN Club c ON r.Rep_club_ID = c.ClubID
INNER JOIN Match m ON m.Host_club_ID = c.ClubID OR m.Guest_club_ID = c.ClubID
INNER JOIN Club h ON h.ClubID = m.Host_club_ID
INNER JOIN Club g ON g.ClubID = m.Guest_club_ID
WHERE r.RepName = @repName AND m.Start_Time > CURRENT_TIMESTAMP
END




go
CREATE PROCEDURE stadmanagerInfo(@manName varchar(20))
AS
BEGIN
SELECT s.StadName, s.StadLocation, s.StadCapacity, s.StadStatus
FROM StadiumManager m
INNER JOIN Stadium s ON m.Stad_id = s.StadID
WHERE m.ManagerName = @manName
END

EXEC stadmanagerInfo @manName = 'crota'

DROP PROCEDURE stadmanagerInfo





go
create view stadmanagerRequests as
select rep.RepName, ManagerName
from HostRequest, Match
inner join HostRequest as h on h.Match_ID = Match.MatchID
INNER JOIN ClubRepresentative AS Rep ON Rep.RepID = h.Representative_ID
INNER JOIN StadiumManager AS Manager ON Manager.ManagerID = h.Manager_ID
inner join club as c1 on c1.clubname= Match.Host_club_ID and Rep.Rep_club_ID= c1.ClubID
inner join club as c2 on c2.clubname = Match.Guest_club_ID and  Rep.Rep_club_ID= c2.ClubID

where Match.Guest_club_ID= c2.ClubID and Match.Host_club_ID= c1.ClubID 
group by Start_Time, End_Time , RepName, ManagerName

go
SELECT * FROM stadmanagerRequests

DROP VIEW stadmanagerRequests






go
SELECT * FROM HostRequest

SELECT * FROM Match

SELECT * FROM Stadium

SELECT * FROM ClubRepresentative

SELECT * FROM StadiumManager

SELECT * FROM Stadium

SELECT * FROM Match

SELECT * FROM Fan




