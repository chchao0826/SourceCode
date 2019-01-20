--月初
select convert(varchar(10),dateadd(dd,-datepart(dd,GETDATE())+1,GETDATE()) ,120)
 
--月末
select convert(varchar(10),dateadd(day,-day(GETDATE()),dateadd(month,1,GETDATE())),120) 




--上月初
SELECT CONVERT(NVARCHAR(10),DATEADD(MONTH,-1,convert(varchar(10),dateadd(dd,-datepart(dd,GETDATE())+1,GETDATE()) ,120)),120)



--上月末
SELECT CONVERT(NVARCHAR(10),DATEADD(MONTH,-1,convert(varchar(10),dateadd(day,-day(GETDATE()),dateadd(month,1,GETDATE())),120)),120)


