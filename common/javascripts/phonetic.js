// Wrapped so its table stays out of the global scope the apps' concatenated
// asset bundles share.
(() => {
'use strict';

const words = {
  '0' : 'zero',
  '1' : 'one',
  '2' : 'two',
  '3' : 'three',
  '4' : 'four',
  '5' : 'five',
  '6' : 'six',
  '7' : 'seven',
  '8' : 'eight',
  '9' : 'nine',

  'A' : 'ALPHA',
  'B' : 'BRAVO',
  'C' : 'CHARLIE',
  'D' : 'DELTA',
  'E' : 'ECHO',
  'F' : 'FOXTROT',
  'G' : 'GOLF',
  'H' : 'HOTEL',
  'I' : 'INDIA',
  'J' : 'JULIETT',
  'K' : 'KILO',
  'L' : 'LIMA',
  'M' : 'MIKE',
  'N' : 'NOVEMBER',
  'O' : 'OSCAR',
  'P' : 'PAPA',
  'Q' : 'QUEBEC',
  'R' : 'ROMEO',
  'S' : 'SIERRA',
  'T' : 'TANGO',
  'U' : 'UNIFORM',
  'V' : 'VICTOR',
  'W' : 'WHISKEY',
  'X' : 'XRAY',
  'Y' : 'YANKEE',
  'Z' : 'ZULU',

  'a' : 'alpha',
  'b' : 'bravo',
  'c' : 'charlie',
  'd' : 'delta',
  'e' : 'echo',
  'f' : 'foxtrot',
  'g' : 'golf',
  'h' : 'hotel',
  'i' : 'india',
  'j' : 'juliett',
  'k' : 'kilo',
  'l' : 'lima',
  'm' : 'mike',
  'n' : 'november',
  'o' : 'oscar',
  'p' : 'papa',
  'q' : 'quebec',
  'r' : 'romeo',
  's' : 'sierra',
  't' : 'tango',
  'u' : 'uniform',
  'v' : 'victor',
  'w' : 'whiskey',
  'x' : 'xray',
  'y' : 'yankee',
  'z' : 'zulu'
};

// Returns id spelled out as NATO phonetic words, one per character, eg
// 'Fx2' gives ['FOXTROT', 'xray', 'two']. Upper-case letters give upper-case
// words so the case of each character can be heard. Used by every app that
// shows an id someone may need to read out (creator's enter page, web's
// info dialog).
window.phoneticSpelling = (id) => Array.from(id).map((char) => words[char]);
})();
