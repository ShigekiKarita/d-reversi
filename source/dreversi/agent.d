module dreversi.agent;

import dreversi.env;

import std.math;
import std.stdio;

import mir.ndslice;

alias Score = double;

struct Action {
    size_t row = 0, col = 0;
    Score score = double.nan;
}

/// this is not efficient implementation
/// as it computes without memory of game tree
struct MinMaxAgent {
    bool isBlack;
    bool verbose = false;

    Action select(in Board board, size_t depth = 3) {
        Action best;
        foreach (r; 0 .. board.length!0) {
            foreach (c; 0 .. board.length!1) {
                auto next = board.put(this.isBlack, r, c);
                if (next.valid) {
                    immutable score = search(next, false, depth);
                    if (this.verbose) writefln!"Action(%d, %d, %f)"(r, c, score);
                    if (best.score.isNaN || score > best.score) {
                        best = Action(r, c, score);
                    }
                }
            }
        }
        return best;
    }

    Score search(in Board board, bool isMine, // true if board is result of my action
                 size_t depth
        ) {
        import std.algorithm : max, min;

        if (board.finished || depth == 0) {
            return cast(double) board.score(this.isBlack);
        }

        /// pass
        if ((isMine && board.pass(this.isBlack)) || (!isMine && board.pass(!this.isBlack))) {
            return search(board, !isMine, depth-1);
        }

        Score alpha = -double.infinity;
        Score beta = double.infinity;
        foreach (r; 0 .. board.length!0) {
            foreach (c; 0 .. board.length!1) {
                immutable color = isMine ? this.isBlack : !this.isBlack; // XOR
                immutable b = board.put(color, r, c);
                if (b.valid) {
                    const score = search(b, !isMine, depth - 1); // recur
                    if (isMine) {
                        alpha = max(alpha, score);
                    } else {
                        beta = min(beta, score);
                    }
                }
            }
        }
        return isMine ? alpha : beta;
    }
}


unittest {
    auto env = reset(4, 4); // 4x4 is known to result that second player won +8 points
    auto agent = MinMaxAgent(true); // as a first player
    auto action = agent.select(env, 11);
    assert(action.score == -8.0);
}

/// this is not efficient implementation
/// as it computes without memory of game tree
struct AlphaBetaAgent {
    bool isBlack;
    bool verbose = false;
    double[Board] scoreCache;

    @safe
    Action select(in Board board, size_t depth = 3) {
        Action best;
        foreach (r; 0 .. board.length!0) {
            foreach (c; 0 .. board.length!1) {
                immutable next = board.put(this.isBlack, r, c);
                if (next.valid) {
                    /*
                    if (board !in this.scoreCache) {
                        this.scoreCache[board] = search(next, depth, -double.infinity, double.infinity);
                    }
                    immutable score = this.scoreCache[board];
                    */
                    immutable score = search(next, depth, -double.infinity, double.infinity);
                    if (this.verbose) {
                        writefln!"Action(%d, %d, %f)"(r, c, score);
                    }
                    if (best.score.isNaN || score > best.score) {
                        best = Action(r, c, score);
                    }
                }
            }
        }
        return best;
    }

    pure @safe
    Score search(bool isMine = false)(in Board board, size_t depth, Score alpha, Score beta) {
        // import std.algorithm : max, min;
        import mir.math.common : fmax, fmin;

        if (board.finished || depth == 0) {
            return cast(double) board.score(this.isBlack);
        }

        /// pass
        static if (isMine) {
            immutable color = this.isBlack;
        } else {
            immutable color = !this.isBlack;
        }
        if (board.pass(color)) {
            return search!(!isMine)(board, depth-1, alpha, beta);
        }

        foreach (r; 0 .. board.length!0) {
            foreach (c; 0 .. board.length!1) {
                immutable b = board.put(color, r, c);
                if (b.valid) {
                    immutable score = search!(!isMine)(b, depth - 1, alpha, beta); // recur
                    static if (isMine) {
                        alpha = fmax(alpha, score);
                    } else {
                        beta = fmin(beta, score);
                    }
                    if (alpha >= beta) { // cut
                        return isMine ? alpha : beta;
                    }
                }
            }
        }
        static if (isMine) {
            return alpha;
        } else {
            return beta;
        }
    }
}

unittest {
    auto env0 = reset(4, 4); // 4x4 is known to result that second player won +8 points
    auto agentB = AlphaBetaAgent(true); // as a first player
    auto agentW = AlphaBetaAgent(false); // as a first player

    auto action0 = agentB.select(env0, 11);
    assert(action0.score == -8.0);
    auto env1 = env0.put(agentB.isBlack, action0.row, action0.col);

    auto action1 = agentW.select(env1, 11);
    assert(action1.score == 8.0);
    auto env2 = env1.put(agentW.isBlack, action1.row, action1.col);

    auto action2 = agentB.select(env2, 11);
    assert(action2.score == -8.0);
    auto env3 = env2.put(agentB.isBlack, action2.row, action2.col);
}
