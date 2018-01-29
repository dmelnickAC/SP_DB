SELECT  Schedule.ScheduleID AS JobName
       ,[Catalog].Name AS ReportName
       ,Subscriptions.Description AS Recipients
       ,[Catalog].Path AS ReportPath
       ,StartDate
       ,Schedule.LastRunTime
FROM    [ReportServer].dbo.ReportSchedule
        INNER JOIN [ReportServer].dbo.Schedule ON ReportSchedule.ScheduleID = Schedule.ScheduleID
        INNER JOIN [ReportServer].dbo.Subscriptions ON ReportSchedule.SubscriptionID = Subscriptions.SubscriptionID
        INNER JOIN [ReportServer].dbo.[Catalog] ON ReportSchedule.ReportID = [Catalog].ItemID
        AND Subscriptions.Report_OID = [Catalog].ItemID