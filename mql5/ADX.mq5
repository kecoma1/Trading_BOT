

int adx_h;
double main[];
double plus[];
double minus[];


int OnInit() {
   adx_h = iADX(_Symbol, _Period, 15);
   
   if (adx_h == INVALID_HANDLE) {
      Print("Error loading the indicator");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(main, true);
   ArraySetAsSeries(plus, true);
   ArraySetAsSeries(minus, true);
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   if (adx_h != INVALID_HANDLE) IndicatorRelease(adx_h);
}

void OnTick() {
   CopyBuffer(adx_h, MAIN_LINE, 1, 10, main);
   CopyBuffer(adx_h, PLUSDI_LINE, 1, 10, plus);
   CopyBuffer(adx_h, MINUSDI_LINE, 1, 10, minus);
}