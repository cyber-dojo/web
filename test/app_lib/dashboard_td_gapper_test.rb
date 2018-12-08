require_relative 'app_lib_test_base'

class DashboardTdGapperTest < AppLibTestBase

  def self.hex_prefix
    '449'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  def hex_setup
    @gapper = DashboardTdGapper.new(start, seconds_per_td, max_seconds_uncollapsed)
    set_runner_class('NotUsed')
    set_differ_class('NotUsed')
  end

  attr_reader :gapper

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AC6',
  'number' do
    # 0 : 2:30:00 - 2:30:20
    # 1 : 2:30:20 - 2:30:40
    # 2 : 2:30:40 - 2:31:00
    # 3 : 2:31:00 - 2:31:20
    # 4 : 2:31:20 - 2:31:40
    # 5 : 2:31:40 - 2:32:00

    assert_equal 0, gapper.number(make_light(30,19))
    assert_equal 1, gapper.number(make_light(30,22))
    assert_equal 2, gapper.number(make_light(30,58))
    assert_equal 3, gapper.number(make_light(31,11))
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F5E',
  'stats' do
    # 0 : 2:30:00 - 2:30:20
    # 1 : 2:30:20 - 2:30:40
    # 2 : 2:30:40 - 2:31:00
    # 3 : 2:31:00 - 2:31:20
    # 4 : 2:31:20 - 2:31:40
    # 5 : 2:31:40 - 2:32:00
    # 6 : 2;32;00 - 2:32:20
    # 7 : 2;32:20 - 2:32:40

    all_lights =
    {
      hippo_id => [ t1=make_light(30,21), # 1
                    t2=make_light(31,33), # 4
                  ],
      lion_id =>  [ t3=make_light(30,25), # 1
                    t4=make_light(31,37), # 4
                    t5=make_light(31,39), # 4
                  ],
      panda_id => [ t6=make_light(31,42), # 5
                  ]
    }
    expected =
    {
      :katas =>
      {
        hippo_id => { 1 => [ t1 ], 4 => [ t2    ] },
        lion_id  => { 1 => [ t3 ], 4 => [ t4,t5 ] },
        panda_id => {                             5 => [ t6 ] }
      },
      :td_nos => [0,1,4,5,7]
    }
    now = [year,month,day,hour,32,23] # 7
    assert_equal expected, gapper.stats(all_lights, now)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E42',
  'vertical bleed' do
    all_lights =
    {
      hippo_id => [ t1=make_light(30,21), # 1
                    t2=make_light(31,33), # 4
                  ],
      lion_id =>  [ t3=make_light(30,25), # 1
                    t4=make_light(31,37), # 4
                    t5=make_light(31,39), # 4
                  ],
      panda_id => [ t6=make_light(31,42), # 5
                  ]
    }
    expected =
    {
      hippo_id => { 0 => [], 1 => [ t1 ], 4 => [ t2    ], 5 => [    ], 7 => [ ] },
      lion_id  => { 0 => [], 1 => [ t3 ], 4 => [ t4,t5 ], 5 => [    ], 7 => [ ] },
      panda_id => { 0 => [], 1 => [    ], 4 => [       ], 5 => [ t6 ], 7 => [ ] }
    }
    now = [year,month,day,hour,32,23] #td 7
    s = gapper.stats(all_lights, now)
    gapper.vertical_bleed(s)
    assert_equal expected, s[:katas]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '315',
  'collapsed table' do
    # 30 mins = 30 x 3 x 20 secs = 90 tds
    td_nos = [0,1,4,5]
    expected =
    {
      0 => [ :dont_collapse, 0 ],
      1 => [ :dont_collapse, 2 ],
      4 => [ :dont_collapse, 0 ]
    }
    actual = gapper.collapsed_table(td_nos)
    assert_equal expected, actual

    td_nos = [0,1,3,95]
    expected =
    {
      0 => [ :dont_collapse, 0 ],
      1 => [ :dont_collapse, 1 ],
      3 => [ :collapse, 91 ]
    }
    actual = gapper.collapsed_table(td_nos)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '634',
  'strip removes lightless tds from both ends' do
    t1=make_light(30,21) # 1
    t2=make_light(31,33) # 4
    t3=make_light(30,25) # 1
    t4=make_light(31,37) # 4
    t5=make_light(31,39) # 4
    t6=make_light(31,42) # 5
    unstripped =
    {
      hippo_id => { 0 => [], 1 => [ t1 ], 2 => [], 3 => [], 4 => [ t2    ], 5 => [    ], 6 => { :collapsed => 4321 }, 4327 => [ ] },
      lion_id  => { 0 => [], 1 => [ t3 ], 2 => [], 3 => [], 4 => [ t4,t5 ], 5 => [    ], 6 => { :collapsed => 4321 }, 4327 => [ ] },
      panda_id => { 0 => [], 1 => [    ], 2 => [], 3 => [], 4 => [       ], 5 => [ t6 ], 6 => { :collapsed => 4321 }, 4327 => [ ] }
    }
    stripped =
    {
      hippo_id => { 1 => [ t1 ], 2 => [], 3 => [], 4 => [ t2    ], 5 => [    ] },
      lion_id  => { 1 => [ t3 ], 2 => [], 3 => [], 4 => [ t4,t5 ], 5 => [    ] },
      panda_id => { 1 => [    ], 2 => [], 3 => [], 4 => [       ], 5 => [ t6 ] }
    }
    assert_equal stripped, gapper.strip(unstripped)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '220',
  'fully gapped no traffic_lights yet' do
    all_lights = { }
    now = [year,month,day+1,hour,32,23] #td 4327
    actual = gapper.fully_gapped(all_lights, now)
    expected = { }
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9F3',
  'fully gapped with no collapsing and no td-holes' do
    all_lights =
    {
      hippo_id => [ t1=make_light(30,21), # 1
                    t2=make_light(31,33), # 4
                  ],
      lion_id =>  [ t3=make_light(30,25), # 1
                    t4=make_light(31,37), # 4
                    t5=make_light(31,39), # 4
                  ],
      panda_id => [ t6=make_light(31,42), # 5
                  ]
    }
    expected =
    {
      hippo_id => { 1 => [ t1 ], 2 => [], 3 => [], 4 => [ t2    ], 5 => [    ] },
      lion_id  => { 1 => [ t3 ], 2 => [], 3 => [], 4 => [ t4,t5 ], 5 => [    ] },
      panda_id => { 1 => [    ], 2 => [], 3 => [], 4 => [       ], 5 => [ t6 ] }
    }
    now = [year,month,day+1,hour,32,23] #td 4327
    actual = gapper.fully_gapped(all_lights, now)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9F4',
  'fully gapped with collapsing and td-holes' do
    start = Time.mktime(*[year,month,day,hour,0,0])
    @gapper = DashboardTdGapper.new(start, seconds_per_td=60, max_seconds_uncollapsed=60*4)

    all_lights =
    {
      lion_id =>  [ t1=make_light( 5, 0),
                    t2=make_light( 5,10),
                    t3=make_light(11, 0),
                    t4=make_light(11,10)
                  ],
      tiger_id => [ t5=make_light( 5,11),
                    t6=make_light( 7, 0),
                    t7=make_light( 7,10),
                    t8=make_light(18,20)
                  ]
    }

    assert_equal  5, @gapper.number(t1)
    assert_equal  5, @gapper.number(t2)
    assert_equal 11, @gapper.number(t3)
    assert_equal 11, @gapper.number(t4)
    assert_equal  5, @gapper.number(t5)
    assert_equal  7, @gapper.number(t6)
    assert_equal  7, @gapper.number(t7)
    assert_equal 18, @gapper.number(t8)

    now = [year,month,day,hour,32,23] #td 32
    expected =
    {
      :katas =>
      {
        lion_id  => { 5 => [ t1,t2 ],
                     11 => [ t3,t4 ]
                    },
        tiger_id => { 5 => [ t5 ],
                      7 => [ t6,t7 ],
                     18 => [t8]
                    },
      },
      :td_nos => [0,5,7,11,18,32]
    }
    actual = @gapper.stats(all_lights, now)
    assert_equal expected, actual

    # - - - - - - - - - - - - - - -

    gapper.vertical_bleed(actual)
    expected =
    {
      :katas =>
      {
        lion_id  => { 0=>[], 5 => [t1,t2], 7=>[],        11=>[t3,t4], 18=>[],   32=>[] },
        tiger_id => { 0=>[], 5 => [t5],    7=>[ t6,t7 ], 11=>[]     , 18=>[t8], 32=>[] },
      },
      :td_nos => (td_nos=[0,5,7,11,18,32])
    }
    assert_equal expected, actual

    # - - - - - - - - - - - - - - -

    actual = @gapper.collapsed_table(td_nos)
    expected = {
       0 => [:collapse,      4],
       5 => [:dont_collapse, 1],
       7 => [:collapse,      3],
      11 => [:collapse,      6],
      18 => [:collapse,     13]
    }
    assert_equal expected, actual

    # - - - - - - - - - - - - - - -

    expected =
    {
      lion_id  => {  5 => [t1,t2],
                     6 => [],
                     7 => [],
                     8 => {collapsed:3},
                    11 => [t3,t4],
                    12 => {collapsed:6},
                    18 => []
                  },
      tiger_id => {  5 => [t5],
                     6 => [],
                     7 => [t6,t7],
                     8 => {collapsed:3},
                    11 => [],
                    12 => {collapsed:6},
                    18 => [t8]
                  }
    }
    actual = @gapper.fully_gapped(all_lights, now)

    assert_equal expected.keys, actual.keys, 'kata-ids'
    expected.keys.each do |kata_id|
      assert_equal expected[kata_id].keys.sort, actual[kata_id].keys.sort, "#{name}'s td_nos"
      expected[kata_id].keys.each do |td|
        assert_equal expected[kata_id][td], actual[kata_id][td], "#{kata_id}[#{td}]"
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9F7',
  'time-ticks with no katas is {}' do
    all_lights = { }
    now = [year,month,day+1,hour,32,23] #td 4327
    gapped = gapper.fully_gapped(all_lights, now)
    assert_equal({}, gapper.time_ticks(gapped))
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9F5',
  'time-ticks with no collapsing and no td-holes' do
    start = Time.mktime(*[year,month,day,hour,0,0])
    @gapper = DashboardTdGapper.new(start, seconds_per_td=60, max_seconds_uncollapsed=60*4)

    all_lights =
    {
      hippo_id => [ t1=make_light(0,21), # 0
                    t2=make_light(1,33), # 1
                  ],
      lion_id  => [ t3=make_light(0,25), # 0
                    t4=make_light(1,37), # 1
                    t5=make_light(2,39), # 2
                  ],
      panda_id => [ t6=make_light(3,42), # 3
                  ]
    }

    assert_equal  0, @gapper.number(t1)
    assert_equal  1, @gapper.number(t2)
    assert_equal  0, @gapper.number(t3)
    assert_equal  1, @gapper.number(t4)
    assert_equal  2, @gapper.number(t5)
    assert_equal  3, @gapper.number(t6)

    expected = { 0 => 60, 1 => 120, 2 => 180, 3 => 240 }
    now = [year,month,day+1,hour,4,23]
    gapped = gapper.fully_gapped(all_lights, now)
    actual = gapper.time_ticks(gapped)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9F6',
  'time-ticks with collapsing and td-holes' do
    start = Time.mktime(*[year,month,day,hour,0,0])
    @gapper = DashboardTdGapper.new(start, seconds_per_td=60, max_seconds_uncollapsed=60*4)

    all_lights =
    {
      lion_id =>  [ t1=make_light( 5, 0),
                    t2=make_light( 5,10),
                    t3=make_light(11, 0),
                    t4=make_light(11,10)
                  ],
      tiger_id => [ t5=make_light( 5,11),
                    t6=make_light( 7, 0),
                    t7=make_light( 7,10),
                    t8=make_light(18,20)
                  ]
    }

    expected = { 5=>360, 6=>420, 7=>480, 8=>{collapsed:3}, 11=>720, 12=>{collapsed:6}, 18=>1140 }
    now = [year,month,day+1,hour,4,23]
    gapped = gapper.fully_gapped(all_lights, now)
    actual = gapper.time_ticks(gapped)
    assert_equal expected, actual
  end

  private

  def hippo_id
    'a4r9YN'
  end

  def lion_id
    'TAWcLv'
  end

  def panda_id
    'Z38WR4'
  end

  def tiger_id
    'Ztxp3p'
  end

  def year
    YEAR
  end

  def month
    MONTH
  end

  def day
    DAY
  end

  def hour
    HOUR
  end

  def start
    Time.mktime(*[year,month, day,hour,30,0])
  end

  def max_seconds_uncollapsed
    30 * 60
  end

  def seconds_per_td
    20
  end

  def make_light(min, sec)
    LightStub.new(min, sec)
  end

  class LightStub
    def initialize(min, sec)
      @min = min
      @sec = sec
    end
    def time
      Time.mktime(YEAR,MONTH,DAY, HOUR,@min,@sec)
    end
  end

  YEAR = 2011
  MONTH = 5
  DAY = 18
  HOUR = 2

end
