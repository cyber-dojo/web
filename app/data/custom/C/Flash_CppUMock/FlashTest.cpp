#include "CppUTest/TestHarness.h"
#include "CppUTestExt/MockSupport.h"

extern "C"
{
}

TEST_GROUP(Flash)
{
    void setup()
    {
    }

    void teardown()
    {
        mock("IO").checkExpectations();
        mock().clear();
    }
};

TEST(Flash, test1)
{
//      FAIL("Start here");
}
