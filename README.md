# D-Reversi

[![Build Status](https://travis-ci.org/ShigekiKarita/d-reversi.svg?branch=master)](https://travis-ci.org/ShigekiKarita/d-reversi)
[![codecov](https://codecov.io/gh/ShigekiKarita/d-reversi/branch/master/graph/badge.svg)](https://codecov.io/gh/ShigekiKarita/d-reversi)
[![Dub version](https://img.shields.io/dub/v/d-reversi.svg)](https://code.dlang.org/packages/d-reversi)

D language implementaion of Reversi

You can play it by `$ dub`

```
$ dub
Running ./d-reversi 
     0  1  2  3  4  5  6  7
  0[ ][ ][ ][ ][ ][ ][ ][ ]
  1[ ][ ][ ][ ][ ][ ][ ][ ]
  2[ ][ ][ ][ ][ ][ ][ ][ ]
  3[ ][ ][ ][x][o][ ][ ][ ]
  4[ ][ ][ ][o][x][ ][ ][ ]
  5[ ][ ][ ][ ][ ][ ][ ][ ]
  6[ ][ ][ ][ ][ ][ ][ ][ ]
  7[ ][ ][ ][ ][ ][ ][ ][ ]

turn: black(x). stat: [empty:60, white:2, black:2]
>>> input '{row} {col}\n'
1 1
>>> Error: invalid action. retry.
4 2
     0  1  2  3  4  5  6  7
  0[ ][ ][ ][ ][ ][ ][ ][ ]
  1[ ][ ][ ][ ][ ][ ][ ][ ]
  2[ ][ ][ ][ ][ ][ ][ ][ ]
  3[ ][ ][ ][x][o][ ][ ][ ]
  4[ ][ ][x][x][x][ ][ ][ ]
  5[ ][ ][ ][ ][ ][ ][ ][ ]
  6[ ][ ][ ][ ][ ][ ][ ][ ]
  7[ ][ ][ ][ ][ ][ ][ ][ ]
turn: white(o). stat: [empty:59, white:1, black:4]
>>> input '{row} {col}\n'
^C
```
