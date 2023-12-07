//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <ArrayFunctions.mqh>
template<typename T>
T                 AddToArray2(T &arr[], T &value)
  {

   ArrayResize(arr,ArraySize(arr)+1);
   arr[ArraySize(arr)-1] = value;
   return value;
  }
template <typename T> void DeepCopyAnArray2(T* &A[],T* &B[])
  {
   for(int i=0; i<ArraySize(A); i++)   // make deep copy of the original
     {
      if(CheckPointer(A[i])==POINTER_DYNAMIC)
        {
         T *obj = new T(A[i]);
         AddToArray2(B,obj);
        }
      else
         if(CheckPointer(A[i])==POINTER_AUTOMATIC)
           {
            //Print("CheckPointer(A[i])!=POINTER_DYNAMIC at index: " + i);
            T *obj = T(A[i]);
            AddToArray2(B,obj);
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HorizontalLine
  {
private:
   string            m_type;
   string            m_name;
   double            m_price;
   datetime          m_time1;
   datetime          m_time2;
   bool              m_is_broken;
public:
                     HorizontalLine();
                     HorizontalLine(HorizontalLine& sample);
   void              initialize(string type, string name, double price, datetime time1, datetime time2);
   string            getType() {return m_type;};
   string            getName() {return m_name;}
   double            getPrice() {return m_price;}
   datetime          getTime1() {return m_time1;}
   datetime          getTime2() {return m_time2;}
   void              setBroken() {m_is_broken = true;}
   bool              isBroken() {return m_is_broken;}

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HorizontalLine::HorizontalLine()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HorizontalLine::HorizontalLine(HorizontalLine& sample)
  {
   m_name = sample.getName();
   m_price = sample.getPrice();
   m_time1 = sample.getTime1();
   m_time2 = sample.getTime2();
   m_is_broken = sample.isBroken();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void         HorizontalLine::initialize(string type, string name,double price,datetime time1, datetime time2)
  {
   m_type = type;
   m_name = name;
   m_price = price;
   m_time1 = time1;
   m_time2 = time2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              IsPointerOk(HorizontalLine* &obj)
  {
   return CheckPointer(obj)==POINTER_DYNAMIC;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ArrayOfHorizontalLines
  {

   //
private:
   HorizontalLine    *m_horizontal_lines[];
   void              removeFromArrayByName(string symbol, HorizontalLine* &arr[]);
   double            findLevelOfShortestDistance(double currentPrice, datetime currentTime, double &avoidableLevels[]);
   double            findLevelOfNewestTimestamp(datetime currentTime, datetime &avoidableLevels[]);
   void              emptyArray(HorizontalLine* &arr[]);
public:
   //void              initialize(int arraySize) {ArrayResize(m_horizontal_lines,arraySize);}
   bool              add(string type, string name, double price, datetime time1, datetime time2);
   bool              removeByName(string name);
   bool              removeByPrice(double price);
   bool              findLevelsWithShortestDistancesToCurrentPrice(double currentPrice, datetime currentTime, int numberOfDistances, double &priceArrayToFill[]);
   bool              findLevelsWithNewestTimeStamp(datetime currentTime, int numberOfDistances, double &priceArrayToFill[]);
   int               findByName(string name);
   int               getAmountOfHorizontalLines() {return ArraySize(m_horizontal_lines);}
   void              setLineAsBroken(string name);
   void              printValuesOfAll(datetime time);
                    ~ArrayOfHorizontalLines();

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayOfHorizontalLines::setLineAsBroken(string name)
  {
   for(int i=0; i<ArraySize(m_horizontal_lines); i++)
     {
      HorizontalLine *pointer = m_horizontal_lines[i];
      datetime time1 = pointer.getTime1();
      //if(time1>=StringToTime("2023.05.18 01:00:00"))
      // Alert("name#: " + name + " nameOfThisIteration: " + pointer.getName());
      if(IsPointerOk(pointer) && name == pointer.getName())
        {
         pointer.setBroken();
         Alert("pointer set broken");
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrayOfHorizontalLines::findLevelsWithShortestDistancesToCurrentPrice(double currentPrice, datetime currentTime,int numberOfDistances, double &priceArrayToFill[])
  {
   double avoidableDistances[];
   int counterForLevelsFound;
   for(int i=0; i<numberOfDistances; i++)
     {
      double levelOfShortestLevelOfThisIteration = findLevelOfShortestDistance(currentPrice, currentTime,avoidableDistances);
      if(levelOfShortestLevelOfThisIteration != (-1))
        {
         AddToArray2(priceArrayToFill,levelOfShortestLevelOfThisIteration);
         counterForLevelsFound++;
        }
     }
   if(counterForLevelsFound == numberOfDistances)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrayOfHorizontalLines::findLevelsWithNewestTimeStamp(datetime currentTime,int numberOfDistances,double &priceArrayToFill[])
  {
   datetime avoidableDistances[];
   int counterForLevelsFound;

   for(int i=0; i<numberOfDistances; i++)
     {
      double levelOfShortestLevelOfThisIteration = findLevelOfNewestTimestamp(currentTime,avoidableDistances);
      if(levelOfShortestLevelOfThisIteration != (-1))
        {
         AddToArray2(priceArrayToFill,levelOfShortestLevelOfThisIteration);
         counterForLevelsFound++;
        }
     }
   if(counterForLevelsFound == numberOfDistances)
     {
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ArrayOfHorizontalLines::findLevelOfNewestTimestamp(datetime currentTime,datetime &avoidableLevels[])
  {
   datetime newestTimeStamp = (datetime)0;
   double levelOfShortestDistance = -1;
   string name;
   double price_;
   datetime time1, time2;
   for(int i=0; i<ArraySize(m_horizontal_lines); i++)
     {
      HorizontalLine *pointer = m_horizontal_lines[i];
      if(IsPointerOk(pointer))
        {
         datetime time1 = pointer.getTime1();
         datetime time2 = pointer.getTime2();
         if(currentTime>time2 || currentTime<time1 || pointer.isBroken())
           {
            continue;
           }
         datetime time = m_horizontal_lines[i].getTime1();
         double price = m_horizontal_lines[i].getPrice();
         if(!arrayIncludes(avoidableLevels, time))
           {
            if(time > newestTimeStamp)
              {
               newestTimeStamp = time;
               levelOfShortestDistance = price;
               name = m_horizontal_lines[i].getName();
               time1 = m_horizontal_lines[i].getTime1();
               time2 = m_horizontal_lines[i].getTime2();
               //Alert("findLevelOfShortestDistance(), Type: " + m_horizontal_lines[i].getType() + ", time1: " + time1 + ", time2: " + time2 + ", price: " + price);
               //Alert("Horizontal line found. Its name is: " + m_horizontal_lines[i].getName() + " , Type: " + m_horizontal_lines[i].getType() + ", time1: " + time1 + ", time2: " + time2 + ", price: " + price);
               price_ = price;
              }
           }
        }
     }
   if(levelOfShortestDistance != (-1))
     {
      AddToArray2(avoidableLevels,newestTimeStamp);
     }
//Alert("name: " + name + " price: " + price_ + ", time1: " + time1 + ", time2: " + time2);
   if(currentTime >= StrToTime("2023.05.19 00:00:00") && _Symbol == "GBPUSD.r")
      Alert("levelOfShortestDistance: " + levelOfShortestDistance);
   return levelOfShortestDistance;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ArrayOfHorizontalLines::findLevelOfShortestDistance(double currentPrice, datetime currentTime, double &avoidableLevels[])
  {
   double shortestDistance = EMPTY_VALUE;
   double levelOfShortestDistance = -1;
   string name;
   double price_;
   datetime time1, time2;
   for(int i=0; i<ArraySize(m_horizontal_lines); i++)
     {
      HorizontalLine *pointer = m_horizontal_lines[i];
      if(IsPointerOk(pointer))
        {
         datetime time1 = pointer.getTime1();
         datetime time2 = pointer.getTime2();
         if(currentTime>time2 || currentTime<time1 || pointer.isBroken())
           {
            continue;
           }
         double price = m_horizontal_lines[i].getPrice();
         if(!arrayIncludes(avoidableLevels, price))
           {
            double distanceOfThisIteration = MathAbs(currentPrice - price);
            if(distanceOfThisIteration < shortestDistance)
              {
               shortestDistance = distanceOfThisIteration;
               levelOfShortestDistance = price;
               name = m_horizontal_lines[i].getName();
               time1 = m_horizontal_lines[i].getTime1();
               time2 = m_horizontal_lines[i].getTime2();
               //Alert("findLevelOfShortestDistance(), Type: " + m_horizontal_lines[i].getType() + ", time1: " + time1 + ", time2: " + time2 + ", price: " + price);
               //Alert("Horizontal line found. Its name is: " + m_horizontal_lines[i].getName() + " , Type: " + m_horizontal_lines[i].getType() + ", time1: " + time1 + ", time2: " + time2 + ", price: " + price);
               price_ = price;
              }
           }
        }
     }
   if(levelOfShortestDistance != (-1))
     {
      AddToArray2(avoidableLevels,levelOfShortestDistance);
     }
//Alert("name: " + name + " price: " + price_ + ", time1: " + time1 + ", time2: " + time2);
   return levelOfShortestDistance;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ArrayOfHorizontalLines::findByName(string name)
  {
//Alert("Name to search for: " + name);
   for(int i=0; i<ArraySize(m_horizontal_lines); i++)
     {
      HorizontalLine* pointer = m_horizontal_lines[i];
      //Alert("Name of this iteration: " + pointer.getName() + " name to search for: " + name);
      if(pointer.getName()==name)
        {
         //Alert("Name of this iteration: " + pointer.getName() + " just found! time1: " + pointer.getTime1() + ", time2: " + pointer.getTime2());
         return i;
        }

     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrayOfHorizontalLines::add(string type, string name, double price, datetime time1, datetime time2)
  {
   HorizontalLine *horizontalLine = new HorizontalLine();
   horizontalLine.initialize(type, name,price,time1, time2);
   AddToArray2(m_horizontal_lines,horizontalLine);
//Alert("A new HorizontalLine type object added. Type: " + horizontalLine.getType() + ", name: " + name + ", time1: " + horizontalLine.getTime1() + ", time2: " + horizontalLine.getTime2() + ", price level: "+ horizontalLine.getPrice());
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrayOfHorizontalLines::removeByName(string name)
  {
   for(int i=0; i<ArraySize(m_horizontal_lines); i++)
     {
      HorizontalLine *pointerOfThisIteration = GetPointer(m_horizontal_lines[i]);
      if(true)
        {
         string nameOfThisIteration = pointerOfThisIteration.getName();
         if(pointerOfThisIteration.getTime1()>=StrToTime("2023.05.18 01:00:00"))
            //Alert("name: " + name + ", nameOfThisIteration: " + nameOfThisIteration);
            if(nameOfThisIteration == name)
              {
               removeFromArrayByName(name,m_horizontal_lines);
               //Alert("Hline with name " + name + " was just removed. time1: " + pointerOfThisIteration.getTime1() + ", time2: " + pointerOfThisIteration.getTime2()+ ", type: " + pointerOfThisIteration.getType());
               return true;
              }
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              ArrayOfHorizontalLines::removeFromArrayByName(string symbol, HorizontalLine* &arr[])
  {
   symbol = StringTrimRight(StringTrimLeft(symbol));
   HorizontalLine* copyArr[];
//DeepCopyAnArray2(arr,copyArr);
   for(int i=0; i<ArraySize(arr); i++)
     {
      HorizontalLine *obj = arr[i];
      bool pointerOK = IsPointerOk(obj);
      string sym = obj.getName();
      //Print(pointerOK + " sym: " + sym + ", symbol: " + symbol);
      if(pointerOK && sym!=symbol)
        {
         HorizontalLine* objCopied = new HorizontalLine(obj);
         AddToArray2(copyArr,objCopied);
         //EraseOrdered(copyArr,i);
         break;
        }
     }


   int siz = ArraySize(arr);
//Print("siz: " + siz);
//deleteOldObjectsButNotThisChartObject(arr);
   emptyArray(arr);

   siz = ArraySize(copyArr);
//Print("siz2: " + siz);
   DeepCopyAnArray2(copyArr,arr);
//deleteOldObjectsButNotThisChartObject(copyArr);
   emptyArray(copyArr);
   siz = ArraySize(arr);
//Print("siz3: " + siz);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayOfHorizontalLines::emptyArray(HorizontalLine *&arr[])
  {
//Alert("function emptyArray() was just called, ArraySize(arr): " + ArraySize(arr));
   int counterForDeletions;
   for(int i=0; i<ArraySize(arr); i++)
     {
      HorizontalLine *pointerOfThisIteration = GetPointer(arr[i]);
      if(CheckPointer(pointerOfThisIteration)==POINTER_DYNAMIC)
        {
         delete pointerOfThisIteration;
         counterForDeletions++;
        }
     }
//Alert("ArraySize(arr)2: " + ArraySize(arr) + ", counterForDeletions: " + counterForDeletions);
   ArrayResize(arr,0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayOfHorizontalLines::printValuesOfAll(datetime time)
  {

//Alert("Function printValuesOfAll() was just called at: " + time);
   for(int i=0; i<ArraySize(m_horizontal_lines); i++)
     {
      HorizontalLine* pointer = m_horizontal_lines[i];
      if(IsPointerOk(pointer))
        {
         Print("Variables of HorizontalLine object, type: " + pointer.getType() + ", name: " + pointer.getName() + ", price: " + pointer.getPrice() + ", time1: " + pointer.getTime1() + ", time2: " + pointer.getTime2());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ArrayOfHorizontalLines::~ArrayOfHorizontalLines()
  {
   emptyArray(m_horizontal_lines);
   ArrayResize(m_horizontal_lines,0);
   /*
    for(int i=0; i<ArraySize(m_horizontal_lines); i++)
      {
       HorizontalLine *pointer = GetPointer(m_horizontal_lines[i]);
       if(CheckPointer(pointer)==POINTER_DYNAMIC)
         {
          delete pointer;
          Print("pointer deleted");
         }
      }
      */
  }

enum distance_method
  {
   Closest_price = 1,
   Newest_levels = 2
  };
//+------------------------------------------------------------------+
//|                                                  MTF Fractal.mq4 |
//|                                         Copyright © 2014, TrueTL |
//|                                            http://www.truetl.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, TrueTL"
#property link      "http://www.truetl.com"
#property version "1.40"
#property indicator_separate_window
#property indicator_buffers 6
#include <FractalsMultiSymbolMultiTimeframe.mqh>
//#include <ArrayFunctions.mqh>

extern string  Version_140                      = "www.truetl.com";
input bool Original_code = true;
input int      How_many_horizontal_lines = 3;
sinput distance_method Distance_method = Closest_price;

input string   Symbol_to_use = "";
extern int     Fractal_Timeframe                = 1440;
extern bool    User_defined_maxbars             = false;
extern int     Maxbar                           = 2000;
extern color   Up_Fractal_Color                 = Red;
extern int     Up_Fractal_Symbol                = 108;
extern color   Down_Fractal_Color               = DodgerBlue;
extern int     Down_Fractal_Symbol              = 108;
extern bool    Extend_Line                      = true;
extern bool    Extend_Line_to_Background        = true;
extern bool    Show_Validation_Candle           = true;
extern color   Up_Fractal_Extend_Line_Color     = Red;
extern int     Up_Fractal_Extend_Width          = 2;
extern int     Up_Fractal_Extend_Style          = 2;
extern color   Down_Fractal_Extend_Line_Color   = DodgerBlue;
extern int     Down_Fractal_Extend_Width        = 2;
extern int     Down_Fractal_Extend_Style        = 2;
int Timeframe = Fractal_Timeframe;
double UpBuffer[], DoBuffer[], StdUpBuffer[], StdDownBuffer[],refchk, tempref, level;
double auxBuffer1[], auxbuffer2[];
int barc;
MqlRates rates[];
FractalsMultiSymbolMultiTimeframe fractalsMultiSymbolMultiTimeframe;
ArrayOfHorizontalLines supportLines;
ArrayOfHorizontalLines resistanceLines;
const int periodToUse = 5;
bool initJustDone;

//+------------------------------------------------------------------+
//|                                                             INIT |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,UpBuffer);
   SetIndexStyle(0,DRAW_NONE, DRAW_ARROW, 0, Up_Fractal_Color);
//SetIndexArrow(0,Up_Fractal_Symbol);
   SetIndexBuffer(1,DoBuffer);
   SetIndexStyle(1,DRAW_NONE, DRAW_ARROW, 0, Down_Fractal_Color);
//SetIndexArrow(1,Down_Fractal_Symbol);
   SetIndexBuffer(2,StdUpBuffer);
   SetIndexStyle(2,DRAW_LINE, 0, 0, Up_Fractal_Color);
   SetIndexBuffer(3,StdDownBuffer);
   SetIndexStyle(3,DRAW_LINE, 0, 0, Down_Fractal_Color);
   SetIndexBuffer(4,auxBuffer1);
   SetIndexStyle(4,DRAW_NONE, DRAW_ARROW, 0, Up_Fractal_Color);
//SetIndexArrow(0,Up_Fractal_Symbol);
   SetIndexBuffer(5,auxbuffer2);
   SetIndexStyle(5,DRAW_NONE, DRAW_ARROW, 0, Down_Fractal_Color);
//SetIndexArrow(1,Down_Fractal_Symbol);
   initJustDone=true;
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
   int i, c, dif, limit;
   tempref =   iHigh(Symbol(), Fractal_Timeframe, 1) +
               iHigh(Symbol(), Fractal_Timeframe, 51) +
               iHigh(Symbol(), Fractal_Timeframe, 101);

   if(barc != Bars || IndicatorCounted() < 0 || tempref != refchk)
     {
      barc = Bars;
      refchk = tempref;
     }
   else
      return(0);

//deinit();
   int responseArr[];
   int bars = ArrayCopyRates(rates,Symbol_to_use,Timeframe);
   int lastError = DownloadedBars(rates,responseArr);
   limit = responseArr[0] - 1;
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
      if(limit>Rates_total)
        {
         limit = Rates_total-1;
        }
      fractalsMultiSymbolMultiTimeframe.Initialize(periodToUse,limit,rates);
     }
   if(Fractal_Timeframe <= Period())
      Fractal_Timeframe = Period();

   dif = Fractal_Timeframe/Period();

   if(Maxbar > Bars || !User_defined_maxbars)
      Maxbar = Bars-10;
   bool newBar = NewBar();
   if(initJustDone)
     {
      for(i = Maxbar - 1; i>=0; i--)
        {
         if(i>=ArrayRange(rates,0))
           {
            continue;
           }
         fractalsMultiSymbolMultiTimeframe.AddValues(rates[i].high,rates[i].low,Time[i],i);
         if(iBarShift(NULL,Fractal_Timeframe,Time[i]) < 3)
           {
            UpBuffer[i] = 0;
            DoBuffer[i] = 0;
            continue;
           }

         if(i>(limit-periodToUse))
           {
            continue;
           }


         double upperFractal = fractalsMultiSymbolMultiTimeframe.GetUpper();
         double lowerFractal = fractalsMultiSymbolMultiTimeframe.GetLower();

         UpBuffer[i] = upperFractal;//iFractals(NULL,Fractal_Timeframe,1,iBarShift(NULL,Fractal_Timeframe,Time[i]));
         DoBuffer[i] = lowerFractal;//iFractals(NULL,Fractal_Timeframe,2,iBarShift(NULL,Fractal_Timeframe,Time[i]));
        }
      GenerateBufferValues(0,dif,Maxbar);

      initJustDone = false;
     }
   else
      if(!initJustDone && newBar)
        {
         GenerateBufferValues(0,dif,1);
        }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GenerateBufferValues(int i, int dif, int maxBar)
  {
   if(Extend_Line)
     {
      int c;
      for(i = 0; i < Maxbar; i++)
        {
         int pos = i-2*dif+2;
         if(UpBuffer[i] != EMPTY_VALUE)
           {
            level = UpBuffer[i];
            datetime time_;
            for(c = i; c > 0; c--)
              {
               double open = rates[c].open;
               double close = rates[c].close;
               double openNext = rates[c-1].open;
               double closeNext = rates[c-1].close;
               time_ = rates[c].time;
               string nameToGive = "MTF_Fractal_" + "H" + pos;
               string nameToGive2 = "MTF_Fractal_" + "L" + pos;

               if((rates[c].open < level && close > level) || (open > level && close < level))
                 {
                  //supportLines.setLineAsBroken(("L" + pos));
                  resistanceLines.setLineAsBroken(nameToGive);
                  break;
                 }
               if(open <= level && close <= level && openNext >= level && closeNext >= level)
                 {
                  //supportLines.setLineAsBroken(("L" + pos));
                  resistanceLines.setLineAsBroken(nameToGive);
                  break;
                 }
               if(open >= level && close >= level && openNext <= level && closeNext <= level)
                 {
                  //supportLines.setLineAsBroken(("L" + pos));
                  resistanceLines.setLineAsBroken(nameToGive);
                  break;
                 }
              }

            /*
            bool hLineAddedInArray, hLineAddedInChart;
            if(resistanceLines.findByName(nameToGive)== (-1) && time_ != (datetime)0 && level != 0)
              {
               resistanceLines.add("Resistance", nameToGive,level,time_);
               hLineAddedInArray = true;
              }
            else
               if(resistanceLines.findByName(nameToGive)!= (-1) && time_ != (datetime)0 && level != 0)
                 {
                  resistanceLines.removeByName(nameToGive);
                  resistanceLines.add("Resistance", nameToGive,level,time_);
                  hLineAddedInArray = true;
                  Alert("HEPPPP_");
                 }
                 */
            if(time_ != (datetime)0 && level != 0)
              {
               DrawLine("H", pos, c, level, Extend_Line_to_Background, Up_Fractal_Extend_Line_Color, Up_Fractal_Extend_Width, Up_Fractal_Extend_Style);
               //hLineAddedInChart = true;
               /*int supports = supportLines.getAmountOfHorizontalLines();
               int resistances = resistanceLines.getAmountOfHorizontalLines();
               int objects = ObjectsTotal();
               if((supports + resistances) != objects)
                 {
                  //supportLines.printValuesOfAll(time_);
                  Alert("supportLines.getAmountOfHorizontalLines(): " + supportLines.getAmountOfHorizontalLines());
                  Alert("resistanceLines.getAmountOfHorizontalLines(): " + resistanceLines.getAmountOfHorizontalLines());
                  Alert("Objects: " + ObjectsTotal());
                 }
                 */
              }
            if(pos>0 && Show_Validation_Candle && pos<ArraySize(UpBuffer))
               UpBuffer[pos] = level;
            i += dif;
            int amount = supportLines.getAmountOfHorizontalLines();
            int objects = ObjectsTotal();

           }
        }

      for(i = 0; i < Maxbar; i++)
        {
         int pos = i-2*dif+2;
         if(DoBuffer[i] != EMPTY_VALUE)
           {
            level = DoBuffer[i];
            datetime time_;
            for(c = i; c > 0; c--)
              {
               double open = rates[c].open;
               double close = rates[c].close;
               double openNext = rates[c-1].open;
               double closeNext = rates[c-1].close;
               string nameToGive = "MTF_Fractal_" + "H" + pos;
               string nameToGive2 = "MTF_Fractal_" + "L" + pos;
               time_ = rates[c].time;
               if((open < level && close > level) || (open > level && close < level))
                 {
                  //supportLines.setAllBroken();
                  //resistanceLines.setAllBroken();
                  //resistanceLines.setLineAsBroken(("H" + pos));
                  supportLines.setLineAsBroken(nameToGive2);
                  break;
                 }
               if(open <= level && close <= level && openNext >= level && closeNext >= level)
                 {
                  //supportLines.setAllBroken();
                  //resistanceLines.setAllBroken();
                  //resistanceLines.setLineAsBroken(("H" + pos));
                  supportLines.setLineAsBroken(nameToGive2);
                  break;
                 }
               if(open >= level && close >= level && openNext <= level && closeNext <= level)
                 {
                  //supportLines.setAllBroken();
                  //resistanceLines.setAllBroken();
                  //resistanceLines.setLineAsBroken(("H" + pos));
                  supportLines.setLineAsBroken(nameToGive);
                  break;
                 }
              }

            bool hLineAddedInArray, hLineAddedInChart;
            /*if(supportLines.findByName(nameToGive)== (-1) && time_ != (datetime)0 && level != 0)
              {
               supportLines.add("Support", nameToGive,level,time_);
               hLineAddedInArray = true;
              }
            else
               if(supportLines.findByName(nameToGive)!= (-1) && time_ != (datetime)0 && level != 0)
                 {
                  supportLines.removeByName(nameToGive);
                  supportLines.add("Support", nameToGive,level,time_);
                  hLineAddedInArray = true;
                  Alert("HEPPPP2_");
                 }
                 */
            if(time_ != (datetime)0 && level != 0)
              {
               DrawLine("L", pos, c, level, Extend_Line_to_Background, Down_Fractal_Extend_Line_Color, Down_Fractal_Extend_Width, Down_Fractal_Extend_Style);
               hLineAddedInChart = true;

               /*int supports = supportLines.getAmountOfHorizontalLines();
               int resistances = resistanceLines.getAmountOfHorizontalLines();
               int objects = ObjectsTotal();
               /*
               if((supports + resistances) != objects)
                 {
                  //supportLines.printValuesOfAll(time_);
                  Alert("supportLines.getAmountOfHorizontalLines(): " + supportLines.getAmountOfHorizontalLines());
                  Alert("resistanceLines.getAmountOfHorizontalLines(): " + resistanceLines.getAmountOfHorizontalLines());
                  Alert("Objects: " + ObjectsTotal());
                 }
                 */
              }
            if(pos>0 && Show_Validation_Candle && pos<ArraySize(DoBuffer))
               DoBuffer[pos] = level;
            i += dif;
            /*
            if(pos==21)
              {
               double closestLevels[];
               double price = Close[pos];
               supportLines.findLevelsWithShortestDistancesToCurrentPrice(price,iTime(NULL,Timeframe,pos),3,closestLevels);
               Alert("Situation at: " + Time[pos]);
               for(int i=0; i<ArraySize(closestLevels); i++)
                 {
                  double levelOfThis = closestLevels[i];
                  Alert("Closest support level: " + levelOfThis);
                 }
               ArrayResize(closestLevels,0);
               resistanceLines.findLevelsWithShortestDistancesToCurrentPrice(price,iTime(NULL,Timeframe,pos),3,closestLevels);
               for(int i=0; i<ArraySize(closestLevels); i++)
                 {
                  double levelOfThis = closestLevels[i];
                  Alert("Closest resistance level: " + levelOfThis);
                 }
              }
              */

           }

        }
      GenerateFinalValues();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GenerateFinalValues()
  {

//int lastIndex = Maxbar - 1;
   for(int i=Maxbar-1; i>=0; i--)
     {
      if((i+1)>=ArrayRange(rates,0))
        {
         continue;
        }
      int shift = iBarShift(Symbol_to_use,Timeframe,Time[i+1],true);
      /*if(shift != (-1))
        {
         lastIndex = i;
        }
        */
      double closestLevels[],closestLevels2[];
      if(shift<ArrayRange(rates,0) == false || shift == (-1))
        {
         continue;
        }
      double price = rates[shift].close;
      datetime time = rates[shift].time;
      if(Distance_method == Closest_price)
        {
         supportLines.findLevelsWithShortestDistancesToCurrentPrice(price,time,How_many_horizontal_lines,closestLevels);
         resistanceLines.findLevelsWithShortestDistancesToCurrentPrice(price, time,How_many_horizontal_lines,closestLevels2);
        }
      else
         if(Distance_method == Newest_levels)
           {
            supportLines.findLevelsWithNewestTimeStamp(time,How_many_horizontal_lines,closestLevels);
            resistanceLines.findLevelsWithNewestTimeStamp(time,How_many_horizontal_lines,closestLevels2);
           }
      double range;
      if(ArraySize(closestLevels)==0 || ArraySize(closestLevels2)==0)
        {
         continue;
        }
      range = MathAbs(closestLevels[0] - closestLevels2[0]);
      double distanceToClosest, distanceToClosest2;
      double finalValue1, finalValue2;
      if(ArraySize(closestLevels)!=0)
        {
         distanceToClosest = MathAbs(closestLevels[0] - price);
         double value = MathSqrt(Variance(closestLevels)) + distanceToClosest;
         //Alert("range: " + range + " at: " + time);
         if(value!=0 && range!=0)
           {
            value = value/range;
            finalValue1 = 1/value;
            auxBuffer1[i] = finalValue1;
           }
        }

      if(ArraySize(closestLevels2)!=0)
        {
         distanceToClosest2 = MathAbs(closestLevels2[0] - price);
         double value = MathSqrt(Variance(closestLevels2)) + distanceToClosest2;
         if(value!=0 && range!=0)
           {
            value = value/range;
            finalValue2 = -1/value;
            auxbuffer2[i] = finalValue2;
           }
        }

      double absUpValue = MathAbs(finalValue1);
      double absDownValue = MathAbs(finalValue2);
      double coeff;
      if(absUpValue>=absDownValue)
        {
         coeff = -1*distanceToClosest;
        }
      else
        {
         coeff = 1*distanceToClosest2;
        }
      if(absUpValue>=absDownValue && absDownValue!=0)
        {
         StdDownBuffer[i] = coeff*absDownValue/absUpValue;
        }
      else
         if(absUpValue<absDownValue && absUpValue!=0)
           {
            StdDownBuffer[i] = coeff*absUpValue/absDownValue;
           }
      /*
            if(StdUpBuffer[i+1]==EMPTY_VALUE && StdUpBuffer[i] != EMPTY_VALUE)
              {
               StdUpBuffer[i+1] = StdUpBuffer[i];
              }
            if(StdDownBuffer[i+1]==EMPTY_VALUE && StdDownBuffer[i] != EMPTY_VALUE)
              {
               StdDownBuffer[i+1] = StdDownBuffer[i];
              }
              */


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Custom_iBarShift(string symbol,int timeFrame,datetime time,bool exact, int lastIndex)
  {
   for(int i=lastIndex; i>=0; i--)
     {
      if(lastIndex>=ArrayRange(rates,0)-1)
        {
         continue;
        }
      datetime timeThis = rates[i].time;
      datetime diff = time - timeThis;
      if(!exact && diff<=(datetime)timeFrame*60 && diff>=0)
        {
         Alert("!exact && diff<=(datetime)timeFrame*60 && diff>=0 at: " + time);
         return i;
        }
      else
         if(exact && time == timeThis)
           {
            return i;
           }
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                        DRAW LINE |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(string dir, int i, int c, double lev, bool back, color col, int width, int style)
  {

   string nameToGive = "MTF_Fractal_"+dir+i;
   if(ObjectFind(0,nameToGive) == 0)
     {
      ResetLastError();

      Alert("Object was found at: " + i);
      /*
      int err = GetLastError();
      if(err)
        {
         Alert("err: " + err);
        }
      else
        {

        }
      if(dir == "H")
        {
         if(i<=21)
           {
            Alert("Object MTF_Fractal___" + dir + "" + i + " found at i time: " + iTime(Symbol(),Period(),i) + " and c time: "  + iTime(Symbol(),Period(),c) +  " and its price: " + price);
            resistanceLines.findByName(nameToGive);
           }
         resistanceLines.removeByName(nameToGive);
        }
      else
         if(dir == "L")
           {
            if(i<=21)
              {
               Alert("Object MTF_Fractal___" + dir + "" + i + " found at i time: " + iTime(Symbol(),Period(),i) + " and c time: "  + iTime(Symbol(),Period(),c) +  " and its price: " + price);
               supportLines.findByName(nameToGive);
              }
            supportLines.removeByName(nameToGive);
           }
           */
     }

   string trimmedString = StringTrimRight(StringTrimLeft(dir));
   if(trimmedString == "H")
     {
      //if(i<=23)
      //   Alert("H dir == H at: " + i);
      resistanceLines.add("Resistance",nameToGive,lev,iTime(Symbol(),Timeframe,i),iTime(Symbol(),Timeframe,c));
     }
   else
      if(trimmedString == "L")
        {
         // if(i<=23)
         //  Alert("L dir == L at: " + i);
         supportLines.add("Support",nameToGive,lev,iTime(Symbol(),Timeframe,i),iTime(Symbol(),Timeframe,c));
        }
      else
        {

        }
//if(i<=23)
//  Alert("dir at " + i + " is: " + dir);
   /*
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
   */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DownloadedBars(MqlRates &rates[], int &responseArr[])
  {
   ResetLastError();
   int bars = ArrayCopyRates(rates,Symbol_to_use,Timeframe);
   AddToArray2(responseArr,bars);
   return GetLastError();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DownloadedBars2(MqlRates &rates[], int &responseArr[])
  {
   ResetLastError();
   int bars = ArrayCopyRates(rates,Symbol_to_use,Timeframe);
   AddToArray2(responseArr,bars);
   return GetLastError();
  }
//+------------------------------------------------------------------+
