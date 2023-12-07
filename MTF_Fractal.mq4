//+------------------------------------------------------------------+
//|                                                  MTF Fractal.mq4 |
//|                                         Copyright © 2014, TrueTL |
//|                                            http://www.truetl.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, TrueTL"
#property link      "http://www.truetl.com"
#property version "1.40"
#property indicator_chart_window
#property indicator_buffers 4
#property strict
#include <CRiMaxMin.mqh>
#include <FractalsMultiSymbolMultiTimeframe.mqh>
#include <ArrayFunctions.mqh>
extern string  Version_140                      = "www.truetl.com";
input string Symbol_to_use = "";
input int    Timeframe = 0;
extern int     Fractal_Timeframe                = 0;
input  bool    User_defined_Maxbar              = true;
extern int     Maxbar                           = 2000;
extern color   Up_Fractal_Color                 = Red;
extern int     Up_Fractal_Symbol                = 108;
extern color   Down_Fractal_Color               = Blue;
extern int     Down_Fractal_Symbol              = 108;
extern bool    Extend_Line                      = true;
extern bool    Extend_Line_to_Background        = true;
extern bool    Show_Validation_Candle           = true;
extern color   Up_Fractal_Extend_Line_Color     = Red;
int     Up_Fractal_Extend_Width          = 0;
extern int     Up_Fractal_Extend_Style          = 2;
extern color   Down_Fractal_Extend_Line_Color   = Blue;
int     Down_Fractal_Extend_Width        = 0;
extern int     Down_Fractal_Extend_Style        = 2;

double UpBuffer_[], DoBuffer_[], UpBuffer2[], DoBuffer2[], refchk, tempref, level;
int barc, maxBar;
FractalsMultiSymbolMultiTimeframe fractalsMultiSymbolMultiTimeframe;
MqlRates rates[];

//+------------------------------------------------------------------+
//|                                                             INIT |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {

   SetIndexBuffer(0,UpBuffer_);
   SetIndexStyle(0,DRAW_ARROW, DRAW_ARROW, 2, Up_Fractal_Color);
   SetIndexArrow(0,Up_Fractal_Symbol);
   SetIndexBuffer(1,DoBuffer_);
   SetIndexStyle(1,DRAW_ARROW, DRAW_ARROW, 2, Down_Fractal_Color);
   SetIndexArrow(1,Down_Fractal_Symbol);
   SetIndexBuffer(2,UpBuffer2);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(3,DoBuffer2);
   SetIndexStyle(3,DRAW_NONE);
   if(_Period == 43200)
     {
      Down_Fractal_Extend_Width = 4;
      Up_Fractal_Extend_Width = 4;
     }
   else
      if(_Period == 10080)
        {
         Down_Fractal_Extend_Width = 3;
         Up_Fractal_Extend_Width = 3;
        }
   if(_Period == 1440)
     {
      Down_Fractal_Extend_Width = 2;
      Up_Fractal_Extend_Width = 2;
     }
   if(_Period == 240)
     {
      Down_Fractal_Extend_Width = 1;
      Up_Fractal_Extend_Width = 1;
     }

   return(0);
  }

//+------------------------------------------------------------------+
//|                                                           DEINIT |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal(); i >= 0; i--)
     {
      if(StringSubstr(ObjectName(i),0,12) == "MTF_Fractal_")
        {
         ObjectDelete(ObjectName(i));
        }
     }

   return(0);
  }

//+------------------------------------------------------------------+
//|                                                            START |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int               OnCalculate(const int  Rates_total,
                              const int prev_calculated,
                              const datetime &time[],
                              const double &open[],
                              const double &high[],
                              const double &low[],
                              const double &close[],
                              const long &tick_volume[],
                              const long &volume[],
                              const int &spread[])
  {
   int i, c, dif;
   tempref =   iHigh(Symbol(), Fractal_Timeframe, 1) +
               iHigh(Symbol(), Fractal_Timeframe, 51) +
               iHigh(Symbol(), Fractal_Timeframe, 101);
   if(!User_defined_Maxbar)
     {
      maxBar = Bars;
     }
   else
     {
      maxBar = Maxbar;
     }
   if(barc != Bars || IndicatorCounted() < 0 || tempref != refchk)
     {
      barc = Bars;
      refchk = tempref;
     }
   else
      return(0);

   deinit();
   int responseArr[];
   int bars = ArrayCopyRates(rates,Symbol_to_use,Timeframe);
   int lastError = DownloadedBars(rates,responseArr);
   int limit = responseArr[0] - 1;
   int lastError2;
   if(lastError == 0)
     {
      ArrayResize(responseArr,0);
      lastError2 = DownloadedBars2(rates,responseArr);
      if(lastError!=lastError2)
        {
         Alert("lastError!=lastError2");
        }
     }
   if(limit<=0)
     {
      Alert("limit<=0");
      return prev_calculated;
     }
   else
     {
      Alert("limit>0: " + limit);
      if(limit>Rates_total)
        {
         limit = Rates_total-1;
         fractalsMultiSymbolMultiTimeframe.Initialize(5,limit,rates);
        }
     }
   if(Fractal_Timeframe <= Period())
      Fractal_Timeframe = Period();

   dif = Fractal_Timeframe/Period();

   if(maxBar > Bars)
      maxBar = Bars-10;
   double lastHigh, lastLow;
   for(i = limit; i > 0; i--)
     {
      int index = iBarShift(NULL,Fractal_Timeframe,Time[i]);
      int index2 = fractalsMultiSymbolMultiTimeframe.BarShift(Timeframe,Time[i],rates);
      if(i<100)Alert("index: " + index + ", index2: " + index2);
      if(i>=ArrayRange(rates,0))
        {
         continue;
        }
      fractalsMultiSymbolMultiTimeframe.AddValues(rates[i].high,rates[i].low,Time[i],i);
      if(i>(limit-5))
        {
         continue;
        }
      if(index < 3)
        {
         UpBuffer2[i] = 0;
         DoBuffer2[i] = 0;
         continue;
        }
      UpBuffer2[i] = iFractals(NULL,Fractal_Timeframe,1,iBarShift(NULL,Fractal_Timeframe,Time[i]));
      DoBuffer2[i] = iFractals(NULL,Fractal_Timeframe,2,iBarShift(NULL,Fractal_Timeframe,Time[i]));

      double UpBuffer2_ = fractalsMultiSymbolMultiTimeframe.GetMaxValueOfMax();
      double DoBuffer2_ = fractalsMultiSymbolMultiTimeframe.GetMinValueOfMin();



      double upValue = UpBuffer2[i];
      if(upValue!=EMPTY_VALUE && upValue!=0)
        {
         lastHigh = upValue;
         if(i<100)
            Alert("UpBuffer2_: " + UpBuffer2_ + ", UpBuffer2[i]: " + UpBuffer2[i]);
        }
      double downValue = DoBuffer2[i];
      if(downValue!=EMPTY_VALUE && downValue!=0)
        {
         lastLow = downValue;
         if(i<100)
            Alert("DoBuffer2_: " + DoBuffer2_ + ", DoBuffer2[i]: " + DoBuffer2[i]);
        }

      if(time[i]>=StrToTime("2023.04.05 00:00:00") && (UpBuffer2[i]!=EMPTY_VALUE || DoBuffer2[i]!=EMPTY_VALUE))
        {
         //Alert("MTF_Fractal, time: " + TimeToStr(time[i]) + ", high: "+ lastHigh + ", low: "+ lastLow);
        }
     }

   if(Extend_Line)
     {
      for(i = 0; i < maxBar; i++)
        {
         int index = i-2*dif;
         if(UpBuffer2[i] > 0)
           {
            level = UpBuffer2[i];
            for(c = i; c > 0; c--)
              {
               if((Open[c] < level && Close[c] > level) || (Open[c] > level && Close[c] < level))
                  break;
               if(Open[c] <= level && Close[c] <= level && Open[c-1] >= level && Close[c-1] >= level)
                  break;
               if(Open[c] >= level && Close[c] >= level && Open[c-1] <= level && Close[c-1] <= level)
                  break;
              }
            DrawLine("H", i, c, level, Extend_Line_to_Background, Up_Fractal_Extend_Line_Color, Up_Fractal_Extend_Width, Up_Fractal_Extend_Style);
            if(Show_Validation_Candle)
              {
               if(index>=0)
                 {
                  UpBuffer_[index] = level;
                  i += dif;
                 }
              }

           }
        }

      for(i = 0; i < maxBar; i++)
        {
         int index = i-2*dif;
         if(DoBuffer2[i] > 0)
           {
            level = DoBuffer2[i];
            for(c = i; c > 0; c--)
              {
               if((Open[c] < level && Close[c] > level) || (Open[c] > level && Close[c] < level))
                  break;
               if(Open[c] <= level && Close[c] <= level && Open[c-1] >= level && Close[c-1] >= level)
                  break;
               if(Open[c] >= level && Close[c] >= level && Open[c-1] <= level && Close[c-1] <= level)
                  break;
              }
            DrawLine("L", i, c, level, Extend_Line_to_Background, Down_Fractal_Extend_Line_Color, Down_Fractal_Extend_Width, Down_Fractal_Extend_Style);
            if(Show_Validation_Candle)
              {
               if(index>=0)
                 {
                  DoBuffer_[index] = level;
                  i += dif;
                 }
              }
           }
        }
     }

   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DownloadedBars(MqlRates &rates[], int &responseArr[])
  {
   ResetLastError();
   int bars = ArrayCopyRates(rates,Symbol_to_use,Timeframe);
   AddToArray(responseArr,bars);
   return GetLastError();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DownloadedBars2(MqlRates &rates[], int &responseArr[])
  {
   ResetLastError();
   int bars = ArrayCopyRates(rates,Symbol_to_use,Timeframe);
   AddToArray(responseArr,bars);
   return GetLastError();
  }
//+------------------------------------------------------------------+
//|                                                        DRAW LINE |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(string dir, int i, int c, double lev, bool back, color col, int width, int style)
  {
   ObjectCreate("MTF_Fractal_"+dir+i,OBJ_TREND,0,0,0,0,0);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_TIME1,iTime(Symbol(),Period(),i));
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_PRICE1,lev);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_TIME2,iTime(Symbol(),Period(),c));
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_PRICE2,lev);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_RAY,0);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_BACK,back);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_COLOR,col);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_WIDTH,width);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_STYLE,style);
  }
//+------------------------------------------------------------------+
