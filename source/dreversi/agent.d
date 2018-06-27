module dreversi.agent;

import dreversi.env;
import mir.ndslice;

struct Action {
    size_t row, col;
}

/// this is not efficient implementation
/// as it computes without memory of game tree
struct AlphaBetaAgent {
    bool isBlack;
    alias Score = double;

    Action select(in Board board, size_t depth = 3) {
        Score bestScore = -double.infinity;
        Action bestAction;
        foreach (r; 0 .. board.length!0) {
            foreach (c; 0 .. board.length!1) {
                auto next = board.put(this.isBlack, r, c);
                if (next.valid) {
                    immutable score = search(next, true, depth,
                                             -double.infinity,
                                             double.infinity);
                    if (score > bestScore) {
                        bestAction = Action(r, c);
                    }
                }
            }
        }
        return bestAction;
    }

    Score search(in Board board, bool isMine, // true if board is result of my action
                 size_t depth, Score alpha, Score beta // search stats
        ) {
        import std.algorithm : max, min;

        if (board.finished || depth == 0) {
            return cast(double) board.score(this.isBlack);
        }

        /// pass
        if ((isMine && board.pass(!this.isBlack)) || (!isMine && board.pass(this.isBlack))) {
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
