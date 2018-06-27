module dreversi.agent;

import dreversi.env;
import std.math;
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

    Action select(in Board board, size_t depth = 3) {
        Action best;
        foreach (r; 0 .. board.length!0) {
            foreach (c; 0 .. board.length!1) {
                auto next = board.put(this.isBlack, r, c);
                if (next.valid) {
                    immutable score = search(next, false, depth);
                    // writefln!"(%d, %d, %f)"(r, c, score);
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
    alias Score = double;

    Action select(in Board board, size_t depth = 3) {
        Action best;
        foreach (r; 0 .. board.length!0) {
            foreach (c; 0 .. board.length!1) {
                auto next = board.put(this.isBlack, r, c);
                if (next.valid) {
                    immutable score = search(next, false, depth,
                                             -double.infinity,
                                             double.infinity);
                    // writefln!"(%d, %d, %f)"(r, c, score);
                    if (best.score.isNaN || score > best.score) {
                        best = Action(r, c, score);
                    }
                }
            }
        }
        return best;
    }

    Score search(in Board board, bool isMine, // true if board is result of my action
                 size_t depth, Score alpha, Score beta // search stats
        ) {
        import std.algorithm : max, min;

        if (board.finished || depth == 0) {
            return cast(double) board.score(this.isBlack);
        }

        /// pass
        if ((isMine && board.pass(this.isBlack)) || (!isMine && board.pass(!this.isBlack))) {
            return search(board, !isMine, depth-1, alpha, beta);
        }

        foreach (r; 0 .. board.length!0) {
            foreach (c; 0 .. board.length!1) {
                immutable color = isMine ? this.isBlack : !this.isBlack; // XOR
                immutable b = board.put(color, r, c);
                if (b.valid) {
                    const score = search(b, !isMine, depth - 1, alpha, beta); // recur
                    if (isMine) {
                        alpha = max(alpha, score);
                    } else {
                        beta = min(beta, score);
                    }
                    if (alpha >= beta) { // cut
                        return isMine ? alpha : beta;
                    }
                }
            }
        }
        return isMine ? alpha : beta;
    }
}

unittest {
    auto env = reset(4, 4); // 4x4 is known to result that second player won +8 points
    auto agent = AlphaBetaAgent(true); // as a first player
    auto action = agent.select(env, 11);
    assert(action.score == -8.0);
}
