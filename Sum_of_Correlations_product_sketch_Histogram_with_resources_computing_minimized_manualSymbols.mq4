//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SymbolCorrelation
  {

#define INDEX uint   // Zero based.
#define COUNT uint   // One based.


private:

   string            m_symbol;
   double            m_correlation;
   int               m_direction;   // direction of correlation
   int               m_matching_times;
   int               m_limit;
   bool              m_this_symbol_is_updatable;
   bool              m_is_active;
   bool              m_first_bar_matches_with_first_of_current_chart;
   MqlRates          m_symbol_rates_array[];
   double            m_symbol_values_array[];
   int               m_amount_of_bars;
   datetime          m_first_match;


public:

                     SymbolCorrelation(string symbol, int limit)
     {

      m_symbol = symbol;
      m_amount_of_bars = ArrayCopyRates(m_symbol_rates_array,symbol,0);
      m_limit = limit;
      m_this_symbol_is_updatable = false;
      m_is_active = true;
      //m_dax_driver_correlation = correlation;
      //m_dax_driver_direction   = direction;
      //m_dax_driver_index       = index;
      //m_dax_driver_best_shift  = bestShift;


     };
   // Parameterized Constructor for
   // for implementing deep copy
                     SymbolCorrelation(SymbolCorrelation& sample)
     {
      m_symbol                   = sample.getSymbol();
      m_correlation              = sample.getCorrelation();
      m_direction                = sample.getDirection();
      m_matching_times           = sample.m_matching_times;
      m_limit                    = sample.m_limit;
      m_this_symbol_is_updatable = sample.m_this_symbol_is_updatable;
      m_is_active                = sample.m_is_active;
      m_first_bar_matches_with_first_of_current_chart              = sample.m_first_bar_matches_with_first_of_current_chart;
      ArrayCopy(m_symbol_rates_array,sample.m_symbol_rates_array,0,0,WHOLE_ARRAY);
      ArrayCopy(m_symbol_values_array,sample.m_symbol_values_array,0,0,WHOLE_ARRAY);
      m_amount_of_bars           = sample.m_amount_of_bars;
      m_first_match              = sample.m_first_match;


     };
   /*
    SymbolCorrelation(string symbol){

     m_symbol = symbol;


   };

   */


   datetime          getFirstMatch()
     {
      return m_first_match;
     }

   string            getSymbol()
     {
      return m_symbol;
     }

   double            getCorrelation()
     {
      return m_correlation;

     }

   double            getDirection()
     {
      return m_direction;
     }

   int            getAmountOfBars()
     {
      return ArrayRange(m_symbol_rates_array,0);
     }

   int               resizeArray(int size)
     {
      return ArrayResize(m_symbol_values_array,size);
     }

   int               searchForZeros()
     {
      int zeros;
      for(int i=0; i<ArraySize(m_symbol_values_array); i++)
        {
         if(m_symbol_values_array[i]==0)
           {
            zeros++;
            //Print("Symbol and its zero index: " + m_symbol + " " + i);
           }
        }
      return zeros;
     }

   int               generateComparableTimeSeriesForThisSymbol()
     {

      int limit2 = ArraySize(m_symbol_rates_array);
      /*if(limitForComputingOfCorrelation<m_limit){
         m_limit = limitForComputingOfCorrelation;
      }
      */
      int arr[];
      searchFirstMatch(arr,m_symbol_rates_array, m_limit, limit2);
      if(ArraySize(arr)>1)
        {
         int firstLoopStart = arr[0];
         int secondLoopStart = arr[1];
         //if(getSymbol()=="EURUSD")Print("firstLoopStart, secondLoopStart: " + TimeToStr(Time[firstLoopStart]) + " " + TimeToStr(Time[secondLoopStart]));
         if(firstLoopStart==secondLoopStart)
           {
            m_this_symbol_is_updatable = true;
           }

         int counter=0;
         bool counterFull;

         ArrayResize(m_symbol_values_array,ArrayRange(m_symbol_rates_array,0));
         ArraySetAsSeries(m_symbol_values_array,true);
         for(int i=firstLoopStart; i<m_limit; i++)
           {
            double value;
            int j;

            for(int l=secondLoopStart; l<ArrayRange(m_symbol_rates_array,0); l++)
              {
               //Print("l " + l);
               if(l!=(-1) && ArraySize(Time)>i  && ArrayRange(m_symbol_rates_array,0)>l && (Time[i]) == (m_symbol_rates_array[l].time))
                 {

                  value = m_symbol_rates_array[l].open;
                  //double thisSymbolValue = iOpen(NULL,0,i);
                  if(value!=0 && value!=EMPTY_VALUE && ArraySize(m_symbol_values_array)>counter)
                    {
                     secondLoopStart = l-1;
                     //if(TimeToStr(Time[i])>"2021.09.01 00:00")
                     //Print("Time[i], assett, counter, barAmount " + TimeToStr(Time[i]) + " " + thisIterationSymbolName + " " + counter + " " + barAmount);
                     //ExtMapBuffer1[counter] = thisSymbolValue;
                     m_symbol_values_array[counter] = value;

                     //AddToArray2(arr2,comparable);
                     //AddToArray2(arr1,btc);
                     counter++;
                    }
                  break;
                 }
               /*if(counter==limitForComputingOfCorrelation){
                  counterFull = true;
                  //counterForAssets++;
                  break;
               }
               */

              }
            if(counterFull)
              {
               break;
              }

            /*
            if(k==0){

                int origSize = ArraySize(ExtMapBuffer1);
                //counter = origSize;
                /*while(ExtMapBuffer1[counter]==0 && ExtMapBuffer2[counter]==0){
                   counter--;
                }
                */
            /*
            int res = origSize-counter;
            Print("ArraySize(ExtMapBuffer1)1 " + ArraySize(ExtMapBuffer1));
            ArrayResize(ExtMapBuffer1,counter);
            Print("ArraySize(ExtMapBuffer1)2 " + ArraySize(ExtMapBuffer1));
            //Print("origSize-counter: " + res);
            */
            //Print("ArraySize(ExtMapBuffer1), counter " + ArraySize(ExtMapBuffer1) + " " + counter);
            /*for(int h=0;h<ArraySize(ExtMapBuffer1);h++){
               if(ExtMapBuffer1[h]!=0 || ExtMapBuffer2[h]!=0){
                  Print("Symbol: " + thisIterationSymbolName);
                  Print("ExtMapBuffer1[h]: " + ExtMapBuffer1[h]);
                  Print("ExtMapBuffer2[h]: " + ExtMapBuffer2[h]);
               }
            }

            } */

           }
         //int diff = ArraySize(m_symbol_values_array) - counter;
         //Print("diff " + m_symbol + " " + diff);
         ArrayResize(m_symbol_values_array,counter);
         //diff = ArraySize(m_symbol_values_array) - counter;
         //if(diff!=0)Print("diff2 " + m_symbol + " " + diff);
         m_matching_times = counter;
         return m_matching_times;
        }
      else
        {
         return -1;
        }

     }

   //+-------------------------------------------------------------------------------------------------+
   //| Function to search first matching time of assetts                                               |
   //+-------------------------------------------------------------------------------------------------+


   void              searchFirstMatch(int &arr[], MqlRates& assettOfThisIteration[], int limit1, int limit2)
     {

      bool matchFound;

      /*if(limitForComputingOfCorrelation<extern_limit){
         extern_limit = limitForComputingOfCorrelation;
      }
      */
      string timeOfFirstBarOfCurrentChart;
      if(ArraySize(Time)!=0)
        {
         timeOfFirstBarOfCurrentChart = TimeToStr(Time[0]);
        }
      else
        {
         //Alert("Not all data downloaded yet. Please refresh the indicator.");
         deleteChartObjects();
         string warning_part1 = "Warning: Not all data downloaded yet. Please refresh the indicator.";
         string arr[];
         AddToArray2(arr,warning_part1);
         //AddToArray2(arr,warning_part2);
         writeWarningOnChart(arr,Red);
         return;
        }
      for(int i=0; i<limit1; i++)
        {
         for(int j=0; j<limit2; j++)
           {

            if(Time[i]!=0 && ArrayRange(assettOfThisIteration,0)>j && Time[i] == assettOfThisIteration[j].time)
              {
               AddToArray2(arr,i);
               AddToArray2(arr,j);
               matchFound = true;
               //Print(SYMBOL + " Time " + TimeToStr(rates[j].time));
               //Print(SYMBOL + " Value " + rates[j].open);
               //m_first_match = i;
               if(timeOfFirstBarOfCurrentChart==TimeToStr(assettOfThisIteration[j].time))
                 {
                  //Print("Symbol: " + getSymbol() + " " + " time of first match: " + TimeToStr(Time[i]));
                  m_first_bar_matches_with_first_of_current_chart = true;
                 }
               else
                 {
                  //Print("Symbol: " + getSymbol() + " " + " time of first match: " + TimeToStr(Time[i]));
                 }
               //Print("Time current: " + TimeToStr(TimeCurrent()));
               break;
              }

           }

         if(matchFound)
           {
            return;
            break;
           }

        }
      Print("Symbol: " + getSymbol() + " " + " matching time not found.");
     }

   int               getMatchingTimes()
     {
      return m_matching_times;
     }

   bool              doesFirstMatch()
     {
      return m_first_bar_matches_with_first_of_current_chart;
     }

   bool              isUpdatable()
     {
      return m_this_symbol_is_updatable;
     }

   double            computeCorrelation(int length)
     {
      m_correlation = correlation_coefficient(m_symbol_values_array,length);
      if(m_correlation>=0)
        {
         m_direction = 1;
        }
      else
        {
         m_direction = 0;
        }
      return m_correlation;
     }

   bool              setActivityValue(bool value)
     {
      m_is_active = value;
      return m_is_active;
     }
   bool              getActivityValue()
     {
      return m_is_active;
     }

   //+------------------------------------------------------------------+
   //| Function to compute a correlation value                          |
   //+------------------------------------------------------------------+


   double            correlation_coefficient(double &a[], COUNT length, INDEX iBeg=0)
     {
      INDEX    iEnd  = iBeg + length;
      /* https://en.wikipedia.org/wiki/Correlation_and_dependence
       * CorrelationCoefficient = ss(xy)/Sqrt( ss(xx) ss(yy) )
       * ss(xy) = E (xi-Ave(x))(yi-Ave(y)) = n E XiYi - E Xi E Yi
       * ss(xx) = E (xi-Ave(x))^2          = n E Xi**2 - (E Xi)**2
       * ss(yy) = E (yi-Ave(y))^2          = n E Yi**2 - (E Yi)**2
       */
      double   Ex=0.0,  Ex2=0.0,    Ey=0.0,  Ey2=0.0,    Exy=0.0;    // Ex=Sum(x)
      for(; iBeg < iEnd && iBeg<ArraySize(a); ++iBeg)
        {
         double   x = a[iBeg],   y = iOpen(NULL,0,iBeg);
         if(x!=0 && y!=0)
           {
            Ex += x;
            Ex2 += x * x;
            Ey += y;
            Ey2 += y * y;
            Exy += x * y;
           }
         else
           {
            Print(m_symbol + " function correlation_coefficient, one or both values are zero.");
            length--;
           }

        }
      double   ssxy  = length * Exy - Ex * Ey;
      double   ssxx  = length * Ex2 - Ex * Ex;
      double   ssyy  = length * Ey2 - Ey * Ey;
      double   deno  = MathSqrt(ssxx * ssyy);
      //Print("correlation_coefficient length: " + length);
      return (deno == 0.0) ? 0.0 : ssxy / deno;
     }




  };



//+----------------------------------------------------------------------------------+
//|                                            Divergence to best correlations.mq4   |
//|                                            Copyright © 2021, Matti Kinnunen      |
//|                                                                                  |
//+----------------------------------------------------------------------------------+
#property copyright "Copyright © 2021, Matti Kinnunen"
#resource  "Extra_Symbol_product_version_new.ex4"
#property strict
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Black
#property indicator_width1 1
#property indicator_color2 Orange
#property indicator_width2 1
#property indicator_color3 Orange
#property indicator_width3 1
#property indicator_color4 Lime
#property indicator_width4 1
#property indicator_color5 Red
#property indicator_width5 1
#property indicator_color6 Orange
#property indicator_width6 1
#property indicator_color7 Lime
#property indicator_width7 1
#property indicator_color8 Red
#property indicator_width8 1
#property indicator_level1 0
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
#property indicator_levelcolor DodgerBlue
#define SYMBOL string

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];


enum correlations  // enumeration of named constants
  {
   One = 1,   // 1
   Two = 2,   // 2
   Three = 3, // 3
   Four = 4,  // 4
   Five = 5,  // 5
   Six = 6,   // 6
   Seven = 7, // 7
   Eight = 8  // 8

  };

enum data_selection
  {
   Based_on_correlations = 1,
   Manual_input = 2

  };
enum visualMode
  {
   Histogram = 1,
   Line      = 0

  };

enum limit_definition
  {
   Automatic = 1,
   User_defined = 2

  };
sinput string Correlation_parameters =  "---------------------------------------------------------------------------------------------------------------";
input correlations Correlations = Eight;
extern bool Use_difference_to_best_correlations = false;
input limit_definition Limit_for_computing_of_correlation = Automatic;
extern int Limit_value_for_computing_of_correlation = 1000;
extern bool Compute_correlations_on_every_new_bar = true;
//extern bool Ignore_symbols_which_do_not_have_data_enough = false;
sinput string Visual_parameters =  "---------------------------------------------------------------------------------------------------------------";
input visualMode Visual_mode = Histogram;
extern bool Show_info_table = true;
extern bool Show_all_on_info_table = true;
sinput string Graph_computing_parameters =  "---------------------------------------------------------------------------------------------------------------";
extern bool Combine_to_this_symbol = false;
extern int SMA_period1=30;
extern int SMA_period2 =50;
sinput string Symbol_selection_parameters = "---------------------------------------------------------------------------------------------------------------";
input data_selection Symbol_selection = Based_on_correlations;
sinput string Manually_added_symbols =  "If Symbol_selection is set to 'Manual_input', input fields below will be the only symbols to compute correlations.";
extern string Symbol_1 = "";
extern string Symbol_2 = "";
extern string Symbol_3 = "";
extern string Symbol_4 = "";
extern string Symbol_5 = "";
extern string Symbol_6 = "";
extern string Symbol_7 = "";
extern string Symbol_8 = "";

int barMaximum_for_one;
int barMaximum_for_two;
int barMaximum_for_three;
int barMaximum_for_four;
int barMaximum_for_five;
int barMaximum_for_six;
int barMaximum_for_seven;
int barMaximum_for_eight;


//extern bool turn_direction = false;
bool Compute_correlation = false;
//extern int LimitForComputingOfCorrelation = 1000;

int shift = 0;
bool alertActive = false;
int  maxShiftForCorrelation;
double bestCorr;
SymbolCorrelation  *allSymbolCorrelationObjects[];
SymbolCorrelation *copyOf_allSymbolCorrelationObjects[];
SymbolCorrelation  *manuallyAddedSymbolCorrelationObjects[];
SymbolCorrelation *printables[];
string arrayOfInputFields[];

int limitForComputingOfCorrelation = Limit_value_for_computing_of_correlation;
bool GetBarAmount = false;

static datetime lastAlertTime;
bool initDone = false;
string indicatorShortName = "Divergence to best correlations, ID:";
string indicatorShortName_orig = indicatorShortName;

int leastMatches = 1000000000;
long chartid;
bool downloadOk;
bool manualInput;
int biggestNumberOfMatches = -1;
string symbolOfBiggestNumberOfMatches;
int counterForOnInit = 0;
bool firstNewBar=true;
bool tooBigValue=true;

string GVName   = indicatorShortName;
string tag_      = "";
int instance    = -1;
int instances[] = {1,2,4,8,16,32,64,128,256,512};
//string globalThisInstance;
bool firstMatches;
int firstMatchesCount;
int counterForSymbol1;
int counterForSymbol2;
int counterForSymbol3;
int counterForSymbol4;
int counterForSymbol5;
int counterForSymbol6;
int counterForSymbol7;
int counterForSymbol8;

string tagForGraphicals      = "_";
string namesOfGraphicalsOfThisInstance [];

int counterForAssets;
bool firstLaunch = true;
int counterForMyOwnInitCalls;
int counterForSymbolDownloads;
bool allDownloaded;













//int winind;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("init");
   firstMatchesCount = 0;
   /*
   bool firstInit = GlobalVariableGet("firstInitialization");
   Print("firstInit " + firstInit);
   if(!firstInit){ // if does not exist yet
      //GlobalVariableDel("firstInitialization");
      firstInitialization = TimeCurrent();
      //GlobalVariableSet("firstInitialization",firstInitialization);
   }else{
      Print("GlobalVariableGet(firstInitialization) " + GlobalVariableGet("firstInitialization"));
   }
   */

//---- indicators

   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,NULL);

   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"Histogram (+) value - history");
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexLabel(2,"Histogram (-) value - history");

   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexLabel(3,"Histogram (+) value - real time");
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexLabel(4,"Histogram (-) value - real time");

   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexLabel(5,"Line value - history");

   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexLabel(6,"Line (+) value - real time");

   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,ExtMapBuffer8);
   SetIndexLabel(7,"Line (-) value  - real time");



//Print(TimeToStr(firstInitialization));


//----
   /*if(GlobalVariableGet("Symbols downloaded") != (double)Period()){
      downloadAllSymbolsByOpeningCharts();
      GlobalVariableSet("Symbols downloaded", (double)Period());
   }
   */
   /* int minMatches = getLeastMatches();
    Print("minMatches " + minMatches);
   */
   manualInput = doesInputFieldsContain();
   downloadAssettDataAndComputeCorrelations();
   firstLaunch = false;

   /*
   if(!manualInput){
      downloadAssettDataAndComputeCorrelations(false);
   }else{
      downloadAssettDataAndComputeCorrelations(true);
   }
   */
   int maxBars = leastMatches;
   if(maxBars==0 && Limit_for_computing_of_correlation == Automatic)
     {
      //maxBars = limitForComputingOfCorrelation;
      Alert("Some of symbols misses the all data. To ignore those symbols in calculations, switch 'Ignore_symbols_which_do_not_have_data_enough' to true.");
     }
   else
      if(Limit_for_computing_of_correlation == Manual_input)
        {
         maxBars = biggestNumberOfMatches;
        }
//Print("maxBars " + maxBars);
//int symbolsWhichLacksData = downloadAllSymbols();
//int counter;
   /*if(maxBars>0){
      //symbolsWhichLacksData = downloadAllSymbols();
      //if(counter>100){
         //Alert("Data download is not finished yet. Please try to reload the indicator or check your internet connection.");
         //Print("Print(symbolsWhichLacksData) " + symbolsWhichLacksData);
        // break;
     // }
      //Print(symbolsWhichLacksData);
     // counter++;

   }
   */
   if(maxBars>0 && allDownloaded)
     {
      downloadOk = true;
     }

   initDone = true;

   GVName+=(string)ChartID();
   if(!GlobalVariableCheck(GVName))
     {
      if(!GlobalVariableTemp(GVName))
         return(INIT_FAILED);
      GlobalVariableSet(GVName,instances[0]);
      //globalThisInstance = "" + GlobalVariableGet(GVName);
      //tag_+=globalThisInstance;
      //Print("tag " + tag);
      ObjectsDeleteAll(0,tag_);
      instance = instances[0];
      tag_+=(string)instance;
      Print("No GV found... Assigning 1, deleting ALL orphaned objects");
     }
   else
     {
      int val = (int)GlobalVariableGet(GVName),
          cnt = ArraySize(instances);
      //Print("Another instance: " + val);
      for(int i=0; i<cnt; i++)
        {
         if((val&instances[i])==0)
           {
            instance=instances[i];
            GlobalVariableSet(GVName,val|instance);
            //globalThisInstance = "" + GlobalVariableGet(GVName);
            //tag_+=globalThisInstance;
            tag_+=(string)instance;
            ObjectsDeleteAll(0,tag_);
            printf("Assigning %i, deleting all orphaned '~%i' objects",instance,instance);
            break;
           }
        }
     }
   if(instance<0)
      return(INIT_FAILED);
//Print("Instance of this: " + GlobalVariableGet(GVName));
//Print("tag2 " + tag);
//globalThisInstance = "" + GlobalVariableGet(GVName);
//ObjectCreate(0,tag_,OBJ_LABEL,0,0,0);
   counterForOnInit = 0;
   tagForGraphicals += tag_;
//indicatorShortName+=ChartID();
   indicatorShortName=indicatorShortName_orig;
   indicatorShortName+=tag_;
   indicatorShortName+=" ";

   IndicatorShortName(indicatorShortName);
   deleteChartObjects();

   if(counterForAssets<Correlations)
     {
      //Alert("counterForAssets<Correlations");
      /* string warning_part1 = "Warning: Parameter 'Correlations' is bigger than amount of";
       string warning_part2 = "symbols downloaded. Is this the first launch of this indicator";
       string warning_part3 = "on this time frame or are there symbols enough on MarketWatch";
       string warning_part4 = "which are set visible? Please try to refresh the indicator.";
       string warning_part5 = "If refreshing does not fix the problem, please make sure";
       string warning_part6 = "there are symbols enough on MarketWatch which are set visible.";

       /*string warning_part4 = "";
       string warning_part5 = "Otherwise, if 'Limit_for_computing_of_correlation' is";
       string warning_part6 = "set to 'Automatic', maximum value for";
       string warning_part7 = "'Limit_value_for_computing_of_correlation' is: " + leastMatches ;
       */
      /*
      string arr[];
      AddToArray2(arr,warning_part1);
      AddToArray2(arr,warning_part2);
      AddToArray2(arr,warning_part3);
      AddToArray2(arr,warning_part4);
      AddToArray2(arr,warning_part5);
      AddToArray2(arr,warning_part6);
      /*
      AddToArray2(arr,warning_part5);
      AddToArray2(arr,warning_part6);
      AddToArray2(arr,warning_part7);
      */

      downloadOk = false;
      //writeWarningOnChart(arr);
     }








   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   deleteOldObjects();
   deleteChartObjects();
   string text="";
   int deInitReason = UninitializeReason();
   bool chartObjectsRemoved;
   /*string correlationsName = "Correlations" + tag_;
   string limit_for_computing_of_correlationName = "Limit_for_computing_of_correlation" + tag_;
   string limit_value_for_computing_of_correlationName = "Limit_value_for_computing_of_correlation" + tag_;
   string combineToThisSymbolName = "CombineToThisSymbol" + tag_;
   string sMA_period1Name = "SMA_period1" + tag_;
   string sMA_period2Name = "SMA_period2" + tag_;
   string symbol_sourceName = "Symbol_source" + tag_;
   */
   switch(deInitReason)
     {
      case REASON_ACCOUNT:
         text="Account was changed";
         deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         deleteChartObjects();
         setBuffersToZero();
         //GlobalVariablesDeleteAll("Symbols downloaded");
         break;
      case REASON_CHARTCHANGE:
         deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         deleteChartObjects();
         setBuffersToZero();
         firstLaunch = true;
         //GlobalVariablesDeleteAll("Symbols downloaded");
         text="Symbol or timeframe was changed";
         break;
      case REASON_CHARTCLOSE:
         ChartIndicatorDelete(ChartID(),0,indicatorShortName);
         /*deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         deleteChartObjects();
         setBuffersToZero();
         */
         //GlobalVariableDel("firstInitialization");
         //GlobalVariablesDeleteAll("Symbols downloaded");
         text="Chart was closed";
         break;
      case REASON_PARAMETERS:
         deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         deleteChartObjects();
         setBuffersToZero();
         //Alert("Correlations__ " + Correlations);




         text="Input-parameter was changed";
         break;
      case REASON_RECOMPILE:
         deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         deleteChartObjects();
         setBuffersToZero();
         //GlobalVariableDel("firstInitialization");
         text="Program "+__FILE__+" was recompiled";
         break;
      case REASON_REMOVE:
         deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         deleteChartObjects();
         setBuffersToZero();
         //GlobalVariableDel("firstInitialization");
         //GlobalVariablesDeleteAll("Symbols downloaded");
         for(int i=0; i<GlobalVariablesTotal(); i++)
           {
            GlobalVariableDel(StringSubstr(GlobalVariableName(i),0,3));

           }
         text="Program "+__FILE__+" was removed from chart";
         break;
      case REASON_TEMPLATE:
         deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         deleteChartObjects();
         setBuffersToZero();
         firstLaunch = true;
         text="New template was applied to chart";
         break;
      case REASON_CLOSE:
         deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         chartObjectsRemoved = deleteChartObjects();
         Print("chartObjectsRemoved? " + chartObjectsRemoved);
         setBuffersToZero();
         text="Terminal was closed.";
         break;
      default:
         deleteOldObjects();
         deleteOldObjects(copyOf_allSymbolCorrelationObjects);
         deleteChartObjects();
         //GlobalVariableDel("firstInitialization");
         //GlobalVariablesDeleteAll("Symbols downloaded");
         text="Another reason";
     }
//Print("tag " + tag);
   ObjectsDeleteAll(0,tagForGraphicals);
   int val=(int)GlobalVariableGet(GVName);
   GlobalVariableSet(GVName,val&~instance);
   printf("Freeing up %i and deleting all '~%i' objects",instance,instance);
//--- The first way to get the uninitialization reason code
   Print(__FUNCTION__,"_Uninitalization reason code = ",deInitReason);
//--- The second way to get the uninitialization reason code
   Print(__FUNCTION__,"_UninitReason = ",text);

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)
      return(-1);
   if(counted_bars>0)
      counted_bars--;
//Print("Time of first bar of current chart: " + TimeToStr(Time[0]));
//return -1;
   if(!downloadOk)
     {
      /*downloadAssettDataAndComputeCorrelations();
      deleteChartObjects();
      */
      //counterForSymbolDownloads++;
      string warning_part1 = "Notification: System has to download data for all symbols.";
      string warning_part2 = "Especially the first time ever on the platform and time";
      string warning_part3 = "frame change after long time can take quite a long time";
      string warning_part4 = "to get all data downloaded.";
      string arr[];
      AddToArray2(arr,warning_part1);
      AddToArray2(arr,warning_part2);
      AddToArray2(arr,warning_part3);
      AddToArray2(arr,warning_part4);
      writeWarningOnChart(arr, Orange);
      downloadOk = isAllDownloaded();
     }
   /*Alert("Symbols download will be tried again.");
   }else if(!downloadOk && counterForSymbolDownloads==11){
   deleteChartObjects();
   string warning_part1 = "Warning: System has tried to download data several times";
   string warning_part2 =  "but failed. Is your computer connected to the internet?";
   string arr[];
   AddToArray2(arr,warning_part1);
   AddToArray2(arr,warning_part2);
   writeWarningOnChart(arr);
   return (-1);
   }
   */


   if(downloadOk)
     {





      if(initDone)
        {
         Print("initDone");
         //maxBars = getMaximumBarAmount();


         setBestSymbols();
         if(!tooBigValue)
           {
            for(int i=1; i<limitForComputingOfCorrelation; i++)
              {
               setNewValue(i);
              }
           }
         //setMaValues(limit - SMA_period2);


         initDone = false;
         //EraseTail(limit);
         Print("graph finished");
         //Print("ArraySize(allSymbolCorrelationObjects)  " + ArraySize(allSymbolCorrelationObjects));
        }


      if(!initDone && NewBar() && !tooBigValue)
        {


         Print("!initDone && NewBar()");
         if(!firstNewBar && Compute_correlations_on_every_new_bar)
           {

            //maxBars = getMaximumBarAmount();
            deleteOldObjects();
            //manualInput = doesInputFieldsContain();
            downloadAssettDataAndComputeCorrelations();
            /*
            if(!manualInput){
              downloadAssettDataAndComputeCorrelations(false);
            }else{
              downloadAssettDataAndComputeCorrelations(true);
            }
            */
            //maxBars = leastMatches;
            /*if(maxBars==0 && !Ignore_symbols_which_do_not_have_data_enough){
               //maxBars = limitForComputingOfCorrelation;
               Alert("Some of symbols misses the all data. To ignore those symbols in calculations, switch 'Ignore_symbols_which_do_not_have_data_enough' to true.");
               */
            /*if(Limit_for_computing_of_correlation == Manual_input)
              {
               maxBars = biggestNumberOfMatches;
              }

              */
            setBestSymbols();
           }





         setNewValue(0);
         firstNewBar = false;

         if(firstMatchesCount==0 && counterForOnInit==0)
           {
            counterForOnInit++;
            Print("firstMatchesCount==0");
            initDone = true;
            start();
           }
         else
           {
            firstMatchesCount=0;
           }


        }
      else
         if(!initDone && !tooBigValue)
           {


            int c;
            bool syncOk = true;
            while(c<100 && c<limitForComputingOfCorrelation && counterForMyOwnInitCalls<6)
              {
               if(ArraySize(ExtMapBuffer1)>c && ArraySize(Time)>c && TimeToStr(ExtMapBuffer1[c])!=TimeToStr(Time[c]))
                 {
                  syncOk = false;
                  Alert("TimeToStr(ExtMapBuffer1[c]): " + TimeToStr(ExtMapBuffer1[c]) + " TimeToStr(Time[c])" + TimeToStr(Time[c]));
                  break;
                 }
               else
                  if(ArraySize(ExtMapBuffer1)<=c || ArraySize(Time)<=c)
                    {
                     syncOk = false;
                     //Alert("TimeToStr(ExtMapBuffer1[c]): " + TimeToStr(ExtMapBuffer1[c]) + " TimeToStr(Time[c])" + TimeToStr(Time[c]));
                     break;
                    }
               c++;
              }
            if(!syncOk && counterForMyOwnInitCalls<6)
              {
               Print("Buffers will be reinitialized.");
               setBuffersToZero();
               Print("OnInit will be reloaded.");
               counterForMyOwnInitCalls++;
               deleteChartObjects();
               deleteOldObjects();
               OnInit();
              }

           }


      //GlobalVariableSet("LimitForComputingOfCorrelation" + Period(), LimitForComputingOfCorrelation);
     }
   else
     {
      /*int symbolsWhichLacksData = downloadAssettDataAndComputeCorrelations();
      int counter;
      if(symbolsWhichLacksData>0){
         //symbolsWhichLacksData = downloadAllSymbols();
         //if(counter>100){
            Alert("Data download is not finished yet. Please try to reload the indicator or check your internet connection.");
            //Print("Print(symbolsWhichLacksData) " + symbolsWhichLacksData);
           // break;
        // }
         Print(symbolsWhichLacksData);
        // counter++;

      }
      if(symbolsWhichLacksData==0){
         downloadOk = true;
      }
      */
     }


//---- done
   return(0);
  }

//+-------------------------------------------------------------------------------------------------+
//| Function to search first matching time of assetts                                               |
//+-------------------------------------------------------------------------------------------------+


//+---------------------------------------------------------------------------------------------------+
//| Function to ensure the graph gets drawed properly after the platform launch and time frame change |
//+---------------------------------------------------------------------------------------------------+
/*
void ensureGraph(){

    if(counterForHalfEmptyGraph<1 && !initDone){  // this functionality is for checking if the graph is not drawn completely especially in cases which the platform is started and the indicator is attached already on chart
         for(int q=0;q<100;q++){
            if(ExtMapBuffer4[q]==EMPTY_VALUE && ExtMapBuffer5[q]==EMPTY_VALUE && ExtMapBuffer7[q]==EMPTY_VALUE){
               counterForHalfEmptyGraph++;
               Print("Bars missing!");
               break;
            }
         }
         counterForHalfEmptyGraph++;
      }
      if(!initDone && counterForHalfEmptyGraph<2){
         initDone = true;
         counterForHalfEmptyGraph++;
      }

}
*/


//+------------------------------------------------------------------+
//|  Function to check if all symbols are downloaded                 |
//+------------------------------------------------------------------+
bool isAllDownloaded()
  {

   int counterForOkAssets;
   for(int i=0; i<ArraySize(allSymbolCorrelationObjects); i++)
     {
      if(allSymbolCorrelationObjects[i].getAmountOfBars()>0)
        {
         counterForOkAssets++;
        }
     }

   Alert("SymbolsTotal(true)" + SymbolsTotal(true));
   int val = counterForOkAssets+1;
   Alert("counterForOkAssets+1 " + val);
   if(SymbolsTotal(true)==(counterForOkAssets+1))
     {
      return true;
     }
   else
     {
      return false;
     }
  }

//+-----------------------------------------------------------+
//| Function to validate content of input fields for symbols  |
//+-----------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isContentValid(string text)
  {

   int symbolAmount = (int)SymbolsTotal(true);

   for(int k=0; k<symbolAmount; k++)
     {
      string thisIterationSymbolName = SymbolName(k,true);
      if(thisIterationSymbolName == text)
        {
         return true;
        }

     }

   return false;

  }


//+---------------------------------------------------------------------------------------------------------------+
//| Function to determine if input fields contains valid symbols and if yes, to fill the array reserved for them  |
//+---------------------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool doesInputFieldsContain()
  {

   int validCount;

   if(isContentValid(Symbol_1))
     {
      validCount++;
      AddToArray2(arrayOfInputFields,Symbol_1);
     }
   if(isContentValid(Symbol_2))
     {
      validCount++;
      AddToArray2(arrayOfInputFields,Symbol_2);
     }
   if(isContentValid(Symbol_3))
     {
      validCount++;
      AddToArray2(arrayOfInputFields,Symbol_3);
     }
   if(isContentValid(Symbol_4))
     {
      validCount++;
      AddToArray2(arrayOfInputFields,Symbol_4);
     }
   if(isContentValid(Symbol_5))
     {
      validCount++;
      AddToArray2(arrayOfInputFields,Symbol_5);
     }
   if(isContentValid(Symbol_6))
     {
      validCount++;
      AddToArray2(arrayOfInputFields,Symbol_6);
     }
   if(isContentValid(Symbol_7))
     {
      validCount++;
      AddToArray2(arrayOfInputFields,Symbol_7);
     }
   if(isContentValid(Symbol_8))
     {
      validCount++;
      AddToArray2(arrayOfInputFields,Symbol_8);
     }

   if(validCount>0)
     {
      return true;
     }
   else
     {
      return false;
     }


  }

//+--------------------------------------------------------------------------------------------------------+
//| Function to find the moment when the extern symbol matches with the current symbol for the first time  |
//+--------------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void searchFirstMatch(int &arr[], MqlRates& assettOfThisIteration[], int limit1, int limit2)
  {

   bool matchFound;

   /*if(limitForComputingOfCorrelation<extern_limit){
      extern_limit = limitForComputingOfCorrelation;
   }
   */
   for(int i=0; i<limit1; i++)
     {
      for(int j=0; j<limit2; j++)
        {
         if(ArraySize(Time)<i && ArrayRange(assettOfThisIteration,0)<j)
           {
            if(Time[i]!=0 && Time[i] == assettOfThisIteration[j].time)
              {
               AddToArray2(arr,i);
               AddToArray2(arr,j);
               matchFound = true;
               //Print(SYMBOL + " Time " + TimeToStr(rates[j].time));
               //Print(SYMBOL + " Value " + rates[j].open);
               break;
              }
           }

        }

      if(matchFound)
        {
         break;
        }

     }

  }
//+-------------------------------------------------------------------------------------------------------+
//| Function to determine the symbol which time series has least amount of matches to the current symbol  |
//+-------------------------------------------------------------------------------------------------------+
/*
int getLeastMatches(){

   string thisSymbolName = Symbol();
   int limit1 = Bars;
   int symbolAmount = (int)SymbolsTotal(true);

   int leastAmountOfMatches=1000000000;
   string symbol = "";
   for(int k=0;k<symbolAmount;k++){

      string thisIterationSymbolName = SymbolName(k,true);

      if(thisSymbolName != thisIterationSymbolName){

         MqlRates rates[];
         ArrayCopyRates(rates,thisIterationSymbolName,0);
         ArrayInitialize(ExtMapBuffer1,0);
         ArrayInitialize(ExtMapBuffer2,0);

         int arr[];
         int limit2 = ArraySize(rates);

         searchFirstMatch(arr,rates, limit1, limit2);
         int firstLoopStart = arr[0];
         int secondLoopStart = arr[1];

         if(firstLoopStart!=secondLoopStart){
            continue;
         }
         int counter=0;
         for(int i=firstLoopStart; i<limit1; i++){
              double value;
              int j;

              for(int l=secondLoopStart;l<ArraySize(rates);l++){

                  if((Time[i]) == (rates[l].time)){

                     value = rates[l].open;
                     if(l!=0){
                        secondLoopStart = l-1;
                        //if(TimeToStr(Time[i])>"2021.09.01 00:00")
                        //Print("Time[i], assett, counter, barAmount " + TimeToStr(Time[i]) + " " + thisIterationSymbolName + " " + counter + " " + barAmount);
                        ExtMapBuffer1[counter] = iOpen(NULL,0,i);
                        ExtMapBuffer2[counter] = rates[l].open;

                        //AddToArray2(arr2,comparable);
                        //AddToArray2(arr1,btc);
                        counter++;
                     }
                     break;
                  }

              }

         }

         if(counter<leastAmountOfMatches){
            leastAmountOfMatches = counter;
            //symbol = thisIterationSymbolName;

         }


      }
   }
   return leastAmountOfMatches;


}
*/

//+-------------------------------------------------------------------------------------------------------------------+
//| Function to determine if arrayOfInputFields contains a symbol of current iteration of allSymbolCorrelationObjects |
//+-------------------------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool doesArrayContain(string symbol, string &arr[])
  {
   for(int i=0; i<ArraySize(arr); i++)
     {
      if(symbol == arr[i])
        {
         //Print("TRUE");
         return true;
        }
     }
//Print("FALSE " + symbol);
   return false;
  }
//+---------------------------------------------------------------------------------+
//| Function to start downloading of all symbol rates                               |
//+---------------------------------------------------------------------------------+
int downloadAssettDataAndComputeCorrelations()
  {

   string thisSymbolName = Symbol();
//int counterForSymbolDataDownloading;

   int limit1 = Bars;
   int symbolAmount = (int)SymbolsTotal(true);
   int symbolAmountMoreThanZeroBars;


   /*int barAmountArray[];
   for(int k=0;k<symbolAmount;k++){
      MqlRates rates[];
      int barAmount_ = ArrayCopyRates(rates,SymbolName(k,true),0);
      AddToArray2(barAmountArray,barAmount_);
   }
   int minBars = barAmountArray[ArrayMinimum(barAmountArray,WHOLE_ARRAY,0)];
   if(limitForComputingOfCorrelation>minBars){
      limitForComputingOfCorrelation = minBars;
   }
   */
//ArrayResize(ExtMapBuffer1,limitForComputingOfCorrelation);
//ArrayResize(ExtMapBuffer2,limitForComputingOfCorrelation);
//Print("ArraySize(ExtMapBuffer1) " + ArraySize(ExtMapBuffer1));
//Print("ArraySize(ExtMapBuffer2) " + ArraySize(ExtMapBuffer2));
   leastMatches = 1000000000;
   for(int k=0; k<symbolAmount; k++)
     {
      string thisIterationSymbolName;
      thisIterationSymbolName = SymbolName(k,true);


      if(thisSymbolName != thisIterationSymbolName)
        {

         //MqlRates rates[];
         //int sizeOfRates = ArrayCopyRates(rates,thisIterationSymbolName,0);
         //ArrayInitialize(ExtMapBuffer1,0);
         //ArrayInitialize(ExtMapBuffer2,0);
         /*if(barAmount>limitForComputingOfCorrelation){
            barAmount = limitForComputingOfCorrelation;
         }
         */
         SymbolCorrelation *symCorr = new SymbolCorrelation(thisIterationSymbolName,limit1);
         //Print(symCorr.getSymbol() + " object was created");
         if(firstLaunch)
           {
            if(symCorr.getAmountOfBars()>0)
              {
               symbolAmountMoreThanZeroBars++;
              }

           }


         int matchingTimes = symCorr.generateComparableTimeSeriesForThisSymbol();
         if(matchingTimes!=(-1))
           {
            //symCorr.computeCorrelation();
            counterForAssets++;
            int counter = symCorr.getMatchingTimes();
            if(counter<leastMatches)
              {
               leastMatches = counter;
              }
            if(counter>biggestNumberOfMatches)
              {
               biggestNumberOfMatches = counter;
               symbolOfBiggestNumberOfMatches = symCorr.getSymbol();
              }
            SymbolCorrelation *symCorr_copy = new SymbolCorrelation(symCorr);
            AddToArray2(allSymbolCorrelationObjects,symCorr);
            AddToArray2(copyOf_allSymbolCorrelationObjects, symCorr_copy);


            if(doesArrayContain(thisIterationSymbolName,arrayOfInputFields))
              {
               SymbolCorrelation *symCorr_copy2 = new SymbolCorrelation(symCorr);
               AddToArray2(manuallyAddedSymbolCorrelationObjects,symCorr_copy2);
              }
            /*
            Print("Counter " + counter);
            */
            //if(counterForAssets>1)break;
            /*
            if(barAmount<minBars){
               minBars = barAmount;
            }
            */
           }
         else
           {
            Print(symCorr.getSymbol() + " is deletable");
            delete symCorr;
            continue;
           }
        }

      //Print("Symbolss: " + ArraySize(allSymbolCorrelationObjects));
     }
//Print("leastMatches "  + leastMatches);
//Print("biggestNumberOfMatches "  + biggestNumberOfMatches);

   int coun;

   SymbolCorrelation* analysables[];
   if(Symbol_selection == Manual_input)
     {
      generateAttributes(manuallyAddedSymbolCorrelationObjects, true);
     }
   else
     {
      generateAttributes(allSymbolCorrelationObjects, true);
     }
   removeDuplicatesAndSortByCorrelation();



   for(int j=0; j<ArraySize(allSymbolCorrelationObjects); j++)
     {
      //Print("Symbol2: " + allSymbolCorrelationObjects[j].getSymbol() + " isUpdatable: " + allSymbolCorrelationObjects[j].isUpdatable() + " correlation: " + allSymbolCorrelationObjects[j].getCorrelation() + " is active: " + allSymbolCorrelationObjects[j].getActivityValue() + " matching times: " + allSymbolCorrelationObjects[j].getMatchingTimes());

     }

   if(firstLaunch)
     {
      int val = symbolAmount - symbolAmountMoreThanZeroBars;
      if(val==1)
        {
         allDownloaded = true;
        }
      else
        {
         allDownloaded = false;
         Alert("Symbols not downloaded: " + val);
        }

     }
//s = ArraySize(allSymbolCorrelationObjects);
//Print("size3 " + s);
   if(Limit_for_computing_of_correlation == Automatic)
     {
      return leastMatches;
     }
   else
     {
      return limitForComputingOfCorrelation;
     }


  }
//+---------------------------------------------------------------------------------+
//| Function to generate needed attributes for objects                              |
//+---------------------------------------------------------------------------------+
void generateAttributes(SymbolCorrelation* &analysables[], bool isPrimary)
  {
   if(isPrimary)
     {
      for(int j=0; j<ArraySize(analysables); j++)
        {


         if(Limit_for_computing_of_correlation == User_defined && analysables[j].getMatchingTimes()<limitForComputingOfCorrelation)
           {
            analysables[j].generateComparableTimeSeriesForThisSymbol();
            analysables[j].setActivityValue(false);
           }
         else
            if(Limit_for_computing_of_correlation == User_defined && analysables[j].getMatchingTimes()>=limitForComputingOfCorrelation)
              {
               analysables[j].generateComparableTimeSeriesForThisSymbol();
               analysables[j].computeCorrelation(limitForComputingOfCorrelation);
               firstMatches = analysables[j].doesFirstMatch();
               if(firstMatches==true)
                 {
                  firstMatchesCount++;
                 }
              }
            else
               if(Limit_for_computing_of_correlation == Automatic)
                 {
                  analysables[j].generateComparableTimeSeriesForThisSymbol();
                  analysables[j].computeCorrelation(leastMatches);
                  firstMatches = analysables[j].doesFirstMatch();
                  if(firstMatches==true)
                    {
                     firstMatchesCount++;
                    }
                 }
        }
     }
   else
     {

      for(int j=0; j<ArraySize(analysables); j++)
        {


         if(Limit_for_computing_of_correlation == User_defined && analysables[j].getMatchingTimes()<limitForComputingOfCorrelation)
           {
            analysables[j].generateComparableTimeSeriesForThisSymbol();
            analysables[j].setActivityValue(false);
           }
         else
            if(Limit_for_computing_of_correlation == User_defined && analysables[j].getMatchingTimes()>=limitForComputingOfCorrelation)
              {
               analysables[j].generateComparableTimeSeriesForThisSymbol();
               analysables[j].computeCorrelation(limitForComputingOfCorrelation);
               firstMatches = analysables[j].doesFirstMatch();
              }
            else
               if(Limit_for_computing_of_correlation == Automatic)
                 {
                  analysables[j].generateComparableTimeSeriesForThisSymbol();
                  analysables[j].computeCorrelation(leastMatches);
                  firstMatches = analysables[j].doesFirstMatch();
                 }
        }


     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getDirectionOfCorrelation(double corr)
  {

   if(corr > 0)
     {
      return 1;
     }
   else
     {
      return 0;
     }
  }

//+---------------------------------------------------------------------------------+
//| Function to check data of a certain symbol by a custom indicator                |
//+---------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double checkSymbolDataByIndy(string symbol)
  {
//int counter;
//while(iTime(symbol,0,0)!=iTime(NULL,0,0)){

   return iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,symbol,true,limitForComputingOfCorrelation,false,4,0);
   /*if(possibly_correlation>1){

      //Alert("Is there something wrong with your internet connection?");
      //Print("Count " + counter + " " + downloadOk);
      return false;

   }else if(iTime(symbol,0,0)==iTime(NULL,0,0)){
      //Print("Count " + counter + " " + downloadOk);
      return true;
   }
   //counter++;

   */



  }


//+---------------------------------------------------------------------------------+
//| Function to check data of a certain symbol                                      |
//+---------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkSymbolData(string symbol)
  {
//int counter;
//while(iTime(symbol,0,0)!=iTime(NULL,0,0)){

   if(iTime(symbol,0,0)==iTime(NULL,0,0))
     {
      //Print("Count " + counter + " " + downloadOk);
      return true;
     }

   return false;



  }


//+------------------------------------------------------------------+
//| Function to download all symbols                                 |
//+------------------------------------------------------------------+
/*
int downloadAllSymbols(){

   string thisSymbolName = Symbol();
   int counterForSymbolDataDownloading;

   for(int k=0;k<SymbolsTotal(true);k++){

      string thisIterationSymbolName = SymbolName(k,true);

      if(thisSymbolName != thisIterationSymbolName){
         double possibly_correlation = checkSymbolDataByIndy(thisIterationSymbolName);
         //Print("thisIterationSymbolName " + thisIterationSymbolName);
         //Print("possibly_correlation " + possibly_correlation);
         if(EMPTY_VALUE!=possibly_correlation && possibly_correlation<1){

            SymbolCorrelation *symCorr = new SymbolCorrelation(thisIterationSymbolName,possibly_correlation,getDirectionOfCorrelation(possibly_correlation),k,0);
            AddToArray2(allSymbolCorrelationObjects,symCorr);
            continue;
         }else if(possibly_correlation == 4066){
            counterForSymbolDataDownloading++;
         }
      }
   }

   //Print("Symbols available: " + ArraySize(allSymbolCorrelationObjects));
   return counterForSymbolDataDownloading;
}
*/

//+------------------------------------------------------------------+
//| Function to download all symbols by opening charts               |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void downloadAllSymbolsByOpeningCharts()
  {
   long curChartID = ChartID();
   string thisSymbolName = Symbol();
   for(int k=0; k<SymbolsTotal(true); k++)
     {

      string thisIterationSymbolName = SymbolName(k,true);

      if(thisSymbolName != thisIterationSymbolName)
        {

         long chartid=ChartOpen(SymbolName(k,true),PERIOD_CURRENT);
         if(curChartID != chartid && chartid != 0)
           {
            //Print("curChartID " + curChartID + ", chartid " + chartid);
            bool closeOk = ChartClose(chartid);
            if(closeOk)
              {
               continue;
              }
            else
              {
               downloadAllSymbolsByOpeningCharts();
              }
           }
        }
     }

  }

//+------------------------------------------------------------------+
//| Function to initialize buffers                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setBuffersToZero()
  {

   ArrayInitialize(ExtMapBuffer1,EMPTY_VALUE);
   ArrayInitialize(ExtMapBuffer2,EMPTY_VALUE);
   ArrayInitialize(ExtMapBuffer3,EMPTY_VALUE);
   ArrayInitialize(ExtMapBuffer4,EMPTY_VALUE);
   ArrayInitialize(ExtMapBuffer5,EMPTY_VALUE);
   ArrayInitialize(ExtMapBuffer6,EMPTY_VALUE);
   ArrayInitialize(ExtMapBuffer7,EMPTY_VALUE);
  }


//+------------------------------------------------------------------+
//| Function to trim indicator buffer ExtMapBuffer1 just in case     |
//+------------------------------------------------------------------+

/*
void EraseTail(int limit){

   for(int i=limit; i>=limit-SMA_period2; i--){

             ExtMapBuffer1[i] = EMPTY_VALUE;
             //ExtMapBuffer3[i] = EMPTY_VALUE;

   }


}
*/
//+------------------------------------------------------------------+
//| Function to detect the forming of a new bar                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime lastbar;
   datetime curbar;
   if(ArraySize(Time)>0)
     {
      curbar = Time[0];
     }
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

//+-------------------------------------------------------------------+
//| Function to delete all class objects which are used for computing |
//+-------------------------------------------------------------------+
void deleteOldObjects(SymbolCorrelation* &symCorrs[])
  {

   for(int h=0; h<ArraySize(symCorrs); h++)
     {
      if(CheckPointer(symCorrs[h])!=POINTER_INVALID)
        {
         delete symCorrs[h];
        }
     }
   ArrayResize(symCorrs,0);

  }

//+-----------------------------------------------------------------------------------+
//| Function to delete all class objects which are used for computing of correlations |
//+-----------------------------------------------------------------------------------+
void deleteOldObjects()
  {

   for(int h=0; h<ArraySize(allSymbolCorrelationObjects); h++)
     {
      if(CheckPointer(allSymbolCorrelationObjects[h])!=POINTER_INVALID)
        {
         delete allSymbolCorrelationObjects[h];
        }
     }
   ArrayResize(allSymbolCorrelationObjects,0);

   for(int h=0; h<ArraySize(manuallyAddedSymbolCorrelationObjects); h++)
     {
      if(CheckPointer(manuallyAddedSymbolCorrelationObjects[h])!=POINTER_INVALID)
        {
         delete manuallyAddedSymbolCorrelationObjects[h];
        }
     }
   ArrayResize(manuallyAddedSymbolCorrelationObjects,0);

  }

//+------------------------------------------------------------------+
//| Function to delete chart objects                             |
//+------------------------------------------------------------------+
bool deleteChartObjects()
  {
   bool success = true;
   bool returnable = true;
   for(int iObj=ArraySize(namesOfGraphicalsOfThisInstance)-1; iObj >= 0; iObj--)
     {
      string on = namesOfGraphicalsOfThisInstance[iObj];
      if(StringFind(on, tagForGraphicals) == 0)
        {
         //Print("deleted " + on + " " + tagForGraphicals);
         success = ObjectDelete(on);
         if(!success)
           {
            returnable = false;
            success = true;
            int err = GetLastError();
            //Print("Deleting " + on + " failed. Error code: " + err);
           }
         else
           {
            //Print("Deleting " + on + " succeed");

           }
        }
      else
         if(StringFind(on, tagForGraphicals == 0))
           {
            success = ObjectDelete(on);
            if(!success)
              {
               returnable = false;
               success = true;
               //Print("Deleting " + on + " failed");
              }
            else
              {
               //Print("Deleting " + on + " succeed");
              }
           }
     }
   return returnable;
  }


/*
bool deleteChartObjects()
  {

   for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
     {
      string on = ObjectName(iObj);
      if(StringFind(on, tagForGraphicals) == 0)
        {
         //Print("deleted " + on + " " + tagForGraphicals);
         if(!ObjectDelete(tagForGraphicals)){
            return false;
         }
        }
      else
         if(StringFind(on, tagForGraphicals == 0))
           {
            if(!ObjectDelete(tagForGraphicals)){
               return false;
            }
           }
     }

     return true;

  }

*/

//+------------------------------------------------------------------+
//| Function to create a colored background for correlations         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateBackground(string backName, string text, int Bfontsize, int LabelCorner, int xB, int yB, color colour)
  {
   if(ObjectFind(backName) == -1)
     {
      if(ObjectCreate(backName, OBJ_LABEL, 0, 0, 0, 0, 0))
        {
         AddToArray2(namesOfGraphicalsOfThisInstance, backName);
        }
     }
   ObjectSetText(backName, text, Bfontsize, "Webdings");
   ObjectSet(backName, OBJPROP_CORNER, LabelCorner);
   ObjectSet(backName, OBJPROP_BACK, false);
   ObjectSet(backName, OBJPROP_XDISTANCE, xB);
   ObjectSet(backName, OBJPROP_YDISTANCE, yB);
   ObjectSet(backName, OBJPROP_COLOR, colour);
  }

//+------------------------------------------------------------------+
//| Function to compute moving averages                              |
//+------------------------------------------------------------------+
/*
void setMaValues(int limit){

   for(int i=0; i<limit; i++){
      ExtMapBuffer2[i]=0;
      ExtMapBuffer3[i]=0;
   for(int z=0; z<SMA_period2; z++){
      if((i+z)<ArraySize(ExtMapBuffer1)){
         if(z<SMA_period1)
            ExtMapBuffer2[i]=ExtMapBuffer2[i]+ExtMapBuffer1[i+z];
            ExtMapBuffer3[i]=ExtMapBuffer3[i]+ExtMapBuffer1[i+z];
      }
   }

      ExtMapBuffer2[i] = ExtMapBuffer2[i]/SMA_period1;
      ExtMapBuffer3[i] = ExtMapBuffer3[i]/SMA_period2;
      double value = (ExtMapBuffer1[i] - ExtMapBuffer2[i]) + (ExtMapBuffer1[i] - ExtMapBuffer3[i]) + (ExtMapBuffer2[i] - ExtMapBuffer3[i]) - ExtMapBuffer6[i];
      if(VisualMode == Histogram){
         if(value>=0){
           ExtMapBuffer4[i] = value;
         }else{
           ExtMapBuffer5[i] = value;
         }
      }else{

         ExtMapBuffer7[i] = value;

      }
   }

}
*/
//+------------------------------------------------------------------+
//| Function to test which symbols are available                     |
//+------------------------------------------------------------------+
/*
bool setAvailableSymbols(){

   int total=SymbolsTotal(true)-1;
   for(int i=total-1;i>=0;i--){
      string Sembol=SymbolName(i,true);
      bool symbolOk = downloadSymbol(Sembol);
      if(symbolOk){
         DaxDriverSymbol *newSymbol = new DaxDriverSymbol(Sembol);
         AddToArray2(allAvailableDaxDriverSymbolObjects,newSymbol);
      }
   }
   int size = ArraySize(allDaxDriverSymbolObjects);
   Alert("Symbols downloaded: " + size);

   if(size>0){
      return true;
   }else{
      return false;
   }

}


//+------------------------------------------------------------------+
//| Function to download available symbols                           |
//+------------------------------------------------------------------+
/*
bool downloadSymbol(string symbol){

   if(TimeDayOfWeek(TimeCurrent()) != day){

         day = TimeDayOfWeek(TimeCurrent());
         while(!download_history(symbol,PERIOD_CURRENT) ){ Sleep(1000); RefreshRates(); }

         datetime start_time = TimeCurrent() - 2*PERIOD_D1*60;
         // datetime end_time = TimeCurrent() - 1*PERIOD_D1*60;
         datetime end_time = TimeCurrent();

         //Print("Set times - start: ", start_time, " stop: ", end_time);
         Print("iBars = ", iBars(symbol, 0));
         // Get rates of smaller periods within the session
         MqlRates rates[];

         int num_rates = CopyRates(symbol, PERIOD_CURRENT, start_time, end_time, rates);

         Print("Num rates = ", num_rates);
         if(num_rates == -1)
         {
            Print("Error Code = ",GetLastError());
            ResetLastError();
            return false;
         }else{
            return true;
         }
   }else{
      return true;

   }

}

//+------------------------------------------------------------------+
//| Function to download a certain symbol                            |
//+------------------------------------------------------------------+

bool     download_history(SYMBOL symbol, ENUM_TIMEFRAMES period=PERIOD_CURRENT){
   if(period == PERIOD_CURRENT)  period = (ENUM_TIMEFRAMES)_Period;
   ResetLastError();    datetime other = iTime(symbol, period, 0);
   if(_LastError == 0 && other != 0)   return true;
   if(_LastError != ERR_HISTORY_WILL_UPDATED
   && _LastError != ERR_NO_HISTORY_DATA
     )   PrintFormat("iTime(%s,%i) Failed: %i", symbol, period, _LastError);
   return false;
}

*/
//+------------------------------------------------------------------+
//| Function to set new value by index                               |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setNewValue(int i)
  {

   double externSymbol1_;
   double externSymbol2_;
   double externSymbol3_;
   double externSymbol4_;
   double externSymbol5_;
   double externSymbol6_;
   double externSymbol7_;
   double externSymbol8_;
   double ourValue;

   double thisValue1;
   double thisValue2;
   double thisValue3;
   double thisValue4;
   double thisValue5;
   double thisValue6;
   double thisValue7;
   double thisValue8;


   int denominator;
   bool thisSymbolOk;
   SymbolCorrelation* drawable[];
   if(Symbol_selection == Manual_input && ArraySize(manuallyAddedSymbolCorrelationObjects)>0)
     {
      DeepCopyAnArray2(manuallyAddedSymbolCorrelationObjects, drawable);
     }
   else
      if(Symbol_selection == Based_on_correlations)
        {
         DeepCopyAnArray2(allSymbolCorrelationObjects, drawable);
        }

   GetBarAmount = false;
   Compute_correlation = false;
   double thisSymbol =  iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,Symbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
   if(thisSymbol!=EMPTY_VALUE)
     {
      thisSymbolOk=true;

     }
//ExtMapBuffer6[i] = iCustom(NULL,0,"::Extra_symbol_product_version.ex4",SMA_period1, SMA_period2, false,Symbol(),3,i);
   if(Correlations  == 8 && ArraySize(drawable)>=8)
     {
      thisValue1 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[0].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
      thisValue2 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[1].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
      thisValue3 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[2].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
      thisValue4 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[3].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
      thisValue5 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[4].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
      thisValue6 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[5].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
      thisValue7 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[6].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
      thisValue8 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[7].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);

      if(drawable[0].getDirection()==1 && thisValue1!=EMPTY_VALUE)
        {
         externSymbol1_ =  thisValue1;
         denominator++;
         counterForSymbol1++;
        }
      else
         if(drawable[0].getDirection()==0 && thisValue1!=EMPTY_VALUE)
           {
            externSymbol1_ =  -1*thisValue1;
            denominator++;
            counterForSymbol1++;
           }

      if(drawable[1].getDirection()==1 && thisValue2!=EMPTY_VALUE)
        {
         externSymbol2_ =  thisValue2;
         denominator++;
         counterForSymbol2++;
        }
      else
         if(drawable[1].getDirection()==0 && thisValue2!=EMPTY_VALUE)
           {
            externSymbol2_ =  -1*thisValue2;
            denominator++;
            counterForSymbol2++;
           }

      if(drawable[2].getDirection()==1 && thisValue3!=EMPTY_VALUE)
        {
         externSymbol3_ = thisValue3;
         denominator++;
         counterForSymbol3++;
        }
      else
         if(drawable[2].getDirection()==0 && thisValue3!=EMPTY_VALUE)
           {
            externSymbol3_ =  -1*thisValue3;
            denominator++;
            counterForSymbol3++;
           }

      if(drawable[3].getDirection()==1 && thisValue4!=EMPTY_VALUE)
        {
         externSymbol4_ =  thisValue4;
         denominator++;
         counterForSymbol4++;
        }
      else
         if(drawable[3].getDirection()==0 && thisValue4!=EMPTY_VALUE)
           {
            externSymbol4_ =  -1*thisValue4;
            denominator++;
            counterForSymbol4++;
           }

      if(drawable[4].getDirection()==1 && thisValue5!=EMPTY_VALUE)
        {
         externSymbol5_ =  thisValue5;
         denominator++;
         counterForSymbol5++;
        }
      else
         if(drawable[4].getDirection()==0 && thisValue5!=EMPTY_VALUE)
           {
            externSymbol5_ =  -1*thisValue5;
            denominator++;
            counterForSymbol5++;
           }

      if(drawable[5].getDirection()==1 && thisValue6!=EMPTY_VALUE)
        {
         externSymbol6_ = thisValue6;
         denominator++;
         counterForSymbol6++;
        }
      else
         if(drawable[5].getDirection()==0 && thisValue6!=EMPTY_VALUE)
           {
            externSymbol6_ =  -1*thisValue6;
            denominator++;
            counterForSymbol6++;
           }

      if(drawable[6].getDirection()==1 && thisValue7!=EMPTY_VALUE)
        {
         externSymbol7_ =  thisValue7;
         denominator++;
         counterForSymbol7++;
        }
      else
         if(drawable[6].getDirection()==0 && thisValue7!=EMPTY_VALUE)
           {
            externSymbol7_ =  -1*thisValue7;
            denominator++;
            counterForSymbol7++;
           }

      if(drawable[7].getDirection()==1 && thisValue8!=EMPTY_VALUE)
        {
         externSymbol8_ = thisValue8;
         denominator++;
         counterForSymbol8++;
        }
      else
         if(drawable[7].getDirection()==0 && thisValue8!=EMPTY_VALUE)
           {
            externSymbol8_ =  -1*thisValue8;
            denominator++;
            counterForSymbol8++;
           }


      if(Combine_to_this_symbol && thisSymbolOk && denominator!=0)
        {
         ourValue=(((externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_ + externSymbol5_ + externSymbol6_ + externSymbol7_ + externSymbol8_)/denominator) + thisSymbol)/2;
        }
      else
         if(denominator!=0)
           {
            ourValue=(externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_ + externSymbol5_ + externSymbol6_ + externSymbol7_ + externSymbol8_)/denominator;
           }
     }
   else
      if(Correlations  == 7 && ArraySize(drawable)>=7)
        {
         thisValue1 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[0].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
         thisValue2 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[1].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
         thisValue3 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[2].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
         thisValue4 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[3].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
         thisValue5 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[4].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
         thisValue6 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[5].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
         thisValue7 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[6].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);

         if(drawable[0].getDirection()==1 && thisValue1!=EMPTY_VALUE)
           {
            externSymbol1_ =  thisValue1;
            denominator++;
            counterForSymbol1++;
           }
         else
            if(drawable[0].getDirection()==0 && thisValue1!=EMPTY_VALUE)
              {
               externSymbol1_ =  -1*thisValue1;
               denominator++;
               counterForSymbol1++;
              }

         if(drawable[1].getDirection()==1 && thisValue2!=EMPTY_VALUE)
           {
            externSymbol2_ =  thisValue2;
            denominator++;
            counterForSymbol2++;
           }
         else
            if(drawable[1].getDirection()==0 && thisValue2!=EMPTY_VALUE)
              {
               externSymbol2_ =  -1*thisValue2;
               denominator++;
               counterForSymbol2++;
              }

         if(drawable[2].getDirection()==1 && thisValue3!=EMPTY_VALUE)
           {
            externSymbol3_ = thisValue3;
            denominator++;
            counterForSymbol3++;
           }
         else
            if(drawable[2].getDirection()==0 && thisValue3!=EMPTY_VALUE)
              {
               externSymbol3_ =  -1*thisValue3;
               denominator++;
               counterForSymbol3++;
              }

         if(drawable[3].getDirection()==1 && thisValue4!=EMPTY_VALUE)
           {
            externSymbol4_ =  thisValue4;
            denominator++;
            counterForSymbol4++;
           }
         else
            if(drawable[3].getDirection()==0 && thisValue4!=EMPTY_VALUE)
              {
               externSymbol4_ =  -1*thisValue4;
               denominator++;
               counterForSymbol4++;
              }

         if(drawable[4].getDirection()==1 && thisValue5!=EMPTY_VALUE)
           {
            externSymbol5_ =  thisValue5;
            denominator++;
            counterForSymbol5++;
           }
         else
            if(drawable[4].getDirection()==0 && thisValue5!=EMPTY_VALUE)
              {
               externSymbol5_ =  -1*thisValue5;
               denominator++;
               counterForSymbol5++;
              }

         if(drawable[5].getDirection()==1 && thisValue6!=EMPTY_VALUE)
           {
            externSymbol6_ = thisValue6;
            denominator++;
            counterForSymbol6++;
           }
         else
            if(drawable[5].getDirection()==0 && thisValue6!=EMPTY_VALUE)
              {
               externSymbol6_ =  -1*thisValue6;
               denominator++;
               counterForSymbol6++;
              }

         if(drawable[6].getDirection()==1 && thisValue7!=EMPTY_VALUE)
           {
            externSymbol7_ =  thisValue7;
            denominator++;
            counterForSymbol7++;
           }
         else
            if(drawable[6].getDirection()==0 && thisValue7!=EMPTY_VALUE)
              {
               externSymbol7_ =  -1*thisValue7;
               denominator++;
               counterForSymbol7++;
              }
         if(Combine_to_this_symbol && thisSymbolOk && denominator!=0)
           {
            ourValue=(((externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_ + externSymbol5_ + externSymbol6_ + externSymbol7_)/denominator) + thisSymbol)/2;
           }
         else
            if(denominator!=0)
              {
               ourValue=(externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_ + externSymbol5_ + externSymbol6_ + externSymbol7_)/denominator;
              }

        }
      else
         if(Correlations  == 6 && ArraySize(drawable)>=6)
           {
            thisValue1 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[0].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
            thisValue2 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[1].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
            thisValue3 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[2].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
            thisValue4 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[3].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
            thisValue5 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[4].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
            thisValue6 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[5].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);

            if(drawable[0].getDirection()==1 && thisValue1!=EMPTY_VALUE)
              {
               externSymbol1_ =  thisValue1;
               denominator++;
               counterForSymbol1++;
              }
            else
               if(drawable[0].getDirection()==0 && thisValue1!=EMPTY_VALUE)
                 {
                  externSymbol1_ =  -1*thisValue1;
                  denominator++;
                  counterForSymbol1++;
                 }

            if(drawable[1].getDirection()==1 && thisValue2!=EMPTY_VALUE)
              {
               externSymbol2_ =  thisValue2;
               denominator++;
               counterForSymbol2++;
              }
            else
               if(drawable[1].getDirection()==0 && thisValue2!=EMPTY_VALUE)
                 {
                  externSymbol2_ =  -1*thisValue2;
                  denominator++;
                  counterForSymbol2++;
                 }

            if(drawable[2].getDirection()==1 && thisValue3!=EMPTY_VALUE)
              {
               externSymbol3_ = thisValue3;
               denominator++;
               counterForSymbol3++;
              }
            else
               if(drawable[2].getDirection()==0 && thisValue3!=EMPTY_VALUE)
                 {
                  externSymbol3_ =  -1*thisValue3;
                  denominator++;
                  counterForSymbol3++;
                 }

            if(drawable[3].getDirection()==1 && thisValue4!=EMPTY_VALUE)
              {
               externSymbol4_ =  thisValue4;
               denominator++;
               counterForSymbol4++;
              }
            else
               if(drawable[3].getDirection()==0 && thisValue4!=EMPTY_VALUE)
                 {
                  externSymbol4_ =  -1*thisValue4;
                  denominator++;
                  counterForSymbol4++;
                 }

            if(drawable[4].getDirection()==1 && thisValue5!=EMPTY_VALUE)
              {
               externSymbol5_ =  thisValue5;
               denominator++;
               counterForSymbol5++;
              }
            else
               if(drawable[4].getDirection()==0 && thisValue5!=EMPTY_VALUE)
                 {
                  externSymbol5_ =  -1*thisValue5;
                  denominator++;
                  counterForSymbol5++;
                 }

            if(drawable[5].getDirection()==1 && thisValue6!=EMPTY_VALUE)
              {
               externSymbol6_ = thisValue6;
               denominator++;
               counterForSymbol6++;
              }
            else
               if(drawable[5].getDirection()==0 && thisValue6!=EMPTY_VALUE)
                 {
                  externSymbol6_ =  -1*thisValue6;
                  denominator++;
                  counterForSymbol6++;
                 }
            if(Combine_to_this_symbol && thisSymbolOk && denominator!=0)
              {
               ourValue=(((externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_ + externSymbol5_ + externSymbol6_)/denominator) + thisSymbol)/2;
              }
            else
               if(denominator!=0)
                 {
                  ourValue=(externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_ + externSymbol5_ + externSymbol6_)/denominator;
                 }

           }
         else
            if(Correlations  == 5 && ArraySize(drawable)>=5)
              {
               thisValue1 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[0].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
               thisValue2 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[1].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
               thisValue3 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[2].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
               thisValue4 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[3].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
               thisValue5 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[4].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);

               if(drawable[0].getDirection()==1 && thisValue1!=EMPTY_VALUE)
                 {
                  externSymbol1_ =  thisValue1;
                  denominator++;
                  counterForSymbol1++;
                 }
               else
                  if(drawable[0].getDirection()==0 && thisValue1!=EMPTY_VALUE)
                    {
                     externSymbol1_ =  -1*thisValue1;
                     denominator++;
                     counterForSymbol1++;
                    }

               if(drawable[1].getDirection()==1 && thisValue2!=EMPTY_VALUE)
                 {
                  externSymbol2_ =  thisValue2;
                  denominator++;
                  counterForSymbol2++;
                 }
               else
                  if(drawable[1].getDirection()==0 && thisValue2!=EMPTY_VALUE)
                    {
                     externSymbol2_ =  -1*thisValue2;
                     denominator++;
                     counterForSymbol2++;
                    }

               if(drawable[2].getDirection()==1 && thisValue3!=EMPTY_VALUE)
                 {
                  externSymbol3_ = thisValue3;
                  denominator++;
                  counterForSymbol3++;
                 }
               else
                  if(drawable[2].getDirection()==0 && thisValue3!=EMPTY_VALUE)
                    {
                     externSymbol3_ =  -1*thisValue3;
                     denominator++;
                     counterForSymbol3++;
                    }

               if(drawable[3].getDirection()==1 && thisValue4!=EMPTY_VALUE)
                 {
                  externSymbol4_ =  thisValue4;
                  denominator++;
                  counterForSymbol4++;
                 }
               else
                  if(drawable[3].getDirection()==0 && thisValue4!=EMPTY_VALUE)
                    {
                     externSymbol4_ =  -1*thisValue4;
                     denominator++;
                     counterForSymbol4++;
                    }

               if(drawable[4].getDirection()==1 && thisValue5!=EMPTY_VALUE)
                 {
                  externSymbol5_ =  thisValue5;
                  denominator++;
                  counterForSymbol5++;
                 }
               else
                  if(drawable[4].getDirection()==0 && thisValue5!=EMPTY_VALUE)
                    {
                     externSymbol5_ =  -1*thisValue5;
                     denominator++;
                     counterForSymbol5++;
                    }

               if(Combine_to_this_symbol && thisSymbolOk && denominator!=0)
                 {
                  ourValue=(((externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_ + externSymbol5_)/5) + thisSymbol)/2;
                 }
               else
                  if(denominator!=0)
                    {
                     ourValue=(externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_ + externSymbol5_)/5;
                    }
              }
            else
               if(Correlations  == 4 && ArraySize(drawable)>=4)
                 {

                  thisValue1 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[0].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
                  thisValue2 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[1].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
                  thisValue3 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[2].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
                  thisValue4 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[3].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);

                  if(drawable[0].getDirection()==1 && thisValue1!=EMPTY_VALUE)
                    {
                     externSymbol1_ =  thisValue1;
                     denominator++;
                     counterForSymbol1++;
                    }
                  else
                     if(drawable[0].getDirection()==0 && thisValue1!=EMPTY_VALUE)
                       {
                        externSymbol1_ =  -1*thisValue1;
                        denominator++;
                        counterForSymbol1++;
                       }

                  if(drawable[1].getDirection()==1 && thisValue2!=EMPTY_VALUE)
                    {
                     externSymbol2_ =  thisValue2;
                     denominator++;
                     counterForSymbol2++;
                    }
                  else
                     if(drawable[1].getDirection()==0 && thisValue2!=EMPTY_VALUE)
                       {
                        externSymbol2_ =  -1*thisValue2;
                        denominator++;
                        counterForSymbol2++;
                       }

                  if(drawable[2].getDirection()==1 && thisValue3!=EMPTY_VALUE)
                    {
                     externSymbol3_ = thisValue3;
                     denominator++;
                     counterForSymbol3++;
                    }
                  else
                     if(drawable[2].getDirection()==0 && thisValue3!=EMPTY_VALUE)
                       {
                        externSymbol3_ =  -1*thisValue3;
                        denominator++;
                        counterForSymbol3++;
                       }

                  if(drawable[3].getDirection()==1 && thisValue4!=EMPTY_VALUE)
                    {
                     externSymbol4_ =  thisValue4;
                     denominator++;
                     counterForSymbol4++;
                    }
                  else
                     if(drawable[3].getDirection()==0 && thisValue4!=EMPTY_VALUE)
                       {
                        externSymbol4_ =  -1*thisValue4;
                        denominator++;
                        counterForSymbol4++;
                       }
                  if(Combine_to_this_symbol && thisSymbolOk && denominator!=0)
                    {
                     ourValue=(((externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_)/denominator) + thisSymbol)/2;
                    }
                  else
                     if(denominator!=0)
                       {
                        ourValue=(externSymbol1_ + externSymbol2_ + externSymbol3_ + externSymbol4_)/denominator;
                       }

                 }
               else
                  if(Correlations  == 3 && ArraySize(drawable)>=3)
                    {
                     thisValue1 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[0].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
                     thisValue2 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[1].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
                     thisValue3 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[2].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);

                     if(drawable[0].getDirection()==1 && thisValue1!=EMPTY_VALUE)
                       {
                        externSymbol1_ =  thisValue1;
                        denominator++;
                        counterForSymbol1++;
                       }
                     else
                        if(drawable[0].getDirection()==0 && thisValue1!=EMPTY_VALUE)
                          {
                           externSymbol1_ =  -1*thisValue1;
                           denominator++;
                           counterForSymbol1++;
                          }

                     if(drawable[1].getDirection()==1 && thisValue2!=EMPTY_VALUE)
                       {
                        externSymbol2_ =  thisValue2;
                        denominator++;
                        counterForSymbol2++;
                       }
                     else
                        if(drawable[1].getDirection()==0 && thisValue2!=EMPTY_VALUE)
                          {
                           externSymbol2_ =  -1*thisValue2;
                           denominator++;
                           counterForSymbol2++;
                          }

                     if(drawable[2].getDirection()==1 && thisValue3!=EMPTY_VALUE)
                       {
                        externSymbol3_ = thisValue3;
                        denominator++;
                        counterForSymbol3++;
                       }
                     else
                        if(drawable[2].getDirection()==0 && thisValue3!=EMPTY_VALUE)
                          {
                           externSymbol3_ =  -1*thisValue3;
                           denominator++;
                           counterForSymbol3++;
                          }

                     if(Combine_to_this_symbol && thisSymbolOk && denominator!=0)
                       {
                        ourValue=(((externSymbol1_ + externSymbol2_ + externSymbol3_)/denominator) + thisSymbol)/2;
                       }
                     else
                        if(denominator!=0)
                          {
                           ourValue=(externSymbol1_ + externSymbol2_ + externSymbol3_)/denominator;
                          }

                    }
                  else
                     if(Correlations  == 2 && ArraySize(drawable)>=2)
                       {
                        thisValue1 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[0].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);
                        thisValue2 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[1].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);

                        if(drawable[0].getDirection()==1 && thisValue1!=EMPTY_VALUE)
                          {
                           externSymbol1_ =  thisValue1;
                           denominator++;
                           counterForSymbol1++;
                          }
                        else
                           if(drawable[0].getDirection()==0 && thisValue1!=EMPTY_VALUE)
                             {
                              externSymbol1_ =  -1*thisValue1;
                              denominator++;
                              counterForSymbol1++;
                             }

                        if(drawable[1].getDirection()==1 && thisValue2!=EMPTY_VALUE)
                          {
                           externSymbol2_ =  thisValue2;
                           denominator++;
                           counterForSymbol2++;
                          }
                        else
                           if(drawable[1].getDirection()==0 && thisValue2!=EMPTY_VALUE)
                             {
                              externSymbol2_ =  -1*thisValue2;
                              denominator++;
                              counterForSymbol2++;
                             }

                        if(Combine_to_this_symbol && thisSymbolOk && denominator!=0)
                          {
                           ourValue=(((externSymbol1_ + externSymbol2_)/denominator) + thisSymbol)/2;
                          }
                        else
                           if(denominator!=0)
                             {
                              ourValue=(externSymbol1_ + externSymbol2_)/denominator;
                             }

                       }
                     else
                        if(Correlations  == 1 && ArraySize(drawable)>=1)
                          {
                           thisValue1 = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,drawable[0].getSymbol(),Compute_correlation,limitForComputingOfCorrelation,GetBarAmount,3,i);

                           if(drawable[0].getDirection()==1 && thisValue1!=EMPTY_VALUE)
                             {
                              externSymbol1_ =  thisValue1;
                              denominator++;
                              counterForSymbol1++;
                             }
                           else
                              if(drawable[0].getDirection()==0 && thisValue1!=EMPTY_VALUE)
                                {
                                 externSymbol1_ =  -1*thisValue1;
                                 denominator++;
                                 counterForSymbol1++;
                                }

                           if(Combine_to_this_symbol && thisSymbolOk && denominator!=0)
                             {
                              ourValue=(externSymbol1_ + thisSymbol)/2;
                             }
                           else
                              if(denominator!=0)
                                {
                                 ourValue=externSymbol1_;
                                }

                          }
   double result;
   if(Use_difference_to_best_correlations)
     {
      result = ourValue - thisSymbol;
     }
   else
     {
      result = ourValue;
      //Print("ourValue " + ourValue);
      //Print("thisSymbol  " + thisSymbol);
      //Print("index " + i);
     }
   if(i==0)
     {
      //Print("firstNewBar " + firstNewBar + " time: " + TimeToString(Time[i]));
      if(Visual_mode == Histogram)
        {
         if((result)>=0)
           {
            ExtMapBuffer4[i] = result;
            if(i<ArraySize(Time))
              {
               ExtMapBuffer1[i] = Time[i];
              }
           }
         else
           {
            ExtMapBuffer5[i] = result;
            if(i<ArraySize(Time))
              {
               ExtMapBuffer1[i] = Time[i];
              }
           }
        }
      else
        {
         if((result)>=0)
           {
            ExtMapBuffer7[i] = result;
            if(i<ArraySize(Time))
              {
               ExtMapBuffer1[i] = Time[i];
              }

           }
         else
           {
            ExtMapBuffer8[i] = result;
            if(i<ArraySize(Time))
              {
               ExtMapBuffer1[i] = Time[i];
              }

           }
        }
     }
   else
     {
      /*if(Symbol_source == MarketWatch)
        {
        */
      if(Visual_mode == Histogram)
        {

         if((result)>=0)
           {
            ExtMapBuffer2[i] = result;
            if(i<ArraySize(Time))
               ExtMapBuffer1[i] = Time[i];
           }
         else
           {
            ExtMapBuffer3[i] = result;
            if(i<ArraySize(Time))
               ExtMapBuffer1[i] = Time[i];
           }
        }
      else
        {

         ExtMapBuffer6[i] = result;
         if(i<ArraySize(Time))
           {
            ExtMapBuffer1[i] = Time[i];
           }

        }
     }

   if(firstNewBar && Visual_mode == Line)
     {

      ExtMapBuffer6[i] = result;

     }
   /*
   else
   {

    if(VisualMode == Histogram)
      {
       if((result)>=0)
         {
          ExtMapBuffer4[i] = result;
          if(i<ArraySize(Time))
             ExtMapBuffer1[i] = Time[i];
         }
       else
         {
          ExtMapBuffer5[i] = result;
          if(i<ArraySize(Time))
             ExtMapBuffer1[i] = Time[i];
         }
      }
    else
      {

       ExtMapBuffer7[i] = result;
       if(i<ArraySize(Time))
          ExtMapBuffer1[i] = Time[i];

      }

   }


   }

   */

//Print("Index, ExtMapBuffer7[index]: " + i + " " + ExtMapBuffer7[i]);
   /*
   if(i==0){
      if(Correlations==8){
         Print("counterForSymbol1 " + counterForSymbol1);
         Print("counterForSymbol2 " + counterForSymbol2);
         Print("counterForSymbol3 " + counterForSymbol3);
         Print("counterForSymbol4 " + counterForSymbol4);
         Print("counterForSymbol5 " + counterForSymbol5);
         Print("counterForSymbol6 " + counterForSymbol6);
         Print("counterForSymbol7 " + counterForSymbol7);
         Print("counterForSymbol8 " + counterForSymbol8);
      }

   }

   */

//if(denominator!=0 && i<= Limit_value_for_computing_of_correlation)Print("Index, denominator " + i + " " + denominator);

//ExtMapBuffer1[i] = ourValue;



   deleteOldObjects(drawable);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void removeDuplicatesAndSortByCorrelation()
  {

   if(Symbol_selection == Manual_input)
     {
      sortByCorrelation(manuallyAddedSymbolCorrelationObjects);
      removeDuplicates(manuallyAddedSymbolCorrelationObjects);
     }
   else
     {
      sortByCorrelation(allSymbolCorrelationObjects);
      removeDuplicates(allSymbolCorrelationObjects);
     }

  }

//+------------------------------------------------------------------+
//| Function to compute and write best correlations                  |
//+------------------------------------------------------------------+
void setBestSymbols()
  {


   deleteChartObjects();
   int correlationObjectsSize = ArraySize(allSymbolCorrelationObjects);
   bool basicConditionOk;
   if(Symbol_selection == Based_on_correlations)
     {
      basicConditionOk = ArraySize(allSymbolCorrelationObjects)>=Correlations;
     }
   else
     {
      basicConditionOk = true;
     }
   int manuallyAddedSymbols = ArraySize(manuallyAddedSymbolCorrelationObjects);
   if(Symbol_selection == Manual_input && Correlations > manuallyAddedSymbols)
     {
      tooBigValue = true;
      deleteChartObjects();
      string warning_part1 = "Warning: Out of symbols. Your parameter 'Correlations' is set";
      string warning_part2 =  "to " + Correlations + " and there are no manually added symbols enough.";
      string arr[];
      AddToArray2(arr,warning_part1);
      AddToArray2(arr,warning_part2);
      writeWarningOnChart(arr,Red);
      return;
     }
   if(Limit_for_computing_of_correlation == User_defined)
     {
      if(limitForComputingOfCorrelation > biggestNumberOfMatches)
        {
         tooBigValue = true;
         deleteChartObjects();
         string warning_part1 = "Warning: Out of bar limit. Your parameter";
         string warning_part2 = "'Limit_value_for_computing_of_correlation' should be less or";
         string warning_part3 =  "equal to " + biggestNumberOfMatches + " to get at least one correlation computed.";
         string warning_part4 = "";
         string warning_part5 = "In case 'Limit_for_computing_of_correlation' is set to";
         string warning_part6 = "'Automatic', parameter Limit_value_for_computing_of_correlation";
         string warning_part7 = "will be ignored and a bar amount of a symbol which has smallest";
         string warning_part8 = "amount of bars will be used instead. That value is shown on the";
         string warning_part9 = "info table.";
         string arr[];

         AddToArray2(arr,warning_part1);
         AddToArray2(arr,warning_part2);
         AddToArray2(arr,warning_part3);
         AddToArray2(arr,warning_part4);
         AddToArray2(arr,warning_part5);
         AddToArray2(arr,warning_part6);
         AddToArray2(arr,warning_part7);
         AddToArray2(arr,warning_part8);
         AddToArray2(arr,warning_part9);
         writeWarningOnChart(arr,Red);

        }
      else
         if(limitForComputingOfCorrelation <= biggestNumberOfMatches && !basicConditionOk)
           {
            tooBigValue = true;
            deleteChartObjects();
            sortByAmountOfBars(copyOf_allSymbolCorrelationObjects);
            int maxBars_ = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,Correlations);
            string warning_part1 = "Warning: Your parameter";
            string warning_part2 = "'Limit_value_for_computing_of_correlation' should be less or";
            string warning_part3 = "equal to " + maxBars_ + " in case parameter 'Correlation' is set to " + Correlations + " and";
            string warning_part4 = "parameter 'Limit_for_computing_of_correlation' is set to";
            string warning_part5 = "'User_defined'.";

            string warning_part6 = "";
            string warning_part7 = "Otherwise, if 'Limit_for_computing_of_correlation' is";
            string warning_part8 = "set to 'Automatic', maximum value for";
            string warning_part9 = "'Limit_value_for_computing_of_correlation' is: " + leastMatches ;
            string arr[];
            AddToArray2(arr,warning_part1);
            AddToArray2(arr,warning_part2);
            AddToArray2(arr,warning_part3);
            AddToArray2(arr,warning_part4);
            AddToArray2(arr,warning_part5);
            AddToArray2(arr,warning_part6);
            AddToArray2(arr,warning_part7);
            AddToArray2(arr,warning_part8);
            AddToArray2(arr,warning_part9);
            writeWarningOnChart(arr,Red);
           }
         else
           {
            tooBigValue = false;
            if(Show_info_table)
              {
               writeOnChart();
              }
           }
     }
   else
      if(Limit_for_computing_of_correlation == Automatic)
        {
         limitForComputingOfCorrelation=leastMatches;
         /*if(limitForComputingOfCorrelation>leastMatches)
           {
            tooBigValue = true;
            deleteChartObjects();
            //Alert("Your parameter 'LimitForComputingOfCorrelation' should be less or equal to " + leastMatches + " in case parameter 'Ignore_symbols_which_do_not_have_data_enough' is set to 'false'.");
            string warning_part1 = "Warning: Your parameter 'LimitForComputingOfCorrelation'";
            string warning_part2 = "should be less or equal to " + leastMatches +  " in case";
            string warning_part3 = "parameter 'Ignore_symbols_which_do_not_have_data_enough'";
            string warning_part4 = "is set to 'false'.";
            string arr[];
            AddToArray2(arr,warning_part1);
            AddToArray2(arr,warning_part2);
            AddToArray2(arr,warning_part3);
            AddToArray2(arr,warning_part4);
            writeWarningOnChart(arr);
           }
         else
           {
           */
         tooBigValue = false;
         if(Show_info_table)
           {
            writeOnChart();
           }


        }
      else
         if(basicConditionOk && Limit_for_computing_of_correlation == Automatic)
           {
            if(limitForComputingOfCorrelation <= biggestNumberOfMatches)
              {
               tooBigValue = false;
               //Print("Case1");
               if(Show_info_table)
                 {
                  writeOnChart();
                 }
              }
           }
         else
            if(basicConditionOk && Limit_for_computing_of_correlation == Automatic)
              {
               if(limitForComputingOfCorrelation<=leastMatches)
                 {
                  tooBigValue = false;
                  //Print("Case2");
                  if(Show_info_table)
                    {
                     writeOnChart();
                    }
                 }
              }
   /*
   bool limitIsSmallerThanLeastMatchesAndAnySymbolIsSupposedToBeIgnored = !Ignore_symbols_which_do_not_have_data_enough && limitForComputingOfCorrelation<=leastMatches;
   if(ArraySize(allSymbolCorrelationObjects)>0 && Show_info_table && (limitIsSmallerThanLeastMatchesAndAnySymbolIsSupposedToBeIgnored || symbolsWhichLacksDataAreIgnoredAndLimitIsSmallerThanBiggestNumberOfMatches)){
      writeOnChart();
   }else if(ArraySize(allSymbolCorrelationObjects)>0 && Show_info_table && limitIsSmallerThanLeastMatchesAndAnySymbolIsSupposedToBeIgnored == false){
       tooBigValue = true;
       Alert("Your parameter 'LimitForComputingOfCorrelation' should be less or equal to ");
   }
   */

  }

//+------------------------------------------------------------------+
//| Function to determine the length needed for colored background   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getLongestStringLength(string header)
  {
   int longest = 6;
   string maxBarsForAll = "Maximum limit to get all symbols involved for computing of correlation: ";
   int corrLen = StringLen(header);
   longest = corrLen;
   for(int i=0; i<Correlations; i++)
     {
      if(i<ArraySize(allSymbolCorrelationObjects))
        {
         int ourLength = StringLen(allSymbolCorrelationObjects[i].getSymbol());
         if(ourLength > longest)
           {
            longest = ourLength;
           }
        }
      else
        {
         //Print("Symbols " + ArraySize(allSymbolCorrelationObjects));
        }
     }
   return longest;
  }

//+-------------------------------------------------------------------------------------------------+
//| Function to set length of background based on number of g letters (a property of Webdings font) |
//+-------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getGees(int length)
  {
   string returnable = "";
   for(int i=0; i<length; i++)
     {
      returnable+="g";
     }
   return returnable;
  }
//+-------------------------------------------------------------------------------------------------+
//| Function to print warnings and the background for them                                          |
//+-------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void writeWarningOnChart(string &arr[], color backGroundColor)
  {
   ChartSetInteger(0,CHART_FOREGROUND,0,false);
   string gees = getGees(20);
   for(int i=1; i<ArraySize(arr)+1; i++)
     {
      string warning = arr[i-1];
      //Print("i-1 " + i + " warning: " + warning);
      CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,i*15,backGroundColor);
      writeTextOnChart(true, false, i, 8, i, false, White, warning);
      //writeWarningOnChart(arr[i-1],i);
     }

// Print("lengthOfLongest " + lengthOfLongest);

// Print("gees " + gees);



//Alert("Your parameter 'LimitForComputingOfCorrelation' should be less or equal to " + biggestNumberOfMatches + " in case parameter 'Ignore_symbols_which_do_not_have_data_enough' is set to 'true'.");



  }

//+-------------------------------------------------------------------------------------------------+
//| Function to round double type variables to a certain accuracy                                   |
//+-------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RoundNumber(double number, int digits)
  {
   number = MathRound(number * MathPow(10, digits));
   return (number * MathPow(10, -digits));
  }


//+-------------------------------------------------------------------------------------------------+
//| Function to print a content of a SymbolCorrelation type array                                   |
//+-------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void printSymbolCorrelationTypeArrayContent(SymbolCorrelation* &arr[])
  {
   Print("ArraySize(arr) " + ArraySize(arr));
   for(int i=0; i<ArraySize(arr); i++)
     {
      Print("Symbol: " + arr[i].getSymbol() + ", correlation: " + arr[i].getCorrelation() + ", amount of bars: " + arr[i].getAmountOfBars() + ", matching bars: " + arr[i].getMatchingTimes());
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void writeOnChart()
  {
//Alert("getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,8) 1 " + getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,8));
   string corrs;
   int adder;
   int adder2;
   string manualInput_;
   if(Symbol_selection == Manual_input)
     {
      manualInput_ = "Manual input";
     }
   else
     {
      manualInput_ = "Based on best correlations of symbols added to MarketWatch";
     }
   if(Show_all_on_info_table)
     {
      corrs  = "                              Best correlations, ID:" + tag_;
      adder  = -1;
      adder2 = 1;
     }
   else
     {
      corrs = "Best correlations, ID:" + tag_;
     }
   string maxBarsForGettingAllSymbolsInvolved1 = "Biggest number of bars to get all symbols available in";
//string maxBarsForGettingAllSymbolsInvolved2 = "to get all symbols";
   string maxBarsForGettingAllSymbolsInvolved2 = "MarketWatch involved in computing";
//string maxBarsForGettingAllSymbolsInvolved4 = "involved in computing";
   string maxBarsForGettingAnySymbolInvolved1 = "Biggest amount of bars for a certain amount of correlations";
   string maxBarsForGettingAnySymbolInvolved2 = "";
//string maxBarsForGettingAnySymbolInvolved2 = "correlation";
//string maxBarsForGettingAnySymbolInvolved3 = "correlation";
//string maxBarsForGettingAnySymbolInvolved3 = "of correlation";
   string symbolSelection = "Symbol selection in use";
   int coeff = 1;
   if(Show_all_on_info_table)
     {
      coeff = 2;
     }
   int lengthOfLongest = coeff*(getLongestStringLength("")+3);
//Alert(ArraySize(allSymbolCorrelationObjects));
   string gees = getGees(lengthOfLongest);
//Print("Hep!");
   ChartSetInteger(0,CHART_FOREGROUND,0,false);
   int positiveCounter;
   bool header    = false;
   bool isMaxBars = false;
   bool bold      = false;
   int limitForLoop;
   SymbolCorrelation* analyzables[];
   if(Symbol_selection == Based_on_correlations)
     {
      limitForLoop = Correlations;
      if(Show_info_table)
        {
         DeepCopyAnArray2(allSymbolCorrelationObjects,printables);
         DeepCopyAnArray2(copyOf_allSymbolCorrelationObjects,analyzables);
        }
     }
   else
     {
      limitForLoop = Correlations;
      if(Show_info_table)
        {
         DeepCopyAnArray2(manuallyAddedSymbolCorrelationObjects,printables);
         DeepCopyAnArray2(manuallyAddedSymbolCorrelationObjects,analyzables);
        }
     }
//Alert("getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,8) 2 " + getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,8));
   /*if(ArraySize(allSymbolCorrelationObjects)<Correlations || !Ignore_symbols_which_do_not_have_data_enough && limitForComputingOfCorrelation>leastMatches){
      Alert("Something went wrong. Did you set a bigger value for 'Limit_value_for_computing_of_correlation' parameter than available bars? Please try some smaller value.");
      return;
   }
   */
//printSymbolCorrelationTypeArrayContent(manuallyAddedSymbolCorrelationObjects);
   string symbol_for_one;

   if(Symbol_selection == Based_on_correlations && Show_all_on_info_table && ArraySize(copyOf_allSymbolCorrelationObjects)>7)
     {
      sortByAmountOfBars(copyOf_allSymbolCorrelationObjects);
      barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,1);
      symbol_for_one       = copyOf_allSymbolCorrelationObjects[0].getSymbol();
      barMaximum_for_two   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,2);
      barMaximum_for_three = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,3);
      barMaximum_for_four  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,4);
      barMaximum_for_five  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,5);
      barMaximum_for_six   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,6);
      barMaximum_for_seven = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,7);
      barMaximum_for_eight = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,8);
      //Alert("getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,8) 3 " + getBiggestAmountsOfBarsForCertainAmountOfCorrelations(copyOf_allSymbolCorrelationObjects,8));
     }
   else
      if(Symbol_selection == Manual_input && Show_all_on_info_table)
        {
         if(ArraySize(analyzables)==1)
           {
            barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,1);
            symbol_for_one       = analyzables[0].getSymbol();
           }
         else
            if(ArraySize(analyzables)==2)
              {
               sortByAmountOfBars(analyzables);
               symbol_for_one       = analyzables[0].getSymbol();
               barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,1);
               barMaximum_for_two   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,2);
              }
            else
               if(ArraySize(analyzables)==3)
                 {
                  sortByAmountOfBars(analyzables);
                  symbol_for_one       = analyzables[0].getSymbol();
                  barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,1);
                  barMaximum_for_two   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,2);
                  barMaximum_for_three = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,3);
                 }
               else
                  if(ArraySize(analyzables)==4)
                    {
                     sortByAmountOfBars(analyzables);
                     symbol_for_one       = analyzables[0].getSymbol();
                     barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,1);
                     barMaximum_for_two   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,2);
                     barMaximum_for_three = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,3);
                     barMaximum_for_four  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,4);
                    }
                  else
                     if(ArraySize(analyzables)==5)
                       {
                        sortByAmountOfBars(analyzables);
                        symbol_for_one       = analyzables[0].getSymbol();
                        barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,1);
                        barMaximum_for_two   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,2);
                        barMaximum_for_three = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,3);
                        barMaximum_for_four  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,4);
                        barMaximum_for_five  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,5);
                       }
                     else
                        if(ArraySize(analyzables)==6)
                          {
                           sortByAmountOfBars(analyzables);
                           symbol_for_one       = analyzables[0].getSymbol();
                           barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,1);
                           barMaximum_for_two   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,2);
                           barMaximum_for_three = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,3);
                           barMaximum_for_four  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,4);
                           barMaximum_for_five  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,5);
                           barMaximum_for_six   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,6);
                          }
                        else
                           if(ArraySize(analyzables)==7)
                             {
                              sortByAmountOfBars(analyzables);
                              symbol_for_one       = analyzables[0].getSymbol();
                              barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,1);
                              barMaximum_for_two   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,2);
                              barMaximum_for_three = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,3);
                              barMaximum_for_four  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,4);
                              barMaximum_for_five  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,5);
                              barMaximum_for_six   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,6);
                              barMaximum_for_seven = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,7);
                             }
                           else
                              if(ArraySize(analyzables)==8)
                                {
                                 sortByAmountOfBars(analyzables);
                                 symbol_for_one       = analyzables[0].getSymbol();
                                 barMaximum_for_one   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,1);
                                 barMaximum_for_two   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,2);
                                 barMaximum_for_three = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,3);
                                 barMaximum_for_four  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,4);
                                 barMaximum_for_five  = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,5);
                                 barMaximum_for_six   = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,6);
                                 barMaximum_for_seven = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,7);
                                 barMaximum_for_eight = getBiggestAmountsOfBarsForCertainAmountOfCorrelations(analyzables,8);
                                }
        }
   for(int i=-2; i<limitForLoop+19; i++)
     {

      positiveCounter = i+2;
      bold = false;

      if(i<(limitForLoop + 19))
        {
         //CreateBackground("BgroundGG" + i,gees,15,0,15,(i+1)*15);
         int isPositiveCorr;
         string ourString;
         int fontSize;
         if(i>(-1+adder) && i<limitForLoop+adder2)
           {
            CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
            if(i<limitForLoop-adder2)
              {
               header = false;
               fontSize = 7;
               string ourSymbol;
               double ourCorr;
               if(Show_all_on_info_table)
                 {
                  if((i+1)<ArraySize(printables))
                    {
                     ourSymbol = printables[i+1].getSymbol();
                     ourCorr = RoundNumber(printables[i+1].getCorrelation(),2);
                     isPositiveCorr = printables[i+1].getDirection();
                    }

                 }
               else
                  if(!Show_all_on_info_table)
                    {
                     if(i<ArraySize(printables))
                       {
                        ourSymbol = printables[i].getSymbol();
                        ourCorr = RoundNumber(printables[i].getCorrelation(),2);
                        isPositiveCorr = printables[i].getDirection();
                       }

                     if(i+adder==0)
                       {
                        //Alert("Hep");
                        int extension =  i-1;
                        CreateBackground(tagForGraphicals + "BgroundGG" + extension,gees,15,0,15,(positiveCounter+1-1)*15,LightBlue);
                       }
                    }

               //Print("ourSymbol, i, correlation" + ourSymbol + " " + i + " " + allSymbolCorrelationObjects[i].getCorrelation());

               //double ourCorr = RoundNumber(allSymbolCorrelationObjects[i+1].getCorrelation(),2);
               string ourValue = "" + ourCorr;

               string first = ShortToString(StringGetCharacter(ourValue,0));
               string second = ShortToString(StringGetCharacter(ourValue,1));
               string third = ShortToString(StringGetCharacter(ourValue,2));

               string fourth = ShortToString(StringGetCharacter(ourValue,3));
               string fifth = ShortToString(StringGetCharacter(ourValue,4));
               //ourValue = StringConcatenate(first,second,third,fourth,fifth);
               if(fifth!="0")
                 {
                  ourValue = first + second + third + fourth + fifth;
                 }
               else
                 {
                  ourValue = first + second + third + fourth;
                 }
               //ourValue = "";
               /*
               if(StringLen(ourValue)>3){
                  fifth = ShortToString(StringGetCharacter(ourValue,4));
                  //ourValue = StringConcatenate(first,second,third,fourth,fifth);
                   Print("ourValue, symbol " + ourValue + " " + ourSymbol);
               }else{
                  ourValue = StringConcatenate(first,second,third,fourth);
                   Print("ourValue2, symbol " + ourValue + " " + ourSymbol);
               }

               */






               ourValue = StringTrimLeft(ourValue);
               ourValue = StringTrimRight(ourValue);
               ourValue = DoubleToStr(StrToDouble(ourValue));
               ourValue = StringSubstr(ourValue,0,5);
               fifth = ShortToString(StringGetCharacter(ourValue,4));
               if(fifth=="0")
                 {
                  ourValue = StringSubstr(ourValue,0,4);
                 }
               int isMinus = StringFind(ourValue,"-",0);
               int len = StringLen(ourValue);
               //Print("len, sym " + len + " " + ourSymbol + " ourCorr " + ourCorr);
               if((len == 3 && isMinus == -1) || (len == 4 && isMinus != (-1)))
                 {
                  ourValue+="0";
                  //Alert("");
                 }
               if(ourCorr > 0)
                 {
                  ourString ="   " +  ourValue +  " " + ourSymbol;
                 }
               else
                 {
                  ourString = " " + ourValue + " " + ourSymbol;
                 }
              }
           }
         else
            if(i==(-2))
              {
               //Print("i==(-2)");
               header = true;
               fontSize = 9;
               CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
               isPositiveCorr = 1;
               ourString = corrs;
              }
            else
               if(i==Correlations || (Show_all_on_info_table && i==Correlations+4) || (Show_all_on_info_table && i==Correlations+2)  || (Show_all_on_info_table && i==Correlations+3) || (Show_all_on_info_table && i==Correlations+9) || (Show_all_on_info_table && i==Correlations+10) || (Show_all_on_info_table && i==Correlations+5) || (Show_all_on_info_table && i==Correlations+6) || (Show_all_on_info_table && i==Correlations+7) || (Show_all_on_info_table && i==Correlations+8))
                 {
                  //Print("space");
                  header = false;
                  fontSize = 7;
                  CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                  isPositiveCorr = 1;
                  ourString = "";
                 }
         if(Show_all_on_info_table)
           {
            if(i==Correlations)
              {
               //Print("maxBarsForGettingAllSymbolsInvolved1");
               header = true;
               fontSize = 8;
               CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
               isPositiveCorr = 1;
               ourString = maxBarsForGettingAllSymbolsInvolved1;
              }
            else
               if(i==Correlations+1)
                 {
                  //Print("maxBarsForGettingAllSymbolsInvolved2");
                  header = true;
                  fontSize = 8;
                  CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                  isPositiveCorr = 1;
                  ourString = maxBarsForGettingAllSymbolsInvolved2;
                 }
               /*else
                  if(i==Correlations+3)
                    {
                     //Print("maxBarsForGettingAllSymbolsInvolved3");
                     header = true;
                     fontSize = 8;
                     CreateBackground(tag + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                     isPositiveCorr = 1;
                     //ourString = maxBarsForGettingAllSymbolsInvolved3;
                    }
               else
                  if(i==Correlations+4)
                    {
                     //Print("maxBarsForGettingAllSymbolsInvolved4");
                     header = true;
                     fontSize = 8;
                     CreateBackground(tag + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                     isPositiveCorr = 1;
                     //ourString = maxBarsForGettingAllSymbolsInvolved4;
                    }
                                                                                                                              */else
                  if(i==Correlations+3)
                    {
                     //Print("leastMatches number");
                     header = false;
                     fontSize = 7;
                     CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                     isPositiveCorr = 1;
                     if(leastMatches!=0)
                       {
                        ourString = "  " + leastMatches + " (based on the smallest amount of bars of the source)";

                       }
                     else
                       {
                        ourString = "  " + leastMatches + " (some of symbols are ignored)";
                       }
                     isMaxBars = true;
                    }
                  else
                     if(i==Correlations+5)
                       {
                        //Print("maxBarsForGettingAnySymbolInvolved1");
                        header = true;
                        fontSize = 8;
                        //CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                        isPositiveCorr = 1;
                        ourString =symbolSelection;
                        isMaxBars = false;
                       }

                     else
                        if(i==Correlations+7)
                          {
                           //Print("maxBarsForGettingAnySymbolInvolved1");
                           header = false;
                           fontSize = 7;
                           //CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                           isPositiveCorr = 1;
                           ourString =manualInput_;
                           isMaxBars = true;
                          }
                        else
                           if(i==Correlations+9)
                             {
                              //Print("maxBarsForGettingAnySymbolInvolved1");
                              header = true;
                              fontSize = 8;
                              CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                              isPositiveCorr = 1;
                              ourString =maxBarsForGettingAnySymbolInvolved1;
                              isMaxBars = false;
                             }
                           else
                              if(i==Correlations+10)
                                {
                                 //Print("maxBarsForGettingAnySymbolInvolved1");
                                 header = true;
                                 fontSize = 8;
                                 CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                 isPositiveCorr = 1;
                                 ourString =maxBarsForGettingAnySymbolInvolved2;
                                 isMaxBars = false;
                                }
                              else
                                 if(i==Correlations+11)
                                   {
                                    //Print("maxBarsForGettingAnySymbolInvolved2");
                                    header = true;
                                    fontSize = 8;
                                    CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                    isPositiveCorr = 1;
                                    ourString ="Correlations                Bars maximum";
                                    isMaxBars = false;
                                    bold = true;
                                   }
                                 /*else
                                    if(i==Correlations+7)
                                      {
                                       //Print("maxBarsForGettingAnySymbolInvolved3");
                                       header = true;
                                       fontSize = 8;
                                       CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                       isPositiveCorr = 1;
                                       //ourString =maxBarsForGettingAnySymbolInvolved3;
                                       isMaxBars = false;
                                      }*/
                                 else
                                    if(i==Correlations+12)
                                      {
                                       //Print("maxBarsForGettingAnySymbolInvolved3");
                                       header = false;
                                       fontSize = 7;
                                       CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                       isPositiveCorr = 1;
                                       //ourString ="        1                               " + barMaximum_for_one + " (" + symbol_for_one + ")";
                                       if(barMaximum_for_one!=0)
                                         {
                                          ourString ="        1                               " + barMaximum_for_one;
                                         }
                                       else
                                          if(barMaximum_for_one==0 && Symbol_selection == Manual_input)
                                            {
                                             ourString ="        1                               " + barMaximum_for_one + " (no symbols enough)";
                                            }
                                       isMaxBars = true;
                                      }
                                    else
                                       if(i==Correlations+13)
                                         {
                                          //Print("maxBarsForGettingAnySymbolInvolved3");
                                          header = false;
                                          fontSize = 7;
                                          CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                          isPositiveCorr = 1;
                                          if(barMaximum_for_two!=0)
                                            {
                                             ourString ="        2                               " + barMaximum_for_two;
                                            }
                                          else
                                             if(barMaximum_for_two==0 && Symbol_selection == Manual_input)
                                               {
                                                ourString ="        2                               " + barMaximum_for_two + " (no symbols enough)";
                                               }
                                          isMaxBars = true;
                                         }
                                       else
                                          if(i==Correlations+14)
                                            {
                                             //Print("maxBarsForGettingAnySymbolInvolved3");
                                             header = false;
                                             fontSize = 7;
                                             CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                             isPositiveCorr = 1;

                                             if(barMaximum_for_three!=0)
                                               {
                                                ourString ="        3                               " + barMaximum_for_three;
                                               }
                                             else
                                                if(barMaximum_for_three==0 && Symbol_selection == Manual_input)
                                                  {
                                                   ourString ="        3                               " + barMaximum_for_three + " (no symbols enough)";
                                                  }
                                             isMaxBars = true;
                                            }
                                          else
                                             if(i==Correlations+15)
                                               {
                                                //Print("maxBarsForGettingAnySymbolInvolved3");
                                                header = false;
                                                fontSize = 7;
                                                CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                                isPositiveCorr = 1;

                                                if(barMaximum_for_four!=0)
                                                  {
                                                   ourString ="        4                               " + barMaximum_for_four;
                                                  }
                                                else
                                                   if(barMaximum_for_four==0 && Symbol_selection == Manual_input)
                                                     {
                                                      ourString ="        4                               " + barMaximum_for_four + " (no symbols enough)";
                                                     }
                                                isMaxBars = true;
                                               }
                                             else
                                                if(i==Correlations+16)
                                                  {
                                                   //Print("maxBarsForGettingAnySymbolInvolved3");
                                                   header = false;
                                                   fontSize = 7;
                                                   CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                                   isPositiveCorr = 1;

                                                   if(barMaximum_for_five!=0)
                                                     {
                                                      ourString ="        5                               " + barMaximum_for_five;
                                                     }
                                                   else
                                                      if(barMaximum_for_five==0 && Symbol_selection == Manual_input)
                                                        {
                                                         ourString ="        5                               " + barMaximum_for_five + " (no symbols enough)";
                                                        }
                                                   isMaxBars = true;
                                                  }
                                                else
                                                   if(i==Correlations+17)
                                                     {
                                                      //Print("maxBarsForGettingAnySymbolInvolved3");
                                                      header = false;
                                                      fontSize = 7;
                                                      CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                                      isPositiveCorr = 1;
                                                      ourString ="        6                               " + barMaximum_for_six;
                                                      if(barMaximum_for_six!=0)
                                                        {
                                                         ourString ="        6                               " + barMaximum_for_six;
                                                        }
                                                      else
                                                         if(barMaximum_for_six==0 && Symbol_selection == Manual_input)
                                                           {
                                                            ourString ="        6                               " + barMaximum_for_six + " (no symbols enough)";
                                                           }
                                                      isMaxBars = true;
                                                     }
                                                   else
                                                      if(i==Correlations+18)
                                                        {
                                                         //Print("maxBarsForGettingAnySymbolInvolved3");
                                                         header = false;
                                                         fontSize = 7;
                                                         CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                                         isPositiveCorr = 1;

                                                         if(barMaximum_for_seven!=0)
                                                           {
                                                            ourString ="        7                               " + barMaximum_for_seven;
                                                           }
                                                         else
                                                            if(barMaximum_for_seven==0 && Symbol_selection == Manual_input)
                                                              {
                                                               ourString ="        7                               " + barMaximum_for_seven + " (no symbols enough)";
                                                              }
                                                         isMaxBars = true;
                                                        }
                                                      else
                                                         if(i==Correlations+19)
                                                           {
                                                            //Print("maxBarsForGettingAnySymbolInvolved3");
                                                            header = false;
                                                            fontSize = 7;
                                                            CreateBackground(tagForGraphicals + "BgroundGG" + i,gees,15,0,15,(positiveCounter+1)*15,LightBlue);
                                                            isPositiveCorr = 1;

                                                            if(barMaximum_for_eight!=0)
                                                              {
                                                               ourString ="        8                               " + barMaximum_for_eight;
                                                              }
                                                            else
                                                               if(barMaximum_for_eight==0 && Symbol_selection == Manual_input)
                                                                 {
                                                                  ourString ="        8                               " + barMaximum_for_eight + " (no symbols enough)";
                                                                 }
                                                            isMaxBars = true;
                                                           }
           }

         if(i==Correlations+13)
           {
            //break;
           }

         color colour;
         if(isPositiveCorr && !header)
           {
            if(!isMaxBars)
              {
               colour = Green;
              }
            else
              {
               colour = Black;
              }
           }
         else
            if(isPositiveCorr && header)
              {
               colour = DarkBlue;
              }
            else
               if(!isPositiveCorr && !header)
                 {
                  colour = Red;
                 }

         writeTextOnChart(false,bold, i, fontSize, positiveCounter, isPositiveCorr, colour, ourString);

        }
     }
   if(Show_all_on_info_table)
     {
      deleteOldObjects(copyOf_allSymbolCorrelationObjects);
     }
   if(Show_info_table)
     {
      deleteOldObjects(printables);
      deleteOldObjects(analyzables);
     }
  }

//+-------------------------------------------------------------------------------------------------+
//| Function to write text on chart                                                                 |
//+-------------------------------------------------------------------------------------------------+
void writeTextOnChart(bool isWarning, bool isBold, int i, int fontSize, int positiveCounter, bool isPositiveCorr, color colour, string ourString)
  {
   string name = tagForGraphicals + i;
   if(!isWarning)
     {
      if(!isBold)
        {

         if(ObjectCreate(name, OBJ_LABEL, 0, 0, 0))
           {
            AddToArray2(namesOfGraphicalsOfThisInstance,name);
           }
         if(isPositiveCorr)
           {
            ObjectSetText(tagForGraphicals + i,ourString,fontSize, "Verdana", colour);
           }
         else
           {
            ObjectSetText(tagForGraphicals + i,ourString,fontSize, "Verdana", colour);
           }
         ObjectSet(tagForGraphicals + i, OBJPROP_CORNER, 0);
         ObjectSet(tagForGraphicals + i, OBJPROP_XDISTANCE, 20);
         if(i==(-2))
           {
            ObjectSet(tagForGraphicals + i, OBJPROP_YDISTANCE, 20);
           }
         else
           {
            if(i>(-2))
              {
               ObjectSet(tagForGraphicals + i, OBJPROP_YDISTANCE, 5 + (positiveCounter+1)*15);
              }
           }
        }
      else
        {
         if(ObjectCreate(name, OBJ_LABEL, 0, 0, 0))
           {
            AddToArray2(namesOfGraphicalsOfThisInstance,name);
           }
         if(isPositiveCorr)
           {
            ObjectSetText(tagForGraphicals + i,ourString,fontSize, "Verdana Bold", colour);
           }
         else
           {
            ObjectSetText(tagForGraphicals + i,ourString,fontSize, "Verdana Bold", colour);
           }
         ObjectSet(tagForGraphicals + i, OBJPROP_CORNER, 0);
         ObjectSet(tagForGraphicals + i, OBJPROP_XDISTANCE, 20);
         if(i==(-2))
           {
            ObjectSet(tagForGraphicals + i, OBJPROP_YDISTANCE, 20);
           }
         else
           {
            if(i>(-2))
              {
               ObjectSet(tagForGraphicals + i, OBJPROP_YDISTANCE, 5 + (positiveCounter+1)*15);
              }
           }

        }
     }
   else
     {
      if(!isBold)
        {
         //Print("isBold1 " + isBold);
         if(ObjectCreate(name, OBJ_LABEL, 0, 0, 0))
           {
            AddToArray2(namesOfGraphicalsOfThisInstance,name);
           }
         //if(isPositiveCorr){
         ObjectSetInteger(0,tagForGraphicals + i,OBJPROP_BACK,false);
         ObjectSetText(tagForGraphicals + i,ourString,fontSize, "Verdana", colour);
         //}else{
         //   ObjectSetText("ObjNameName" + i,ourString,fontSize, "Verdana", colour);
         //}
         ObjectSet(tagForGraphicals + i, OBJPROP_CORNER, 0);
         ObjectSet(tagForGraphicals + i, OBJPROP_XDISTANCE, 20);
         if(i==0)
           {
            ObjectSet(tagForGraphicals + i, OBJPROP_YDISTANCE, 20);
           }
         else
           {
            if(i>0)
              {
               ObjectSet(tagForGraphicals + i, OBJPROP_YDISTANCE, 5 + positiveCounter*15);
              }
           }
        }
      else
        {
         //Print("isBold2 " + isBold);
         if(ObjectCreate(name, OBJ_LABEL, 0, 0, 0))
           {
            AddToArray2(namesOfGraphicalsOfThisInstance,name);
           }
         //if(isPositiveCorr){
         ObjectSetInteger(0,tagForGraphicals + i,OBJPROP_BACK,false);
         ObjectSetText(tagForGraphicals + i,ourString,fontSize, "Verdana Bold", colour);
         //}else{
         //   ObjectSetText("ObjNameName" + i,ourString,fontSize, "Verdana", colour);
         //}
         ObjectSet(tagForGraphicals + i, OBJPROP_CORNER, 0);
         ObjectSet(tagForGraphicals + i, OBJPROP_XDISTANCE, 20);
         if(i==0)
           {
            ObjectSet(tagForGraphicals + i, OBJPROP_YDISTANCE, 20);
           }
         else
           {
            if(i>0)
              {
               ObjectSet(tagForGraphicals + i, OBJPROP_YDISTANCE, 5 + positiveCounter*15);
              }
           }
        }

     }


  }

//+-------------------------------------------------------------------------------------------------+
//| Function to determine maximum bar count based on smallest amount of bars found among symbols    |
//+-------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getMaximumBarAmount()
  {

   int total=SymbolsTotal(true)-1;
   int smallestBarAmount = 1000000000;
   for(int i=total-1; i>=0; i--)
     {
      string Sembol=SymbolName(i,true);
      if(Sembol != Symbol())
        {
         int barsInHistory = iCustom(NULL,0,"::Extra_Symbol_product_version_new.ex4",SMA_period1, SMA_period2, false,Sembol,false,limitForComputingOfCorrelation,true,5,i);
         if(barsInHistory < smallestBarAmount)
           {
            smallestBarAmount = barsInHistory;
           }
        }
      else
        {
         continue;
        }
     }

   return smallestBarAmount;

  }

//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
/*
bool checkIfAssettAvailable(string symbol){

   int      bar   =  iBarShift(symbol, Period(), TimeCurrent()-Period(), true);
   int      error =  GetLastError();
   //PrintFormat("Time=%s, bar=%i, bar time=%s, error=%i", TimeToStr(TimeCurrent()), bar, TimeToStr(iTime(SYMBOL, 0, bar)), error);
   if(error != 0 && bar == -1){
      Alert("Error occured. Please wait.");
      ResetLastError();
      for (int j = 0; j < 20 && error!=0; j++) {
          Sleep(1000);
          RefreshRates();
          bar   =  iBarShift(symbol, Period(), TimeCurrent()-Period(), true);
          error =  GetLastError();
          if(bar == -1){
             Alert("The information requested by this indicator is being loaded.");
          }
      }

   }
   if(bar == -1){
        // Alert( symbol + " could not be loaded.");
         return false;
      }


}

//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
   void refreshAssetts(){
      int total=SymbolsTotal(true)-1;
      for(int i=total-1;i>=0;i--){
         checkIfAssettAvailable(SymbolName(i,true));
      }

   }

*/
//+-------------------------------------------------------------------------------------------------+
//| Function to compute all correlations                                                            |
//+-------------------------------------------------------------------------------------------------+

/*
void calcAndSetCorrelations(){


    int total=SymbolsTotal(true)-1;

    int counterForCorrelationAmount = 0;
    string Sembol;

    for(int i=total-1;i>=0;i--){
        if(Sembol != Symbol()){
            Sembol=SymbolName(i,true);
       }else{
         continue;
       }
       double corr1;
       int s;
       if(Sembol != Symbol()){
         s = getBestShiftOfCorrelation(Sembol,1);
         double c = getCorrelationByShift(1,Sembol,s);
         corr1 = c;
         //Alert("corr: " + corr1);
         int dir;
         if(corr1 > 0){
            dir=1;
         }else{
            dir=0;
         }
       }

    SymbolCorrelation *symbolObj = new SymbolCorrelation(Sembol,corr1,dir,i,s);
    AddToArray2(allSymbolCorrelationObjects, symbolObj);
    counterForCorrelationAmount++;

         //Alert("Sembol dir " + Sembol + " " + dir);
         //addToArray3(allCorrelations,Sembol,corr1,dir,i);
    }


}
*/
//+-------------------------------------------------------------------------------------------------+
//| Function to compute a correlation of a certain symbol                                           |
//+-------------------------------------------------------------------------------------------------+

/*

int getBestShiftOfCorrelation(string assett,int i_){


    int bestShift = 0;
    double bestCorr = -1.1;

    for(int i=0;i<(maxShiftForCorrelation+i_); i++){

         double corr = MathAbs(getCorrelationByShift(i_,assett,i));
            if(corr > bestCorr){
               bestCorr = corr;
               bestShift = i;
            }

    }


   return bestShift;
}

*/

//+-------------------------------------------------------------------------------------------------+
//| Function to compute a correlation of a certain symbol by shift                                  |
//+-------------------------------------------------------------------------------------------------+
/*
double getCorrelationByShift(int i_, string assett, int shift_){

   double sum = 0;
   double arr1[];
   double arr2[];

   double resultArr[];
   double corr;
   int maxAmountOfBars = maxBars;
   if(limitForComputingOfCorrelation > maxAmountOfBars){
      limitForComputingOfCorrelation = maxAmountOfBars;
      Alert("Maximum amount of bars is " + maxAmountOfBars + ". You can use it as a parameter to prevent alerts appearing any more.");
   }

   if(assett != ""){
      for(int i=i_; i<(limitForComputingOfCorrelation+i_); i++)
        {


            double btc = iOpen(NULL,0,i_+i+1);
            double comparable = iOpen(assett,0,i_+i+1+shift_);

            AddToArray2(arr2,comparable);
            AddToArray2(arr1,btc);


        }
     }

         corr = correlation_coefficient(arr2, arr1, limitForComputingOfCorrelation);





         return corr;

}


*/
//+-------------------------------------------------------------------------------------------------+
//| Function to remove duplicates from all symbols                                                  |
//+-------------------------------------------------------------------------------------------------+
void removeDuplicates(SymbolCorrelation* &arr[])
  {
//Print("ArraySize(allSymbolCorrelationObjects) before " + ArraySize(allSymbolCorrelationObjects));
   for(int h=0; h<ArraySize(arr); h++)
     {
      for(int i=0; i<ArraySize(arr); i++)
        {
         if(h!=i && arr[h].getSymbol() == arr[i].getSymbol())
           {
            EraseOrdered(arr,i);
           }

        }


     }
//Print("ArraySize(allSymbolCorrelationObjects) after " + ArraySize(allSymbolCorrelationObjects));

  }
//+-------------------------------------------------------------------------------------------------+
//| Function to get 8 biggest amounts of bars if available                                          |
//+-------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getBiggestAmountsOfBarsForCertainAmountOfCorrelations(SymbolCorrelation* &arr[], int amountOfCorrelations)
  {
   int alreadyChosenAmounts[];
   int biggestAmountsOfBars[];
   int i;
   int bars;
   int counterForAssetts;
//Print("ArraySize(arr) " + ArraySize(arr));
   while(counterForAssetts<amountOfCorrelations && i<ArraySize(arr))
     {
      bars = arr[i].getMatchingTimes();
      if(!arrayIncludes(alreadyChosenAmounts,bars))
        {
         AddToArray2(biggestAmountsOfBars,bars);
         AddToArray2(alreadyChosenAmounts,bars);
         //Print("Includes");
         counterForAssetts++;
        }
      else
        {
         counterForAssetts++;
         //Print("Does not include");
        }
      i++;
     }
   return bars;
  }

//+-------------------------------------------------------------------------------------------------+
//| Function to sort correlations by their amount of bars                                           |
//+-------------------------------------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sortByAmountOfBars(SymbolCorrelation* &arr[])
  {

   SymbolCorrelation *arrNew[];         // new array for manipulation - don't touch the original
   DeepCopyAnArray2(arr,arrNew);        // make deep copy of the original

   int i=ArraySize(arrNew);          // set iteration counts for while loop
   SymbolCorrelation *arrNew2[];  // new array for sorting
   int avoidables[];
   while(i>0)
     {
      int indexOfBiggestGap = findBiggestAmountOfBars(arrNew, avoidables);
      if(CheckPointer(arrNew[indexOfBiggestGap])!=POINTER_INVALID)
        {
         SymbolCorrelation *newObj = new SymbolCorrelation(arrNew[indexOfBiggestGap]); // make deep copy of the founded object
         AddToArray2(arrNew2,newObj);
         delete arrNew[indexOfBiggestGap];
         EraseOrdered(arrNew, indexOfBiggestGap);   // remove the founded object from the array to seek 2nd, 3rd, 4th... biggest gap
         i = ArraySize(arrNew);                     // reduce the iterations until the array is empty
         //Print("sortByAmountOfBars: This index ok " + indexOfBiggestGap);
        }
      else
        {
         //delete arrNew[indexOfBiggestGap];
         //EraseOrdered2(arrNew, indexOfBiggestGap);
         //Print("sortByAmountOfBars: Error " + indexOfBiggestGap);
         AddToArray2(avoidables,indexOfBiggestGap);
         i--;
        }
     }

   for(i=0; i<ArraySize(arr); i++)
     {
      delete arr[i];
      //ArrayResize(A, ArraySize(A)-1);
     }
//DeleteObjectsFromAnArray(arr);
   ArrayResize(arr,0);
   DeepCopyAnArray2(arrNew2, arr);
   for(i=0; i<ArraySize(arrNew); i++)
     {
      delete arrNew[i];
      //ArrayResize(A, ArraySize(A)-1);
     }
//DeleteObjectsFromAnArray(arrNew);
   ArrayResize(arrNew,0);
   for(i=0; i<ArraySize(arrNew2); i++)
     {
      delete arrNew2[i];
      //ArrayResize(A, ArraySize(A)-1);
     }
//DeleteObjectsFromAnArray(arrNew2);
   ArrayResize(arrNew2,0);





  }


//+-------------------------------------------------------------------------------------------------+
//| Function to sort correlations                                                                   |
//+-------------------------------------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sortByCorrelation(SymbolCorrelation* &arr[])
  {

   SymbolCorrelation *arrNew[];         // new array for manipulation - don't touch the original
   DeepCopyAnArray2(arr,arrNew);        // make deep copy of the original

   int i=ArraySize(arrNew);          // set iteration counts for while loop
   SymbolCorrelation *arrNew2[];  // new array for sorting
   int avoidables[];
   while(i>0)
     {
      int indexOfBiggestGap = findBiggestCorrelation(arrNew, avoidables);
      if(CheckPointer(arrNew[indexOfBiggestGap])!=POINTER_INVALID && arrNew[indexOfBiggestGap].getActivityValue()==1)
        {
         SymbolCorrelation *newObj = new SymbolCorrelation(arrNew[indexOfBiggestGap]); // make deep copy of the founded object
         AddToArray2(arrNew2,newObj);
         delete arrNew[indexOfBiggestGap];
         EraseOrdered(arrNew, indexOfBiggestGap);   // remove the founded object from the array to seek 2nd, 3rd, 4th... biggest gap
         i = ArraySize(arrNew);                     // reduce the iterations until the array is empty
         //Print("This index ok " + indexOfBiggestGap);
        }
      else
        {
         //delete arrNew[indexOfBiggestGap];
         //EraseOrdered2(arrNew, indexOfBiggestGap);
         //Print("Error " + indexOfBiggestGap);
         AddToArray2(avoidables,indexOfBiggestGap);
         i--;
        }
     }

   for(i=0; i<ArraySize(arr); i++)
     {
      delete arr[i];
      //ArrayResize(A, ArraySize(A)-1);
     }
//DeleteObjectsFromAnArray(arr);
   ArrayResize(arr,0);
   DeepCopyAnArray2(arrNew2, arr);
   for(i=0; i<ArraySize(arrNew); i++)
     {
      delete arrNew[i];
      //ArrayResize(A, ArraySize(A)-1);
     }
//DeleteObjectsFromAnArray(arrNew);
   ArrayResize(arrNew,0);
   for(i=0; i<ArraySize(arrNew2); i++)
     {
      delete arrNew2[i];
      //ArrayResize(A, ArraySize(A)-1);
     }
//DeleteObjectsFromAnArray(arrNew2);
   ArrayResize(arrNew2,0);





  }


//+------------------------------------------------------------------+
//| Function to display alert                                        |
//+------------------------------------------------------------------+
void DisplayAlert(string message,int shift)
  {
   if(ArraySize(Time)>shift)
     {
      if(shift<=2 && Time[shift]!=lastAlertTime)
        {
         lastAlertTime=Time[shift];
         Alert(message,Symbol()," , ",Period()," minutes chart");
        }
     }
  }
//+---------------------------------------------------------------------+
//| Function to find the biggest amount of bars from in an object array |
//+---------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findBiggestAmountOfBars(SymbolCorrelation* &arr[], int &avoidables[])
  {

   double biggestGap=0;
   int biggestGapIndex;

   for(int i=0; i<ArraySize(arr); i++)
     {
      if(!arrayIncludes(avoidables,i) && CheckPointer(arr[i])!=POINTER_INVALID)
        {
         double bars = arr[i].getMatchingTimes();
         if(bars > biggestGap)
           {
            biggestGap = bars;
            biggestGapIndex = i;
           }
        }


     }

   return biggestGapIndex;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Function to find the best correlation value in an object array   |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findBiggestCorrelation(SymbolCorrelation* &arr[], int &avoidables[])
  {

   double biggestGap=0;
   int biggestGapIndex;

   for(int i=0; i<ArraySize(arr); i++)
     {
      if(!arrayIncludes(avoidables,i) && CheckPointer(arr[i])!=POINTER_INVALID)
        {
         double gap = MathAbs(arr[i].getCorrelation());
         if(gap > biggestGap)
           {
            biggestGap = gap;
            biggestGapIndex = i;
           }
        }


     }

   return biggestGapIndex;
  }

//+------------------------------------------------------------------+
//| Function to check if a value contains in an array                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool arrayIncludes(int &array[], int value)
  {

   for(int i=0; i<ArraySize(array); i++)
     {
      if(array[i]==value)
        {
         return true;
        }
     }
   return false;
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


//----------------------------------------------------------------------------------------------------------
// Function for simple type array (double) to avoid 'parameter passed as reference, variable expected' error
//----------------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AddToArray3(double &arr[], double value)
  {

   ArrayResize(arr,ArraySize(arr)+1);
   arr[ArraySize(arr)-1] = value;
   return value;
  }

//------------------------------------------------------------------------------------------------
// Generic function for erasing values in any type of array
//------------------------------------------------------------------------------------------------

template <typename T> int EraseOrdered(T& A[], int iPos)
  {
   int iLast;
   if(CheckPointer(A[iPos])!=POINTER_INVALID)
     {
      delete A[iPos];
      for(iLast = ArraySize(A) - 1; iPos < iLast; ++iPos)
         A[iPos] = A[iPos + 1];
      ArrayResize(A, iLast);
      return iPos;
     }
   else
     {
      return -1;
     }
  }


//------------------------------------------------------------------------------------------------
// Generic function for erasing values in any type of array of basic data types
//------------------------------------------------------------------------------------------------

template <typename T> void EraseOrdered2(T& A[], int iPos)
  {
   for(int iLast = ArraySize(A) - 1; iPos < iLast; ++iPos)
      A[iPos] = A[iPos + 1];
   ArrayResize(A, iLast);
  }


//------------------------------------------------------------------------------------------------
// Generic function for deleting all objects in any type of array
//------------------------------------------------------------------------------------------------

template <typename T> void DeleteObjectsFromAnArray(T& A[])
  {
   for(int i=0; i<ArraySize(A); i++)
     {
      delete A[i];
      //ArrayResize(A, ArraySize(A)-1);
     }
  }

//------------------------------------------------------------------------------------------------
// Generic function for deep copying any type of array (actually for DaxDriverObject type only)
//------------------------------------------------------------------------------------------------


template <typename T> void DeepCopyAnArray(T& A[],T& B[])
  {

   for(int i=0; i<ArraySize(A); i++)   // make deep copy of the original
     {
      SymbolCorrelation *obj = new SymbolCorrelation(A[i]);
      AddToArray2(B,obj);
     }
  }

//----------------------------------------------------------------------------------------------------
// Generic function for deep copying arrays which represents DaxDriverSymbol types
//-----------------------------------------------------------------------------------------------------


template <typename T> void DeepCopyAnArray2(T& A[],T& B[])
  {

   for(int i=0; i<ArraySize(A); i++)   // make deep copy of the original
     {
      if(CheckPointer(A[i])!=POINTER_INVALID)
        {
         SymbolCorrelation *obj = new SymbolCorrelation(A[i]);
         AddToArray2(B,obj);
        }
     }
  }


//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
