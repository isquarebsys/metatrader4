void OnStart(){
   //MQL Get Spread Value
   //Get Spread Value with MarketInfo() 
   //and save the value in a variable
   double Spread=MarketInfo(0,MODE_SPREAD);
   //Showing a message box with the values
   MessageBox("Spread="+Spread);  
}

