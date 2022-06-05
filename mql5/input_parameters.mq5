input int            MA_Period=14;
input int            MA_Shift=0;
input ENUM_MA_METHOD MA_Method=MODE_SMA;

input int            MA_Period2=14;        // Period
input int            MA_Shift2=0;          // Shift
input ENUM_MA_METHOD MA_Method2=MODE_SMA;  // Method

enum customEnum {
   value1=0,   // Red
   value2=1,   // Green
   value3=2,   // Blue
};

input customEnum     val=value1;    // Color

void OnInit() {}