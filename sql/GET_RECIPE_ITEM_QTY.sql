CREATE OR REPLACE
FUNCTION GET_RECIPE_ITEM_QTY (FP_RECIPE_CDE IN VARCHAR2,FP_ITEM_CDE IN VARCHAR2,FP_SITE_ID IN NUMBER,FP_COMPANY_ID IN NUMBER) 
RETURN NUMBER 
IS
V_ITEM_QTY NUMBER := 0;
BEGIN
  V_ITEM_QTY := 0;
  SELECT NVL(RD.QTY,0) QTY INTO V_ITEM_QTY FROM RECIPE_DETAIL RD, RECIPE_MASTER RM 
    WHERE RD.RECIPE_MASTER_ID=RM.RECIPE_MASTER_ID AND RM.SITE_ID=FP_SITE_ID AND RM.COMPANY_ID=FP_COMPANY_ID
      AND RM.COA_CDE=FP_RECIPE_CDE AND RD.COA_CDE=FP_ITEM_CDE;
  RETURN V_ITEM_QTY;
END; 