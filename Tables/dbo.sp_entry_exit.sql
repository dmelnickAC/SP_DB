USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'sp_entry_exit'))
BEGIN
    DROP TABLE sp_entry_exit
END

CREATE TABLE [dbo].[sp_entry_exit](
	[active] [char](1) NULL,
	[client_id] [int] NULL,
	[date_added] [datetime] NULL,
	[date_updated] [datetime] NULL,
	[destination_other] [text] NULL,
	[destination] [varchar](max) NULL,
	[entry_date] [datetime] NULL,
	[entry_exit_id] [int] PRIMARY KEY,
	[exit_date] [datetime] NULL,
	[group_id] [int] NULL,
	[household_id] [int] NULL,
	[notes] [text] NULL,
	[provider_creating_id] [int] NULL,
	[provider_id] [int] NULL,
	[provider_updating_id] [int] NULL,
	[reason_leaving_other] [text] NULL,
	[reason_leaving] [varchar](max) NULL,
	[subsidy] [varchar](max) NULL,
	[tenure] [varchar](max) NULL,
	[type_entry_exit] [varchar](max) NULL,
	[user_creating_id] [int] NULL,
	[user_updating_id] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


