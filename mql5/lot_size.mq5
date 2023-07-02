double getLotage(double percentage, long lot_size = 100000) {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   double to_use = percentage * balance;
   
   double lotes = to_use / lot_size;
   
   return NormalizeDouble(lotes, 2);
}


void OnInit() {
   double lotage = getLotage(0.10);
   
   Print("Lotaje: ", lotage);
}