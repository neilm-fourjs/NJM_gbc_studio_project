# FOURJS_START_COPYRIGHT(U,2002)
# Property of Four Js*
# (c) Copyright Four Js 2002, 2016. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these samples are
# accurate and suitable for your purposes.
# Their inclusion is purely for information purposes only.
# FOURJS_END_COPYRIGHT
SCHEMA custdemo

FUNCTION display_custlist()
  DEFINE cust_arr DYNAMIC ARRAY OF RECORD
           store_num     LIKE customer.store_num,
           store_name    LIKE customer.store_name,
           city          LIKE customer.city
         END RECORD, 
         cust_rec RECORD
           store_num     LIKE customer.store_num,
           store_name    LIKE customer.store_name,
           city          LIKE customer.city
         END RECORD, 
         ret_num       LIKE customer.store_num,
         ret_name      LIKE customer.store_name,
         curr_pa, idx  SMALLINT
  
  OPEN WINDOW wcust WITH FORM "custlist"
 
  DECLARE custlist_curs CURSOR FOR
    SELECT store_num, store_name, city 
      FROM customer
     ORDER BY store_num
  
  LET idx = 0
  CALL cust_arr.clear()
  FOREACH custlist_curs INTO cust_rec.*
    LET idx = idx + 1
    LET cust_arr[idx].* = cust_rec.*
  END FOREACH
   
  LET ret_num = 0
  LET ret_name = NULL

  IF idx > 0 THEN 
     LET int_flag = FALSE
     DISPLAY ARRAY cust_arr TO sa_cust.* 
         ATTRIBUTES(COUNT=idx)
     IF (NOT int_flag) THEN
        LET curr_pa = arr_curr()
        LET ret_num = cust_arr[curr_pa].store_num
        LET ret_name = cust_arr[curr_pa].store_name
     END IF
  END IF   
  
  CLOSE WINDOW wcust

  RETURN ret_num, ret_name 

END FUNCTION

