CREATE OR REPLACE TYPE OBJECT_SALES_PERFORMANCE_WEEK IS OBJECT (
  COA_CDE VARCHAR2(32), 
  TITLE VARCHAR2(128),
  TARGET NUMBER, 
  SOLD NUMBER,
  SOLD_DTE DATE
);
/
CREATE OR REPLACE TYPE TABLE_SALES_PERFORMANCE_WEEK IS TABLE OF OBJECT_SALES_PERFORMANCE_WEEK;
/
CREATE OR REPLACE
FUNCTION GET_SALES_PERFORMANCE_WEEK(FP_MONTH IN VARCHAR2, FP_START_DTE IN VARCHAR2, FP_END_DTE IN VARCHAR2, FP_SITE_ID IN NUMBER, FP_FINYEAR_ID IN NUMBER, FP_COMPANY_ID IN NUMBER) 
RETURN TABLE_SALES_PERFORMANCE_WEEK PIPELINED IS
CURSOR CS_SALES_PERFORMANCE_WEEK IS 
        SELECT SP.COA_CDE, MAX(COA.TITLE) TITLE, SUM(SP.TARGET) TARGET, SUM(CASE WHEN SP.COA_CDE LIKE '375-02%' THEN SP.SOLD ELSE ABS(SP.SOLD) END) SOLD, SP.SOLD_DTE FROM (
             SELECT COA.COA_CDE, NVL(ST.TARGET,0) TARGET, 0 SOLD, NULL SOLD_DTE FROM (
                  SELECT ST.COA_CDE, ST.TARGET FROM SALES_TARGET ST
                  WHERE ST.SITE_ID=FP_SITE_ID  AND ST.COMPANY_ID=FP_COMPANY_ID  AND ST.FIN_YEAR_ID=FP_FINYEAR_ID  AND ST.MONTH_NME=FP_MONTH
             ) ST, CHART_OF_ACCOUNT COA 
             WHERE COA.COA_CDE=ST.COA_CDE(+) AND COA.COMPANY_ID=FP_COMPANY_ID 
             AND COA.COA_CDE IN (SELECT COA.COA_CDE FROM CHART_OF_ACCOUNT COA WHERE COA.ENTRY_LEVEL_IND='Y'
                                   START WITH COA.COA_CDE IN (SELECT CAD.COA_CDE FROM COA_ASSOCIATION_DETAIL CAD, COA_ASSOCIATION CA
                                   WHERE CAD.COA_ASSOCIATION_ID=CA.COA_ASSOCIATION_ID AND CA.ASSOCIATION_TITLE IN ('SALES TARGET'))
                                   CONNECT BY PRIOR COA.COA_CDE=COA.PARENT_CDE UNION ALL
                                 SELECT COA.COA_CDE FROM (SELECT COA.COA_CDE FROM CHART_OF_ACCOUNT COA  WHERE COA.ENTRY_LEVEL_IND='Y' 
                                   START WITH COA.COA_CDE IN (SELECT CAD.COA_CDE FROM COA_ASSOCIATION_DETAIL CAD, COA_ASSOCIATION CA 
                                   WHERE CAD.COA_ASSOCIATION_ID=CA.COA_ASSOCIATION_ID AND CA.ASSOCIATION_TITLE IN ('DAILY SHEET ITEMS')) 
                                   CONNECT BY PRIOR COA.COA_CDE=COA.PARENT_CDE
                                 ) COA, SITE_INVENTORY SI WHERE COA.COA_CDE=SI.COA_CDE AND SI.SITE_ID=FP_SITE_ID) 
             UNION ALL
             SELECT DDS.COA_CDE, MIN(0) TARGET, SUM(DDS.SAL_QTY) SOLD, DDS.VOUCHER_DTE SOLD_DTE
              FROM ( SELECT DDS.COA_CDE, DDS.VOUCHER_DTE, NVL(DDS.SAL_QTY,0) SAL_QTY, DDS.MONTH_NME 
                      FROM DEPT_DAILY_SALE DDS, SITE_INVENTORY SI
                      WHERE (DDS.VOUCHER_DTE BETWEEN TO_DATE(FP_START_DTE,'DD-MM-YYYY') AND TO_DATE(FP_END_DTE,'DD-MM-YYYY'))  
                      AND DDS.SITE_ID=FP_SITE_ID AND DDS.FIN_YEAR_ID=FP_FINYEAR_ID AND DDS.COMPANY_ID=FP_COMPANY_ID
                      AND DDS.COA_CDE=SI.COA_CDE AND SI.SITE_ID=FP_SITE_ID
              ) DDS GROUP BY DDS.COA_CDE, DDS.VOUCHER_DTE
             UNION ALL
             SELECT MAX('500-01-06-0020') COA_CDE, MIN(0) TARGET, 
              ROUND(((MAX(NVL(SP.PP_TRANSACTION,0))/SUM(NVL(SP.TOTAL_TRANSACTION,0)+NVL(SP.FUEL_TRANSACTION,0)))*100),2) SOLD, DSR.RECON_DTE             
              FROM SHIFT_POS SP,DAILY_SHIFT_RECON DSR
              WHERE SP.DAILY_SHIFT_RECON_ID=DSR.DAILY_SHIFT_RECON_ID AND DSR.COMPANY_ID=FP_COMPANY_ID
                AND DSR.SITE_ID=FP_SITE_ID AND (DSR.RECON_DTE BETWEEN TO_DATE(FP_START_DTE,'DD-MM-YYYY') AND TO_DATE(FP_END_DTE,'DD-MM-YYYY'))
              GROUP BY DSR.RECON_DTE HAVING SUM(NVL(SP.TOTAL_TRANSACTION,0)+NVL(SP.FUEL_TRANSACTION,0))<>0
             UNION ALL
             SELECT VD.COA_CDE, MIN(0) TARGET,
               SUM(CASE WHEN VD.COA_CDE LIKE '500-01-01%' THEN CASE WHEN VD.QTY<0 THEN VD.QTY ELSE 0 END ELSE VD.AMNT END) SOLD, VD.VOUCHER_DTE SOLD_DTE
             FROM ( SELECT VD.COA_CDE, VM.VOUCHER_DTE, VD.AMNT, NVL(VD.QTY,0) QTY, TO_CHAR(VM.VOUCHER_DTE,'MON-YYYY') MONTH_NME
                      FROM VOUCHER_DETAIL VD, VOUCHER_MASTER VM, VOUCHER_SUB_TYPE VST
                      WHERE VM.VOUCHER_MASTER_ID=VD.VOUCHER_MASTER_ID AND VM.VOUCHER_SUB_TYP_ID=VST.VOUCHER_SUB_TYP_ID
                       AND VST.VOUCHER_SUB_TYP_DESC NOT IN ('FAL','FAG','CJV','AJV') AND (VM.VOUCHER_DTE BETWEEN TO_DATE(FP_START_DTE,'DD-MM-YYYY') AND TO_DATE(FP_END_DTE,'DD-MM-YYYY'))
                      AND VM.SITE_ID=FP_SITE_ID AND VM.FIN_YEAR_ID=FP_FINYEAR_ID AND VM.COMPANY_ID=FP_COMPANY_ID AND VM.CANCELLED_BY IS NULL AND VM.POSTED_IND='Y'
                      AND VD.COA_CDE IN (SELECT COA.COA_CDE FROM CHART_OF_ACCOUNT COA WHERE COA.ENTRY_LEVEL_IND='Y'
                                          START WITH COA.COA_CDE IN (SELECT CAD.COA_CDE FROM COA_ASSOCIATION_DETAIL CAD, COA_ASSOCIATION CA
                                          WHERE CAD.COA_ASSOCIATION_ID=CA.COA_ASSOCIATION_ID AND CA.ASSOCIATION_TITLE IN ('SALES TARGET'))
                                          CONNECT BY PRIOR COA.COA_CDE=COA.PARENT_CDE UNION ALL
                                         SELECT COA.COA_CDE FROM (SELECT COA.COA_CDE FROM CHART_OF_ACCOUNT COA  WHERE COA.ENTRY_LEVEL_IND='Y' 
                                           START WITH COA.COA_CDE IN (SELECT CAD.COA_CDE FROM COA_ASSOCIATION_DETAIL CAD, COA_ASSOCIATION CA 
                                           WHERE CAD.COA_ASSOCIATION_ID=CA.COA_ASSOCIATION_ID AND CA.ASSOCIATION_TITLE IN ('DAILY SHEET ITEMS')) 
                                           CONNECT BY PRIOR COA.COA_CDE=COA.PARENT_CDE
                                         ) COA, SITE_INVENTORY SI WHERE COA.COA_CDE=SI.COA_CDE AND SI.SITE_ID=FP_SITE_ID)
             ) VD GROUP BY VD.COA_CDE, VD.VOUCHER_DTE
        ) SP, CHART_OF_ACCOUNT COA WHERE SP.COA_CDE=COA.COA_CDE GROUP BY SP.COA_CDE, SP.SOLD_DTE ORDER BY SP.COA_CDE ASC, SP.SOLD_DTE ASC;
BEGIN
    FOR FL_SP IN CS_SALES_PERFORMANCE_WEEK LOOP
      PIPE ROW (OBJECT_SALES_PERFORMANCE_WEEK(FL_SP.COA_CDE, FL_SP.TITLE, FL_SP.TARGET, FL_SP.SOLD, FL_SP.SOLD_DTE));          
    END LOOP;
  RETURN;  
END;
/




