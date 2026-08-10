'use strict';

const { avatarsActive, avatarsNeighbours } = require('./avatars');

describe('avatarsActive/avatarsNeighbours', () => {

  it('returns {} when kata.id is not in a group', () => {
    const id = 'RNCzUr';
    const joined = {};
    expectNeighbours(id, joined, null, null, null);
    expectActive(joined);
  });

  it('returns nulls when kata.id is only member of group', () => {
    const id = 'w34rd5';
    const joined = {
      '2': { 'id':id, 'events':eventsWithLights(2) },
    };
    expectNeighbours(id, joined, null, 2, null);
    expectActive(joined, 2);
  });

  it('returns prev-index when one avatar is before', () => {
    const id = 'w34rd5';
    const prevId = 'TZ6f29';
    const joined = {
       '2':{ 'id':prevId, 'events':eventsWithLights(3) },
      '12':{ 'id':id    , 'events':eventsWithLights(5) },
    };
    expectNeighbours(id, joined, 2, 12, null);
    expectActive(joined, 2, 12);
  });

  it('returns next-index when one avatar is after', () => {
    const id = 'w34rd5';
    const nextId = 'TZ6f29';
    const joined = {
       '2': { 'id':id    , 'events':eventsWithLights(4) },
      '27': { 'id':nextId, 'events':eventsWithLights(1) },
    };
    expectNeighbours(id, joined, null, 2, 27);
    expectActive(joined, 2, 27);
  });

  it('returns prev-index and next-index for active groups', () => {
    const prevId = 'SyG9sT';
    const id = 'w34rd5';
    const nextId = 'TZ6f29';
    const joined = {
       '9': { 'id':prevId, 'events':eventsWithLights(4) },
      '13': { 'id':    id, 'events':eventsWithLights(1) },
      '27': { 'id':nextId, 'events':eventsWithLights(5) },
    };
    expectNeighbours(id, joined, 9, 13, 27);
    expectActive(joined, 9, 13, 27);
  });

  //- - - - - - - - - - - - - - - - - - - - - - - - - -

  // The events group_joined serves for an avatar: its creation event, followed
  // by one event per test run. Shaped like the real payload (the creation event
  // is the one carrying colour 'create') so the activity rule is exercised on
  // events, not on bare array positions.
  const eventsWithLights = (count) => {
    const created = { 'index':0, 'event':'created', 'colour':'create', 'major_index':0, 'minor_index':0 };
    const lights = Array.from({ length:count }, (ignored, i) => (
      { 'index':i + 1, 'colour':'green', 'major_index':i + 1, 'minor_index':0 }
    ));
    return [created].concat(lights);
  };

  const expectNeighbours = (id, joined, prev, index, next) => {
    const expected = [prev, index, next];
    expect(avatarsNeighbours(id, joined)).toEqual(expected);
    inactiveAvatarsAreIgnored(joined);
    expect(avatarsNeighbours(id, joined)).toEqual(expected);
  };

  const expectActive = (joined, ...indexes) => {
    expect(avatarsActive(joined)).toEqual(false64(indexes));
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - -

  // Avatars who joined but never ran a test, ie only their creation event.
  const inactiveAvatarsAreIgnored = (joined) => {
    joined[ '0'] = { 'id':'112233', 'events':eventsWithLights(0) };
    joined[ '3'] = { 'id':'dSef54', 'events':eventsWithLights(0) };
    joined['14'] = { 'id':'332255', 'events':eventsWithLights(0) };
    joined['15'] = { 'id':'33xx55', 'events':eventsWithLights(0) };
    joined['42'] = { 'id':'657543', 'events':eventsWithLights(0) };
    joined['61'] = { 'id':'9QwS39', 'events':eventsWithLights(0) };
  };

  const false64 = (indexes) => {
    const active = Array(64).fill(false);
    indexes.forEach(index => active[index] = true);
    return active;
  };
});
