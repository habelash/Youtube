USE YOUTUBE;

SELECT * FROM HOLDTIMETAT;

IF OBJECT_ID('tempdb..#START_DATE') IS NOT NULL DROP TABLE #START_DATE
IF OBJECT_ID('tempdb..#END_DATE') IS NOT NULL DROP TABLE #END_DATE

-- Fetch and save the event start date into a temp table
SELECT  
    APP_NO, 
    EVENT_DATE AS EVENT_START_DATE
INTO #START_DATE
FROM HOLDTIMETAT
WHERE EVENT_NAME IN ('Event Start');

-- Fetch and save the event end date into a temp table

SELECT
    APP_NO,
    EVENT_DATE AS EVENT_END_DATE
INTO #END_DATE
FROM HOLDTIMETAT
WHERE EVENT_NAME IN('Event End');


-- Joing the temp tables with the main table with the application number to get the data in the required format
SELECT 
    DISTINCT H1.APP_NO,
    EVENT_START_DATE,
    EVENT_END_DATE
FROM HOLDTIMETAT H1
LEFT JOIN #START_DATE D1
ON H1.APP_NO = D1.APP_NO
LEFT JOIN #END_DATE D2
ON H1.APP_NO = D2.APP_NO

