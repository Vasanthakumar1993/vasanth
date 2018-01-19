select isNull(a.app_number,'${totals}') as 'Application number',
       a.start_date as 'From',
       a.end_date as 'To',
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
       SUM(a.time) as 'Total time'
from (
       select a.app_number as 'app_number',
              CONVERT(varchar(50), a.start_date, 121) as 'start_date',
              CONVERT(varchar(50), a.end_date, 121) as 'end_date',
              DATEPART(month, d.entry_date) as 'month',
              d.time as 'time'
       from application a, daily_time_entry d, employee e, project p, company c
       where a.id = p.application_id
             and a.id = ${applicationId?c}
             and p.id = d.project_id
             and d.employee_id = e.id
             and c.id = a.company_id
             and d.submitted = 1
             and (((select isdelete from activities where id = d.activities_id) = 0)  or activities_id is null)
			       and (((select active from activities where id = d.activities_id) = 1) or activities_id is null)
			       and (((select isdelete from work_package where id=(select work_package_id from activities where id = d.activities_id) )= 0)  or activities_id is null)
			       and (((select active from work_package where id=(select work_package_id from activities where id = d.activities_id)) = 1) or activities_id is null)

       union all

       select NULL as 'app_number',
              NULL as 'start_date',
              NULL as 'end_date',
              DATEPART(month, d.entry_date) as 'month',
              d.time as 'time'
       from application a, daily_time_entry d, employee e, project p, company c
       where a.id = p.application_id
             and a.id = ${applicationId?c}
             and p.id = d.project_id
             and d.employee_id = e.id
             and c.id = a.company_id
             and d.submitted = 1
             and (((select isdelete from activities where id = d.activities_id) = 0)  or activities_id is null)
			       and (((select active from activities where id = d.activities_id) = 1) or activities_id is null)
			       and (((select isdelete from work_package where id=(select work_package_id from activities where id = d.activities_id) )= 0)  or activities_id is null)
			       and (((select active from work_package where id=(select work_package_id from activities where id = d.activities_id)) = 1) or activities_id is null)

       union all

       select a.app_number as 'app_number',
              CONVERT(varchar(50), a.start_date, 121) as 'start_date',
              CONVERT(varchar(50), a.end_date, 121) as 'end_date',
              DATEPART(month, r.start_period) as 'month',
              r.time as 'time'
       from application a, range_time_entry r, employee e, project p, company c
       where a.id = p.application_id
             and a.id = ${applicationId?c}
             and p.id = r.project_id
             and r.employee_id = e.id
             and c.id = a.company_id
             and r.submitted = 1

       union all

       select NULL as 'app_number',
              NULL as 'start_date',
              NULL as 'end_date',
              DATEPART(month, r.start_period) as 'month',
              r.time as 'time'
       from application a, range_time_entry r, employee e, project p, company c
       where a.id = p.application_id
             and a.id = ${applicationId?c}
             and p.id = r.project_id
             and r.employee_id = e.id
             and c.id = a.company_id
             and r.submitted = 1
) a
group by a.app_number, a.start_date, a.end_date
order by case when a.app_number is null then 1 else 0 end, a.app_number