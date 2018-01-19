select isNull(a.employee, '${totals}') as 'Employee',
        '${year?c}' as 'Year',
        SUM(CASE WHEN a.month = 1 THEN a.time ELSE 0 END) AS 'Jan',
        SUM(CASE WHEN a.month = 2 THEN a.time ELSE 0 END) AS 'Feb',
        SUM(CASE WHEN a.month = 3 THEN a.time ELSE 0 END) AS 'Mar',
        SUM(CASE WHEN a.month = 4 THEN a.time ELSE 0 END) AS 'Apr',
        SUM(CASE WHEN a.month = 5 THEN a.time ELSE 0 END) AS 'May',
        SUM(CASE WHEN a.month = 6 THEN a.time ELSE 0 END) AS 'Jun',
        SUM(CASE WHEN a.month = 7 THEN a.time ELSE 0 END) AS 'Jul',
        SUM(CASE WHEN a.month = 8 THEN a.time ELSE 0 END) AS 'Aug',
        SUM(CASE WHEN a.month = 9 THEN a.time ELSE 0 END) AS 'Sep',
        SUM(CASE WHEN a.month = 10 THEN a.time ELSE 0 END) AS 'Oct',
        SUM(CASE WHEN a.month = 11 THEN a.time ELSE 0 END) AS 'Nov',
        SUM(CASE WHEN a.month = 12 THEN a.time ELSE 0 END) AS 'Dec',
        SUM(a.time) as 'Total Time'
from (
   select CONCAT(e.first_name, ' ',  e.last_name) as 'employee',
          DATEPART(month, d.entry_date) as 'month',
          e.national_id_number,
          d.time
   from daily_time_entry d, employee e, company c, project p
   where e.id = d.employee_id
      and p.id = d.project_id
      and c.id = e.company_id
      and c.id = ${companyId?c}
      and d.submitted = ${submitted?c}
      and d.entry_date between '${year?c}-01-01' and '${year?c}-12-31'
      and p.active = 1
      and (((select isdelete from activities where id = d.activities_id) = 0)  or activities_id is null)
		  and (((select active from activities where id = d.activities_id) = 1) or activities_id is null)
		  and (((select isdelete from work_package where id=(select work_package_id from activities where id = d.activities_id) )= 0)  or activities_id is null)
		  and (((select active from work_package where id=(select work_package_id from activities where id = d.activities_id)) = 1) or activities_id is null)

   union all

   select NULL,
          DATEPART(month, d.entry_date) as 'month',
          NULL,
          d.time
   from daily_time_entry d, employee e, company c, project p
   where e.id = d.employee_id
      and p.id = d.project_id
      and c.id = e.company_id
      and c.id = ${companyId?c}
      and d.submitted = ${submitted?c}
      and d.entry_date between '${year?c}-01-01' and '${year?c}-12-31'
      and p.active = 1
      and (((select isdelete from activities where id = d.activities_id) = 0)  or activities_id is null)
	    and (((select active from activities where id = d.activities_id) = 1) or activities_id is null)
		  and (((select isdelete from work_package where id=(select work_package_id from activities where id = d.activities_id) )= 0)  or activities_id is null)
		  and (((select active from work_package where id=(select work_package_id from activities where id = d.activities_id)) = 1) or activities_id is null)

   union all

   select CONCAT(e.first_name, ' ',  e.last_name) as 'employee',
          DATEPART(month, r.start_period) as 'month',
          NULL,
          r.time
   from range_time_entry r, employee e, company c, project p
   where e.id = r.employee_id
      and p.id = r.project_id
      and c.id = e.company_id
      and c.id = ${companyId?c}
      and r.submitted = ${submitted?c}
      and r.start_period >= '${year?c}-01-01' and r.end_period <= '${year?c}-12-31'
      and p.active = 1

   union all

   select NULL,
          DATEPART(month, r.start_period) as 'month',
          NULL,
          r.time
   from range_time_entry r, employee e, company c, project p
   where e.id = r.employee_id
      and p.id = r.project_id
      and c.id = e.company_id
      and c.id = ${companyId?c}
      and r.submitted = ${submitted?c}
      and r.start_period >= '${year?c}-01-01' and r.end_period <= '${year?c}-12-31'
      and p.active = 1
) a
group by a.employee, a.national_id_number
order by case when a.employee is null then 1 else 0 end, a.employee

