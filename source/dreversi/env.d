module dreversi.env;

import mir.ndslice;

// states of reversi points
enum Point {
    empty = 0,
    black = 1,
    white = 2
}

/// text representaion of Point
enum pointString = [Point.empty: " ",
                    Point.black: "x",
                    Point.white: "o"];

/// board data of reversi
struct Board {
    Slice!(Contiguous, [2LU], Point*) data;
    bool valid = true;
    alias data this;

    @property @safe
    pure toString() const {
        import std.string;
        string ret = "   ";
        foreach (j; 0..this.length!1) {
            ret ~= format!"%3d"(j);
        }
        ret ~= "\n";
        foreach (i; 0..this.length!0) {
            ret ~= format!"%3d"(i);
            foreach (j; 0..this.length!1) {
                ret ~= format!"[%s]"(pointString[this.slice[i, j]]);
            }
            ret ~= "\n";
        }
        return ret;
    }
}

/// returns next step by the action
@safe pure put(in Board b, bool isBlack, size_t row, size_t col) {
    import std.algorithm : min;

    immutable p = isBlack ? Point.black : Point.white;
    if (!b.valid || row >= b.length!0 || col >= b.length!1 || b[row, col] != Point.empty) {
        return Board(b.data, false);
    }

    auto ret = b.data.slice; // dup
    // upper
    foreach_reverse (r; 0 .. row) {
        if (ret[r, col] == Point.empty) {
            break;
        }
        if (ret[r, col] == p) {
            ret[r..row, col] = p;
            break;
        }
    }
    // lower
    foreach (r; row+1 .. ret.length!0) {
        if (ret[r, col] == Point.empty) {
            break;
        }
        if (ret[r, col] == p) {
            ret[row+1..r, col] = p;
            break;
        }
    }
    // left
    foreach_reverse (c; 0 .. col) {
        if (ret[row, c] == Point.empty) {
            break;
        }
        if (ret[row, c] == p) {
            ret[row, c..col] = p;
            break;
        }
    }
    // right
    foreach (c; col+1..ret.length!1) {
        if (ret[row, c] == Point.empty) {
            break;
        }
        if (ret[row, c] == p) {
            ret[row, col+1..c] = p;
            break;
        }
    }
    // left-upper
    foreach (n; 1..min(row, col) + 1) {
        if (ret[row-n, col-n] == Point.empty) {
            break;
        }
        if (ret[row-n, col-n] == p) {
            foreach (m; 1 .. n+1) {
                ret[row-m, col-m] = p;
            }
            break;
        }
    }
    // left-lower
    foreach (n; 1..min(row, ret.length!1 - col - 1) + 1) {
        if (ret[row-n, col+n] == Point.empty) {
            break;
        }
        if (ret[row-n, col+n] == p) {
            foreach (m; 1 .. n+1) {
                ret[row-m, col+m] = p;
            }
            break;
        }
    }
    // right-upper
    foreach (n; 1..min(ret.length!0 - row - 1, col) + 1) {
        if (ret[row+n, col-n] == Point.empty) {
            break;
        }
        if (ret[row+n, col-n] == p) {
            foreach (m; 1 .. n+1) {
                ret[row+m, col-m] = p;
            }
            break;
        }
    }
    // right-lower
    foreach (n; 1..min(ret.length!0 - row - 1, ret.length!1 - col - 1) + 1) {
        if (ret[row+n, col+n] == Point.empty) {
            break;
        }
        if (ret[row+n, col+n] == p) {
            foreach (m; 1 .. n+1) {
                ret[row+m, col+m] = p;
            }
            break;
        }
    }
    // if nothing is changed, the action is invalid
    immutable valid = ret != b.data;
    ret[row, col] = p;
    return Board(ret, valid);
}

/// counts the number of empty/black/white positions
pure count(in Board b) {
    auto ret =  [Point.empty: 0, Point.black: 0, Point.white: 0];
    b.each!((p) { ++ret[p]; });
    return ret;
}

/// returns true if no next move for the color
pure pass(in Board b, bool isBlack) {
    import std.algorithm : any, map;
    auto stat = b.count;
    if (stat.byValue.map!"a == 0".any) return true;
    foreach (i; 0 .. b.length!0) {
        foreach (j; 0 .. b.length!1) {
            if (b.put(isBlack, i, j).valid) {
                return false;
            }
        }
    }
    return true;
}

/// test rules
unittest {
    immutable b0 = Board([Point.empty, Point.empty, Point.empty, Point.empty,
                          Point.empty, Point.black, Point.white, Point.empty,
                          Point.empty, Point.empty, Point.black, Point.empty,
                          Point.empty, Point.empty, Point.empty, Point.empty].sliced(4, 4));
    assert(!b0.put(true, 0, 4).valid); // out-of-bounds
    assert(!b0.put(true, 1, 1).valid); // non empty
    assert(!b0.put(true, 0, 0).valid); // begin
    assert(!b0.put(true, 3, 3).valid); // end
    assert(!b0.put(true, 0, 1).valid); // no reverse neighbor

    immutable b1 = b0.put(true, 1, 3);
    assert(b1 == [Point.empty, Point.empty, Point.empty, Point.empty,
                  Point.empty, Point.black, Point.black, Point.black,
                  Point.empty, Point.empty, Point.black, Point.empty,
                  Point.empty, Point.empty, Point.empty, Point.empty].sliced(4, 4));
    assert(b1.valid);
    assert(b1.pass(true));
    assert(b1.pass(false));

    immutable b5x5 = Board([Point.white, Point.empty, Point.white, Point.white, Point.white,
                            Point.empty, Point.black, Point.black, Point.black, Point.empty,
                            Point.black, Point.black, Point.empty, Point.black, Point.white,
                            Point.empty, Point.black, Point.black, Point.black, Point.empty,
                            Point.white, Point.empty, Point.white, Point.white, Point.white].sliced(5, 5));
    auto b5x5_ = b5x5.put(false, 2, 2);
    assert(b5x5_.toString ==
`     0  1  2  3  4
  0[o][ ][o][o][o]
  1[ ][o][o][o][ ]
  2[x][x][o][o][o]
  3[ ][o][o][o][ ]
  4[o][ ][o][o][o]
`);
    assert(b5x5_.count == [Point.empty: 6, Point.white: 17, Point.black: 2]);
    assert(!b5x5_.pass(true));
    assert(!b5x5_.pass(false));

    immutable b2 = Board([Point.empty, Point.empty, Point.empty, Point.empty,
                          Point.empty, Point.black, Point.black, Point.black,
                          Point.empty, Point.empty, Point.black, Point.empty,
                          Point.empty, Point.empty, Point.white, Point.empty].sliced(4, 4));
    assert(b2.pass(true));
    assert(!b2.pass(false));
}

/// returns initial board
@safe pure reset(size_t rows = 8, size_t cols = 8) {
    assert(rows % 2 == 0, "row size should be even");
    assert(cols % 2 == 0, "col size should be even");
    auto s = uninitSlice!Point(rows, cols);
    s[] = Point.empty;
    s[rows / 2, cols / 2] = Point.black;
    s[rows / 2, cols / 2 - 1] = Point.white;
    s[rows / 2 - 1, cols / 2] = Point.white;
    s[rows / 2 - 1, cols / 2 - 1] = Point.black;
    return Board(s);
}

pure finished(in Board board) {
    return board.pass(true) && board.pass(false);
}

pure score(in Board board, bool isBlack) {
    immutable stat = board.count;
    return stat[isBlack ? Point.black : Point.white] - stat[isBlack ? Point.white : Point.black];
}
