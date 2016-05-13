
#include "CppUTest/TestHarness.h"
#include "CppUTestExt/MockSupport.h"

extern "C"
{
#include "IOReadWrite.h"
}

TEST_GROUP(IOReadWrite_CppUMockTest)
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

TEST(IOReadWrite_CppUMockTest, IOWrite)
{
    mock("IO")
        .expectOneCall("IOWrite")
        .withParameter("addr", 0x1000)
        .withParameter("data", 0xa000);

    IOWrite(0x1000, 0xa000);
}

TEST(IOReadWrite_CppUMockTest, IORead)
{
    mock("IO")
        .expectOneCall("IORead")
        .withParameter("addr", 1000)
        .andReturnValue(55);

    LONGS_EQUAL(55, IORead(1000));
}

TEST(IOReadWrite_CppUMockTest, MultiplsIORead)
{
    mock("IO")
        .expectNCalls(4, "IORead")
        .withParameter("addr", 1000)
        .andReturnValue(0);

    LONGS_EQUAL(0, IORead(1000));
    LONGS_EQUAL(0, IORead(1000));
    LONGS_EQUAL(0, IORead(1000));
    LONGS_EQUAL(0, IORead(1000));
}

TEST(IOReadWrite_CppUMockTest, by_default_call_order_is_not_enforced)
{
    mock("IO")
        .expectOneCall("IOWrite")
        .withParameter("addr", 0)
        .withParameter("data", 1);

    mock("IO")
        .expectOneCall("IOWrite")
        .withParameter("addr", 2)
        .withParameter("data", 4);
    mock("IO")
        .expectNCalls(4, "IORead")
        .withParameter("addr", 10)
        .andReturnValue(0);

    IORead(10);
    IORead(10);
    IOWrite(2, 4);
    IORead(10);
    IOWrite(0, 1);
    IORead(10);
}

TEST(IOReadWrite_CppUMockTest, can_have_strict_call_order)
{
    mock("IO").strictOrder();
    mock("IO")
        .expectOneCall("IOWrite")
        .withParameter("addr", 0)
        .withParameter("data", 1);
    mock("IO")
        .expectOneCall("IOWrite")
        .withParameter("addr", 2)
        .withParameter("data", 4);
    mock("IO")
        .expectNCalls(4, "IORead")
        .withParameter("addr", 10)
        .andReturnValue(0);

    IOWrite(0, 1);
    IOWrite(2, 4);
    IORead(10);
    IORead(10);
    IORead(10);
    IORead(10);
}



