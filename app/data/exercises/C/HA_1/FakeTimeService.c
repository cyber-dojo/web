//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com

#include "CppUTest/TestHarness_c.h"
#include "FakeTimeService.h"

static int theMinute;
static Day theDay;
static int savedCallbackPeriod;
static void (*savedCallbackFunction)(void);

void TimeService_Create(void)
{
    theMinute = FAKE_TIME_INVALID;
    theDay = FAKE_TIME_INVALID;
    savedCallbackPeriod = FAKE_TIME_INVALID;
    savedCallbackFunction = 0;
}

void TimeService_Destroy(void)
{
}

int TimeService_GetMinute(void)
{
    return theMinute;
}

void FakeTimeService_SetMinute(int minute)
{
    theMinute = minute;
}

void FakeTimeService_SetDay(Day day)
{
    CHECK_C(day >= SUNDAY && day <= SATURDAY);
    theDay = day;
}

Day TimeService_GetDay(void)
{
    return theDay;
}

void TimeService_SchedulePeriodicAlarm(int ms, void callback(void))
{
  savedCallbackPeriod = ms;
  savedCallbackFunction = callback;
}

void TimeService_CancelPeriodicAlarm(int ms, void callback(void))
{
  CHECK_EQUAL_C_INT(savedCallbackPeriod, ms);
  CHECK_C(savedCallbackFunction == callback);
  savedCallbackPeriod = FAKE_TIME_INVALID;
  savedCallbackFunction = 0;
}

void FakeTimeService_SimulateOneMinuteTic(void)
{
  if (savedCallbackFunction)
    savedCallbackFunction();
}

int FakeTimeService_GetPeriodicAlarm(void)
{
  return savedCallbackPeriod;
}

void * FakeTimeService_GetCallback(void)
{
  return (void *)savedCallbackFunction;
}
