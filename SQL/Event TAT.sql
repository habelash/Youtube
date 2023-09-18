USE YOUTUBE;

CREATE TABLE HOLDTIMETAT(
    APP_NO INTEGER,
    EVENT_DATE DATE,
    EVENT_NAME VARCHAR(20)
);

INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-21', 'Event Start')
INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-22', 'Hold')
INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-23', 'Random Event')
INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-24', 'Random Event')
INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-25', 'Random Event')
INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-26', 'Randon Event')
INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-27', 'Released')
INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-28', 'Comment')
INSERT INTO HOLDTIMETAT
VALUES
    (1001, '2023-07-29', 'Event End')



SELECT * FROM HOLDTIMETAT;

--Step 1: - Get all the Events between start and end event

SELECT 
    * 
INTO #EVENTSLIST
FROM 
    HOLDTIMETAT H1
WHERE EVENT_DATE
    BETWEEN
        (
            SELECT 
                EVENT_DATE
            FROM 
                HOLDTIMETAT H2
            WHERE EVENT_NAME IN ('Event Start')
            AND H1.APP_NO = H2.APP_NO
            AND EVENT_DATE = (
                SELECT 
                    MIN(EVENT_DATE)
                FROM 
                    HOLDTIMETAT H3
                WHERE EVENT_NAME IN('Event Start')
                AND H2.APP_NO = H3.APP_NO
            )
        )
    AND 
    (
            SELECT
                EVENT_DATE
            FROM
                HOLDTIMETAT H2
            WHERE EVENT_NAME IN ('Event End')
            AND H1.APP_NO = H2.APP_NO
            AND EVENT_DATE = (
                SELECT
                    MAX(EVENT_DATE)
                FROM
                    HOLDTIMETAT H3
                WHERE EVENT_NAME IN('Event End')
                AND H2.APP_NO = H3.APP_NO
            )
        )

-- Step 2 :- Fetch the Hold and Released date to calculate the date difference

SELECT
    APP_NO,
    EVENT_DATE,
    EVENT_NAME
INTO #PEND_DATE
FROM #EVENTSLIST
WHERE 
    EVENT_NAME IN ('Hold', 'Released')
ORDER BY 1,2

-- Step 3 :- Find the number of time the Hold event was triggered and calculate the datedifference between Hold and Released date

SELECT 
    A.*, 
    ROW_NUMBER() OVER (PARTITION BY APP_NO ORDER BY EVENT_DATE ASC) AS PEND_COUNT,
    DATEDIFF(DAY,EVENT_DATE, NEXT_PEND_STATE_TIME) AS PEND_TIME
FROM
    (
        SELECT 
            APP_NO,
            EVENT_DATE,
            EVENT_NAME,
            LEAD(EVENT_NAME) OVER (PARTITION BY APP_NO ORDER BY EVENT_NAME ASC) NEXT_PEND_STATE,
            LEAD (EVENT_DATE) OVER (PARTITION BY APP_NO ORDER BY EVENT_DATE ASC) NEXT_PEND_STATE_TIME
        FROM #PEND_DATE
    ) A
WHERE 
    EVENT_NAME = 'Hold' 
    AND NEXT_PEND_STATE = 'Released'