'use strict';

const { avatarsActive,avatarsNeighbours } = require('./avatars');

describe('avatarsActive/avatarsNeighbours', () => {

  it('returns {} when kata.id is not in a group', () => {
    const id = 'RNCzUr';
    const joined = {};
    expectNeighbours(id, joined, '','','');
    expectActive(joined);
  });

  it('returns empty strings when kata.id is only member of group', () => {
    const id = 'w34rd5';
    const joined = {
      '2': { 'id':id, 'events':[0,1,2] },
    };
    expectNeighbours(id, joined, '',2,'');
    expectActive(joined, 2);
  });

  it('returns prev-index when one avatar is before', () => {
    const id = 'w34rd5';
    const prevId = 'TZ6f29';
    const joined = {
       '2':{ 'id':prevId, 'events':[0,1,2,3    ] },
      '12':{ 'id':id    , 'events':[0,1,2,3,4,5] },
    };
    expectNeighbours(id, joined, 2,12,'');
    expectActive(joined, 2,12);
  });

  it('returns next-index when one avatar is after', () => {
    const id = 'w34rd5';
    const nextId = 'TZ6f29';
    const joined = {
       '2': { 'id':id    , 'events':[0,1,2,3,4] },
      '27': { 'id':nextId, 'events':[0,1      ] },
    };
    expectNeighbours(id,joined, '',2,27);
    expectActive(joined, 2,27);
  });

  it('returns prev-index and next-index for active groups', () => {
    const prevId = 'SyG9sT';
    const id = 'w34rd5';
    const nextId = 'TZ6f29';
    const joined = {
       '9': { 'id':prevId, 'events':[0,1,2,3,4  ] },
      '13': { 'id':    id, 'events':[0,1        ] },
      '27': { 'id':nextId, 'events':[0,1,2,3,4,5] },
    };
    expectNeighbours(id,joined, 9,13,27);
    expectActive(joined, 9,13,27);
  });

  //- - - - - - - - - - - - - - - - - - - - - - - - - -

  const expectNeighbours = (id,joined,prev,index,next) => {
    const expected = [prev,index,next];
    expect(avatarsNeighbours(id,joined)).toEqual(expected);
    inactiveAvatarsAreIgnored(joined);
    expect(avatarsNeighbours(id,joined)).toEqual(expected);
  };

  const expectActive = (joined,...indexes) => {
    expect(avatarsActive(joined)).toEqual(false64(indexes));
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - -

  const inactiveAvatarsAreIgnored = (joined) => {
    joined[ '0'] = { 'id':'112233', 'events':[0] };
    joined[ '3'] = { 'id':'dSef54', 'events':[0] };
    joined['14'] = { 'id':'332255', 'events':[0] };
    joined['15'] = { 'id':'33xx55', 'events':[0] };
    joined['42'] = { 'id':'657543', 'events':[0] };
    joined['61'] = { 'id':'9QwS39', 'events':[0] };
  };

  const false64 = (indexes) => {
    const active = Array(64).fill(false);
    indexes.forEach(index => active[index] = true);
    return active;
  };
});
