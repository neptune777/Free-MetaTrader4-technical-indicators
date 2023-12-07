//+-----------------------------------------------------------------------------------+
//|                                                 Extra_symbol_product_version.mq4  |
//|                                                  Copyright © 2021, Matti Kinnunen |
//|                                                                                   |
//+-----------------------------------------------------------------------------------+
#property copyright "Copyright © 2021, Matti Kinnunen"

#property strict
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Black
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 2
//#property indicator_style2 1
#property indicator_color3 Blue
#property indicator_width3 2
#property script_show_inputs

#define INDEX uint   // Zero based.
#define COUNT uint   // One based.
//#property indicator_style3 2
//---- buffers


extern int short_term_SMA_period=30;
extern int long_term_SMA_period =50;
extern bool turn_direction = false;
extern string SYMBOL = "SPAIN35";
extern bool Compute_correlation = false;
extern int LimitForComputingOfCorrelation = 1000;
extern bool GetBarAmount = false;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double range;
double coeff;
double diff;
int limit;

MqlRates rates[];
MqlRates rates2[];
int startIndex;
int barAmount;
int thisBarAmount;
double lastValue;
int error;
int gapCoeff;
bool firstPrint = true;
bool initJustDone;
int biggestHourGap;
int limitForComputingOfCorrelation = LimitForComputingOfCorrelation;
int  maxShiftForCorrelation;
int maxBars;




//--------------------------------------------------------------------------*

//int winind;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {







//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
//SetIndexLabel(0,"DXY");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,short_term_SMA_period+"SMA");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexLabel(2,long_term_SMA_period+"SMA");
   IndicatorShortName("Extra_symbol_product_version " + SYMBOL + ": "+short_term_SMA_period+" SMA / "+long_term_SMA_period+" SMA");
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);


   barAmount = ArrayCopyRates(rates,SYMBOL,0);
   thisBarAmount = ArrayCopyRates(rates2,NULL,0);
   ArraySetAsSeries(rates,true);
   ArraySetAsSeries(rates2,true);


   initJustDone = true;

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {




   error = GetLastError();
   if(error)
      Print("error: " + error);

   if(!error)
     {

      if(GetBarAmount)
        {
         ExtMapBuffer6[0]= barAmount;
         return -1;
        }
      int counted_bars=IndicatorCounted();
      if(counted_bars < 0)
         return(-1);
      if(counted_bars>0)
         counted_bars--;
      int externBars = barAmount;
      int limitation = long_term_SMA_period+1;

      if(Bars>externBars)
        {
         limit = externBars - 1;
        }
      else
        {
         limit = Bars - 1;
        }

      range  = getRange_(limit, "range");
      if(range == -1)
        {
         return(-1);
        }
      coeff  = getCoefficient(range);
      diff   = getDifference(limit, range, coeff);

      int arr[];
      int firstLoopStart;
      int secondLoopStart;

      searchFirstMatch(arr);
      if(ArraySize(arr)>1)
        {
         firstLoopStart = arr[0];
         secondLoopStart = arr[1];


         if(NewBar() && range != (-1))
           {
            int counter;
            for(int i=firstLoopStart; i>=0; i--)
              {
               double value;
               int j;

               for(int l=secondLoopStart; l>=0; l--)
                 {

                  if((Time[i]) == (rates[l].time))
                    {

                     value = rates[l].open;
                     if(l!=0)
                       {
                        secondLoopStart = l-1;
                       }
                     break;
                    }
                 }

               if(value!=0)
                 {
                  double customIndyValue;
                  counter++;
                  maxBars = counter;
                  if(!turn_direction)
                    {

                     ExtMapBuffer1[i]= lastValue = coeff*value - diff;

                    }
                  else
                    {

                     ExtMapBuffer1[i]= lastValue = -1*coeff*value + diff;

                    }
                 }
               else
                 {
                  //ExtMapBuffer1[i] = lastValue;
                 }

              }

            if(Compute_correlation)
              {
               ExtMapBuffer5[0] = getCorrelationByShift(0,SYMBOL,0);
               return -1;
              }

            computeMovingAveragesAndSetThemToBuffers(limitation);
           }

        }
     }
   else
     {
      ExtMapBuffer5[0] = (double)error;
      ResetLastError();
     }


//---- done
   return(0);
  }



//+-------------------------------------------------------------------------------------------------+
//| Function to compute values for moving averages and initialize them to corresponding buffers     |
//+-------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void computeMovingAveragesAndSetThemToBuffers(int limitation)
  {
   int val = limit - limitation;
//Print("limit-limitation " + val);
//Print(maxBars);
   int c;
   for(int i=0; i<val; i++)
     {
      ExtMapBuffer2[i]=0;
      ExtMapBuffer3[i]=0;
      int counter_for_SMAs;
      int counter_for_this_loop;
      int coun;
      while(counter_for_SMAs<long_term_SMA_period && (c+long_term_SMA_period)<maxBars)
        {
         coun++;
         if((i+counter_for_this_loop)<ArraySize(ExtMapBuffer1) && ExtMapBuffer1[i+counter_for_this_loop]!= EMPTY_VALUE)
           {
            if(counter_for_SMAs<short_term_SMA_period)
              {
               ExtMapBuffer2[i]=ExtMapBuffer2[i]+ExtMapBuffer1[i+counter_for_this_loop];

               //counter_for_short_term_SMA++;
               //Print("ExtMapBuffer2[i+counter_for_SMAs] " + ExtMapBuffer2[i] + " counter_for_SMAs: " + counter_for_SMAs + " counter_for_this_loop: " + counter_for_this_loop);
              }
            ExtMapBuffer3[i]=ExtMapBuffer3[i]+ExtMapBuffer1[i+counter_for_this_loop];
            counter_for_SMAs++;
           }
         counter_for_this_loop++;
         //if(coun>= (2*long_term_SMA_period-1))
         //Print("coun " + coun);

         //Print("counter_for_long_term_SMA " + counter_for_long_term_SMA);
        }
      if(ExtMapBuffer1[i]!= EMPTY_VALUE && ExtMapBuffer2[i]!= EMPTY_VALUE && ExtMapBuffer3[i]!= EMPTY_VALUE && (c+long_term_SMA_period)<maxBars)
        {
         //Print("ExtMapBuffer2[i] " + ExtMapBuffer2[i]);
         ExtMapBuffer2[i] = ExtMapBuffer2[i]/short_term_SMA_period;
         ExtMapBuffer3[i] = ExtMapBuffer3[i]/long_term_SMA_period;
         ExtMapBuffer4[i] = (ExtMapBuffer1[i] - ExtMapBuffer2[i]) + (ExtMapBuffer1[i] - ExtMapBuffer3[i]) + (ExtMapBuffer2[i] - ExtMapBuffer3[i]);
         c++;
        }
      else
        {
         ExtMapBuffer2[i] = EMPTY_VALUE;
         ExtMapBuffer3[i] = EMPTY_VALUE;
         ExtMapBuffer4[i] = EMPTY_VALUE;

        }
     }
//Print(c);
   EraseTail();
  }


//+-------------------------------------------------------------------------------------------------+
//| Function to compute a correlation of a certain symbol                                           |
//+-------------------------------------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getBestShiftOfCorrelation(string assett,int i_)
  {


   int bestShift = 0;
   double bestCorr = -1.1;

   for(int i=0; i<(maxShiftForCorrelation+i_); i++)
     {

      double corr = MathAbs(getCorrelationByShift(i_,assett,i));
      if(corr > bestCorr)
        {
         bestCorr = corr;
         bestShift = i;
        }

     }


   return bestShift;
  }

//+-------------------------------------------------------------------------------------------------+
//| Function to compute a correlation of a certain symbol by shift                                  |
//+-------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCorrelationByShift(int i_, string assett, int shift_)
  {

   double sum = 0;
   double arr1[];
   double arr2[];

   double resultArr[];
   double corr;
   int maxAmountOfBars = maxBars;
   if(limitForComputingOfCorrelation > maxAmountOfBars)
     {
      limitForComputingOfCorrelation = maxAmountOfBars;
      //Alert("Maximum amount of bars is " + maxAmountOfBars + ". You can use it as a parameter to prevent alerts appearing any more.");
     }
   int coun;
   if(assett != "")
     {
      int i=i_;
      while(true)
        {
         if(coun == limitForComputingOfCorrelation+i_)
           {
            break;
           }

         if(ExtMapBuffer1[i_+i+1+shift_]!=EMPTY_VALUE)
           {
            double btc = iOpen(NULL,0,i_+i+1);
            double comparable = ExtMapBuffer1[i_+i+1+shift_];

            AddToArray2(arr2,comparable);
            AddToArray2(arr1,btc);
            coun++;
           }
         i++;

        }
     }

   corr = correlation_coefficient(arr2, arr1, limitForComputingOfCorrelation);
//Print(SYMBOL + " correlation " + coun);





   return corr;

  }

//+------------------------------------------------------------------+
//| Function to compute a correlation value of a certain symbol      |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double correlation_coefficient(double& a[], double& b[], COUNT length, INDEX iBeg=0)
  {
   INDEX    iEnd  = iBeg + length;
   /* https://en.wikipedia.org/wiki/Correlation_and_dependence
    * CorrelationCoefficient = ss(xy)/Sqrt( ss(xx) ss(yy) )
    * ss(xy) = E (xi-Ave(x))(yi-Ave(y)) = n E XiYi - E Xi E Yi
    * ss(xx) = E (xi-Ave(x))^2          = n E Xi**2 - (E Xi)**2
    * ss(yy) = E (yi-Ave(y))^2          = n E Yi**2 - (E Yi)**2
    */
   double   Ex=0.0,  Ex2=0.0,    Ey=0.0,  Ey2=0.0,    Exy=0.0;    // Ex=Sum(x)
   for(; iBeg < iEnd; ++iBeg)
     {
      double   x = a[iBeg],   y = b[iBeg];
      Ex += x;
      Ex2 += x * x;
      Ey += y;
      Ey2 += y * y;
      Exy += x * y;
     }
   double   ssxy  = length * Exy - Ex * Ey;
   double   ssxx  = length * Ex2 - Ex * Ex;
   double   ssyy  = length * Ey2 - Ey * Ey;
   double   deno  = MathSqrt(ssxx * ssyy);
   return (deno == 0.0) ? 0.0 : ssxy / deno;
  }



//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
void searchFirstMatch(int &arr[])
  {

   bool matchFound;
   for(int i=limit; i>=0; i--)
     {
      for(int j=limit; j>=0; j--)
        {

         if(Time[i]!=0 && Time[i] == (rates[j].time))
           {
            AddToArray2(arr,i);
            AddToArray2(arr,j);
            matchFound = true;
            //Print(SYMBOL + " Time " + TimeToStr(rates[j].time));
            //Print(SYMBOL + " Value " + rates[j].open);
            break;
           }

        }

      if(matchFound)
        {
         break;
        }

     }

  }

//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
int syncronizeValues(int start_i, int start_l)
  {

   double lastValue;
   int counterForMisMatch;

   while(start_i != 0 && start_l != 0)
     {
      if(Time[start_i] == (rates[start_l].time))
        {
         lastValue = rates[start_l].open;
         ExtMapBuffer1[start_i] = lastValue;
        }
      else
        {
         ExtMapBuffer1[start_i] = lastValue;
         counterForMisMatch++;
        }
      start_i--;
      start_l--;
     }

   return counterForMisMatch;

  }
//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
bool arrayIncludes(int &arr[],int value)
  {


   for(int i=0; i<ArraySize(arr); i++)
     {
      if(arr[i]==value)
        {
         return true;
        }
     }
   return false;

  }

//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getBiggestGap(bool extern_)
  {
//int arr[];
//int h=getFirstMatch(arr);
   int biggestHour;
   int smallestHour = 25;
   if(extern_)
     {
      for(int h=barAmount-1; h>=0; h--)
        {
         if(TimeHour(rates[h].time)>biggestHour)
           {
            biggestHour = TimeHour(rates[h].time);
           }
         if(TimeHour(rates[h].time)<smallestHour)
           {
            smallestHour = TimeHour(rates[h].time);
           }
        }

     }
   else
     {
      for(int h=Bars-1; h>=0; h--)
        {
         if(TimeHour(rates2[h].time)>biggestHour)
           {
            biggestHour = TimeHour(rates2[h].time);
           }
         if(TimeHour(rates2[h].time)<smallestHour)
           {
            smallestHour = TimeHour(rates2[h].time);
           }
        }

     }

   return (24-biggestHour + smallestHour);
  }

//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getFirstMatch(int &arr[])
  {

   for(int i=limit; i>=0; i--)
     {
      for(int j=limit; j>=0; j--)
         if((rates2[i].time) == (rates2[j].time) && !arrayIncludes(arr,j))
           {
            return j;
           }
     }

   return -1;
  }


//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
/*
bool openAndCloseChart(){
   long curChartID = ChartID();
   long chartid=ChartOpen(SYMBOL,PERIOD_CURRENT);
   if(curChartID != chartid && chartid != 0){
      //Print("curChartID " + curChartID + ", chartid " + chartid);
      bool closeOk = ChartClose(chartid);
      if(closeOk){
         return false;
      }else{
         true;
      }
   }

}
*/
//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EraseTail()
  {

   for(int i=ArraySize(ExtMapBuffer1)-1; i>=0; i--)
     {
      if(ExtMapBuffer1[i] != EMPTY_VALUE && ExtMapBuffer2[i] == EMPTY_VALUE)
        {
         ExtMapBuffer1[i] = EMPTY_VALUE;
        }
      if(ExtMapBuffer1[i] != EMPTY_VALUE && ExtMapBuffer3[i] == EMPTY_VALUE)
        {
         ExtMapBuffer1[i] = EMPTY_VALUE;
        }
      if(ExtMapBuffer1[i] != EMPTY_VALUE && ExtMapBuffer4[i] == EMPTY_VALUE)
        {
         ExtMapBuffer1[i] = EMPTY_VALUE;
        }
      if(ExtMapBuffer1[i] == 0 && ExtMapBuffer2[i] == 0 && ExtMapBuffer3[i] == 0 && ExtMapBuffer4[i] == 0)
        {
         ExtMapBuffer1[i] = EMPTY_VALUE;
         ExtMapBuffer2[i] = EMPTY_VALUE;
         ExtMapBuffer3[i] = EMPTY_VALUE;
         ExtMapBuffer4[i] = EMPTY_VALUE;
        }

      if(MathAbs(ExtMapBuffer1[i]) > 1 || MathAbs(ExtMapBuffer2[i]) > 1 || MathAbs(ExtMapBuffer3[i]) > 1 || MathAbs(ExtMapBuffer4[i]) > 1)
        {
         ExtMapBuffer1[i] = EMPTY_VALUE;
         ExtMapBuffer2[i] = EMPTY_VALUE;
         ExtMapBuffer3[i] = EMPTY_VALUE;
         ExtMapBuffer4[i] = EMPTY_VALUE;
        }

      //ExtMapBuffer1[i] = EMPTY_VALUE;
      //ExtMapBuffer3[i] = EMPTY_VALUE;

     }


  }

//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getDifference(int limit, double range, double coeff)
  {

   double max = getRange_(limit, "max");
//
   double min = max - range;


   double newMax;
   double newMin;
   double diff;
   if(!turn_direction)
     {
      newMax = max * coeff;
      newMin = min * coeff;
      diff = newMax - 1.0;
     }
   else
      if(turn_direction)
        {
         newMax = max * coeff;
         newMin = min * coeff;
         diff = 1.0 - newMax;
        }

   return diff;

  }
//------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getRange_(double limit, string desiredValue)
  {

   double val;
//double downVal;
   double max = -1000000;
   double min =  1000000;
   double possiblyValue;
//double possiblyMin;
   /*if(rates2[0].time == rates[0].time){
      int      bar   =  iBarShift(SYMBOL, Period(), rates[0].time, true);
      Alert(TimeToStr(rates[0].time));
      */
   /*int      error =  GetLastError();
   //PrintFormat("Time=%s, bar=%i, bar time=%s, error=%i", TimeToStr(TimeCurrent()), bar, TimeToStr(iTime(SYMBOL, 0, bar)), error);
   if(error != 0 && bar == -1){
      Alert("Error occured. Please wait.");
      static int _time_waiting=0;
      ResetLastError();
      _time_waiting = TimeLocal() + 2; // the pause ends in 10 seconds after the current local time
      if ( TimeLocal() >= _time_waiting ){
         bar   =  iBarShift(SYMBOL, Period(), TimeCurrent(), true);
         error =  GetLastError();
         Alert(bar + " " + error);
      }
      /*for (int j = 0; j < 20 && error!=0; j++) {
          Sleep(1000);
          RefreshRates();
          bar   =  iBarShift(SYMBOL, Period(), TimeCurrent()-Period(), true);
          error =  GetLastError();
          if(bar == -1){
             Alert("The information requested by this indicator is being loaded.");
          }
      }


   }
   if(bar == -1){
         //Alert( SYMBOL + " could not be loaded.");
         return -1;
      }
   */
   bool startIndexFound;
   /*
   for(int i=0; i<limit; i++){

      if(rates2[i].time == rates[i].time){
         Alert("i==i " + i);
         startIndex = i;
         startIndexFound = true;
         break;
      }
      else if(i!=0 && rates2[0].time == rates[i].time){
         Alert("First " + (-1)*i);
         startIndex = -1*i;
         startIndexFound = true;
         break;
      }else if(i!=0 && rates2[i].time == rates[0].time){
         Alert("Second " + i);
         startIndex = i;
         startIndexFound = true;
         break;
      }

   }
   */
//if(startIndexFound){
   for(int i=0; i<limit; i++)
     {


      possiblyValue =  rates[i].open;
      //possiblyMin = iLow(SYMBOL,0,i);

      if(!turn_direction)
        {
         val=possiblyValue;
         //downVal=possiblyMin;
        }
      else
        {
         val=-1*possiblyValue;
         //downVal=-1*possiblyMin;

        }




      if(val > max)
        {
         max = val;
        }
      if(val !=0 && val < min)
        {
         min = val;

        }
     }



   double range = max - min;
   double ret;

   if(desiredValue == "range")
     {
      ret = range;
     }
   else
      if(desiredValue == "max")
        {
         ret = max;
        }
//}

   /*}else{
      return -1;
   }
   */

   return ret;

  }

//------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isValidValue(double val)
  {

   if(val != EMPTY_VALUE && val != 0)
     {
      return true;
     }
   else
     {
      return false;
     }

  }

//------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCoefficient(double range)
  {

   double coeff;

   if(range != 0)
     {
      coeff = 1/range;
     }

   return coeff;
  }

//------------------------------------------------------------------------------------------------
bool NewBar()
  {
   static datetime lastbar;
   datetime curbar = Time[0];
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      return (true);
     }
   else
     {
      return(false);
     }
  }

//+------------------------------------------------------------------+
//| Generic function for adding values in any type of array          |
//+------------------------------------------------------------------+

template<typename T>
T AddToArray2(T &arr[], T &value)
  {

   ArrayResize(arr,ArraySize(arr)+1);
   arr[ArraySize(arr)-1] = value;
   return value;
  }
//+------------------------------------------------------------------+
