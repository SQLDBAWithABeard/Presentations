Use ValidationResults

GO

-- Create summary staging table

CREATE TABLE [dbachecks].[Prod_dbachecks_summary_stage](
	[TagFilter] [nvarchar](max) NULL,
	[ExcludeTagFilter] [nvarchar](max) NULL,
	[TestNameFilter] [nvarchar](max) NULL,
	[TotalCount] [int] NULL,
	[PassedCount] [int] NULL,
	[FailedCount] [int] NULL,
	[SkippedCount] [int] NULL,
	[PendingCount] [int] NULL,
	[InconclusiveCount] [int] NULL,
	[Time] [bigint] NULL,
	[TestResult] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- create summary table

CREATE TABLE [dbachecks].[Prod_dbachecks_summary](
	[SummaryID] [int] IDENTITY(1,1) NOT NULL,
	[TestDate] [date] NOT NULL,
	[TagFilter] [nvarchar](max) NULL,
	[ExcludeTagFilter] [nvarchar](max) NULL,
	[TestNameFilter] [nvarchar](max) NULL,
	[TotalCount] [int] NULL,
	[PassedCount] [int] NULL,
	[FailedCount] [int] NULL,
	[SkippedCount] [int] NULL,
	[PendingCount] [int] NULL,
	[InconclusiveCount] [int] NULL,
	[Time] [bigint] NULL,
	[TestResult] [nvarchar](max) NULL,
 CONSTRAINT [PK_Prod_dbachecks_summary] PRIMARY KEY CLUSTERED 
(
	[SummaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_summary] ADD  CONSTRAINT [DF_Prod_dbachecks_summary_TestDate]  DEFAULT (getdate()) FOR [TestDate]
GO

-- Insert trigger on summary stage table

CREATE TRIGGER [dbachecks].[Load_Prod_Summary] 
   ON   [dbachecks].[Prod_dbachecks_summary_stage]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [dbachecks].[Prod_dbachecks_summary] 
	([TagFilter], [ExcludeTagFilter], [TestNameFilter], [TotalCount], [PassedCount], [FailedCount], [SkippedCount], [PendingCount], [InconclusiveCount], [Time], [TestResult])
	SELECT [TagFilter], [ExcludeTagFilter], [TestNameFilter], [TotalCount], [PassedCount], [FailedCount], [SkippedCount], [PendingCount], [InconclusiveCount], [Time], [TestResult] FROM [dbachecks].[Prod_dbachecks_summary_stage]

END
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_summary_stage] ENABLE TRIGGER [Load_Prod_Summary]
GO


-- create a details staging table

CREATE TABLE [dbachecks].[Prod_dbachecks_detail](
	[DetailID] [int] IDENTITY(1,1) NOT NULL,
	[SummaryID] [int] NOT NULL,
	[ErrorRecord] [nvarchar](max) NULL,
	[ParameterizedSuiteName] [nvarchar](max) NULL,
	[Describe] [nvarchar](max) NULL,
	[Parameters] [nvarchar](max) NULL,
	[Passed] [bit] NULL,
	[Show] [nvarchar](max) NULL,
	[FailureMessage] [nvarchar](max) NULL,
	[Time] [bigint] NULL,
	[Name] [nvarchar](max) NULL,
	[Result] [nvarchar](max) NULL,
	[Context] [nvarchar](max) NULL,
	[StackTrace] [nvarchar](max) NULL,
 CONSTRAINT [PK_Prod_dbachecks_detail] PRIMARY KEY CLUSTERED 
(
	[DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_detail]  WITH CHECK ADD  CONSTRAINT [FK_Prod_dbachecks_detail_Prod_dbachecks_summary] FOREIGN KEY([SummaryID])
REFERENCES [dbachecks].[Prod_dbachecks_summary] ([SummaryID])
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_detail] CHECK CONSTRAINT [FK_Prod_dbachecks_detail_Prod_dbachecks_summary]
GO

-- Create detail staging table

CREATE TABLE [dbachecks].[Prod_dbachecks_detail_stage](
	[ErrorRecord] [nvarchar](max) NULL,
	[ParameterizedSuiteName] [nvarchar](max) NULL,
	[Describe] [nvarchar](max) NULL,
	[Parameters] [nvarchar](max) NULL,
	[Passed] [bit] NULL,
	[Show] [nvarchar](max) NULL,
	[FailureMessage] [nvarchar](max) NULL,
	[Time] [bigint] NULL,
	[Name] [nvarchar](max) NULL,
	[Result] [nvarchar](max) NULL,
	[Context] [nvarchar](max) NULL,
	[StackTrace] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- trigger on staging table

CREATE TRIGGER [dbachecks].[Load_Prod_Detail] 
   ON   [dbachecks].[Prod_dbachecks_detail_stage]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [dbachecks].[Prod_dbachecks_detail] 
([SummaryID],[ErrorRecord], [ParameterizedSuiteName], [Describe], [Parameters], [Passed], [Show], [FailureMessage], [Time], [Name], [Result], [Context], [StackTrace])
	SELECT 
	(SELECT MAX(SummaryID) From [dbachecks].[Prod_dbachecks_summary]),[ErrorRecord], [ParameterizedSuiteName], [Describe], [Parameters], [Passed], [Show], [FailureMessage], [Time], [Name], [Result], [Context], [StackTrace]
	FROM [dbachecks].[Prod_dbachecks_detail_stage]

END
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_detail_stage] ENABLE TRIGGER [Load_Prod_Detail]
GO