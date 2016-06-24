import org.junit.*;
import static org.junit.Assert.*;

public class YahtzeeTest {
    
    @Test
    public void Chance_scores_sum_of_all_dice() {
        int expected = 15;
        int actual = Yahtzee.Chance(2,3,4,5,1);
        assertEquals(expected, actual);
        assertEquals(16, Yahtzee.Chance(3,3,4,5,1));
    }

    @Test
    public void Yahtzee_scores_50() 
    {
        int expected = 50;
        int actual = Yahtzee.yahtzee(4,4,4,4,4);
        assertEquals(expected, actual);
        assertEquals(50, Yahtzee.yahtzee(6,6,6,6,6));
        assertEquals(0, Yahtzee.yahtzee(6,6,6,6,3));
    }

    @Test
    public void Test_1s() {
        assertTrue(Yahtzee.Ones(1,2,3,4,5) == 1);
        assertEquals(2, Yahtzee.Ones(1,2,1,4,5));
        assertEquals(0, Yahtzee.Ones(6,2,2,4,5));
        assertEquals(4, Yahtzee.Ones(1,2,1,1,1));
    }

    @Test
    public void test_2s() 
    {
        assertEquals(4, Yahtzee.Twos(1,2,3,2,6));
        assertEquals(10, Yahtzee.Twos(2,2,2,2,2));
    }

    @Test
    public void test_threes() {
        assertEquals(6, Yahtzee.Threes(1,2,3,2,3));
        assertEquals(12, Yahtzee.Threes(2,3,3,3,3));
    }

    @Test
    public void fours_test() {
        assertEquals(12, new Yahtzee(4,4,4,5,5).Fours());
        assertEquals(8, new Yahtzee(4,4,5,5,5).Fours());
        assertEquals(4, new Yahtzee(4,5,5,5,5).Fours());
    }

    @Test
    public void fives() {
        assertEquals(10, new Yahtzee(4,4,4,5,5).Fives());
        assertEquals(15, new Yahtzee(4,4,5,5,5).Fives());
        assertEquals(20, new Yahtzee(4,5,5,5,5).Fives());
    }

    @Test
    public void sixes_test() 
    {
        assertEquals(0, new Yahtzee(4,4,4,5,5).sixes());
        assertEquals(6, new Yahtzee(4,4,6,5,5).sixes());
        assertEquals(18, new Yahtzee(6,5,6,6,5).sixes());
    }

    @Test
    public void one_pair() 
    {
        assertEquals(6, Yahtzee.ScorePair(3,4,3,5,6));
        assertEquals(10, Yahtzee.ScorePair(5,3,3,3,5));
        assertEquals(12, Yahtzee.ScorePair(5,3,6,6,5));
    }

    @Test
    public void two_Pair() 
    {
        assertEquals(16, Yahtzee.TwoPair(3,3,5,4,5));
        assertEquals(0, Yahtzee.TwoPair(3,3,5,5,5));
    }

    @Test
    public void three_of_a_kind() 
    {
        assertEquals(9, Yahtzee.ThreeOfAKind(3,3,3,4,5));
        assertEquals(15, Yahtzee.ThreeOfAKind(5,3,5,4,5));
        assertEquals(0, Yahtzee.ThreeOfAKind(3,3,3,3,5));
    }

    @Test
    public void four_of_a_knd() {
        assertEquals(12, Yahtzee.FourOfAKind(3,3,3,3,5));
        assertEquals(20, Yahtzee.FourOfAKind(5,5,5,4,5));
        assertEquals(0, Yahtzee.FourOfAKind(3,3,3,3,3));
    }

    @Test
    public void smallStraight() {
        assertEquals(15, Yahtzee.SmallStraight(1,2,3,4,5));
        assertEquals(15, Yahtzee.SmallStraight(2,3,4,5,1));
        assertEquals(0, Yahtzee.SmallStraight(1,2,2,4,5));
    }

    @Test
    public void largeStraight() 
    {
        assertEquals(20, Yahtzee.LargeStraight(6,2,3,4,5));
        assertEquals(20, Yahtzee.LargeStraight(2,3,4,5,6));
        assertEquals(0, Yahtzee.LargeStraight(1,2,2,4,5));
    }

    @Test
    public void fullHouse() {
        assertEquals(18, Yahtzee.FullHouse(6,2,2,2,6));
        assertEquals(0, Yahtzee.FullHouse(2,3,4,5,6));
    }
}
