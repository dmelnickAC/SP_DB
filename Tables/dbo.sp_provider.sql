USE [SPReports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'sp_provider'))
BEGIN
    DROP TABLE sp_provider
END

CREATE TABLE [dbo].[sp_provider](
	[accessibility] [varchar](max) NULL,
	[active] [char](1) NULL,
	[affiliated_residential_project] [char](1) NULL,
	[airs_compliant] [char](1) NULL,
	[airs_designation] [varchar](max) NULL,
	[aka] [varchar](max) NULL,
	[area_id] [varchar](max) NULL,
	[brochures] [char](1) NULL,
	[capacity_type] [varchar](max) NULL,
	[cesc_provider] [char](1) NULL,
	[continuum_flag] [char](1) NULL,
	[coc_code] [varchar](max) NULL,
	[date_added] [datetime] NULL,
	[date_officialchange] [datetime] NULL,
	[date_updated] [datetime] NULL,
	[description] [varchar](max) NULL,
	[description_officialchange] [varchar](max) NULL,
	[direct_service_code] [char](1) NULL,
	[eligibility] [varchar](max) NULL,
	[employer_id_number] [int] NULL,
	[facility_code] [varchar](max) NULL,
	[facility_type] [varchar](max) NULL,
	[fips_code] [varchar](max) NULL,
	[geocode] [varchar](max) NULL,
	[handicap_access] [char](1) NULL,
	[hours] [varchar](max) NULL,
	[hud_compliant] [char](1) NULL,
	[hud_grantee_id] [varchar](max) NULL,
	[hud_housing_type] [varchar](max) NULL,
	[hud_site_type] [varchar](max) NULL,
	[hud_tracking_method] [varchar](max) NULL,
	[income_period] [int] NULL,
	[intake_procedure] [varchar](max) NULL,
	[languages] [varchar](max) NULL,
	[maintaining_provider_id] [int] NULL,
	[name] [varchar](max) NULL,
	[operational] [char](1) NULL,
	[org_officialchange_id] [int] NULL,
	[org_requestingchange_id] [int] NULL,
	[parent_provider_id] [int] NULL,
	[payment_methods_accepted] [int] NULL,
	[primary_address_id] [int] NULL,
	[primary_contact_id] [int] NULL,
	[primary_telephone_id] [int] NULL,
	[principal_site] [char](1) NULL,
	[printed_directory] [char](1) NULL,
	[program_fees] [varchar](max) NULL,
	[program_type_code] [varchar](max) NULL,
	[provider_bills_for_medicaid_flag] [char](1) NULL,
	[provider_creating_id] [int] NULL,
	[provider_grant_type] [varchar](max) NULL,
	[provider_id] [int] PRIMARY KEY,
	[provider_type] [varchar](max) NULL,
	[provider_updating_id] [int] NULL,
	[resource_notes] [varchar](max) NULL,
	[service_capacity] [varchar](max) NULL,
	[service_transaction_workflow] [char](1) NULL,
	[shelter_flag] [char](1) NULL,
	[shelter_requirements] [varchar](max) NULL,
	[shelter_service_code] [varchar](max) NULL,
	[show_on_public_site] [char](1) NULL,
	[site_information] [varchar](max) NULL,
	[spuser] [char](1) NULL,
	[target_pop_value] [varchar](max) NULL,
	[user_creating_id] [int] NULL,
	[user_updating_id] [int] NULL,
	[volunteer_ops] [varchar](max) NULL,
	[website_address] [varchar](max) NULL,
	[who_officialchange_id] [int] NULL,
	[who_requestingchange] [varchar](max) NULL,
	[wishlist] [varchar](max) NULL,
	[year_corp] [int] NULL,
	[zips_served] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


