-- Step 1
CREATE TABLE Albums
(
  Title VARCHAR NOT NULL,
  Artist VARCHAR NOT NULL,
  Price FLOAT NOT NULL,
  CONSTRAINT PK_Albums PRIMARY KEY (Title, Artist)
);

CREATE TABLE Instruments
(
  Kind VARCHAR NOT NULL,
  Specifics VARCHAR NOT NULL,
  CONSTRAINT PK_Instruments PRIMARY KEY (Kind)
);

CREATE TABLE Posts
(
  Post_Id INT NOT NULL,
  Kind VARCHAR NOT NULL,
  CONSTRAINT PK_Posts PRIMARY KEY (Post_Id),
  CONSTRAINT FK_Posts_Instruments FOREIGN KEY (Kind) REFERENCES Instruments(Kind)
);

CREATE TABLE Likes
(
  Kind VARCHAR NOT NULL,
  Post_Id INT NOT NULL,
  CONSTRAINT FK_Likes_Posts FOREIGN KEY (Post_Id) REFERENCES Posts(Post_Id),
  CONSTRAINT FK_Likes_Instruments FOREIGN KEY (Kind) REFERENCES Instruments(Kind)
);

-- Copy data from csv
COPY albums
FROM 'data\albums.csv' 
DELIMITER ','
CSV Header;

COPY instruments
FROM 'data\instruments.csv' 
DELIMITER ','
CSV Header;

COPY posts
FROM 'data\posts.csv' 
DELIMITER ','
CSV Header;

COPY likes
FROM 'data\likes.csv' 
DELIMITER ','
CSV Header;

-- Step 2
CREATE FUNCTION GetAveragePrice(ArtistName varchar) RETURNS float
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT
    RETURN (SELECT AVG(Price) FROM Albums WHERE Albums.artist = ArtistName);


SELECT Title FROM Albums
WHERE Price > GetAveragePrice(Artist);

-- Step 3
SELECT kind, COUNT(*) As number_of_likes FROM Likes
GROUP BY kind;

-- Step 4
SELECT instruments.specifics, likes.Post_Id FROM instruments, likes
WHERE instruments.kind = likes.kind;

-- Step 5
CREATE VIEW PostQuantities
As SELECT instruments.kind, instruments.specifics, COUNT(posts.Post_Id) AS number_of_post FROM posts, instruments
WHERE instruments.kind = posts.kind
GROUP BY instruments.kind;

SELECT * FROM PostQuantities;

SELECT PostQuantities.specifics, ((COUNT(likes.Post_Id) * 1.0) / number_of_post) AS average_likes_per_post FROM PostQuantities, likes
WHERE likes.kind = PostQuantities.kind
GROUP BY PostQuantities.specifics, number_of_post;