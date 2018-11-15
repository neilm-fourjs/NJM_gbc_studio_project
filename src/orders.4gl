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

DEFINE  order_rec RECORD
           store_num    LIKE orders.store_num,
           store_name   LIKE customer.store_name,
           order_num    LIKE orders.order_num,
           order_date   LIKE orders.order_date,
           fac_code     LIKE orders.fac_code,
           ship_instr   LIKE orders.ship_instr,
           promo        LIKE orders.promo
        END RECORD,
        arr_items DYNAMIC ARRAY OF RECORD
           stock_num    LIKE items.stock_num,
           description  LIKE stock.description,
           quantity     LIKE items.quantity,
           unit         LIKE stock.unit,
           price        LIKE items.price,
           line_total   DECIMAL(9,2)
        END RECORD

CONSTANT msg01 = "You must query first"
CONSTANT msg02 = "Enter search criteria"
CONSTANT msg03 = "Canceled by user"
CONSTANT msg04 = "No rows in table"
CONSTANT msg05 = "End of list"
CONSTANT msg06 = "Beginning of list"
CONSTANT msg07 = "Invalid stock number"
CONSTANT msg08 = "Row added"
CONSTANT msg09 = "Row updated"
CONSTANT msg10 = "Row deleted"
CONSTANT msg11 = "Enter order"
CONSTANT msg12 = "This customer does not exist"
CONSTANT msg13 = "Quantity must be greather than zero"

MAIN
  DEFINE has_order, query_ok SMALLINT
	DEFINE l_res,l_userName STRING

	LET l_userName = fgl_getEnv("LOGNAME")

  CONNECT TO "custdemo"
  CLOSE WINDOW SCREEN
  
	CALL ui.Interface.setText("GBC Training Example")
  OPEN WINDOW w1 WITH FORM "orderform"

  MENU
    BEFORE MENU
       CALL setup_actions(DIALOG,FALSE,FALSE)

{		ON ACTION setUserName ATTRIBUTES(TEXT="setUserName")
			IF l_userName.getLength() < 1 THEN
				PROMPT "Enter Username:" FOR l_userName
			END IF
			CALL ui.Interface.frontcall("mymodule","setTextById", ["user", NVL(l_userName,"not set")] , [l_res])
			DISPLAY "Res:",l_res}
			--CALL fgl_winMessage("FrontCall Test",SFMT("Result: %1",l_res),"information")

    ON ACTION new
       CLEAR FORM
       LET query_ok = FALSE
       CALL close_order()
       LET has_order = order_new()
       IF has_order THEN
         CALL arr_items.clear()
         CALL items_inpupd()
       END IF
       CALL setup_actions(DIALOG,has_order,query_ok)
    ON ACTION find
       CLEAR FORM
       LET query_ok = order_query()
       LET has_order = query_ok
       CALL setup_actions(DIALOG,has_order,query_ok)
    ON ACTION next
       CALL order_fetch_rel(1)
    ON ACTION previous
       CALL order_fetch_rel(-1)
    ON ACTION getitems
       CALL items_inpupd()

    ON ACTION quit EXIT MENU
		ON ACTION close EXIT MENU
  END MENU

  CLOSE WINDOW w1

END MAIN

FUNCTION setup_actions(d, has_order, query_ok)
  DEFINE d ui.Dialog,
         has_order, query_ok SMALLINT
  CALL d.setActionActive("next",query_ok)
  CALL d.setActionActive("previous",query_ok)
  CALL d.setActionActive("getitems",has_order)
END FUNCTION

FUNCTION order_new()
  DEFINE id INTEGER, name STRING

  MESSAGE msg11

  INITIALIZE order_rec.* TO NULL
  SELECT MAX(order_num)+1 INTO order_rec.order_num
    FROM orders
  IF order_rec.order_num IS NULL
   OR order_rec.order_num == 0 THEN
     LET order_rec.order_num = 1
  END IF 

  LET int_flag = FALSE
  INPUT BY NAME
      order_rec.store_num, 
      order_rec.store_name, 
      order_rec.order_num, 
      order_rec.order_date, 
      order_rec.fac_code,
      order_rec.ship_instr,
      order_rec.promo
    WITHOUT DEFAULTS
    ATTRIBUTES(UNBUFFERED)

    BEFORE INPUT
       LET order_rec.order_date = TODAY
       LET order_rec.fac_code = "ASC"
       LET order_rec.ship_instr = "FEDEX"

    ON CHANGE store_num
       SELECT store_name INTO order_rec.store_name
         FROM customer
        WHERE store_num = order_rec.store_num
       IF (SQLCA.SQLCODE == NOTFOUND) THEN
          ERROR msg12
          NEXT FIELD store_num
       END IF

    ON ACTION zoom1
       CALL display_custlist() RETURNING id, name
       IF (id > 0) THEN
          LET order_rec.store_num = id
          LET order_rec.store_name = name
       END IF

  END INPUT

  IF (int_flag) THEN
     LET int_flag=FALSE
     CLEAR FORM
     MESSAGE msg03
     RETURN FALSE
  END IF

  RETURN order_insert()

END FUNCTION 

FUNCTION order_insert()

  WHENEVER ERROR CONTINUE
  INSERT INTO orders (
     store_num,
     order_num,
     order_date,
     fac_code,
     ship_instr,
     promo
   ) VALUES (
     order_rec.store_num,
     order_rec.order_num,
     order_rec.order_date,
     order_rec.fac_code,
     order_rec.ship_instr,
     order_rec.promo
   )
   WHENEVER ERROR STOP
  
   IF (SQLCA.SQLCODE <> 0) THEN
     CLEAR FORM
     ERROR SQLERRMESSAGE
     RETURN FALSE
   END IF

   MESSAGE "Order added-Now add items"
   RETURN TRUE

END FUNCTION

FUNCTION order_query()
  DEFINE where_clause STRING,
         id INTEGER, name STRING

  MESSAGE msg02

  LET int_flag = FALSE
  CONSTRUCT BY NAME where_clause ON 
      orders.store_num, 
      customer.store_name, 
      orders.order_num, 
      orders.order_date, 
      orders.fac_code

    ON ACTION zoom1
       CALL display_custlist() RETURNING id, name
       IF id > 0 THEN
          DISPLAY id TO orders.store_num
          DISPLAY name TO customer.store_name
       END IF

  END CONSTRUCT

  IF (int_flag) THEN
     LET int_flag=FALSE
     CLEAR FORM
     MESSAGE msg03
     RETURN FALSE
  END IF
  
  RETURN order_select(where_clause)

END FUNCTION 

FUNCTION order_select(where_clause) 
  DEFINE where_clause STRING,   
         sql_text STRING   
      
  LET sql_text = "SELECT "
      || "orders.store_num, "
      || "customer.store_name, "
      || "orders.order_num, "
      || "orders.order_date, "
      || "orders.fac_code, "
      || "orders.ship_instr, "
      || "orders.promo "
      || "FROM orders, customer "
      || "WHERE orders.store_num = customer.store_num "
      || "AND " || where_clause

  DECLARE order_curs SCROLL CURSOR FROM sql_text  
  OPEN order_curs
  IF (NOT order_fetch(1)) THEN
     CLEAR FORM
     MESSAGE msg04
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

FUNCTION order_fetch(p_fetch_flag)
  DEFINE p_fetch_flag SMALLINT

  IF p_fetch_flag = 1 THEN
     FETCH NEXT order_curs INTO order_rec.*
  ELSE
     FETCH PREVIOUS order_curs INTO order_rec.*
  END IF

  IF (SQLCA.SQLCODE == NOTFOUND) THEN
     RETURN FALSE
  END IF

  DISPLAY BY NAME order_rec.*
  CALL items_fetch()
  RETURN TRUE     

END FUNCTION

FUNCTION close_order()
  WHENEVER ERROR CONTINUE
  CLOSE order_curs
  WHENEVER ERROR STOP
END FUNCTION

FUNCTION items_fetch()
  DEFINE item_cnt INTEGER,
         item_rec RECORD
           stock_num    LIKE items.stock_num,
           description  LIKE stock.description,
           quantity     LIKE items.quantity,
           unit         LIKE stock.unit,
           price        LIKE items.price,
           line_total   DECIMAL(9,2)
        END RECORD

  IF order_rec.order_num IS NULL THEN
     RETURN
  END IF

  DECLARE items_curs CURSOR FOR
     SELECT items.stock_num, 
            stock.description, 
            items.quantity, 
            stock.unit, 
            items.price,
            items.price * items.quantity line_total
        FROM items, stock
       WHERE items.order_num = order_rec.order_num
         AND items.stock_num = stock.stock_num

  LET item_cnt = 0
  CALL arr_items.clear()
  FOREACH items_curs INTO item_rec.*
      LET item_cnt = item_cnt + 1
      LET arr_items[item_cnt].* = item_rec.*
  END FOREACH
  FREE items_curs

  CALL items_show()
  CALL order_total(item_cnt)

END FUNCTION

FUNCTION items_show()
  DISPLAY ARRAY arr_items TO sa_items.*
      BEFORE DISPLAY
        EXIT DISPLAY
  END DISPLAY 
END FUNCTION

FUNCTION order_fetch_rel(p_fetch_flag)
  DEFINE p_fetch_flag SMALLINT

  MESSAGE " "
  IF (NOT order_fetch(p_fetch_flag)) THEN
    IF (p_fetch_flag = 1) THEN
      MESSAGE msg05
    ELSE
      MESSAGE msg06
    END IF
  END IF

END FUNCTION

FUNCTION items_inpupd()
  DEFINE opflag CHAR(1),
         item_cnt, curr_pa SMALLINT,
         id INTEGER

  LET opflag = "U"

  LET item_cnt = arr_items.getLength()
  INPUT ARRAY arr_items WITHOUT DEFAULTS FROM sa_items.*
    ATTRIBUTE (UNBUFFERED, INSERT ROW = FALSE)

    BEFORE ROW
      LET curr_pa = ARR_CURR() 
      LET opflag = "U"

    BEFORE INSERT
      LET opflag = "I"
      LET arr_items[curr_pa].quantity = 1

    AFTER INSERT
      CALL item_insert(curr_pa)
      CALL items_line_total(curr_pa)

    BEFORE DELETE
      CALL item_delete(curr_pa)

    ON ROW CHANGE
      CALL item_update(curr_pa)
      CALL items_line_total(curr_pa)

    BEFORE FIELD stock_num
      IF opflag = "U" THEN
         NEXT FIELD quantity 
      END IF

    ON ACTION zoom2
       LET id = display_stocklist()
       IF id > 0 THEN
          IF (NOT get_stock_info(curr_pa,id) ) THEN
             LET arr_items[curr_pa].stock_num = NULL
          ELSE
             LET arr_items[curr_pa].stock_num = id
          END IF
       END IF

    ON CHANGE stock_num
       IF (NOT get_stock_info(curr_pa,
                             arr_items[curr_pa].stock_num) ) THEN
          LET arr_items[curr_pa].stock_num = NULL
          ERROR msg07
          NEXT FIELD stock_num
       END IF

    ON CHANGE quantity
       IF (arr_items[curr_pa].quantity <= 0) THEN
          ERROR msg13
          NEXT FIELD quantity
       END IF

  END INPUT      

  LET item_cnt = arr_items.getLength()
  CALL order_total(item_cnt)

  IF (int_flag) THEN
     LET int_flag = FALSE
  END IF

END FUNCTION

FUNCTION items_line_total(curr_pa)
  DEFINE curr_pa SMALLINT
  LET arr_items[curr_pa].line_total = 
      arr_items[curr_pa].quantity * arr_items[curr_pa].price
END FUNCTION

FUNCTION order_total(arr_length)
  DEFINE order_total DECIMAL(9,2),
         i, arr_length SMALLINT

  LET order_total = 0  
  IF arr_length > 0 THEN
     FOR i = 1 TO arr_length
        IF arr_items[i].line_total IS NOT NULL THEN    
          LET order_total = order_total + arr_items[i].line_total
        END IF
     END FOR 
  END IF

  DISPLAY BY NAME order_total

END FUNCTION

FUNCTION get_stock_info(curr_pa, id)
  DEFINE curr_pa SMALLINT,
         id INTEGER,
         sqltext STRING

  IF id IS NULL THEN    
     RETURN FALSE
  END IF

  LET sqltext="SELECT description, unit,"
  IF order_rec.promo = "N" THEN 
     LET sqltext=sqltext || "reg_price"
  ELSE
     LET sqltext=sqltext || "promo_price"
  END IF
  LET sqltext=sqltext ||
      " FROM stock WHERE stock_num = ? AND fac_code = ?"

  WHENEVER ERROR CONTINUE
  PREPARE get_stock_cursor FROM sqltext
  EXECUTE get_stock_cursor
        INTO arr_items[curr_pa].description,
             arr_items[curr_pa].unit, 
             arr_items[curr_pa].price
        USING id, order_rec.fac_code
  WHENEVER ERROR STOP

  RETURN (SQLCA.SQLCODE == 0)

END FUNCTION

FUNCTION item_insert(curr_pa) 
  DEFINE curr_pa SMALLINT

  WHENEVER ERROR CONTINUE
  INSERT INTO items (
     order_num,
     stock_num, 
     quantity, 
     price
  ) VALUES ( 
     order_rec.order_num, 
     arr_items[curr_pa].stock_num,
     arr_items[curr_pa].quantity,
     arr_items[curr_pa].price
  )
  WHENEVER ERROR STOP

  IF (SQLCA.SQLCODE == 0) THEN
     MESSAGE msg08
  ELSE
     ERROR SQLERRMESSAGE
  END IF

END FUNCTION 

FUNCTION item_update(curr_pa)
  DEFINE curr_pa SMALLINT

  WHENEVER ERROR CONTINUE 
  UPDATE items SET
    items.stock_num = arr_items[curr_pa].stock_num,
    items.quantity  = arr_items[curr_pa].quantity
     WHERE items.stock_num = arr_items[curr_pa].stock_num
       AND items.order_num = order_rec.order_num
  WHENEVER ERROR STOP

  IF (SQLCA.SQLCODE == 0) THEN
     MESSAGE msg09
  ELSE
     ERROR SQLERRMESSAGE
  END IF

END FUNCTION

FUNCTION item_delete(curr_pa)
  DEFINE curr_pa SMALLINT
   
  WHENEVER ERROR CONTINUE 
  DELETE FROM items 
     WHERE items.stock_num = arr_items[curr_pa].stock_num
     AND items.order_num = order_rec.order_num
  WHENEVER ERROR STOP

  IF (SQLCA.SQLCODE == 0) THEN
     MESSAGE msg10
  ELSE
     ERROR SQLERRMESSAGE
  END IF

END FUNCTION

