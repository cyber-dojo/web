//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com

#ifndef TIME_SERVICE_INCLUDED
#define TIME_SERVICE_INCLUDED

typedef enum { EVERYDAY = -1, WEEKEND = -2, WEEKDAY = -3,
    SUNDAY = 0, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY } Day;

void TimeService_Create(void);
void TimeService_Destroy(void);
int TimeService_GetMinute(void);
Day TimeService_GetDay(void);
void TimeService_SchedulePeriodicAlarm(int ms, void callback(void));
void TimeService_CancelPeriodicAlarm(int ms, void callback(void));

#endif
