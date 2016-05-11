//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com

extern "C"
{
#include "LightScheduler.h"
#include "LightControllerSpy.h"
#include "FakeTimeService.h"
}

#include "CppUTest/TestHarness.h"

TEST_GROUP(LightScheduler)
{
    void setup()
    {
        LightScheduler_Create();
    }

    void teardown()
    {
        LightScheduler_Destroy();
    }
};

TEST(LightScheduler, Create)
{
}

/*
 * Wiring tests
    - No lights controlled during scheduler initializations
    - No lights controlled when the scheduler wakes up with an empty schedule
        - this test provides the opportunity to define the wake up function
    - No lights controlled when it is not the scheduled time
        - this provides the opportunity to define the function to
        add something to the schedule
    - Scheduled light turns on at the right time
        - this test illustrates how everything works together

 * Single event tests
    - Schedule to turn off everyday
    - Light scheduled for a specific day does not turn on on
         the wrong day.
    - Light scheduled for a specific day does turn on on the
         right day.
    - Remove a scheduled turn on event, when the scheduled
        time occurs, the previously scheduled light does not turn on

 * Multiple event tests
    - Turn on a light and later turn it off
    - Control two lights at the day/minute

 * Boundary Conditions and special cases
    - Scheduler rejects light IDs that are out of the
       allowed range
    - Scheduler rejects too many.
    - Scheduler rejects multiple duplicate events.
    - Allow setting a fire-once attribute to a
       scheduled event.
    - Write a test to assure that triggering an event
       does not delete it, unless it is a fire-once event

 * Time service registration
    - Scheduler registers during Create
    - Scheduler de-registration in Destroy

 * More features
    - Schedule for weekends.
    - Schedule for weekdays.
    - EVERYDAY schedule can have specific days overridden.
        warn the user when there is an override

 * oops
    - The fine print of the UI agreement says lights
       are numbered 1-32. The hardware wants 0 to 31.
 */
