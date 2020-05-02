void OnStart()
  {
      if(Bars<100 || IsTradeAllowed()==false){
            MessageBox("Trading not allowed","Business hours",0);
            return;
      }else{
         MessageBox("Trading allowed","Business hours",0);
         double price=Ask;
         //--- place market order to buy 1 lot
         int ticket=OrderSend(Symbol(),OP_BUY,1,price,3,0,0,"My order",16384,0,clrGreen);
         if(ticket<0){
            Print("OrderSend failed with error #",GetLastError());
         }
         else{
            Print("OrderSend placed successfully");
         }
      }
   
  }
//+------------------------------------------------------------------+
