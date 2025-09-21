//+------------------------------------------------------------------+
//|                                        smHiLoOpen Lines_v1.9.mq4
//+------------------------------------------------------------------+
#property copyright "Copyright SwingMan, 02.06.2016"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
//
/*-------------------------------------------------------------------
01.06.2016  v1.1  -  Draw options
02.06.2016  v1.2  -  Bug, H1 Higher/Lower Open values
-------------------------------------------------------------------*/

//-- inputs
//====================================================================
input bool TURN_OFF = false;
input bool Draw_Monthly_Lines = false;
input bool Draw_Weekly_Lines = false;
input bool Draw_Daily_Lines = true;
input bool Draw_Hourly_Lines = true;
input bool Draw_H4_Lines = true;
input bool Draw_M30_Lines = true;
input bool Draw_M15_Lines = true;
input bool Draw_M5_Lines = true;
input bool Draw_M1_Lines = true;
input bool Draw_PD_HOLO_Lines = true;
input bool Draw_Pip_Lines = true;
extern double PipIncrement = 5.0;
extern int NumPipLines = 5;

input bool Show_Time_Infos = true;
input string ____Shift_Factors____ = "";
extern int Shift_M1_Labels = 0;
extern int Shift_M5_Labels = 0;
extern int Shift_M15_Labels = 0;
extern int Shift_M30_Labels = 0;
extern int Shift_H1_Labels = 0;
extern int Shift_H4_Labels = 0;
extern int Shift_D1_Labels = 0;
extern int Shift_W1_Labels = 0;
extern int Shift_MN_Labels = 0;

input string ts0 = ""; //______Line Style_____
input ENUM_LINE_STYLE Line_Style_M1 = STYLE_SOLID;
input ENUM_LINE_STYLE Line_Style_M5 = STYLE_DASHDOTDOT;
input ENUM_LINE_STYLE Line_Style_M15 = STYLE_DOT;
input ENUM_LINE_STYLE Line_Style_M30 = STYLE_DOT;
input ENUM_LINE_STYLE Line_Style_H1 = STYLE_DASHDOT;
input ENUM_LINE_STYLE Line_Style_H4 = STYLE_DASH;
input ENUM_LINE_STYLE Line_Style_D1 = STYLE_SOLID;
input ENUM_LINE_STYLE Line_Style_W1 = STYLE_SOLID;
input ENUM_LINE_STYLE Line_Style_MN = STYLE_SOLID;
input ENUM_LINE_STYLE Pip_Line_Style = STYLE_DASH;

input string ts1 = ""; //______Line Width_____
input int Line_Width_M1 = 1;
input int Line_Width_M5 = 1;
input int Line_Width_M15 = 1;
input int Line_Width_M30 = 1;
input int Line_Width_H1 = 1;
input int Line_Width_H4 = 1;
input int Line_Width_D1 = 1;
input int Line_Width_W1 = 2;
input int Line_Width_MN = 2;
input int Pip_Line_Width = 1;

input string s0 = ""; //______Previous Day_____
input bool Draw_OpenLine_Previous_Day = true;
input bool Draw_HiLoLines_Previous_Day = true;
input bool Draw_PriceBoxes_Previous_Day = true;
input bool Draw_Texts_Previous_Day = true;
input string s1 = " "; //______Current Day_____
input bool Draw_OpenLine_Current_Day = true;
input bool Draw_HiLoLines_Current_Day = true;
input bool Draw_PriceBoxes_Current_Day = true;
input bool Draw_Texts_Current_Day = true;
input string s2 = " "; //______Current H1_____
input bool Draw_OpenLine_Current_H1 = false;
input bool Draw_PriceBox_Current_H1 = false;
input bool Draw_Text_Current_H1 = false;
input string s3 = " "; //____Extreme H1-Open of the Day___
input bool Draw_ExtremeOpenLines_Current_Day = true;
input bool Draw_ExtremeOpen_PriceBoxes = true;
input bool Draw_ExtremeOpen_Texts = true;

input bool Draw_PriceBoxes_Weekly = true;
input bool Draw_Text_Weekly = true;
input bool Draw_PriceBoxes_Monthly = true;
input bool Draw_Text_Monthly = true;

input string ts2 = ""; //______Ask Bid_____
input bool Draw_Ask_Bid = true;
input int AskWingDing = 165;
input int BidWingDing = 165;
input int TextPostion = 4;

input string ____Line_Colors____ = "";
input color colorOpenHi = clrMaroon;
input color colorOpenLo = clrDodgerBlue;
input color colorOpen = clrYellow;
input color colorHigh = clrRed;
input color colorLow = clrBlue;
extern color pip_line_color = clrYellow;

input string ____Ask_Bid_Colors____ = "";
input color colorAsk = clrYellow;
input color colorBid = clrYellow;

input string ____Trend____ = "";
input bool Draw_Trend = false;
input int Trend_Bars = 0;
input color colorTrendUp = clrDarkGreen;
input color colorTrendDn = clrFireBrick;
input int Trend_Style = 0;
input int Trend_Width = 1;

input bool Draw_TradeAid = false;
input bool SHADE_HOLO = false;

//================================
//
//---- constants
string CR = "\n";
string sObj = "Hilo_";
//---- variables
double AskBuffer[], BidBuffer[];
double PriceLevel[50], TheSpread, DAILYHIGH, DAILYLOW, YESTERDAYHIGH, YESTERDAYLOW, DISTANCE, PRICE;
int ArrayIndex;
int TBars, BarsInARow;
bool TDirection;
string InARow, TEXT;
int digits;
double point;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   IndicatorDigits(Digits);
   digits = Digits;
   point = Point;

   if (digits == 5 || digits == 3) {
      digits = digits - 1;
      point = point * 10;
   }

   if (Draw_Ask_Bid) {
      SetIndexBuffer(0, AskBuffer);
      SetIndexBuffer(1, BidBuffer);
      SetIndexArrow(0, AskWingDing);
      SetIndexArrow(1, BidWingDing);
      SetIndexStyle(0, DRAW_ARROW, 2, 1, colorAsk);
      SetIndexStyle(1, DRAW_ARROW, 2, 1, colorBid);

   }

   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   Comment("");

   //-- delete objects   
   long chartID = ChartID();
   ObjectsDeleteAll(chartID, sObj);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
   const int prev_calculated,
      const datetime & time[],
         const double & open[],
            const double & high[],
               const double & low[],
                  const double & close[],
                     const long & tick_volume[],
                        const long & volume[],
                           const int & spread[]) {
   //---
   if (TURN_OFF) {
      OnDeinit(0);
      return (0);
   }
   OnDeinit(1);

   //int i,limit;

   for (int p = 0; p < 50; p++) {
      PriceLevel[p] = EMPTY_VALUE;
   }

   DAILYHIGH = iHigh(Symbol(), PERIOD_D1, 0);
   DAILYLOW = iLow(Symbol(), PERIOD_D1, 0);

   YESTERDAYHIGH = iHigh(Symbol(), PERIOD_D1, 1);
   YESTERDAYLOW = iLow(Symbol(), PERIOD_D1, 1);
   //---
   /*
      if(Show_Time_Infos)
         Show_TimeInfos();
   */
   //---
   ArrayIndex = 0;
   ArrayInitialize(PriceLevel, EMPTY_VALUE);

   if (Draw_Daily_Lines)
      Draw_D1_Lines();

   if (Period() < PERIOD_D1) {
      if (Draw_H4_Lines)
         vDraw_H4_Lines();

      if (Draw_Hourly_Lines)
         Draw_H1_Lines();

      if (Draw_M30_Lines)
         vDraw_M30_Lines();

      if (Draw_M15_Lines)
         vDraw_M15_Lines();

      if (Draw_M5_Lines)
         vDraw_M5_Lines();

      if (Draw_M1_Lines)
         vDraw_M1_Lines();

      if (Draw_Trend)
         Draw_TrendLine();

      if (Draw_PD_HOLO_Lines)
         Draw_PD_H1_Lines();

      if (Draw_Weekly_Lines)
         Draw_WEEKLY_Lines();

      if (Draw_Monthly_Lines)
         Draw_MONTHLY_Lines();

      if (Draw_Ask_Bid) {
         for (int p = 0; p < 50; p++) {
            AskBuffer[p] = EMPTY_VALUE;
            BidBuffer[p] = EMPTY_VALUE;
         }

         AskBuffer[0] = NormalizeDouble(Ask, Digits);
         BidBuffer[0] = NormalizeDouble(Bid, Digits);
      }
   }

   if (Show_Time_Infos)
      Show_TimeInfos();

   if (Draw_TradeAid)
      Draw_TRADEAID();

   //--- return value of prev_calculated for next call
   return (rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_D1_Lines() {
   string objectName;
   double open0, high0, low0, close0;
   double open1, high1, low1;
   datetime time0pen0, timeOpen1, timeCurr;

   open0 = iOpen(Symbol(), PERIOD_D1, 0);
   high0 = iHigh(Symbol(), PERIOD_D1, 0);
   low0 = iLow(Symbol(), PERIOD_D1, 0);
   close0 = iClose(Symbol(), PERIOD_D1, 0);

   open1 = iOpen(Symbol(), PERIOD_D1, 1);
   high1 = iHigh(Symbol(), PERIOD_D1, 1);
   low1 = iLow(Symbol(), PERIOD_D1, 1);

   time0pen0 = iTime(Symbol(), PERIOD_D1, 0);
   timeOpen1 = iTime(Symbol(), PERIOD_D1, 1);
   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_D1_Labels * 60;

   TEXT =
      //-- draw lines      
      objectName = sObj + "D1_0open";
   Draw_HorizontalLine(objectName, open0, time0pen0, timeCurr, "D1[0] Open", colorOpen, Line_Style_D1, Line_Width_D1);

   //   DISTANCE = ( DAILYHIGH - close0 ) / Point / 10.0 ; //  " + DoubleToStr(DISTANCE,1);
   //  TEXT     = "D1[0] High " + DoubleToStr(DISTANCE,1);

   objectName = sObj + "D1_0high";
   Draw_HorizontalLine(objectName, high0, time0pen0, timeCurr, "D1[0] High", colorHigh, Line_Style_D1, Line_Width_D1);

   objectName = sObj + "D1_0low";
   Draw_HorizontalLine(objectName, low0, time0pen0, timeCurr, "D1[0] Low", colorLow, Line_Style_D1, Line_Width_D1);

   objectName = sObj + "D1_1open";
   Draw_HorizontalLine(objectName, open1, timeOpen1, timeCurr, "D1[1] Open", colorOpen, Line_Style_D1, Line_Width_D1);
   objectName = sObj + "D1_1high";
   Draw_HorizontalLine(objectName, high1, timeOpen1, timeCurr, "D1[1] High", colorHigh, Line_Style_D1, Line_Width_D1);
   objectName = sObj + "D1_1low";
   Draw_HorizontalLine(objectName, low1, timeOpen1, timeCurr, "D1[1] Low", colorLow, Line_Style_D1, Line_Width_D1);
}

//+------------------------------------------------------------------+
void vDraw_M5_Lines() {
   string objectName;
   double open0, dHigherOpen, dLowerOpen;
   datetime time0pen0, timeHigherOpen, timeLower0pen, timeCurr;
   string sHigherOpen, sLowerOpen;

   //-- 1. current open ---------------------------------------------------
   open0 = iOpen(Symbol(), PERIOD_M5, 0);
   time0pen0 = iTime(Symbol(), PERIOD_M5, 0);
   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_M5_Labels * 60;
   //-- draw line      
   objectName = sObj + "M5_0open";
   Draw_HorizontalLine(objectName, open0, time0pen0, timeCurr, "M5[0] Open", colorOpen, Line_Style_M5, Line_Width_M5);

   //-- 2. highest daily M5 open ------------------------------------------
   datetime timeDailyOpen = iTime(Symbol(), PERIOD_D1, 0);
   int currentDailyBars = iBarShift(Symbol(), PERIOD_M5, timeDailyOpen, true);

   int iBarHigherOpen = iHighest(Symbol(), PERIOD_M5, MODE_OPEN, currentDailyBars + 1, 0); //-- on M5
   dHigherOpen = iOpen(Symbol(), PERIOD_M5, iBarHigherOpen);
   timeHigherOpen = iTime(Symbol(), PERIOD_M5, iBarHigherOpen);
   iBarHigherOpen = iBarShift(Symbol(), Period(), timeHigherOpen, true); //-- on M5

   //-- draw line
   DISTANCE = (DAILYHIGH - dHigherOpen) / Point / 10.0;
   sHigherOpen = "M5[" + (string) iBarHigherOpen + "] Higher Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "M5_HigherOpen";
   Draw_HorizontalLine(objectName, dHigherOpen, timeHigherOpen, timeCurr, sHigherOpen, colorOpenHi, Line_Style_M5, Line_Width_M5);

   //-- 3. lovest daily M5 open -------------------------------------------
   int iBarLowerOpen = iLowest(Symbol(), PERIOD_M5, MODE_OPEN, currentDailyBars + 1, 0); //-- on M5
   dLowerOpen = iOpen(Symbol(), PERIOD_M5, iBarLowerOpen);
   timeLower0pen = iTime(Symbol(), PERIOD_M5, iBarLowerOpen);
   iBarLowerOpen = iBarShift(Symbol(), Period(), timeLower0pen, true); //-- on M5

   DISTANCE = (dLowerOpen - DAILYLOW) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sLowerOpen = "M5[" + (string) iBarLowerOpen + "] Lower Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "M5_LowerOpen";
   Draw_HorizontalLine(objectName, dLowerOpen, timeLower0pen, timeCurr, sLowerOpen, colorOpenLo, Line_Style_M5, Line_Width_M5);
}

//+------------------------------------------------------------------+
void vDraw_M15_Lines() {
   string objectName;
   double open0, dHigherOpen, dLowerOpen;
   datetime time0pen0, timeHigherOpen, timeLower0pen, timeCurr;
   string sHigherOpen, sLowerOpen;

   //-- 1. current open ---------------------------------------------------
   open0 = iOpen(Symbol(), PERIOD_M15, 0);
   time0pen0 = iTime(Symbol(), PERIOD_M15, 0);
   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_M15_Labels * 60;
   //-- draw line      
   objectName = sObj + "M15_0open";
   Draw_HorizontalLine(objectName, open0, time0pen0, timeCurr, "M15[0] Open", colorOpen, Line_Style_M15, Line_Width_M15);

   //-- 2. highest daily M15 open ------------------------------------------
   datetime timeDailyOpen = iTime(Symbol(), PERIOD_D1, 0);
   int currentDailyBars = iBarShift(Symbol(), PERIOD_M15, timeDailyOpen, true);

   int iBarHigherOpen = iHighest(Symbol(), PERIOD_M15, MODE_OPEN, currentDailyBars + 1, 0); //-- on M15
   dHigherOpen = iOpen(Symbol(), PERIOD_M15, iBarHigherOpen);
   timeHigherOpen = iTime(Symbol(), PERIOD_M15, iBarHigherOpen);
   iBarHigherOpen = iBarShift(Symbol(), Period(), timeHigherOpen, true); //-- on M15

   //-- draw line
   DISTANCE = (DAILYHIGH - dHigherOpen) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sHigherOpen = "M15[" + (string) iBarHigherOpen + "] Higher Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "M15_HigherOpen";
   Draw_HorizontalLine(objectName, dHigherOpen, timeHigherOpen, timeCurr, sHigherOpen, colorOpenHi, Line_Style_M15, Line_Width_M15);

   //-- 3. lovest daily M15 open -------------------------------------------
   int iBarLowerOpen = iLowest(Symbol(), PERIOD_M15, MODE_OPEN, currentDailyBars + 1, 0); //-- on M15
   dLowerOpen = iOpen(Symbol(), PERIOD_M15, iBarLowerOpen);
   timeLower0pen = iTime(Symbol(), PERIOD_M15, iBarLowerOpen);
   iBarLowerOpen = iBarShift(Symbol(), Period(), timeLower0pen, true); //-- on M15

   DISTANCE = (dLowerOpen - DAILYLOW) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sLowerOpen = "M15[" + (string) iBarLowerOpen + "] Lower Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "M15_LowerOpen";
   Draw_HorizontalLine(objectName, dLowerOpen, timeLower0pen, timeCurr, sLowerOpen, colorOpenLo, Line_Style_M15, Line_Width_M15);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_H1_Lines() {
   string objectName;
   double open0, dHigherOpen, dLowerOpen;
   datetime time0pen0, timeHigherOpen, timeLower0pen, timeCurr;
   string sHigherOpen, sLowerOpen;

   //-- 1. current open ---------------------------------------------------
   open0 = iOpen(Symbol(), PERIOD_H1, 0);
   time0pen0 = iTime(Symbol(), PERIOD_H1, 0);
   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_H1_Labels * 60;
   //-- draw line      
   objectName = sObj + "H1_0open";
   Draw_HorizontalLine(objectName, open0, time0pen0, timeCurr, "H1[0] Open", colorOpen, Line_Style_H1, Line_Width_H1);

   //-- 2. highest daily H1 open ------------------------------------------
   datetime timeDailyOpen = iTime(Symbol(), PERIOD_D1, 0);
   int currentDailyBars = iBarShift(Symbol(), PERIOD_H1, timeDailyOpen, true);

   int iBarHigherOpen = iHighest(Symbol(), PERIOD_H1, MODE_OPEN, currentDailyBars + 1, 0); //-- on H1
   dHigherOpen = iOpen(Symbol(), PERIOD_H1, iBarHigherOpen);
   timeHigherOpen = iTime(Symbol(), PERIOD_H1, iBarHigherOpen);
   iBarHigherOpen = iBarShift(Symbol(), Period(), timeHigherOpen, true); //-- on M15

   //-- draw line
   DISTANCE = (DAILYHIGH - dHigherOpen) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sHigherOpen = "H1[" + (string) iBarHigherOpen + "] Higher Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "H1_HigherOpen";
   Draw_HorizontalLine(objectName, dHigherOpen, timeHigherOpen, timeCurr, sHigherOpen, colorOpenHi, Line_Style_H1, Line_Width_H1);

   if (SHADE_HOLO) {
      DrawRectangle(sObj + "HO", timeHigherOpen, dHigherOpen, timeCurr, iHigh(Symbol(), PERIOD_D1, 0), colorOpenHi);
   }

   //-- 3. lowest daily H1 open -------------------------------------------
   int iBarLowerOpen = iLowest(Symbol(), PERIOD_H1, MODE_OPEN, currentDailyBars + 1, 0); //-- on H1
   dLowerOpen = iOpen(Symbol(), PERIOD_H1, iBarLowerOpen);
   timeLower0pen = iTime(Symbol(), PERIOD_H1, iBarLowerOpen);
   iBarLowerOpen = iBarShift(Symbol(), Period(), timeLower0pen, true); //-- on M15

   DISTANCE = (dLowerOpen - DAILYLOW) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sLowerOpen = "H1[" + (string) iBarLowerOpen + "] Lower Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "H1_LowerOpen";
   Draw_HorizontalLine(objectName, dLowerOpen, timeLower0pen, timeCurr, sLowerOpen, colorOpenLo, Line_Style_H1, Line_Width_H1);

   if (SHADE_HOLO) {
      DrawRectangle(sObj + "LO", timeLower0pen, dLowerOpen, timeCurr, iLow(Symbol(), PERIOD_D1, 0), colorOpenLo);
   }

   if (!Draw_Hourly_Lines) {
      return;
   }
   if (!Draw_Pip_Lines) {
      return;
   }

   int PipBar, pip, idx;
   datetime PipTime;
   double pips, pip_price, Line_price, myPoint, pip_dir, H, L;
   string sLine_price, sOpenText;
   bool xoverUp, xoverDn;

   myPoint = Point * 10.0;

   xoverDn = false;
   xoverUp = false;

   for (idx = 0; idx < currentDailyBars; idx++) {
      H = iHigh(NULL, PERIOD_H1, idx);
      L = iLow(NULL, PERIOD_H1, idx);

      if (L < dLowerOpen) {
         xoverDn = true;
         break;
      } else
      if (H > dHigherOpen) {
         xoverUp = true;
         break;
      }
   }

   if (iBarLowerOpen < iBarHigherOpen || xoverDn) {
      PipTime = timeLower0pen;
      pip_price = dLowerOpen;
      PipBar = iBarLowerOpen;
      pip_dir = 1.0;
      sOpenText = "Lower Open ";

   } else {
      PipTime = timeHigherOpen;
      pip_price = dHigherOpen;
      PipBar = iBarHigherOpen;
      pip_dir = -1.0;
      sOpenText = "Higher Open ";
   }

   for (pip = 1; pip <= NumPipLines; pip++) {
      pips = (PipIncrement * pip) * myPoint;
      Line_price = pip_price + (pips * pip_dir);
      objectName = sObj + "piplines" + DoubleToString(pip, 5);
      sLine_price = sOpenText + DoubleToStr(PipIncrement * pip * pip_dir, 0);
      Draw_HorizontalLine(objectName, Line_price, PipTime, timeCurr, sLine_price, pip_line_color, Pip_Line_Style, Pip_Line_Width);

   } // for

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void vDraw_H4_Lines() {
   string objectName;
   double open0, dHigherOpen, dLowerOpen;
   datetime time0pen0, timeHigherOpen, timeLower0pen, timeCurr;
   string sHigherOpen, sLowerOpen;

   //-- 1. current open ---------------------------------------------------
   open0 = iOpen(Symbol(), PERIOD_H4, 0);
   time0pen0 = iTime(Symbol(), PERIOD_H4, 0);
   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_H4_Labels * 60;
   //-- draw line      
   objectName = sObj + "H4_0open";
   Draw_HorizontalLine(objectName, open0, time0pen0, timeCurr, "H4[0] Open", colorOpen, Line_Style_H4, Line_Width_H4);

   //-- 2. highest daily H4 open ------------------------------------------
   datetime timeDailyOpen = iTime(Symbol(), PERIOD_D1, 0);
   int currentDailyBars = iBarShift(Symbol(), PERIOD_H4, timeDailyOpen, true);

   int iBarHigherOpen = iHighest(Symbol(), PERIOD_H4, MODE_OPEN, currentDailyBars + 1, 0); //-- on H4
   dHigherOpen = iOpen(Symbol(), PERIOD_H4, iBarHigherOpen);
   timeHigherOpen = iTime(Symbol(), PERIOD_H4, iBarHigherOpen);
   iBarHigherOpen = iBarShift(Symbol(), Period(), timeHigherOpen, true); //-- on M15

   //-- draw line
   DISTANCE = (DAILYHIGH - dHigherOpen) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sHigherOpen = "H4[" + (string) iBarHigherOpen + "] Higher Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "H4_HigherOpen";
   Draw_HorizontalLine(objectName, dHigherOpen, timeHigherOpen, timeCurr, sHigherOpen, colorOpenHi, Line_Style_H4, Line_Width_H4);

   //-- 3. lovest daily H4 open -------------------------------------------
   int iBarLowerOpen = iLowest(Symbol(), PERIOD_H4, MODE_OPEN, currentDailyBars + 1, 0); //-- on H4
   dLowerOpen = iOpen(Symbol(), PERIOD_H4, iBarLowerOpen);
   timeLower0pen = iTime(Symbol(), PERIOD_H4, iBarLowerOpen);
   iBarLowerOpen = iBarShift(Symbol(), Period(), timeLower0pen, true); //-- on M15

   DISTANCE = (dLowerOpen - DAILYLOW) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sLowerOpen = "H4[" + (string) iBarLowerOpen + "] Lower Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "H4_LowerOpen";
   Draw_HorizontalLine(objectName, dLowerOpen, timeLower0pen, timeCurr, sLowerOpen, colorOpenLo, Line_Style_H4, Line_Width_H4);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_HorizontalLine(string objNameX, double price1, datetime time1, datetime time2, string sText, color dColor, int style, int width) {

   string objName;
   int anchor = ANCHOR_LEFT;
   bool draw_DCurr_Open, draw_DCurr_Hilo, draw_DCurr_PBox, draw_DCurr_Text;
   bool draw_DPrev_Open, draw_DPrev_Hilo, draw_DPrev_PBox, draw_DPrev_Text;

   bool draw_HCurr_Open, draw_HCurr_PBox, draw_HCurr_Text;
   bool draw_Extr_Open, draw_Extr_PBox, draw_Extr_Text;
   bool draw_Weekly, draw_Weekly_PBox, draw_Weekly_Text;
   bool draw_Monthly, draw_Monthly_PBox, draw_Monthly_Text;

   //-- current daily
   draw_DCurr_Open = (sText == "D1[0] Open" && Draw_OpenLine_Current_Day);
   draw_DCurr_Hilo = ((sText == "D1[0] High" || sText == "D1[0] Low") && Draw_HiLoLines_Current_Day);
   draw_DCurr_PBox = ((sText == "D1[0] Open" || sText == "D1[0] High" || sText == "D1[0] Low") && Draw_PriceBoxes_Current_Day);
   draw_DCurr_Text = ((sText == "D1[0] Open" || sText == "D1[0] High" || sText == "D1[0] Low") && Draw_Texts_Current_Day);
   //-- previous daily
   draw_DPrev_Open = (sText == "D1[1] Open" && Draw_OpenLine_Previous_Day);
   draw_DPrev_Hilo = ((sText == "D1[1] High" || sText == "D1[1] Low") && Draw_HiLoLines_Previous_Day);
   draw_DPrev_PBox = ((sText == "D1[1] Open" || sText == "D1[1] High" || sText == "D1[1] Low") && Draw_PriceBoxes_Previous_Day);
   draw_DPrev_Text = ((sText == "D1[1] Open" || sText == "D1[1] High" || sText == "D1[1] Low") && Draw_Texts_Previous_Day);
   //-- H1 current Open
   draw_HCurr_Open = (sText == "H1[0] Open" && Draw_OpenLine_Current_H1);
   draw_HCurr_PBox = (sText == "H1[0] Open" && Draw_PriceBox_Current_H1);
   draw_HCurr_Text = (sText == "H1[0] Open" && Draw_Text_Current_H1);
   //-- H1 Extreme Open values
   draw_Extr_Open = ((StringFind(sText, "Higher Open") >= 0 || StringFind(sText, "Lower Open") >= 0) && Draw_ExtremeOpenLines_Current_Day);
   draw_Extr_PBox = ((StringFind(sText, "Higher Open") >= 0 || StringFind(sText, "Lower Open") >= 0) && Draw_ExtremeOpen_PriceBoxes);
   draw_Extr_Text = ((StringFind(sText, "Higher Open") >= 0 || StringFind(sText, "Lower Open") >= 0) && Draw_ExtremeOpen_Texts);

   draw_Weekly = (StringFind(sText, "W1") >= 0);
   draw_Weekly_PBox = (draw_Weekly && Draw_PriceBoxes_Weekly);
   draw_Weekly_Text = (draw_Weekly && Draw_Text_Weekly);

   draw_Monthly = (StringFind(sText, "MN") >= 0);
   draw_Monthly_PBox = (draw_Monthly && Draw_PriceBoxes_Monthly);
   draw_Monthly_Text = (draw_Monthly && Draw_Text_Monthly);

   //-- draw lines   
   if (draw_DCurr_Open || draw_DCurr_Hilo || draw_DPrev_Open || draw_DPrev_Hilo || draw_HCurr_Open || draw_Extr_Open || draw_Weekly || draw_Monthly) {

      bool PriceFound = false;

      for (int p = 0; p < 50; p++) {
         if (PriceLevel[p] == price1) {
            PriceFound = true;
            break;
         }
         if (PriceLevel[p] == EMPTY_VALUE) {
            break;
         }
      }

      if (PriceFound) {
         return;
      } else {
         PriceLevel[ArrayIndex] = price1;
         ArrayIndex = ArrayIndex + 1;
      }

      objName = objNameX;
      ObjectDelete(objName);
      ObjectCreate(objName, OBJ_TREND, 0, time1, price1, time2, price1);
      ObjectSet(objName, OBJPROP_COLOR, dColor);
      ObjectSet(objName, OBJPROP_STYLE, style);
      ObjectSet(objName, OBJPROP_WIDTH, width);
      ObjectSet(objName, OBJPROP_RAY_RIGHT, false);
   }

   //-- draw values
   if (draw_DCurr_PBox || draw_DPrev_PBox || draw_HCurr_PBox || draw_Extr_PBox || draw_Weekly_PBox || draw_Monthly_PBox) {
      objName = objNameX + "Val";
      ObjectDelete(objName);
      ObjectCreate(objName, OBJ_ARROW_RIGHT_PRICE, 0, time2, price1);
      ObjectSet(objName, OBJPROP_COLOR, dColor);
   }

   //-- draw text   
   //   datetime time3;

   int Chart_Scale, Bar_Width;
   Chart_Scale = ChartScaleGet();

   //Set bar widths             
   if (Chart_Scale == 0) {
      Bar_Width = 64;
   } else {
      if (Chart_Scale == 1) {
         Bar_Width = 32;
      } else {
         if (Chart_Scale == 2) {
            Bar_Width = 16;
         } else {
            if (Chart_Scale == 3) {
               Bar_Width = 8;
            } else {
               if (Chart_Scale == 4) {
                  Bar_Width = 4;
               } else {
                  Bar_Width = 2;
               }
            }
         }
      }
   }

   datetime time3 = Time[0] + Period() * 60 * Bar_Width;

   if (draw_DCurr_Text || draw_DPrev_Text || draw_HCurr_Text || draw_Extr_Text || draw_Weekly_Text || draw_Monthly_Text) {
      /* 
            if(draw_DCurr_PBox || draw_DPrev_PBox || draw_HCurr_PBox || draw_Extr_PBox)
               time3=time2+Period()*TextPostion*60;
            else
               time3=time2+Period()*1*60;
      */
      objName = objNameX + "Txt";
      ObjectDelete(objName);
      ObjectCreate(objName, OBJ_TEXT, 0, time3, price1);
      ObjectSet(objName, OBJPROP_ANCHOR, anchor);
      ObjectSetText(objName, sText, 8, "Courier New", dColor);
   }

}
//+------------------------------------------------------------------+

string fFill(string filled, int f) {
   string FILLED;

   FILLED = StringSubstr(filled + "                                         ", 0, f);

   return (FILLED);
}

//+------------------------------------------------------------------+
void Show_TimeInfos() {
   datetime timeServer, timeLocal, timeGMT, timeBarHour;
   //datetime timeOpen;

   string sIndiName = "=== " + WindowExpertName() + " ===";

   timeServer = TimeCurrent();
   timeLocal = TimeLocal();
   timeGMT = TimeGMT();
   //timeOpen  =iTime(Symbol(),Period(),0);
   timeBarHour = iTime(Symbol(), PERIOD_H1, 0);

   string sTimeLeft;
   double ii;
   long m = iTime(Symbol(), Period(), 0) + Period() * 60 - TimeCurrent();
   ii = m / 60.0;
   long s = m % 60;

   m = (m - m % 60) / 60;

   long h = m / 60;
   m = m - (h * 60);
   long d = h / 24;
   h = h - (d * 24);

   if (Period() <= PERIOD_D1) {
      sTimeLeft = DoubleToString(h, 0) + "h " + DoubleToString(m, 0) + "m " + DoubleToString(s, 0) + "s";
   } else {
      sTimeLeft = DoubleToString(d, 0) + "d " + DoubleToString(h, 0) + "h " + DoubleToString(m, 0) + "m ";
   }

   TheSpread = ((Ask - Bid) / Point) / 10.0;

   string BOmessage = "";

   if (Close[0] > YESTERDAYHIGH) {
      BOmessage = "EXTREME CAUTION: PRICE ABOVE YESTERDAY HIGH";
   }
   if (Close[0] < YESTERDAYLOW) {
      BOmessage = "EXTREME CAUTION: PRICE BELOW YESTERDAY LOW";
   }

   if (iHigh(Symbol(), PERIOD_M5, 0) == DAILYHIGH) {
      BOmessage = "WARNING: M5 HIGH BREAKOUT";
   }
   if (iHigh(Symbol(), PERIOD_M15, 0) == DAILYHIGH) {
      BOmessage = "WARNING: M15 HIGH BREAKOUT";
   }
   if (iHigh(Symbol(), PERIOD_M30, 0) == DAILYHIGH) {
      BOmessage = "WARNING: M30 HIGH BREAKOUT";
   }
   if (iHigh(Symbol(), PERIOD_H1, 0) == DAILYHIGH) {
      BOmessage = "WARNING: H1 HIGH BREAKOUT";
   }

   if (iLow(Symbol(), PERIOD_M5, 0) == DAILYLOW) {
      BOmessage = "WARNING: M5 LOW BREAKOUT";
   }
   if (iLow(Symbol(), PERIOD_M15, 0) == DAILYLOW) {
      BOmessage = "WARNING: M15 LOW BREAKOUT";
   }
   if (iLow(Symbol(), PERIOD_M30, 0) == DAILYLOW) {
      BOmessage = "WARNING: M30 LOW BREAKOUT";
   }
   if (iLow(Symbol(), PERIOD_H1, 0) == DAILYLOW) {
      BOmessage = "WARNING: H1 LOW BREAKOUT";
   }

   string ATRmessage = "";

   double range = (iHigh(Symbol(), PERIOD_D1, 0) - iLow(Symbol(), PERIOD_D1, 0)) / point;
   double atr = iATR(Symbol(), PERIOD_D1, 100, 0) / point;
   double ra = (range / atr) * 100.00;
   Comment(

      "", CR, "$$$ TooSlow Version $$$", "", CR,
      sIndiName, CR,
      "Time Local  : ", TimeToString(timeLocal, TIME_DATE | TIME_MINUTES), CR,
      "Time Server : ", TimeToString(timeServer, TIME_DATE | TIME_MINUTES), CR,
      "Time GMT    : ", TimeToString(timeGMT, TIME_DATE | TIME_MINUTES), CR,
      //           "Time BarHour.... ",TimeToString(timeBarHour,TIME_DATE|TIME_MINUTES),CR,
      "Bar ends in : " + sTimeLeft, CR,
      "Spread Pips : " + DoubleToStr(TheSpread, 1), CR,
      "Daily Range : " + DoubleToStr(range, 0), CR,
      "Daily ATR(100) : " + DoubleToStr(atr, 0), CR,
      "Range/ATR(100) : " + DoubleToStr(ra, 0) + "%", CR,
      InARow, CR, CR,
      //"Time BarOpen... ",TimeToString(timeOpen,TIME_DATE|TIME_MINUTES)
      BOmessage, CR,
      ""
   );

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_TrendLine() {
   string objectName;
   color Trend_Color;

   objectName = sObj + "TrendLine";

   TDirection = Open[0] >= Open[1];

   if (Trend_Bars > 0) {
      TBars = Trend_Bars;
      InARow = "";
   } else {
      for (TBars = 0; TBars < 1000; TBars++) {
         if (TDirection && Open[TBars] >= Open[TBars + 1]) {
            continue;
         }
         if (!TDirection && Open[TBars] <= Open[TBars + 1]) {
            continue;
         }
         break;
      }

      BarsInARow = TBars;
      if (TDirection) {
         InARow = DoubleToString(BarsInARow, 5) + " Higher opens in a row";
      } else {
         InARow = DoubleToString(BarsInARow, 5) + " Lower opens in a row";
      }
   }

   if (Open[0] >= Open[TBars]) {
      Trend_Color = colorTrendUp;
   } else {
      Trend_Color = colorTrendDn;
   }

   ObjectDelete(objectName);
   ObjectCreate(objectName, OBJ_TREND, 0, Time[TBars], Open[TBars], Time[0], Open[0]);
   ObjectSet(objectName, OBJPROP_COLOR, Trend_Color);
   ObjectSet(objectName, OBJPROP_STYLE, Trend_Style);
   ObjectSet(objectName, OBJPROP_WIDTH, Trend_Width);
   ObjectSet(objectName, OBJPROP_RAY, false);
}
//+-------------------------------------------------------------------------------------------+
//| Subroutine:  Get the chart scale number                                                   |
//+-------------------------------------------------------------------------------------------+
int ChartScaleGet() {
   long result = -1;
   ChartGetInteger(0, CHART_SCALE, 0, result);
   return ((int) result);
}

//+------------------------------------------------------------------+
void Draw_PD_H1_Lines() {
   string objectName;
   double dHigherOpen, dLowerOpen;
   datetime timeHigherOpen, timeLower0pen, timeCurr;
   string sHigherOpen, sLowerOpen;

   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_H1_Labels * 60;

   //-- 2. highest daily H1 open ------------------------------------------
   datetime timeDailyOpen = iTime(Symbol(), PERIOD_D1, 1);
   int currentDailyBars = iBarShift(Symbol(), PERIOD_H1, timeDailyOpen, true);

   int iBarHigherOpen = iHighest(Symbol(), PERIOD_H1, MODE_OPEN, 24, currentDailyBars - 23); //-- on H1
   dHigherOpen = iOpen(Symbol(), PERIOD_H1, iBarHigherOpen);
   timeHigherOpen = iTime(Symbol(), PERIOD_H1, iBarHigherOpen);
   iBarHigherOpen = iBarShift(Symbol(), Period(), timeHigherOpen, true); //-- on M15

   //-- draw line
   sHigherOpen = "H1[" + (string) iBarHigherOpen + "] PD Higher Open ";
   objectName = sObj + "PDH1_HigherOpen";
   Draw_HorizontalLine(objectName, dHigherOpen, timeHigherOpen, timeCurr, sHigherOpen, colorOpenHi, Line_Style_H1, Line_Width_H1);

   //-- 3. lovest daily H1 open -------------------------------------------
   int iBarLowerOpen = iLowest(Symbol(), PERIOD_H1, MODE_OPEN, 24, currentDailyBars - 23); //-- on H1
   dLowerOpen = iOpen(Symbol(), PERIOD_H1, iBarLowerOpen);
   timeLower0pen = iTime(Symbol(), PERIOD_H1, iBarLowerOpen);
   iBarLowerOpen = iBarShift(Symbol(), Period(), timeLower0pen, true); //-- on M15

   sLowerOpen = "H1[" + (string) iBarLowerOpen + "] PD Lower Open";
   objectName = sObj + "PDH1_LowerOpen";
   Draw_HorizontalLine(objectName, dLowerOpen, timeLower0pen, timeCurr, sLowerOpen, colorOpenLo, Line_Style_H1, Line_Width_H1);

}
//+------------------------------------------------------------------+
void vDraw_M30_Lines() {
   string objectName;
   double open0, dHigherOpen, dLowerOpen;
   datetime time0pen0, timeHigherOpen, timeLower0pen, timeCurr;
   string sHigherOpen, sLowerOpen;

   //-- 1. current open ---------------------------------------------------
   open0 = iOpen(Symbol(), PERIOD_M30, 0);
   time0pen0 = iTime(Symbol(), PERIOD_M30, 0);
   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_M30_Labels * 60;
   //-- draw line      
   objectName = sObj + "M30_0open";
   Draw_HorizontalLine(objectName, open0, time0pen0, timeCurr, "M30[0] Open", colorOpen, Line_Style_M30, Line_Width_M30);

   //-- 2. highest daily M30 open ------------------------------------------
   datetime timeDailyOpen = iTime(Symbol(), PERIOD_D1, 0);
   int currentDailyBars = iBarShift(Symbol(), PERIOD_M30, timeDailyOpen, true);

   int iBarHigherOpen = iHighest(Symbol(), PERIOD_M30, MODE_OPEN, currentDailyBars + 1, 0); //-- on M30
   dHigherOpen = iOpen(Symbol(), PERIOD_M30, iBarHigherOpen);
   timeHigherOpen = iTime(Symbol(), PERIOD_M30, iBarHigherOpen);
   iBarHigherOpen = iBarShift(Symbol(), Period(), timeHigherOpen, true); //-- on M30

   //-- draw line
   DISTANCE = (DAILYHIGH - dHigherOpen) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sHigherOpen = "M30[" + (string) iBarHigherOpen + "] Higher Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "M30_HigherOpen";
   Draw_HorizontalLine(objectName, dHigherOpen, timeHigherOpen, timeCurr, sHigherOpen, colorOpenHi, Line_Style_M30, Line_Width_M30);

   //-- 3. lovest daily M30 open -------------------------------------------
   int iBarLowerOpen = iLowest(Symbol(), PERIOD_M30, MODE_OPEN, currentDailyBars + 1, 0); //-- on M30
   dLowerOpen = iOpen(Symbol(), PERIOD_M30, iBarLowerOpen);
   timeLower0pen = iTime(Symbol(), PERIOD_M30, iBarLowerOpen);
   iBarLowerOpen = iBarShift(Symbol(), Period(), timeLower0pen, true); //-- on M30

   DISTANCE = (dLowerOpen - DAILYLOW) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sLowerOpen = "M30[" + (string) iBarLowerOpen + "] Lower Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "M30_LowerOpen";
   Draw_HorizontalLine(objectName, dLowerOpen, timeLower0pen, timeCurr, sLowerOpen, colorOpenLo, Line_Style_M30, Line_Width_M30);
}

//+------------------------------------------------------------------+
void vDraw_M1_Lines() {
   string objectName;
   double open0, dHigherOpen, dLowerOpen;
   datetime time0pen0, timeHigherOpen, timeLower0pen, timeCurr;
   string sHigherOpen, sLowerOpen;

   //-- 1. current open ---------------------------------------------------
   open0 = iOpen(Symbol(), PERIOD_M1, 0);
   time0pen0 = iTime(Symbol(), PERIOD_M1, 0);
   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_M1_Labels * 60;
   //-- draw line      
   objectName = sObj + "M1_0open";
   Draw_HorizontalLine(objectName, open0, time0pen0, timeCurr, "M1[0] Open", colorOpen, Line_Style_M1, Line_Width_M1);

   //-- 2. highest daily M1 open ------------------------------------------
   datetime timeDailyOpen = iTime(Symbol(), PERIOD_D1, 0);
   int currentDailyBars = iBarShift(Symbol(), PERIOD_M1, timeDailyOpen, true);

   int iBarHigherOpen = iHighest(Symbol(), PERIOD_M1, MODE_OPEN, currentDailyBars + 1, 0); //-- on M1
   dHigherOpen = iOpen(Symbol(), PERIOD_M1, iBarHigherOpen);
   timeHigherOpen = iTime(Symbol(), PERIOD_M1, iBarHigherOpen);
   iBarHigherOpen = iBarShift(Symbol(), Period(), timeHigherOpen, true); //-- on M1

   //-- draw line
   DISTANCE = (DAILYHIGH - dHigherOpen) / Point / 10.0;
   sHigherOpen = "M1[" + (string) iBarHigherOpen + "] Higher Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "M1_HigherOpen";
   Draw_HorizontalLine(objectName, dHigherOpen, timeHigherOpen, timeCurr, sHigherOpen, colorOpenHi, Line_Style_M1, Line_Width_M1);

   //-- 3. lovest daily M1 open -------------------------------------------
   int iBarLowerOpen = iLowest(Symbol(), PERIOD_M1, MODE_OPEN, currentDailyBars + 1, 0); //-- on M1
   dLowerOpen = iOpen(Symbol(), PERIOD_M1, iBarLowerOpen);
   timeLower0pen = iTime(Symbol(), PERIOD_M1, iBarLowerOpen);
   iBarLowerOpen = iBarShift(Symbol(), Period(), timeLower0pen, true); //-- on M1

   DISTANCE = (dLowerOpen - DAILYLOW) / Point / 10.0; //  " + DoubleToStr(DISTANCE,1);
   sLowerOpen = "M1[" + (string) iBarLowerOpen + "] Lower Open " + DoubleToStr(DISTANCE, 1);
   objectName = sObj + "M1_LowerOpen";
   Draw_HorizontalLine(objectName, dLowerOpen, timeLower0pen, timeCurr, sLowerOpen, colorOpenLo, Line_Style_M1, Line_Width_M1);
}

//+------------------------------------------------------------------+
void Draw_WEEKLY_Lines() {
   string objectName;
   double dHigh, dLow;
   datetime timeCurr;
   string sHigherOpen, sLowerOpen;

   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_W1_Labels * 60;

   //-- 2. PREV WEEKLY HIGH  ------------------------------------------
   datetime timeWeeklyOpen = iTime(Symbol(), PERIOD_W1, 1);

   dHigh = iHigh(Symbol(), PERIOD_W1, 1);
   dLow = iLow(Symbol(), PERIOD_W1, 1);

   //-- draw lines
   sHigherOpen = "W1[1] High ";
   objectName = sObj + "W1_High";
   Draw_HorizontalLine(objectName, dHigh, timeWeeklyOpen, timeCurr, sHigherOpen, colorHigh, Line_Style_W1, Line_Width_W1);

   sLowerOpen = "W1[1] Low ";
   objectName = sObj + "W1_Low";
   Draw_HorizontalLine(objectName, dLow, timeWeeklyOpen, timeCurr, sLowerOpen, colorLow, Line_Style_W1, Line_Width_W1);

}

//+------------------------------------------------------------------+
void Draw_MONTHLY_Lines() {
   string objectName;
   double dHigh, dLow;
   datetime timeCurr;
   string sHigherOpen, sLowerOpen;

   timeCurr = iTime(Symbol(), Period(), 0) + Period() * Shift_MN_Labels * 60;

   //-- 2. PREV MONTHLY HIGH  ------------------------------------------
   datetime timeMonthlyOpen = iTime(Symbol(), PERIOD_MN1, 1);

   dHigh = iHigh(Symbol(), PERIOD_MN1, 1);
   dLow = iLow(Symbol(), PERIOD_MN1, 1);

   //-- draw lines
   sHigherOpen = "MN[1] High ";
   objectName = sObj + "MN_High";
   Draw_HorizontalLine(objectName, dHigh, timeMonthlyOpen, timeCurr, sHigherOpen, colorHigh, Line_Style_MN, Line_Width_MN);

   sLowerOpen = "MN[1] Low ";
   objectName = sObj + "MN_Low";
   Draw_HorizontalLine(objectName, dLow, timeMonthlyOpen, timeCurr, sLowerOpen, colorLow, Line_Style_MN, Line_Width_MN);

}
//+------------------------------------------------------------------+   
void Draw_TRADEAID() {
   color dColor = clrNONE;

   if (Close[0] > YESTERDAYHIGH || Close[0] < YESTERDAYLOW) {
      dColor = clrYellow;
   }

   MakeLabel(sObj + "PANEL01", 0, 30, dColor);

   return;
}
//+------------------------------------------------------------------+   
void MakeLabel(string NAME, int xPOS, int yPOS, color pcolor) {

   if (ObjectFind(NAME) != 0) {
      ObjectCreate(NAME, OBJ_LABEL, 0, 0, 0);
      ObjectSet(NAME, OBJPROP_XDISTANCE, xPOS);
      ObjectSet(NAME, OBJPROP_YDISTANCE, yPOS);
      ObjectSet(NAME, OBJPROP_BACK, true);
   } else {
      ObjectMove(NAME, 0, xPOS, yPOS);
   }

   ObjectSet(NAME, OBJPROP_BACK, true);
   ObjectSetText(NAME, "g", 120, "Webdings", pcolor);
}

//+------------------------------------------------------------------+  
void DrawRectangle(string name, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, color Col) {
   if (ObjectFind(name) != 0) {
      ObjectCreate(name, OBJ_RECTANGLE, 0, pTime1, pPrice1, pTime2, pPrice2);
      ObjectSet(name, OBJPROP_COLOR, Col);
      ObjectSet(name, OBJPROP_BACK, true);
      ObjectSetText(name, name);

   } else {
      ObjectDelete(name);
      ObjectCreate(name, OBJ_RECTANGLE, 0, pTime1, pPrice1, pTime2, pPrice2);
      ObjectSet(name, OBJPROP_COLOR, Col);
      ObjectSet(name, OBJPROP_BACK, true);
      ObjectSetText(name, name);
   }
}
//+------------------------------------------------------------------+  
