 select  isNull(a.app_number, '${totals}') as "Application",
        CASE WHEN a.type = 'C' THEN '${cost}' WHEN a.type = 'E' THEN '${expenditure}' ELSE NULL END as 'Type',
        a.project as 'Project',
        isnull(workpackage, '-') as 'WorkPackage',
        isnull(activity, '-') as 'Activity',
        a.description as 'Description',
        a.invoicenumber as 'InvoiceNumber',
        a.invoicedate as 'InvoiceDate',
        SUM(a.amount) as 'Amount',
        a.paymentdate as 'PaymentDate',
        a.percentage as 'Percentage'
from (

  SELECT
    a.app_number     AS 'app_number',
    'C'              AS 'type',
    p.name           AS 'project',
    w.name           AS 'workpackage',
    ac.name          AS 'activity',
    c.description    AS 'description',
    c.invoice_date   AS 'invoicedate',
    c.invoice_number AS 'invoicenumber',
    c.amount         AS 'amount',
    c.payment_date   AS 'paymentdate',
    NULL             AS 'percentage'
   FROM application a
   join project p
   on a.id = p.application_id
   join work_package w
   on p.id = w.project_id
   join activities ac
   on w.id = ac.work_package_id
   join cost c
   on ac.id = c.activities_id
   where a.id =${applicationId?c} and p.isdelete = 0 and p.active = 1 and ((w.name is not null and w.isdelete = 0 and w.active = 1) or (w.name is null))
  UNION ALL

  SELECT
    NULL     AS 'app_number',
    NULL     AS 'type',
    NULL     AS  'project',
    NULL     AS 'workpackage',
    NULL     AS 'activity',
    NULL     AS 'description',
    NULL     AS 'invoicedate',
    NULL     AS 'invoicenumber',
    c.amount AS 'amount',
    NULL     AS 'paymentdate',
    NULL     AS 'percentage'
  FROM application a
     join project p
     on a.id = p.application_id
     join work_package w
     on p.id = w.project_id
     join activities ac
     on w.id = ac.work_package_id
     join cost c
     on ac.id = c.activities_id
     where a.id =${applicationId?c} and p.isdelete = 0 and p.active = 1 and ((w.name is not null and w.isdelete = 0 and w.active = 1) or (w.name is null))

  UNION ALL

  SELECT
    a.app_number     AS 'app_number',
    'E'              AS 'type',
    p.name           AS 'project',
    w.name           AS 'workpackage',
    ac.name          AS 'activity',
    e.description    AS 'description',
    e.entered_date   AS 'invoicedate',
    e.invoice_number AS 'invoicenumber',
    e.invoice_amount_ex_vat AS 'amount',
    e.payment_date   AS 'paymentdate',
    e.vat_rate       AS 'percentage'
    FROM application a join project p
       on a.id = p.application_id  join work_package w
       on p.id = w.project_id join activities ac
       on w.id = ac.work_package_id
   	   join expenditure e
       on ac.id = e.activities_id
       where a.id = ${applicationId?c} and p.isdelete = 0 and p.active = 1 and ((w.name is not null and w.isdelete = 0 and w.active = 1) or (w.name is null))
  UNION ALL

  SELECT
    NULL     AS 'app_number',
    NULL     AS 'type',
    NULL     AS 'project',
    NULL     AS 'workpackage',
    NULL     AS 'activity',
    NULL     AS 'description',
    NULL     AS 'invoicedate',
    NULL     AS 'invoicenumber',
    e.invoice_amount_ex_vat AS 'amount',
    NULL     AS 'paymentdate',
    NULL     AS 'percentage'
 FROM application a join project p
       on a.id = p.application_id  join work_package w
       on p.id = w.project_id join activities ac
       on w.id = ac.work_package_id
   	   join expenditure e
       on ac.id = e.activities_id
       where a.id = ${applicationId?c} and p.isdelete = 0 and p.active = 1 and ((w.name is not null and w.isdelete = 0 and w.active = 1) or (w.name is null))

) a
group by a.app_number, a.type, a.project,workpackage,activity, a.description, a.invoicenumber, a.invoicedate, a.paymentdate, a.percentage
order by case when a.app_number is null then 1 else 0 end, a.app_number, a.project, a.invoicedate