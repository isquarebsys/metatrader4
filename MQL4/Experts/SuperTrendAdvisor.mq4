//+------------------------------------------------------------------+
// References
// https://book.mql4.com/samples/expert: For buy, sell calcuations
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DodgerBlue  // Line up[]
#property indicator_width1 2
#property indicator_color2 Red       // Line down[]
#property indicator_width2 2
#property indicator_color3 DodgerBlue  // arrup[]
#property indicator_width3 1
#property indicator_color4 Red      // arrdwn[]
#property indicator_width4 1
extern double stopLossConstant   =200;     // SL for an opened order
extern double takeProfitConstant =39;      // ТР for an opened order

extern bool   ShowArrows       = true;
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = false;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;
extern bool   enableBuying       = true;
extern bool   enableSelling       = true;

double Super = 2.0;

bool nexttrend;
double minhighprice,maxlowprice;
double up[],down[],atrlo[],atrhi[],trend[];
double arrup[],arrdwn[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(5); // +1 buffer - trend[]

   SetIndexBuffer(0,up);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,down);
   SetIndexStyle(1,DRAW_LINE);

   SetIndexBuffer(4,trend);
   SetIndexBuffer(2,arrup);
   SetIndexBuffer(3,arrdwn);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(4,0.0);

   if(ShowArrows)
     {
      SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID);
      SetIndexArrow(2,233);
      SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID);
      SetIndexArrow(3,234);
     }
   else
     {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
     }


   nexttrend=0;
   minhighprice= High[Bars-1];
   maxlowprice = Low[Bars-1];
   return (0);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFix { } ExtFix;
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
   double atr,lowprice_i,highprice_i,lowma,highma;
   int workbar=0;
   int counted_bars=IndicatorCounted();
   Print("counted_bars: "+counted_bars);
   if(counted_bars<0)
     {
      Print("counted_bars: < 0");
     }

   if(counted_bars>0)
     {
      counted_bars--;
     }
   int limit = MathMin(Bars-counted_bars,Bars-1);
   Print("limit:"+limit);
   Print("Bars:"+Bars);
   for(int i=Bars-1; i>=0; i--)
     {
      Print("i: "+i);
      lowprice_i=iLow(Symbol(),Period(),iLowest(Symbol(),Period(),MODE_LOW,Super,i));
      Print("Low Price: "+lowprice_i);
      highprice_i=iHigh(Symbol(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,Super,i));
      lowma=NormalizeDouble(iMA(NULL,0,Super,0,MODE_SMA,PRICE_LOW,i),Digits());
      highma=NormalizeDouble(iMA(NULL,0,Super,0,MODE_SMA,PRICE_HIGH,i),Digits());
      trend[i]=trend[i+1];
      atr=iATR(Symbol(),0,100,i)/2;

      arrup[i]  = EMPTY_VALUE;
      arrdwn[i] = EMPTY_VALUE;
      if(nexttrend==1)
        {
         maxlowprice=MathMax(lowprice_i,maxlowprice);
         Print("Inside nexttrend=1: "+maxlowprice);
         if(highma<maxlowprice && Close[i]<Low[i+1])
           {
            trend[i]=1.0;
            nexttrend=0;
            minhighprice=highprice_i;
           }
        }
      if(nexttrend==0)
        {
         minhighprice=MathMin(highprice_i,minhighprice);
         Print("Inside nexttrend=0: "+minhighprice);
         if(lowma>minhighprice && Close[i]>High[i+1])
           {
            trend[i]=0.0;
            nexttrend=1;
            maxlowprice=lowprice_i;
           }
        }
      if(trend[i]==0.0)
        {
         if(trend[i+1]!=0.0)
           {
            up[i]=down[i+1];
            up[i+1]=up[i];
            arrup[i] = up[i] - 2*atr;
           }
         else
           {
            up[i]=MathMax(maxlowprice,up[i+1]);
           }

        }
      else
        {
         if(trend[i+1]!=1.0)
           {
            down[i]=up[i+1];
            down[i+1]=down[i];
            arrdwn[i] = down[i] + 2*atr;
           }
         else
           {
            down[i]=MathMin(minhighprice,down[i+1]);
           }

        }
     }
   manageAlerts();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageAlerts()
  {
   if(alertsOn)
     {
      //Print("Inside alertsOn");
      if(alertsOnCurrent)
        {
         int whichBar = 0;
        }
      else
        {
         whichBar = 1;
        }
     }
   if(enableSelling)
     {
      if(arrup[whichBar]  != EMPTY_VALUE)
        {
         //Alert("arrup[whichBar]");
         Print("arrup[whichBar]");
         double stoplossForSelling=OrderStopLoss();
         double takeprofitForSelling=OrderTakeProfit();
         double minstoplevelForSelling=MarketInfo(Symbol(),MODE_STOPLEVEL);
         Print("Stop level of "+Symbol()+"is "+minstoplevelForSelling);
         //Alert("Stop level of "+Symbol()+"is "+minstoplevel);
         double priceToSell=Bid;
         //--- calculated SL and TP prices must be normalized
         //double stoploss=NormalizeDouble(Ask+minstoplevel*Point,Digits);
//         double newStoplossForSelling=NormalizeDouble(Ask+minstoplevelForSelling*Point,Digits);
         //double newTakeprofitForSelling=NormalizeDouble(Ask-minstoplevelForSelling*Point,Digits);
         stoplossForSelling=NormalizeDouble(Ask+newStop(stopLossConstant)*Point,Digits);
         takeprofitForSelling=NormalizeDouble(Ask-newStop(takeProfitConstant)*Point,Digits);
         /**
            https://docs.mql4.com/trading/ordersend

            int  OrderSend(
            string   symbol,              // symbol
            int      cmd,                 // operation
            double   volume,              // volume
            double   price,               // price
            int      slippage,            // slippage
            double   stoploss,            // stop loss
            double   takeprofit,          // take profit
            string   comment=NULL,        // comment
            int      magic=0,             // magic number
            datetime expiration=0,        // pending order expiration
            color    arrow_color=clrNONE  // color
            );
         */
         // This CLOSES the order automatically
         RefreshRates();
         int sellTicket=OrderSend(Symbol(),OP_SELL,1,Bid,1,stoplossForSelling,takeprofitForSelling,"Sell order",16384,0,clrGreen);
         // MarketOrderSend(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment, int magic)
         // This does NOT close the order automatically
         // int sellTicket=MarketOrderSend(Symbol(),OP_SELL,1,priceToSell,1,stoploss,takeprofit,"Sell order",0,clrGreen);
         //int sellTicket=OrderSend(Symbol(),OP_SELL,1,priceToSell,1,0,0,"Sell order",16384,0,clrGreen);
         if(sellTicket<0)
           {
            Print("OrderSend for OP_SELL failed with error #",GetLastError());
            //Print("OrderSend for OP_SELL failed with error #"+GetLastError(),"Debug",0);
           }
         else
           {
            Print("OrderSend for OP_SELL placed successfully");
            //Print("OrderSend for OP_SELL placed successfully","Debug",0);
           }
        }
     }
   doAlert(whichBar,"Up");
   if(enableBuying)
     {
      if(arrdwn[whichBar] != EMPTY_VALUE)
        {
         Print("arrdwn[whichBar]");
         double minstoplevelForBuying=MarketInfo(Symbol(),MODE_STOPLEVEL);
         double stoplossForBuying=OrderStopLoss();
         double takeprofitForBuying=OrderTakeProfit();
         double priceToBuy=Ask;
         //--- calculated SL and TP prices must be normalized
         //double newStoplossForBuying=NormalizeDouble(Bid-minstoplevelForBuying*Point,Digits);
         //double newTakeprofitForBuying=NormalizeDouble(Bid+minstoplevelForBuying*Point,Digits);
         stoplossForBuying=NormalizeDouble(Bid-newStop(stopLossConstant)*Point,Digits);
         takeprofitForBuying=NormalizeDouble(Bid+newStop(takeProfitConstant)*Point,Digits);
         /**
            https://docs.mql4.com/trading/ordersend

            int  OrderSend(
            string   symbol,              // symbol
            int      cmd,                 // operation
            double   volume,              // volume
            double   price,               // price
            int      slippage,            // slippage
            double   stoploss,            // stop loss
            double   takeprofit,          // take profit
            string   comment=NULL,        // comment
            int      magic=0,             // magic number
            datetime expiration=0,        // pending order expiration
            color    arrow_color=clrNONE  // color
            );
         */
         // This CLOSES the order automatically
         RefreshRates();
         int buyTicket=OrderSend(Symbol(),OP_BUY,1,Ask,1,stoplossForBuying,takeprofitForBuying,"Buy order",16384,0,clrBlue);

         // This is NOT closing the order automatically
         //int buyTicket=MarketOrderSend(Symbol(),OP_BUY,1,priceToBuy,1,stoplossForBuying,takeprofitForBuying,"Buy order",0,clrBlue);
         //int buyTicket=OrderSend(Symbol(),OP_BUY,1,priceToBuy,1,0,0,"Buy order",16384,0,clrBlue);

         if(buyTicket<0)
           {
            Print("OrderSend for OP_BUY failed with error #",GetLastError());
            //Print("rderSend for OP_BUY failed with error #"+GetLastError(),"Debug",0);
           }
         else
           {
            //Print("OrderSend for OP_BUY placed successfully");
            //Print("OrderSend for OP_BUY placed successfully","Debug",0);
           }
        }
      doAlert(whichBar,"Down");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;

   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];
      message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS),"New Super Trend ",doWhat);
      if(alertsMessage)
        {
         Alert(message);
        }
      if(alertsEmail)
        {
         SendMail(StringConcatenate(Symbol(),"New Super Trend  "),message);
        }
      if(alertsSound)
        {
         PlaySound("alert2.wav");
        }
     }
  }


int MarketOrderSend(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment, int magic,string colour)
/**
   https://docs.mql4.com/trading/ordersend

   int  OrderSend(
   string   symbol,              // symbol
   int      cmd,                 // operation
   double   volume,              // volume
   double   price,               // price
   int      slippage,            // slippage
   double   stoploss,            // stop loss
   double   takeprofit,          // take profit
   string   comment=NULL,        // comment
   int      magic=0,             // magic number
   datetime expiration=0,        // pending order expiration
   color    arrow_color=clrNONE  // color
   );
*/
  {
   int ticket;

   ticket = OrderSend(symbol, cmd, volume, price, slippage, 0, 0, NULL, magic,colour);
   if(ticket <= 0)
      Print("OrderSend Error: ", GetLastError());
   else
     {
      bool res = OrderModify(ticket, 0, stoploss, takeprofit, 0);
      if(!res)
        {
         Print("OrderModify Error: ", GetLastError());
         Print("IMPORTANT: ORDER #", ticket, " HAS NO STOPLOSS AND TAKEPROFIT");
        }
     }
   return(ticket);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int newStop(int parameter)                      // Checking stop levels
  {
   int minDist=MarketInfo(Symbol(),MODE_STOPLEVEL);// Minimal distance
   if(parameter > minDist)                      // If less than allowed
     {
      parameter=minDist;                        // Sett allowed
      Print("Increased distance of stop level.");
     }
   return(parameter);                            // Returning value
  }
//+------------------------------------------------------------------+
