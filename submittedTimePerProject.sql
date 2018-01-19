select isNull(project, '${totals}') as 'Project',isnull(workpackage, '-') as 'Workpackage',isnull(activities,'-') as 'Activity',
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
	 select distinct pro.name as 'Project', wp.name as 'WorkPackage', act.name as 'Activities', sum(dtp.time) as 'time' , Month(dtp.entry_date) as 'Month'
 FROM daily_time_entry dtp
 Right Join activities act on dtp.activities_id = act.id
 Right Join work_package wp on act.work_package_id = wp.id
 Right Join project pro on wp.project_id = pro.id and dtp.project_id = pro.id
 Right Join application app on pro.application_id = app.id
 Right Join company com  on app.company_id = com.id
 where dtp.activities_id is not null
		and dtp.project_id is not null
		and com.id = ${companyId?c}
		and dtp.submitted = 1
		and dtp.entry_date between '${year?c}-01-01' and '${year?c}-12-31'
		and pro.isdelete = 0 and pro.active = 1
        and ((wp.name is not null and wp.isdelete = 0 and wp.active = 1) or (wp.name is null))
        and ((act.name is not null and act.isdelete = 0 and act.active = 1) or (act.name is null))
 Group by com.id,app.app_number, pro.name, wp.name, act.name, Month(dtp.entry_date)

		union

select distinct pro.name as 'Project', null as 'WorkPackage', null as 'Activities', sum(dtp.time) as 'Total Time' , Month(dtp.entry_date) as 'Month'
 FROM daily_time_entry dtp
 Right Join project pro on dtp.project_id = pro.id
 Right Join application app on pro.application_id = app.id
 Right Join company com  on app.company_id = com.id
 where dtp.activities_id is null
		 and dtp.project_id is not null
		 and com.id = ${companyId?c}
		 and dtp.submitted = 1
		 and dtp.entry_date between '${year?c}-01-01' and '${year?c}-12-31'
		 and pro.isdelete = 0 and pro.active = 1
 Group by com.id,app.app_number, pro.name, Month(dtp.entry_date)

  union all

	 	 select distinct pro.name as 'Project', wp.name as 'WorkPackage', act.name as 'Activities', sum(rtp.time) as 'Total Time' , Month(rtp.start_period) as 'Month'
 FROM range_time_entry rtp
 Right Join activities act on rtp.id = act.id
 Right Join work_package wp on act.work_package_id = wp.id
 Right Join project pro on wp.project_id = pro.id and rtp.project_id = pro.id
 Right Join application app on pro.application_id = app.id
 Right Join company com  on app.company_id = com.id
 where  rtp.project_id is not null
		and com.id = ${companyId?c}
		and rtp.submitted = 1
		and rtp.start_period between '${year?c}-01-01' and '${year?c}-12-31'
		and pro.isdelete = 0 and pro.active = 1
        and ((wp.name is not null and wp.isdelete = 0 and wp.active = 1) or (wp.name is null))
        and ((act.name is not null and act.isdelete = 0 and act.active = 1) or (act.name is null))
 Group by com.id,app.app_number, pro.name, wp.name, act.name, Month(rtp.start_period)

		union

select distinct pro.name as 'Project', null as 'WorkPackage', null as 'Activities', sum(rtp.time) as 'Total Time' , Month(rtp.start_period) as 'Month'
 FROM range_time_entry rtp
 Right Join project pro on rtp.project_id = pro.id
 Right Join application app on pro.application_id = app.id
 Right Join company com  on app.company_id = com.id
 where  rtp.project_id is not null
		 and com.id = ${companyId?c}
		 and rtp.submitted = 1
		 and rtp.start_period between '${year?c}-01-01' and '${year?c}-12-31'
		 and pro.isdelete = 0 and pro.active = 1
 Group by com.id,app.app_number, pro.name, Month(rtp.start_period)

  ) a
group by a.project,workpackage,activities
order by case when a.project is null then 1 else 0 end, a.project
