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
            writeln(">>> Input '{row} {col}\\n'");
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

    const isPlayerBlack = !second; // second will be white
    const isAgentBlack = !isPlayerBlack;

    // mutable states
    auto env = reset(rows, cols);
    auto isPlayerTurn = !second;
    auto agent = AlphaBetaAgent(isAgentBlack);
    // auto agent = MinMaxAgent(isAgentBlack);

    while (true) {
        writeln(env);
        writefln!">>> turn: %s. stat: %s"(isPlayerTurn ? "player" : "agent", env.count);

        if (env.finished) {
            auto stat = env.count;
            writeln(">>> Finished ... ", stat);
            if (stat[Point.white] == stat[Point.black]) {
                writeln(">>> Even!");
            } else if (stat[Point.black] > stat[Point.white]) {
                writefln!">>> You %s!"(isPlayerBlack ? "win" : "lose");
            } else {
                writefln!">>> You %s!"(!isPlayerBlack ? "win" : "lose");
            }
            return;
        }

        if (isPlayerTurn) {
            if (env.pass(isPlayerBlack)) {
                writeln(">>> Skip player turn");
            } else {
                env = env.readAction(isPlayerBlack);
            }
        } else {
            if (env.pass(isAgentBlack)) {
                writeln(">>> Skip agent turn");
            } else {
                const action = agent.select(env, depth);
                env = env.put(agent.isBlack, action.row, action.col);
                writefln!"%d %d"(action.row, action.col);
            }
        }
        isPlayerTurn = !isPlayerTurn;
    }
}
