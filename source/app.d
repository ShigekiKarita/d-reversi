import std.stdio;
import std.typecons;
import std.getopt;

import dreversi.env;
import dreversi.agent;

/// CMD opts
bool second = false;
size_t depth = 3;

void main(string[] args) {
    auto help = getopt(args,
        "second", &second,
        "depth", &depth);
    if (help.helpWanted) {
        defaultGetoptPrinter("D-REVERSI", help.options);
        return;
    }

    auto env = reset();
    bool isBlack = true;
    auto agent = AlphaBetaAgent(second);
    while (true) {
        writeln(env);
        writefln!"turn: %s. stat: %s"(isBlack ? "black(x)" : "white(o)", env.count);
        if (isBlack == agent.isBlack) {
            const action = agent.select(env, depth);
            env = env.put(agent.isBlack, action.row, action.col);
        }
        else {
            writeln(">>> input '{row} {col}\\n'");
            size_t r, c;
            readf!"%d %d\n"(r, c);
            Board board = env.put(isBlack, r, c);
            while (!board.valid) {
                writeln(">>> Error: invalid action. retry.");
                readf!"%d %d\n"(r, c);
                board = env.put(isBlack, r, c);
            }
            // update
            env = board;
        }

        if (env.pass(!isBlack)) {
            if (env.pass(isBlack)) {
                auto stat = env.count;
                writeln(">>> Finished ... ", stat);
                writeln(env);
                if (stat[Point.black] > stat[Point.white]) {
                    writeln("Black is winner!");
                } else if (stat[Point.black] > stat[Point.white]) {
                    writeln("White is winner!");
                } else {
                    writeln("Even!");
                }
                return;
            }
        } else {
            isBlack = !isBlack;
        }
    }
}
