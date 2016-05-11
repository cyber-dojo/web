//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com

#include "CppUTest/TestHarness.h"

extern "C"
{
#include "CircularBuffer.h"
}

TEST_GROUP(CircularBuffer)
{
    CircularBuffer * buffer;

    void setup()
    {
        buffer = CircularBuffer_Create();
    }

    void teardown()
    {
        CircularBuffer_Destroy(buffer);
    }
};

TEST(CircularBuffer, create_destroy)
{
//    FAIL("Start here");
}

/*
 * TDD Exercise
 *
 *   Please read the instructions file.
 *
 *   - Move the #if down the page one test at a time.
 *   - Incrementally develop the circular buffer
 *   - Open the course notes to see some sketches
 *     of interesting CircularBuffer states.
 *   - Delete the conversation comments as you
 *     finish each test.
 *
*/

/* PLEASE DELETE CONVERSATION COMMENTS AS YOU GET TESTS TO PASS */

#ifdef Move_this_line_down_one_test_to_simulate_james_writing_the_test
/*
 * Discussion with James about next test:
 * How do we choose the first test? Let's test initialization.
 * What should the state of the CircularBuffer be after creation?
 * It should be empty.  Let's write a test that defines
 * that interface an assures buffers start out empty.
 */

TEST(CircularBuffer, is_empty_after_creation)
{
    CHECK_TRUE(CircularBuffer_IsEmpty(buffer));
}

/*
 * Discussion with James about next test:
 * While the buffer is empty, it can't also be full.
 * Let's write that test.
 */

TEST(CircularBuffer, is_not_full_after_creation)
{
    CHECK_FALSE(CircularBuffer_IsFull(buffer));
}

/* PLEASE DELETE CONVERSATION COMMENTS AS YOU GET TESTS TO PASS */

/*
 * Retrospective:
 * To get the prior two tests passing
 * all you need are the function declaration in
 * the header with hard coded return results in
 * the implementation.  Please delete any other code you
 * don't need yet.
 */

/*
 * Discussion with James about next test:
 * If we put a value into the buffer, it should no
 * longer be empty. Let's define the Put interface
 * and write a test for the empty to not empty boundary
 * condition.
 */
TEST(CircularBuffer, is_not_empty_after_put)
{
    CircularBuffer_Put(buffer, 10046);
    CHECK_FALSE(CircularBuffer_IsEmpty(buffer));
}

/*
 * Discussion with James about next test:
 * While we are at it, let's transition back to empty
 * after putting in one value.  We're testing another
 * boundary condition.
 */

TEST(CircularBuffer, is_empty_after_put_then_get)
{
    CircularBuffer_Put(buffer, 4567);
    CircularBuffer_Get(buffer);
    CHECK_TRUE(CircularBuffer_IsEmpty(buffer));
}

/*
 * Retrospective:
 * To get the prior two tests passing
 * all you needed to do was to add an input-index
 * and an output-index to the structure, incrementing them
 * in Put and Get and using them to decide if the queue
 * is empty.  (Look at the empty state in course notes.)
 */

/*
 * Discussion with James about next test:
 * Now, lets write a test that checks that a single
 * number put in the queue can be removed.
 */

TEST(CircularBuffer, put_get_one_value)
{
    CircularBuffer_Put(buffer, 4567);
    LONGS_EQUAL(4567, CircularBuffer_Get(buffer));
}

/* PLEASE DELETE CONVERSATION COMMENTS AS YOU GET TESTS TO PASS */

/*
 * Retrospective:
 * With the previous tests passing you should not need to store
 * anything.  You can hard code the return value for Get()
 *
 * If you have more, delete it now!  It is not tested code, you
 * are supposed to be doing TDD!
 */

/*
 * Discussion with James about next test:
 * With this test it will be more trouble to fake several values
 * than to introduce an array to hold the values.  Make the
 * array a fixed size for now. We can make it selectable
 * in a few tests.
 */

TEST(CircularBuffer, put_get_is_fifo)
{
    CircularBuffer_Put(buffer, 1);
    CircularBuffer_Put(buffer, 2);
    CircularBuffer_Put(buffer, 3);
    LONGS_EQUAL(1, CircularBuffer_Get(buffer));
    LONGS_EQUAL(2, CircularBuffer_Get(buffer));
    LONGS_EQUAL(3, CircularBuffer_Get(buffer));
}

/*
 * Retrospective:
 * The previous test has driven you to have a simple internal
 * array in the structure with fixed size, an input-index and
 * an output-index.
 *
 * There should be no circular buffer logic yet!
 *
 * Why?  Your tests do not require it.  Delete untested code now!
 */

/*
 * Discussion with James about next test:
 * We know a hard-coded buffer length is not going to work
 * in production.  The user of the buffer should provide the
 * capacity when the buffer is created.
 *
 * We'll have to pass the capacity to the CircularBuffer
 * during Create. Let's create a Capacity function, so we can
 * query the capacity.  This brings us one step closer to
 * dynamically sizing the values array.
 */

TEST(CircularBuffer, report_capacity)
{
    LONGS_EQUAL(10, CircularBuffer_Capacity(buffer));
}

/*
 * Now let's change the call to CircularBuffer_Create
 * to accept the capacity.
 *
 * Don't forget to update CircularBuffer_Create() in setup()!
 */

TEST(CircularBuffer, create_sets_capacity)
{
    CircularBuffer * buffer = CircularBuffer_Create(2);
    LONGS_EQUAL(2, CircularBuffer_Capacity(buffer));
    CircularBuffer_Destroy(buffer);
}

/*
 * Now that we have all the APIs, the tests provide a
 * safety net to support converting your fixed size array
 * to a pointer to allocated memory.
 *
 * You might be wondering, why don't we need another test
 * to make us allocate the int array?
 *
 * I've been guiding you to solve one problem at a time.
 * The tests you have fully cover you code.  They will
 * also fully cover your code when you change it to use
 * dynamic memory, with the exception of memory leaks.
 * CppUTest has your back for that one.
 *
 */

/*
 * Discussion with James about next test:
 * Now let's fill the queue all the way and add the
 * IsFull implementation.
 *
 * It might be helpful to draw a diagram.
 */

TEST(CircularBuffer, is_full_when_filled_to_capacity)
{
    // its your turn to go first
}

TEST(CircularBuffer, is_not_empty_when_filled_to_capacity)
{
    // its your turn to go first
}

/*
 * Are you having trouble getting IsFull working?
 * Draw a sketch of the full state and compare
 * it to empty....  Interesting.
 *
 * Here is my diagram if you prefer:
 * www.wingman-sw.com/files/cyber-dojo/CircularBuffer.pdf
 *
 * Try to come up with a simple solution
 */

/* Retrospective:
 *
 * If you have wrap around logic already, you have untested code.
 * Please delete the untested code. How many times do I have
 * to tell you?!
 */

/*
 * Discussion with James about next test:
 * Now let's transition from full by getting one thing
 * out.
 */

TEST(CircularBuffer, is_not_full_after_get_from_full_buffer)
{
    /*
     * write the test that fills the buffer
     * takes one item out
     * verifies that the buffer is not full anymore
     */
}

/*
 * Discussion with James about next test:
 * Let's fill it and empty it.
 */

TEST(CircularBuffer, fill_to_capacity_then_empty)
{
    /*
     * Write the test that fills the buffer
     * Then takes all the items out and checks them
     * Then confirms the buffer is empty
     */
}

/*
 * Retrospective:
 * With the EmptyToFullToEmpty test there is still no need for
 * the wrap around logic.  Delete it.
 */

/*
 * Retrospective:
 * Did that test pass without changes to the production code?
 * That is not a big surprise, it happens.
 */

/*
 * Discussion with James about next test:
 * Finally, we have to do the wrap around test.
 *
 * Let's fill the buffer, then take something out
 * and then add a obviously different value.  Then
 * we'll make sure all values are retrieved in FIFO.
 */

TEST(CircularBuffer, force_a_buffer_wraparound)
{
    CircularBuffer * buffer = CircularBuffer_Create(2);
    CircularBuffer_Put(buffer, 1);
    CircularBuffer_Put(buffer, 2);
    CircularBuffer_Get(buffer);
    CircularBuffer_Put(buffer, 1000);
    CHECK_TRUE(CircularBuffer_IsFull(buffer));
    LONGS_EQUAL(2, CircularBuffer_Get(buffer));
    LONGS_EQUAL(1000, CircularBuffer_Get(buffer));
    CHECK_TRUE(CircularBuffer_IsEmpty(buffer));
    CircularBuffer_Destroy(buffer);
}

/*
 * Retrospective:
 * Did Wrap around test pass without change? Did you allocate
 * your internal integer array, or just make it really big?
 * You can write code that passes some tests and is wrong, but
 * that's not the goal.  The goal is correct working code.
 */

/*
 * Retrospective:
 * Do you have duplication in your tests, like loops to fill or empty
 * the buffer?  If so, you can refactor out the duplication into
 * a TEST_GROUP helper function.  TEST_GROUP functions are available
 * to all TESTs in the group.
 *
 * fillTheQueue's signature looks like this:
 *     void fillTheQueue(int seedValue, int numberOfElements)
 */

/*
 * Retrospective:
 * You should not have any production code that is worried about
 * a Getting from an empty buffer, or Putting to a full buffer.
 */

/*
 * Discussion with James about next test:
 * What should we do when putting to a full queue?
 * Maybe we should return FALSE.
 * Also, it should not damage the queue contents
 * or change its state.
 */

TEST(CircularBuffer, put_to_full_fails)
{
    //Your turn again to write the test
}

/*
 * Discussion with James about next test:
 * What should happen when putting to a full queue?
 * It should not damage the queue contents or state.
 */

TEST(CircularBuffer, put_to_full_does_not_damage_contents)
{
    //Your turn again to write the test
}

/*
 * Retrospective:
 * I'm not totally happy with put to full. Maybe we need to
 * talk to the other users of this.  Maybe we should keep the
 * latest value and toss the earlier one.  It might be nice
 * to see an error on the console or in a log.
 */

/*
 * Retrospective:
 * Do you have duplicate index wrapping code in your production
 * code?  You should refactor it into a helper function.
 */

/*
 * Discussion with James about next test:
 * What should happen when we get from an empty queue?
 * We have to return something.  Are all values valid? We could
 * have an invalid value. Maybe we should return the last value
 * again?  Should you add an pointer to an error to populate?
 *
 * After deliberation, we decided to add a default value to
 * Create, so the user of the CircularBuffer could control
 * their own default return result.
 */

TEST(CircularBuffer, get_from_empty_returns_default_value)
{
    /*
     * How do you want to provide the default value?
     * Putting it into Create seems like a good choice.
     *
     * See if you an introduce this feature without
     * breaking your existing tests.
     */
}

#endif

/* Congratulations!
 *
 * Look for test refactoring opportunities.
 *
 * Did you get rid of all those unneeded comments?
 *
 * Do it again next week except without my tests
 * to guide you
 */

/*
 * More if you got this far:
 *
 * Think of a couple other ways of handling
 * overflow and underflow.  Test drive in your
 * next best behavior.
 *
 * New requirements came in, the buffer needs to handle
 * a single producer and a single consumer, and it cannot
 * have any OS locking mechanism in the solution.
 *
 * After some research, you discover that using a single
 * empty cell to to detect the full situation means that
 * the a single producer and a single consumer is thread
 * safe.  Refactor your design to use this technique.
 */
