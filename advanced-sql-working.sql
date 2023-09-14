
SELECT * FROM SessionInfo$
SELECT * FROM SpeakerInfo$

SELECT [Speaker Name], [Session Name], [Start Date], [End Date], [Room Name]
 FROM Red30Tech.dbo.SessionInfo$
 WHERE [Speaker Name] IN (SELECT [Name] FROM Red30Tech.dbo.SpeakerInfo$ WHERE Organization = 'Two Trees Olive Oil')

 SELECT * FROM OnlineRetailSales$
 SELECT * FROM ConventionAttendees$

  SELECT [First Name], [Last Name], [State], [Email], [Phone Number] 
  FROM ConventionAttendees$ as c
  WHERE NOT EXISTS (SELECT [CustState] FROM OnlineRetailSales$ as o
					WHERE c.[State] = o.[CustState])

SELECT *, (SELECT AVG([Order Total]) FROM Red30Tech.dbo.OnlineRetailSales$) AS Av FROM Red30Tech.dbo.OnlineRetailSales$
WHERE [Order Total] >= 
						(SELECT AVG([Order Total]) FROM Red30Tech.dbo.OnlineRetailSales$)

SELECT ProdCategory, ProdNumber, ProdName, [In Stock], (SELECT AVG([In Stock]) FROM Inventory$) AS Average_In_Stock FROM Inventory$
WHERE [In Stock] < (SELECT AVG([In Stock]) FROM Inventory$) 
ORDER BY [In Stock]

WITH AVGTOTAL (AVG_TOTAL) AS 
				(SELECT AVG([Order Total]) AS AVG_TOTAL
				FROM OnlineRetailSales$)

SELECT *  FROM OnlineRetailSales$, AVGTOTAL WHERE [Order Total] >= AVG_TOTAL


WITH AVGTOTAL (AVG_TOTAL) AS 
				(SELECT AVG([In Stock]) AS AVG_TOTAL
				FROM Inventory$)

SELECT *  FROM Inventory$, AVGTOTAL WHERE [In Stock] < AVG_TOTAL
ORDER BY [In Stock]

WITH DirectReports AS (
				SELECT [EmployeeID], [First Name], [Last Name], [Manager] FROM EmployeeDirectory$
				WHERE [EmployeeID] = 42
				UNION ALL
				SELECT e.[EmployeeID], e.[First Name], e.[Last Name], e.[Manager] FROM EmployeeDirectory$ AS e
				INNER JOIN DirectReports AS d ON e.Manager = d.[EmployeeID]
				)
SELECT COUNT(*) AS Direct_Reports FROM DirectReports as d WHERE d.EmployeeID != 42


SELECT TOP (1000) [OrderNum]
      ,[OrderDate]
      ,[OrderType]
      ,[CustomerType]
      ,[CustName]
      ,[CustState]
      ,[ProdCategory]
      ,[ProdNumber]
      ,[ProdName]
      ,[Quantity]
      ,[Price]
      ,[Discount]
      ,[Order Total]
  FROM [Red30Tech].[dbo].[OnlineRetailSales$]

SELECT CustName, COUNT(DISTINCT OrderNum) OrderNumber FROM OnlineRetailSales$
GROUP BY CustName

SELECT OrderNum, OrderDate, CustName, ProdName, Quantity, 
ROW_NUMBER() OVER(PARTITION BY CustName ORDER BY OrderDate DESC) AS RowNum
FROM OnlineRetailSales$


WITH ROW_NUMBERS AS (
SELECT OrderNum, OrderDate, CustName, ProdName, Quantity, 
ROW_NUMBER() OVER(PARTITION BY CustName ORDER BY OrderDate DESC) AS RowNum
FROM OnlineRetailSales$
)
SELECT * FROM ROW_NUMBERS WHERE RowNum = 1


WITH ROW_NUMBERS AS (
SELECT OrderNum, OrderDate, CustName, ProdCategory, ProdName, [Order Total],
ROW_NUMBER() OVER(PARTITION BY ProdCategory ORDER BY [Order Total] DESC) AS RowNum
FROM OnlineRetailSales$ WHERE CustName = 'Boehm Inc.'
)
SELECT * FROM ROW_NUMBERS WHERE RowNum <= 3

--SELECT * FROM OnlineRetailSales$ WHERE CustName = 'Boehm Inc.'



SELECT [Start Date], [End Date], [Session Name],

LAG([Session Name],1) OVER (ORDER BY [Start Date] ASC) AS PrevSession,
LAG([Start Date],1) OVER (ORDER BY [Start Date] ASC) AS PrevSessionStartTime,

LEAD([Session Name],1) OVER (ORDER BY [Start Date] ASC) AS NextSession,
LEAD([Start Date],1) OVER (ORDER BY [Start Date] ASC) AS NextSessionStartTime

FROM SessionInfo$

SELECT OrderDate, Quantity,
LAG(Quantity,1) OVER (ORDER BY OrderDate ASC) AS LastQuantity,
LAG(Quantity,2) OVER (ORDER BY OrderDate ASC) AS LastbutOneQuantity,
LAG(Quantity,3) OVER (ORDER BY OrderDate ASC) AS LastbutTwoQuantity,
LAG(Quantity,4) OVER (ORDER BY OrderDate ASC) AS LastbutThreeQuantity,
LAG(Quantity,5) OVER (ORDER BY OrderDate ASC) AS LastbutFourQuantity
FROM OnlineRetailSales$ WHERE ProdCategory = 'Drones' 
ORDER BY OrderDate DESC


WITH ORDER_BY_DAYS AS (
						SELECT OrderDate, SUM(Quantity) AS QuantityByDay FROM OnlineRetailSales$ 
						WHERE ProdCategory = 'Drones' 
						GROUP BY OrderDate
						)
SELECT OrderDate, QuantityByDay,
LAG(QuantityByDay) OVER (ORDER BY OrderDate ASC) AS LastDateQ_1,
LAG(QuantityByDay,2) OVER (ORDER BY OrderDate ASC) AS LastDateQ_2,
LAG(QuantityByDay,3) OVER (ORDER BY OrderDate ASC) AS LastDateQ_3,
LAG(QuantityByDay,4) OVER (ORDER BY OrderDate ASC) AS LastDateQ_4,
LAG(QuantityByDay,5) OVER (ORDER BY OrderDate ASC) AS LastDateQ_5
FROM ORDER_BY_DAYS



SELECT * FROM EmployeeDirectory$

SELECT *, 
RANK() OVER (ORDER BY [Last Name]) AS RANK_normal,
DENSE_RANK() OVER (ORDER BY [Last Name]) AS RANK_dense
FROM EmployeeDirectory$


SELECT * FROM ConventionAttendees$



WITH ROW_NUMBERS AS (
					SELECT *,
					DENSE_RANK() OVER(PARTITION BY [State] ORDER BY [Registration Date] ASC) AS RowNum
					FROM ConventionAttendees$ 
					)

SELECT * FROM ROW_NUMBERS WHERE RowNum IN (1,2,3)
