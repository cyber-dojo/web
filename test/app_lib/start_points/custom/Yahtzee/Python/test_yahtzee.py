import yahtzee
import unittest

class TestYahtzee(unittest.TestCase):

    def test_chance_scores_sum_of_all_dice(self):
        expected = 15
        actual = yahtzee.Yahtzee.chance(2,3,4,5,1)
        assert expected == actual
        self.assertEqual(16, yahtzee.Yahtzee.chance(3,3,4,5,1))
  
    def test_yahtzee_scores_50(self):
        expected = 50
        actual = yahtzee.Yahtzee.yahtzee([4,4,4,4,4])
        assert expected == actual
        assert 50 == yahtzee.Yahtzee.yahtzee([6,6,6,6,6])
        assert 0 == yahtzee.Yahtzee.yahtzee([6,6,6,6,3])

    def Test_1s(self):
        assert yahtzee.Yahtzee.ones(1,2,3,4,5) == 1
        assert 2 == yahtzee.Yahtzee.ones(1,2,1,4,5)
        assert 0 == yahtzee.Yahtzee.ones(6,2,2,4,5)
        assert 4 == yahtzee.Yahtzee.ones(1,2,1,1,1)
    
    def test_2s(self):
        assert 4 == yahtzee.Yahtzee.twos(1,2,3,2,6)
        assert 10 == yahtzee.Yahtzee.twos(2,2,2,2,2)

    def test_threes(self):
        assert 6 == yahtzee.Yahtzee.threes(1,2,3,2,3)
        assert 12 == yahtzee.Yahtzee.threes(2,3,3,3,3)
  
    def test_fours_test(self):
        assert 12 == yahtzee.Yahtzee(4,4,4,5,5).fours()
        assert 8 == yahtzee.Yahtzee(4,4,5,5,5).fours()
        assert 4 == yahtzee.Yahtzee(4,5,5,5,5).fours()

    def test_fives(self):
        assert 10 == yahtzee.Yahtzee(4,4,4,5,5).fives()
        assert 15 == yahtzee.Yahtzee(4,4,5,5,5).fives()
        assert 20 == yahtzee.Yahtzee(4,5,5,5,5).fives()

    def test_sixes_test(self):
        assert 0 == yahtzee.Yahtzee(4,4,4,5,5).sixes()
        assert 6 == yahtzee.Yahtzee(4,4,6,5,5).sixes()
        assert 18 == yahtzee.Yahtzee(6,5,6,6,5).sixes()

    def test_one_pair(self):
        assert 6 == yahtzee.Yahtzee.score_pair(3,4,3,5,6)
        assert 10 == yahtzee.Yahtzee.score_pair(5,3,3,3,5)
        assert 12 == yahtzee.Yahtzee.score_pair(5,3,6,6,5)
  

    def test_two_Pair(self):
        assert 16 == yahtzee.Yahtzee.two_pair(3,3,5,4,5)
        assert 0 == yahtzee.Yahtzee.two_pair(3,3,5,5,5)
  

    def test_three_of_a_kind(self):
        assert 9 == yahtzee.Yahtzee.three_of_a_kind(3,3,3,4,5)
        assert 15 == yahtzee.Yahtzee.three_of_a_kind(5,3,5,4,5)
        assert 0 == yahtzee.Yahtzee.three_of_a_kind(3,3,3,3,5)

    def test_four_of_a_knd(self):
        assert 12 == yahtzee.Yahtzee.four_of_a_kind(3,3,3,3,5)
        assert 20 == yahtzee.Yahtzee.four_of_a_kind(5,5,5,4,5)
        assert 0 == yahtzee.Yahtzee.three_of_a_kind(3,3,3,3,3)
  

    def test_smallStraight(self):
        assert 15 == yahtzee.Yahtzee.smallStraight(1,2,3,4,5)
        assert 15 == yahtzee.Yahtzee.smallStraight(2,3,4,5,1)
        assert 0 == yahtzee.Yahtzee.smallStraight(1,2,2,4,5)
  
    def test_largeStraight(self):
        assert 20 == yahtzee.Yahtzee.largeStraight(6,2,3,4,5)
        assert 20 == yahtzee.Yahtzee.largeStraight(2,3,4,5,6)
        assert 0 == yahtzee.Yahtzee.largeStraight(1,2,2,4,5)
  


    def test_fullHouse(self):
        assert 18 == yahtzee.Yahtzee.fullHouse(6,2,2,2,6)
        assert 0 == yahtzee.Yahtzee.fullHouse(2,3,4,5,6)
   

if __name__ == '__main__':
    unittest.main()