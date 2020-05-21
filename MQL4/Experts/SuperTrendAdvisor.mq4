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


extern bool   ShowArrows       = true;
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = false;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;

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
      Print("Inside alertsOn");
      if(alertsOnCurrent)
         int whichBar = 0;
      else
         whichBar = 1;
      if(arrup[whichBar]  != EMPTY_VALUE)
        {
         Print("arrup[whichBar]");
         double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
         double priceToSell=Ask;
         //--- calculated SL and TP prices must be normalized
         double stoploss=NormalizeDouble(Bid-minstoplevel*Point,Digits);
         double takeprofit=NormalizeDouble(Bid+minstoplevel*Point,Digits);
         int sellTicket=OrderSend(Symbol(),0,1,priceToSell,1,0,0,"My order",16384,0,clrGreen);
         if(sellTicket<0)
           {
            Print("OrderSend failed with error #",GetLastError());
            Print("OrderSend failed with error #"+GetLastError(),"Debug",0);
           }
         else
            Print("OrderSend placed successfully");
            Print("OrderSend placed successfully","Debug",0);

        }
      doAlert(whichBar,"Up");
     }
   if(arrdwn[whichBar] != EMPTY_VALUE)
     {
      Print("arrdwn[whichBar]");
      //double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
      double priceToBuy=Ask;
      //--- calculated SL and TP prices must be normalized
      //double stoploss=NormalizeDouble(Bid-minstoplevel*Point,Digits);
      //double takeprofit=NormalizeDouble(Bid+minstoplevel*Point,Digits);
      int buyTicket=OrderSend(Symbol(),0,1,priceToBuy,1,0,0,"My order",16384,0,clrBlue);
      if(buyTicket<0)
        {
         Print("OrderSend failed with error #",GetLastError());
         Print("rderSend failed with error #"+GetLastError(),"Debug",0);
        }
      else
        {
         Print("OrderSend placed successfully");
         Print("OrderSend placed successfully","Debug",0);
        }
     }
   doAlert(whichBar,"Down");
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

//+------------------------------------------------------------------+
