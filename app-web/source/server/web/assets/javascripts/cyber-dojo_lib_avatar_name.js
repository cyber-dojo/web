/*global cyberDojo*/
'use strict';
var cyberDojo = ((cd) => {

  const avatarNames = [
    "alligator", "antelope", "bat", "bear", "bee", "beetle", "buffalo",
    "butterfly", "cheetah", "crab", "deer", "dolphin", "eagle", "elephant",
    "flamingo", "fox", "frog", "gopher", "gorilla", "heron", "hippo",
    "hummingbird", "hyena", "jellyfish", "kangaroo", "kingfisher", "koala",
    "leopard", "lion", "lizard", "lobster", "moose", "mouse", "ostrich",
    "owl", "panda", "parrot", "peacock", "penguin", "porcupine", "puffin",
    "rabbit", "raccoon", "ray", "rhino", "salmon", "seal", "shark", "skunk",
    "snake", "spider", "squid", "squirrel", "starfish", "swan", "tiger",
    "toucan", "tuna", "turtle", "vulture", "walrus", "whale", "wolf", "zebra"
  ];

  cd.lib.avatarName = (n) => avatarNames[n];

  return cd;

})(cyberDojo || {});
