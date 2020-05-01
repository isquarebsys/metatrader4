/**
 * Calculates the AveragePrice on a given chart and symbol
 * Simply compile and run it 
*/

void OnStart()
  {
   
   /** In Correct Method
   double AveragePrice = 0.0;   
   AveragePrice += High[0];
   AveragePrice += High[1]; 
   AveragePrice += High[2]; 
   AveragePrice += High[3]; 
   AveragePrice += High[4];   // ... and so on
   AveragePrice /= Bars;
   MessageBox("Average Price is "+AveragePrice,"Message box",0);
   */
   
   /** Correct Method */
   double AveragePriceNext = 0.0;   
   for(int a = 0; a < Bars; a++)
   {     
       AveragePriceNext += High[a];
   }
   MessageBox("Average Price is "+AveragePriceNext,"Message box",0);
  }

