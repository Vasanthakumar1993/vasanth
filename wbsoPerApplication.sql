
CREATE TABLE #Temp ( Month VARCHAR(15),avgmonthlyBudget VARCHAR(15),monthlyBudget VARCHAR(15),monthlyHours VARCHAR(15),RealisationWageCosts VARCHAR(15),totalCosts VARCHAR(15),totalExpenditure VARCHAR(15),Eligible VARCHAR(15),monthlyClaimableRealisation VARCHAR(15) )
		
DECLARE @schemeType VARCHAR(MAX),
		@timeEntry INT, @totalHours INT, @soleTrader bit, @currentDate DATE, @applicaionStartDate DATE, @startDate DATE, @endDate DATE,
		@monthStartDate DATE, @monthEndDate DATE, @remainingBudgetMonths INT, @numMonths INT, @numActiveMonths INT, @ApplicationId INT,
		@remainingBudget DECIMAL(10, 2), @remainingCostExp DECIMAL(10, 2), @remainingWageCosts DECIMAL(10, 2), @levelThreePrice DECIMAL(10, 2),
		@levelFourPrice DECIMAL(10, 2), @remainingL3Hours INT,  @remainingL1Amount DECIMAL(10, 2), @approvalStartDate DATE,  @fixedApprovals VARCHAR(MAX),
		@approvalHourlyWage DECIMAL(10, 2), @periodStart DATE, @periodEnd DATE, @costExpEnd DATE, @monthlyBudget DECIMAL(10, 2), @monthlyHours INT,
        @monthlyCostExp DECIMAL(10, 2), @monthlyWageCosts DECIMAL(10, 2), @monthlyTotalCosts DECIMAL(10, 2), @monthlyCalculatedRealisation DECIMAL(10, 2),
        @monthlyClaimableRealisation DECIMAL(10, 2), @monthlyOverRealisation DECIMAL(10, 2), @approvalStartingCompany INT, @schemeLevelOnePercentage INT,
		@schemeLevelTwoPercentage INT, @WageCosts DECIMAL(10, 2), @approvalHigh DECIMAL(10, 2), @approvalLow DECIMAL(10, 2), @AvgmonthlyBudget DECIMAL(10, 2)

SET @monthlyOverRealisation = 0
SET @ApplicationId = ${applicationId}
SET @CurrentDate = GETDATE()

SELECT  
	@soleTrader = appr.sole_trader , @timeEntry = app.time_entry , @applicaionStartDate = app.start_date, @endDate = app.end_date, @startDate = appr.date_received,
	@remainingBudget = appr.total_funding, @remainingCostExp = appr.total_costs_and_expenditure, @remainingWageCosts = appr.total_wage_cost,@remainingL1Amount = appr.scheme_high,
	@remainingL3Hours = (appr.costs_and_expenditure_high  / sch.level_three_price), @approvalStartDate = appr.date_received, @fixedApprovals = appr.ce_calculation,
	@levelThreePrice = sch.level_three_price, @levelFourPrice = sch.level_four_price, @approvalHourlyWage = appr.hourly_wage, @approvalStartingCompany = appr.starting_company,
	@schemeLevelonePercentage = sch.level_one_percentage, @schemeLevelTwoPercentage = sch.level_two_percentage, @approvalHigh = appr.scheme_high, @approvalLow = appr.scheme_low
from application AS	app
	JOIN approval	AS	appr ON app.approval_id = appr.id 
	JOIN scheme		AS	sch	 ON	app.scheme_id = sch.id
WHERE app.id = @ApplicationId

DECLARE @index INT
SET @index = 0

IF @soleTrader = 1
BEGIN
	IF @timeEntry = 0
		BEGIN
			SELECT  @totalHours= ISNUll(SUM(Time),0) FROM daily_time_entry  dte  
				JOIN project		AS Proj ON dte.project_id = Proj.id		AND Proj.isdelete = 0 
				JOIN activities		AS Act	ON dte.activities_id = Act.id	AND Act.isdelete = 0
				JOIN application	AS Apl ON Apl.id = proj.application_id	AND Act.application_id = Apl.id
			WHERE apl.id = @ApplicationId
		END
	ELSE
		BEGIN
						SELECT  @totalHours= ISNUll(SUM(Time),0) FROM range_time_entry  rte  
			JOIN project		AS Proj ON rte.project_id = Proj.id		AND Proj.isdelete = 0 
			JOIN application	AS Apl ON Apl.id = proj.application_id	
		WHERE apl.id = @ApplicationId
		END
END

SET @remainingBudgetMonths = (DateDiff(MM,@startDate , @endDate) + 1)
SET @monthStartDate = DATEADD(dd,-(DAY(@startDate)-1),@startDate) 
SET @monthEndDate =  CASE WHEN  @CurrentDate < @endDate THEN DATEADD(dd,-(DAY(DATEADD(mm,1,@endDate))), DATEADD(mm,1,@endDate)) ELSE @CurrentDate END
SET @numMonths = CASE WHEN  DATEDIFF(mm,@monthStartDate,@monthEndDate)+ 1 < 0 THEN 0  ELSE  DATEDIFF(mm,@monthStartDate,@monthEndDate)+ 1 END
SET @numActiveMonths = CASE WHEN  @numMonths > @remainingBudgetMonths THEN @remainingBudgetMonths  ELSE @numMonths END
SET @AvgmonthlyBudget = @remainingBudget / @remainingBudgetMonths

WHILE @index < @numActiveMonths
BEGIN
	SET @monthlyBudget = CAST ((@remainingBudget / @remainingBudgetMonths) AS DECIMAL(10,2))
	DECLARE @totalCosts DECIMAL(10,2), @totalExpenditure DECIMAL(10,2)

	IF @index = 0
		BEGIN
			SET @periodStart = @applicaionStartDate
			SET @periodEnd = DATEADD(dd,-(DAY(DATEADD(mm,1,@approvalStartDate))), DATEADD(mm,1,@approvalStartDate))
		END
	ELSE
		BEGIN
			SET @periodStart = DATEADD(MM,@index,(DATEADD(dd,-(DAY(@approvalStartDate)-1),@approvalStartDate)))
			SET @periodEnd = DATEADD(dd,-(DAY(DATEADD(mm,1,@periodStart))), DATEADD(mm,1,@periodStart))
		END

	IF @index = (@remainingBudgetMonths - 1) 
		BEGIN
			SET @costExpEnd = DATEADD(YY,10, @periodEnd)
		END 
	ELSE 
		BEGIN
			SET @costExpEnd = @periodEnd;
		END

	IF @timeEntry = 0
		BEGIN
			SELECT  @monthlyHours= ISNUll(SUM(Time),0) FROM daily_time_entry  dte  
				JOIN project		AS Proj ON dte.project_id = Proj.id		
				JOIN application	AS Apl ON Apl.id = proj.application_id	
			WHERE apl.id = @ApplicationId and dte.entry_date >= @periodStart and dte.entry_date <= @costExpEnd
		END
	ELSE
		BEGIN
			SELECT  @monthlyHours= ISNUll(SUM(Time),0) FROM range_time_entry  rte  
				JOIN project		AS Proj ON rte.project_id = Proj.id		AND Proj.isdelete = 0 
				JOIN application	AS Apl ON Apl.id = proj.application_id	
			WHERE apl.id = @ApplicationId and rte.start_period >= @periodStart and rte.end_period <= @costExpEnd
		END

	DECLARE @monCostExp INT
	SET @monCostExp = 0
	SELECT @totalCosts = SUM(amount) FROM cost WHERE invoice_date between @periodStart and @periodEnd
	SELECT @totalExpenditure = SUM(invoice_amount_ex_vat) FROM expenditure WHERE entered_date between @periodStart and @periodEnd

	IF @fixedApprovals ='Fixed rate'
		BEGIN 
			IF @monthlyHours < @remainingL3Hours
				BEGIN
					SET @monCostExp = @monthlyHours * @levelThreePrice
				END
			ELSE 
				BEGIN
					SET @monCostExp = (@remainingL3Hours * @levelThreePrice) + ((@monthlyHours - @remainingL3Hours) * @levelFourPrice)
				END
		END
	ELSE
		BEGIN
			SET @monCostExp = @totalCosts + @totalExpenditure
		END

	IF @monCostExp > @remainingCostExp
		BEGIN
			SET @monthlyCostExp = @remainingCostExp;
		END
	ELSE 
		BEGIN
			SET @monthlyCostExp = @monCostExp;
		END

	SET @WageCosts = @monthlyHours * @approvalHourlyWage
					
	IF @remainingWageCosts = 0
		BEGIN
			SET @monthlyWageCosts = 0
		END
	ELSE IF @WageCosts > @remainingWageCosts
		BEGIN
			SET @monthlyWageCosts = @remainingWageCosts
		END
	ELSE
		BEGIN
			SET @monthlyWageCosts = @WageCosts
		END

	SET @monthlyTotalCosts =  @monthlyCostExp + @monthlyWageCosts

	IF (@soleTrader != 0 and @totalHours > 500) 
		BEGIN
			SET @monthlyCalculatedRealisation = 0
		END
	ELSE
		BEGIN
			DECLARE @levelOnePercentage INT,
					@realisationHigh INT,
					@realisationLow INT,
					@monthlyRealisation INT

			if @approvalStartingCompany = 1
				BEGIN 
					SET @levelOnePercentage = @schemeLevelTwoPercentage
				END
			ELSE
				BEGIN
					SET @levelOnePercentage = @schemeLevelOnePercentage
				END

			if @monthlyTotalCosts < @remainingL1Amount
				BEGIN
					SET @monthlyRealisation = CAST(((@monthlyTotalCosts * @levelOnePercentage) / 100) AS DECIMAL(10,2))
				END
			ELSE 
				BEGIN
					SET @realisationHigh = CAST(((@remainingL1Amount * @levelOnePercentage) / 100) AS DECIMAL(10,2)) 
					SET @realisationLow = CAST(((@monthlyTotalCosts - @remainingL1Amount) * @schemeLevelTwoPercentage )/ 100 AS DECIMAL(10,2)) 
					SET @monthlyRealisation = @realisationHigh + @realisationLow
				END

			SET @monthlyCalculatedRealisation = @monthlyRealisation + @monthlyOverRealisation
					
			IF @monthlyCalculatedRealisation > @monthlyBudget
				BEGIN
					SET @monthlyOverRealisation = @monthlyCalculatedRealisation - @monthlyBudget
					SET @monthlyClaimableRealisation = @monthlyBudget;
				END 
			ELSE 
				BEGIN
					SET @monthlyOverRealisation = 0
					SET @monthlyClaimableRealisation = @monthlyCalculatedRealisation
				END
		END

		SET @remainingBudget = Case WHEN @remainingBudget - @monthlyClaimableRealisation > 0 THEN @remainingBudget - @monthlyClaimableRealisation ELSE 0 END
		SET @remainingCostExp = Case WHEN @remainingCostExp - @monthlyCostExp > 0 THEN @remainingCostExp - @monthlyCostExp ELSE 0 END
		SET @remainingWageCosts = Case WHEN @remainingWageCosts - @monthlyWageCosts > 0 THEN @remainingWageCosts - @monthlyWageCosts ELSE 0 END
		SET @remainingL3Hours = Case WHEN @remainingL3Hours - @monthlyHours > 0 THEN @remainingL3Hours - @monthlyHours ELSE 0 END
		SET @remainingL1Amount = Case WHEN  @remainingL1Amount - @monthlyTotalCosts > 0 THEN @remainingL1Amount - @monthlyTotalCosts ELSE 0 END
		SET @remainingBudgetMonths = @remainingBudgetMonths - 1 

	INSERT INTO #temp SELECT DATENAME(mm,@periodStart) ,@AvgmonthlyBudget ,@monthlyBudget , @monthlyHours ,@WageCosts , @totalCosts , @totalExpenditure , CAST(@levelOnePercentage AS VARCHAR(MAX)) + ' %' , @monthlyClaimableRealisation

	SET @index = @index + 1;
END

INSERT INTO #temp SELECT 'Total' ,SUM(CAST(AvgmonthlyBudget AS DECIMAL(10,2))) ,SUM(CAST(monthlyBudget AS DECIMAL(10,2))) , SUM(CAST(monthlyHours AS INT)) ,SUM(CAST(RealisationWageCosts AS DECIMAL(10,2))) , SUM(CAST(totalCosts AS DECIMAL(10,2))) , SUM(CAST(totalExpenditure AS DECIMAL(10,2))) , NUll , SUM(CAST(monthlyClaimableRealisation AS DECIMAL(10,2))) from #Temp

SELECT  Month , avgmonthlyBudget ,monthlyBudget ,monthlyHours ,RealisationWageCosts ,totalCosts ,totalExpenditure ,Eligible ,monthlyClaimableRealisation FROM #Temp
		
DROP TABLE #Temp