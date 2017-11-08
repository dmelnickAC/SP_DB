USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'sp_client'))
BEGIN
    DROP TABLE sp_client
END


CREATE TABLE [dbo].[sp_client](
	[active] [char](1) NULL,
	[alias] [text] NULL,
	[anonymous] [char](1) NULL,
	[client_id] [int] PRIMARY KEY,
	[date_added] [datetime] NULL,
	[date_updated] [datetime] NULL,
	[first_name] [text] NULL,
	[last_name] [text] NULL,
	[middle_name] [text] NULL,
	[name_data_quality] [varchar](max) NULL,
	[provider_creating_id] [int] NULL,
	[provider_updating_id] [int] NULL,
	[soc_sec_no_dashed] [text] NULL,
	[ssn_data_quality] [varchar](max) NULL,
	[suffix] [text] NULL,
	[unique_id] [varchar](max) NULL,
	[user_creating_id] [int] NULL,
	[user_updating_id] [int] NULL,
	[veteran_status] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


