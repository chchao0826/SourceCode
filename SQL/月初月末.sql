--�³�
select convert(varchar(10),dateadd(dd,-datepart(dd,GETDATE())+1,GETDATE()) ,120)
 
--��ĩ
select convert(varchar(10),dateadd(day,-day(GETDATE()),dateadd(month,1,GETDATE())),120) 




--���³�
SELECT CONVERT(NVARCHAR(10),DATEADD(MONTH,-1,convert(varchar(10),dateadd(dd,-datepart(dd,GETDATE())+1,GETDATE()) ,120)),120)



--����ĩ
SELECT CONVERT(NVARCHAR(10),DATEADD(MONTH,-1,convert(varchar(10),dateadd(day,-day(GETDATE()),dateadd(month,1,GETDATE())),120)),120)


