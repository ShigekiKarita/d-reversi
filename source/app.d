import std.stdio;
import std.typecons;
import std.getopt;
import std.conv;
import std.format;

import dreversi.env;
import dreversi.agent;

/// CMD opts
bool second = false;
size_t depth = 3;
size_t rows = 8;
size_t cols = 8;

auto readAction(in Board env, bool isBlack) {
    size_t r, c;
    Board board;
    while (true) {
        try {
            writeln(">>> input '{row} {col}\\n'");
            formattedRead!"%d %d\n"(readln(), r, c); // readf is buggy
            board = env.put(isBlack, r, c);
            if (board.valid) {
                break;
            } else {
                writeln(">>> Error: invalid action. retry.");
            }
        } catch (Exception e) {
            writeln(">>> Error: invalid input. Retry.");
            continue;
        }
    }
    return board;
}

void main(string[] args) {
    auto help = getopt(
        args,
        "second", &second,
        "rows", &rows,
        "cols", &cols,
        "depth", &depth);
    if (help.helpWanted) {
        defaultGetoptPrinter("D-REVERSI", help.options);
        return;
    }

    // mutable states
    auto env = reset(rows, cols);
    bool isBlackTurn = true;
    auto agent = AlphaBetaAgent(second);

    while (true) {
        writeln(env);
        writefln!"turn: %s. stat: %s"(isBlackTurn ? "black(x)" : "white(o)", env.count);
        if (env.pass(isBlackTurn)) {
            writeln(isBlackTurn ? "black" : "white", " is pass");
            // isBlackTurn = !isBlackTurn;
            if (env.pass(!isBlackTurn)) {
                auto stat = env.count;
                writeln(">>> Finished ... ", stat);
                writeln(env);
                if (stat[Point.black] > stat[Point.white]) {
                    writeln("Black is winner!");
                } else if (stat[Point.white] > stat[Point.black]) {
                    writeln("White is winner!");
                } else {
                    writeln("Even!");
                }
                return;
            }
            isBlackTurn = !isBlackTurn;
        }

        if (isBlackTurn == agent.isBlack) {
            const action = agent.select(env, depth);
            env = env.put(agent.isBlack, action.row, action.col);
        } else {
            env = env.readAction(isBlackTurn);
        }

        isBlackTurn = !isBlackTurn;

    }
}
