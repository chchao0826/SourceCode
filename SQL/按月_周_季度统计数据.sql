
--sqlserver2005语法统计按周,月,季,年。

--按日
--select sum(price),day([date]) from table_name where year([date]) =
'2006' group by day([date])
--按周quarter
select sum(price),datename(week,price_time) from ble_name where
year(price_time) = '2008' group by datename(week,price_time)
--按月
select sum(price),month(price_time) from ble_name where year(price_time)
= '2008' group by month(price_time)
--按季
select sum(price),datename(quarter,price_time) from ble_name where
year(price_time) = '2008' group by datename(quarter,price_time)

--按年
select sum(price),year(price_time) from ble_name where
year(price_time) >= '2008' group by year(price_time)