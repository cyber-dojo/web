'use strict';

const groupNeighbours = require('./group_neighbours');

describe('groupNeighbours', () => {

  it('returns {} when kata-id is not in a group', () => {
    const id = 'RNCzUr';
    const actual = groupNeighbours(id, {});
    expect(actual).toEqual(['','','']);
  });

  it('returns empty strings when kata-id is only member of group', () => {
    const id = 'w34rd5';
    expect(groupNeighbours(id, {
      '2': { 'id':id, 'events':[0,1,2] },
    })).toEqual(['',2,'']);
  });

  it('returns prev-index when one avatar is before', () => {
    const id = 'w34rd5';
    const prevId = 'TZ6f29';
    const joined = {
       '2':{ 'id':prevId, 'events':[0,1,2,3    ] },
      '12':{ 'id':id    , 'events':[0,1,2,3,4,5] },
    };
    expect(groupNeighbours(id,joined)).toEqual([2,12,'']);
    inactiveAvatarsAreIgnored(joined);
    expect(groupNeighbours(id,joined)).toEqual([2,12,'']);
  });

  it('returns next-index when one avatar is after', () => {
    const id = 'w34rd5';
    const nextId = 'TZ6f29';
    const joined = {
       '2': { 'id':id    , 'events':[0,1,2,3,4] },
      '27': { 'id':nextId, 'events':[0,1      ] },
    };
    expect(groupNeighbours(id,joined)).toEqual(['',2,27]);
    inactiveAvatarsAreIgnored(joined);
    expect(groupNeighbours(id,joined)).toEqual(['',2,27]);
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
    expect(groupNeighbours(id,joined)).toEqual([9,13,27]);
    inactiveAvatarsAreIgnored(joined);
    expect(groupNeighbours(id,joined)).toEqual([9,13,27]);
  });

  const inactiveAvatarsAreIgnored = (joined) => {
    joined[ '0'] = { 'id':'112233', 'events':[0] };
    joined[ '3'] = { 'id':'dSef54', 'events':[0] };
    joined['14'] = { 'id':'332255', 'events':[0] };
    joined['15'] = { 'id':'33xx55', 'events':[0] };
    joined['42'] = { 'id':'657543', 'events':[0] };
    joined['61'] = { 'id':'9QwS39', 'events':[0] };
  };

});
