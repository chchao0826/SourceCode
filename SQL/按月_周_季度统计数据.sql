
--sqlserver2005�﷨ͳ�ư���,��,��,�ꡣ

--����
--select sum(price),day([date]) from table_name where year([date]) =
'2006' group by day([date])
--����quarter
select sum(price),datename(week,price_time) from ble_name where
year(price_time) = '2008' group by datename(week,price_time)
--����
select sum(price),month(price_time) from ble_name where year(price_time)
= '2008' group by month(price_time)
--����
select sum(price),datename(quarter,price_time) from ble_name where
year(price_time) = '2008' group by datename(quarter,price_time)

--����
select sum(price),year(price_time) from ble_name where
year(price_time) >= '2008' group by year(price_time)