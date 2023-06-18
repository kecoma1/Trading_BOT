
int OnInit() {
   long account_id = AccountInfoInteger(ACCOUNT_LOGIN);

   Print("Account ID: ", account_id);
   
   if (account_id != 5012711372) {
      Print("Cuenta inválida");
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}