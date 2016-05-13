//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com

#ifndef FAKE_TIME_SERVICE_INCLUDED
#define FAKE_TIME_SERVICE_INCLUDED

#include "TimeService.h"

enum { FAKE_TIME_INVALID = -1 };

void FakeTimeService_SetMinute(int);
void FakeTimeService_SetDay(Day);
void FakeTimeService_SimulateOneMinuteTic(void);
int FakeTimeService_GetPeriodicAlarm(void);
void * FakeTimeService_GetCallback(void);

#endif
