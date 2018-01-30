CREATE OR REPLACE 
FUNCTION SPLIT_NUMBER(INPUT IN NUMBER, RETURN_TYPE IN VARCHAR2) RETURN NUMBER AS 
OUTPUT NUMBER; 
BEGIN 
  IF INPUT IS NULL THEN 
    OUTPUT := 0;
  ELSE   
    IF RETURN_TYPE = 'H' THEN
        OUTPUT := TRUNC(INPUT);       
    ELSE       
        OUTPUT := (INPUT-TRUNC(INPUT));            
    END IF;  
  END IF;
  
  RETURN OUTPUT;  
END;