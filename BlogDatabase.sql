IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ArticleTag]') AND type in (N'U'))
DROP TABLE [dbo].[ArticleTag]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Comment]') AND type in (N'U'))
DROP TABLE [dbo].[Comment]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Article]') AND type in (N'U'))
DROP TABLE [dbo].[Article]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tag]') AND type in (N'U'))
DROP TABLE dbo.Tag
GO

--Creating Tables

CREATE TABLE dbo.Tag (
		TagId bigint PRIMARY KEY IDENTITY NOT NULL, 
		Content varchar(255) NOT NULL,
)
GO

CREATE TABLE dbo.Article(  
        ArticleId bigint IDENTITY(1,1) NOT NULL,
        Title varchar (255) NOT NULL,
        Article varchar(max) NOT NULL, 
        CreateDate date NULL,
		ViewCount bigint NOT NULL,
		CHECK (CONVERT(varchar, CreateDate /*Can't post a blog on Christmas Eve*/
		)<> '2021-12-24'), 
 CONSTRAINT PK_Article PRIMARY KEY CLUSTERED 
(
        ArticleID ASC
) 
)ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


CREATE TABLE dbo.Comment(
		CommentId bigint NOT NULL, 
		ArticleId bigint NOT NULL,
		ParentId bigint NULL, 
		Comment varchar(max) NULL,
		CommentDate date NULL,
		PRIMARY KEY (CommentId),
		FOREIGN KEY (ArticleId) REFERENCES dbo.Article(ArticleId),
		FOREIGN KEY (ParentId) REFERENCES dbo.Comment(CommentId)
) 
GO


CREATE TABLE dbo.ArticleTag(
		ArticleId bigint NOT NULL,
		TagId bigint NOT NULL,
		FOREIGN KEY (ArticleId) REFERENCES dbo.Article(ArticleId),
		FOREIGN KEY (TagId) REFERENCES dbo.Tag(TagId),
		PRIMARY KEY (ArticleID, TagId)
)
GO

--Tag insertions
INSERT INTO dbo.Tag (Content) Values ('food');
INSERT INTO dbo.Tag (Content) Values ('italian');
INSERT INTO dbo.Tag (Content) Values ('politics');
INSERT INTO dbo.Tag (Content) Values ('origins');
GO

--Article insertions

INSERT INTO dbo.Article (Title, Article, CreateDate, ViewCount) VALUES ('Food is good', 'Food is very good, especially pizza', '2021-04-24', 256);
INSERT INTO dbo.Article (Title, Article, CreateDate, ViewCount) VALUES ('CSUN', 'CSUN is a very good school for computer science majors.', '2021-04-24', 750);
INSERT INTO dbo.Article (Title, Article, CreateDate, ViewCount) VALUES ('Lorem Itsum', 'suscipit adipiscing bibendum est ultricies integer quis auctor elit sed vulputate mi sit amet mauris commodo quis imperdiet massa tincidunt nunc pulvinar sapien et ligula ullamcorper malesuada proin libero nunc consequat interdum varius sit amet mattis vulputate enim nulla aliquet porttitor lacus luctus accumsan tortor posuere ac ut consequat semper viverra nam libero justo laoreet sit amet cursus sit amet dictum sit amet justo donec enim diam vulputate ut pharetra sit amet aliquam id diam maecenas ultricies mi eget mauris pharetra et ultrices neque ornare aenean euismod elementum nisi quis eleifend quam adipiscing vitae proin sagittis nisl rhoncus mattis rhoncus', '2021-04-23', 750);
INSERT INTO dbo.Article (Title, Article, CreateDate, ViewCount) VALUES ('Presidents', 'Joe Biden is the 46th President.', '2021-04-23', 500);
INSERT INTO dbo.Article (Title, Article, CreateDate, ViewCount) VALUES ('Good Movies', 'Star Wars is a good movie', '2021-12-23', 500);
GO

--Comment insertions

INSERT INTO dbo.Comment	VALUES (1, 1, NULL, 'That was a good article!', '2021-04-24');
INSERT INTO dbo.Comment	VALUES (2, 1, 1, 'I disagree', '2021-04-24');
INSERT INTO dbo.Comment	VALUES (3, 2, NULL, 'That was a bad article!', '2021-04-24');
GO

-- ArticleTag insertions

INSERT INTO dbo.ArticleTag VALUES (1,1);
INSERT INTO dbo.ArticleTag VALUES (1,2);
INSERT INTO dbo.ArticleTag VALUES (1,3);
INSERT INTO dbo.ArticleTag VALUES (2,1);
INSERT INTO dbo.ArticleTag VALUES (2,2);
INSERT INTO dbo.ArticleTag VALUES (2,3);
INSERT INTO dbo.ArticleTag VALUES (3,3);
INSERT INTO dbo.ArticleTag VALUES (4,3);
GO

--Retrieve all today's comments
SELECT * FROM dbo.Comment WHERE CommentDate = '2021-04-24';
GO

--Retrieve all comments from today's article(s)

SELECT Comment FROM dbo.Comment INNER JOIN dbo.Article ON dbo.Comment.ArticleId = dbo.Article.ArticleId WHERE dbo.Article.CreateDate = '2021-04-24';
GO

--Select Article with the most views

SELECT * FROM dbo.Article WHERE ViewCount = (SELECT MAX(ViewCount) FROM dbo.Article);
GO

--Select Articles with more than 500 characters

SELECT Title As ArticleWithALotofCharacters FROM dbo.Article WHERE LEN(Article) > 500;
GO

--Select Comments without any children

SELECT CommentId AS CommentIDWithoutChildren FROM dbo.Comment WHERE (SELECT ParentId FROM dbo.Comment WHERE ParentId IS NOT NULL) <> CommentId;
GO

--Select Tags with the keyword "italian"

SELECT Content AS Keyword FROM dbo.Tag WHERE CHARINDEX('italian', Content) > 0;
GO

--Select Articles without any comments

SELECT Article FROM dbo.Article LEFT OUTER JOIN dbo.Comment ON dbo.ARTICLE.ArticleId = dbo.Comment.ArticleId WHERE dbo.Comment.ArticleId is null;
GO

--Selects ArticleID with the most tags (keywords)

SELECT TOP 1 ArticleId FROM dbo.ArticleTag GROUP BY ArticleId ORDER BY COUNT(ArticleId) DESC;
GO

--Selects Article ID's that have 3 or more tags (keywords)

SELECT ArticleId AS InCommon FROM dbo.ArticleTag WHERE TagId IN (SELECT TagId FROM dbo.ArticleTag GROUP BY TagId HAVING COUNT(TagId) > 2);
GO

--Selects Comment with Greatest Depth

WITH DepthCount(parent, child, Depth)
AS ( SELECT ParentId, CommentId, 0 AS Depth
	FROM dbo.Comment 
	WHERE ParentId IS NULL
	UNION ALL
	SELECT ParentId, CommentId, Depth + 1
	FROM dbo.Comment
	INNER JOIN DepthCount
	ON dbo.Comment.ParentId = DepthCount.child)
SELECT TOP 1 child AS CommentIDWithMostDepth, Depth FROM DepthCount ORDER BY Depth DESC;
GO

--Update ViewCount

UPDATE dbo.Article SET ViewCount = 800 WHERE ArticleId = 1;
GO

SELECT Title FROM dbo.Article WHERE ViewCount > 200;
GO

--Gets the average view count for the month of April

SELECT AVG(ViewCount) AS AverageViewCountForThisMonth FROM dbo.Article WHERE CreateDate BETWEEN '2021-04-01' AND '2021-05-01';
GO