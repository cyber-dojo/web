'use strict';

const pickFile = require('./pick_file');

describe('pickFile cascading rules...', () => {
  it('Rule 1: pick the current filename when it has at least one diff', () =>
  {
    const currentFilename = 'readme.txt';
    const diffs = [];
    diffs.push(cyber_dojo_sh(0));
    diffs.push(  changed(1, 'readme.txt',  3, 7));
    diffs.push(  changed(2, 'hiker.c'   , 13,27));
    const picked = pickFile(diffs, currentFilename);
    expect(picked.id).toEqual(1);
  });
  // otherwise
  it('Rule 2: pick the largest diff of non .txt file', () =>
  {
    const currentFilename = 'hiker.h';
    const diffs = [];
    diffs.push(cyber_dojo_sh(0));
    diffs.push(unchanged(1, 'hiker.h', 321));
    diffs.push(  changed(2, 'readme.txt', 34, 18));
    diffs.push(  changed(3, 'data.json',  4, 9));
    diffs.push(  changed(4, 'hiker.test.c',  3, 9));
    const picked = pickFile(diffs, currentFilename);
    expect(picked.id).toEqual(3);
  });

  // otherwise
  it('Rule 3: pick the largest diff of .txt file', () =>
  {
    const currentFilename = 'hiker.h';
    const diffs = [];
    diffs.push(cyber_dojo_sh(0));
    diffs.push(unchanged(1, 'hiker.h', 321));
    diffs.push(  changed(2, 'readme.txt', 4, 8));
    diffs.push(unchanged(3, 'data.json',  21));
    diffs.push(unchanged(4, 'hiker.test.c', 56));
    const picked = pickFile(diffs, currentFilename);
    expect(picked.id).toEqual(2);
  });

  // otherwise
  it('Rule 4: pick the largest 100% identical rename', () =>
  {
    const currentFilename = 'hiker.h';
    const diffs = [];
    diffs.push(cyber_dojo_sh(0));
    diffs.push(unchanged(1, 'hiker.h', 52));
    diffs.push(unchanged(2, 'hiker.c', 683));
    diffs.push(  renamed(3, 'makefile', 0, 0, 7));
    diffs.push(  renamed(4, 'Makefile', 0, 0, 8));
    const picked = pickFile(diffs, currentFilename);
    expect(picked.id).toEqual(4);
  });
  // otherwise
  it('Rule 5: pick the current filename', () =>
  {
    const currentFilename = 'hiker.h';
    const diffs = [];
    diffs.push(cyber_dojo_sh(0));
    diffs.push(unchanged(1, 'hiker.c', 34));
    diffs.push(unchanged(2, 'hiker.h', 44 ));
    diffs.push(unchanged(3, 'makefile', 66));
    diffs.push(unchanged(4, 'Makefile', 12));
    const picked = pickFile(diffs, currentFilename);
    expect(picked.id).toEqual(2);
  });
  // otherwise
  it('Rule 6: pick cyber-dojo.sh (which can never be deleted)', () =>
  {
    const currentFilename = 'hiker.h';
    const diffs = [];
    diffs.push(cyber_dojo_sh(0));
    diffs.push(unchanged(1, 'hiker.c', 23));
    diffs.push(unchanged(2, 'makefile', 55));
    diffs.push(unchanged(3, 'hiker.tests.c', 78));
    const picked = pickFile(diffs, currentFilename);
    expect(picked.id).toEqual(0);
  });
});

const cyber_dojo_sh = (id) => {
  return unchanged(id, 'cyber-dojo.sh');
};

const unchanged = (id, filename, sc) => {
  return diff('unchanged', id, filename, filename, 0, 0, sc);
};

const changed = (id, filename, ac, dc) => {
  return diff('changed', id, filename, filename, ac, dc, 6);
};

const created = (id, filename, ac) => {
  return diff('created', id, undefined, filename, ac, 0, 0);
};

const deleted = (id, filename, dc) => {
  return diff('deleted', id, filename, undefined, 0, dc, 0);
};

const renamed = (id, filename, ac, dc, sc) => {
  return diff('renamed', id, filename+'.old', filename, ac, dc, sc);
};

const diff = (type, id, oldFilename, newFilename, ac, dc, sc) => {
  return {
    id: id,
    type: type,
    old_filename: oldFilename,
    new_filename: newFilename,
    line_counts: { added:ac, deleted:dc, same:sc }
  };
};
