import dreversi.agent;
import dreversi.env;

import std.stdio;
import std.meta;
import std.conv;
import std.exception;
// import std.datetime.benchmark;
import std.datetime.stopwatch;

void alphaBeta(size_t n, size_t s)() {
    auto agent = AlphaBetaAgent(true); // as a first player
    auto env = reset(n, n);
    auto action = agent.select(env, s);
    // 4x4 is known to result that second player won +8 points
    static if (n == 4 && s >= 11) enforce(action.score == -8.0);
}

void main() {
    auto result = std.datetime.stopwatch.benchmark!(alphaBeta!(4, 11), alphaBeta!(4, 5))(100);
    writeln(result);
}
