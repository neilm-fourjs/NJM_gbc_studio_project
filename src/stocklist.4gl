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

FUNCTION display_stocklist()
  DEFINE stock_arr DYNAMIC ARRAY OF RECORD
           stock_num     LIKE stock.stock_num,
           description   LIKE stock.description
         END RECORD, 
         stock_rec RECORD
           stock_num     LIKE stock.stock_num,
           description   LIKE stock.description
         END RECORD, 
         ret_num         LIKE stock.stock_num,
         curr_pa, idx  SMALLINT
  
  OPEN WINDOW wstock WITH FORM "stocklist"
 
  DECLARE stocklist_curs CURSOR FOR
    SELECT stock_num, description 
      FROM stock
     ORDER BY stock_num
  
  LET idx = 0
  CALL stock_arr.clear()
  FOREACH stocklist_curs INTO stock_rec.*
    LET idx = idx + 1
    LET stock_arr[idx].* = stock_rec.*
  END FOREACH
   
  LET ret_num = 0

  IF idx > 0 THEN 
     LET int_flag = FALSE
     DISPLAY ARRAY stock_arr TO sa_stock.* 
         ATTRIBUTES(COUNT=idx)
     IF (NOT int_flag) THEN
        LET curr_pa = arr_curr()
        LET ret_num = stock_arr[curr_pa].stock_num
     END IF
  END IF   
  
  CLOSE WINDOW wstock

  RETURN ret_num

END FUNCTION

