/**
 * This program simply places an order on a currently open chart
 * Executes CONTINUOUSLY until you stop it in the MetaEditor
*/
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){
      MessageBox("Trading not allowed","Business hours",0);
      return;
   }else{
      //MessageBox("Trading IS allowed","Business hours",0);
      double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
      MessageBox("Minimum Stop Level="+minstoplevel+" points","Debug",0);
      double price=Ask;
   //--- calculated SL and TP prices must be normalized
      double stoploss=NormalizeDouble(Bid-minstoplevel*Point,Digits);
      double takeprofit=NormalizeDouble(Bid+minstoplevel*Point,Digits);
   //--- place market order to buy 1 lot
      int ticket=OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
      if(ticket<0)
        {
         Print("OrderSend failed with error #",GetLastError());
         MessageBox("rderSend failed with error #"+GetLastError(),"Debug",0);
        }
      else{
         Print("OrderSend placed successfully");
         MessageBox("OrderSend placed successfully","Debug",0);
         }
   }
  }
//+------------------------------------------------------------------+
