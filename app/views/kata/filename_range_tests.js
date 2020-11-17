'use strict';

const filenameRange = require('./filename_range');

describe('filenameRange', () => {
  it('picks the changeable part of the filename', () => {

    const filenames = {
      'wibble/test/hiker_spec.rb': [12,17],
      'test/hiker_test.exs': [5,10],
      'test_hiker.sh': [5,10],
      'tests_hiker.sh': [6,11],
      'test_hiker.coffee': [5,10],
      'hikerTest.chpl': [0,5],
      'hiker.tests.c': [0,5],
      'hiker_tests.c': [0,5],
      'hikerTests.cpp': [0,5],
      'hiker_test.c': [0,5],
      'hiker_Test.c': [0,5],
      'hiker_spec.rb': [0,5],
      'hikerSpec.feature': [0,5],
      'hiker.feature': [0,5],
      'hiker-test.js': [0,5],
      'src/Hiker_spec.re': [4,9],
      'hiker_steps.rb': [0,5],
      'hiker': [0,5],      
    };
    for(const [f,pos] of Object.entries(filenames)) {
      expect(f.substring(...pos).toLowerCase()).toEqual('hiker');
      expect(filenameRange(f)).toEqual(pos);
    }
  });
});
