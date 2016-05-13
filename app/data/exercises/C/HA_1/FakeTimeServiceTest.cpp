//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com

#include "CppUTest/TestHarness.h"

extern "C"
{
#include "TimeService.h"
#include "FakeTimeService.h"
#include <stdbool.h>
}

static int fakeCallbackCalled;

static void fakeCallback(void)
{
    fakeCallbackCalled = true;
}

TEST_GROUP(TimeService)
{
    void setup()
    {
        fakeCallbackCalled = false;
        TimeService_Create();
    }

    void teardown()
    {
        TimeService_Destroy();
    }
};

TEST(TimeService, Create)
{
    LONGS_EQUAL(FAKE_TIME_INVALID, TimeService_GetMinute());
    LONGS_EQUAL(FAKE_TIME_INVALID, TimeService_GetDay());
}

TEST(TimeService, Set)
{
    FakeTimeService_SetMinute(42);
    LONGS_EQUAL(42, TimeService_GetMinute());
    FakeTimeService_SetDay(FRIDAY);
    LONGS_EQUAL(FRIDAY, TimeService_GetDay());
}

TEST(TimeService, NoPeriodicCallback)
{
    FakeTimeService_SimulateOneMinuteTic();
    CHECK_FALSE(fakeCallbackCalled);
    LONGS_EQUAL(FAKE_TIME_INVALID, FakeTimeService_GetPeriodicAlarm())
}

TEST(TimeService, PeriodicCallback)
{
    TimeService_SchedulePeriodicAlarm(42, fakeCallback);
    FakeTimeService_SimulateOneMinuteTic();
    CHECK_TRUE(fakeCallbackCalled);
    LONGS_EQUAL(42, FakeTimeService_GetPeriodicAlarm());
    POINTERS_EQUAL(fakeCallback, FakeTimeService_GetCallback())
}

TEST(TimeService, CancelPeriodicCallback)
{
    TimeService_SchedulePeriodicAlarm(43, fakeCallback);
    TimeService_CancelPeriodicAlarm(43, fakeCallback);
    FakeTimeService_SimulateOneMinuteTic();
    CHECK_FALSE(fakeCallbackCalled);
    LONGS_EQUAL(-1, FakeTimeService_GetPeriodicAlarm())
    POINTERS_EQUAL(0, FakeTimeService_GetCallback())
}
