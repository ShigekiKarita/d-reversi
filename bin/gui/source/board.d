module board;

import core.atomic : atomicStore;
import std.concurrency : spawn, thisTid, Tid, send, receive;

import dlangui;

import dreversi.agent;
import dreversi.env : Board, reset, P = Point, put, pass;

// helper for scaling relative to average 96dpi FullHD, IDK but maybe a bad idea after all
T scaledByDPI(T)(T val)
{
    return val *= (SCREEN_DPI() / cast(T)96);
}

struct CancelMessage {}
struct CancelAckMessage {}

void worker(Tid parent, bool isBlack, int depth, shared(bool)* _agentDone)
{
    auto agent = AlphaBetaAgent(isBlack, true);
    bool canceled = false;
    Log.d("agent worker started at ", thisTid);

    while (!canceled)
    {
        receive(
            (immutable Board env)
            {
                Log.d("agent received board");
                if (pass(env, agent.isBlack)) {
                    Log.d("skip agent turn");
                    send(parent, env);
                } else {
                    const action = agent.select(env, depth);
                    immutable next = put(env, agent.isBlack, action.row, action.col);
                    Log.d("agent move: ", [action.row, action.col]);
                    send(parent, next);
                    Log.d(next);
                }
                atomicStore(*_agentDone, true);
            },
            (CancelMessage m)
            {
                send(parent, CancelAckMessage());
                canceled = true;
            }
            );
    }
}

class BoardWidget : CanvasWidget
{
    const int rows, cols;
    const int margin;
    const float lineWidth;
    const bool isBlack;

    Board board;
    Tid agentTid;
    bool _isPlayerTurn;

    shared bool _agentDone = false;

    this(int rows, int cols, int depth, bool playFirst = true)
    {
        super("board-widget");

        this.rows = rows;
        this.cols = cols;
        this._isPlayerTurn = playFirst;
        this.isBlack = playFirst;

        this.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        this.margin = 100.scaledByDPI;
        this.lineWidth = 3.scaledByDPI;
        super.minHeight = 400.scaledByDPI;
        this.clickable(true);
        this.board = reset(rows, cols);
        this.agentTid = spawn(&worker, thisTid, !this.isBlack, depth, &this._agentDone);

        this.mouseEvent = delegate bool(Widget w1, MouseEvent e)
            {
                if (e.lbutton.isDown)
                {
                    const rc = xy2rc(e.x, e.y);
                    const move = rc.int2;
                    Log.d("clicked at ", move);
                    if (this._isPlayerTurn)
                    {
                        if (valid(rc))
                        {
                            immutable next = board.put(this.isBlack, move[1], move[0]);
                            if (next.valid)
                            {
                                this.board = next;
                                this._agentDone.atomicStore(false);
                                this._isPlayerTurn = false;
                                send(this.agentTid, next);
                            }
                        }
                    }
                }
                return true;
            };
    }

    ~this()
    {
        import std.concurrency : receiveOnly;

        Log.d("waiting for agent thread closed");
        send(this.agentTid, CancelMessage());
        // receiveOnly!CancelAckMessage;
    }

    struct RC
    {
        float row, col;

        int[2] int2() const { return [cast(int) row, cast(int) col]; }
    }

    auto valid(RC rc)
    {
        return 0 <= rc.row && rc.row < this.rows && 0 <= rc.col && rc.col < this.cols;
    }

    auto xy2rc(int x, int y)
    {
        const rc = shrinkToBoard(this.pos);
        const width = rc.right - rc.left;
        const height = rc.bottom - rc.top;
        const sx = width / this.cols;
        const sy = height / this.rows;
        return RC(cast(float) (x - rc.left) / sx,
                  cast(float) (y - rc.top) / sy);
    }

    override protected void measuredContent(
        int parentWidth, int parentHeight,
        int contentWidth, int contentHeight)
    {
        import std.algorithm.comparison;
        _measuredHeight = max(minHeight, min(contentHeight, contentWidth));
        _measuredWidth = _measuredHeight; // max(minHeight, contentWidth);
    }

    protected void drawText(DrawBuf buf, Rect rc, dstring text)
    {
        FontRef font = font();
        Point sz = font.textSize(text);
        applyAlign(rc, sz, Align.HCenter, Align.Bottom );
        font.drawText(buf, rc.left, rc.top, text, textColor, 4, 0, textFlags);
    }

    // shrink to square with margin
    Rect shrinkToBoard(Rect rc)
    {
        const _width = rc.right - rc.left;
        const _height = rc.bottom - rc.top;
        if (_width > _height)
        {
            rc.shrink((_width - height) / 2, 0);
        }
        else
        {
            rc.shrink(0, (_height - _width) / 2);
        }
        rc.shrink(this.margin, this.margin);
        return rc;
    }

    override void doDraw(DrawBuf buf, Rect _rc)
    {
        if (!this._isPlayerTurn && this._agentDone)
    
        {
            receive(
                (const Board b) {
                    this.board = b;
                    this._isPlayerTurn = true;
                });
        }

        import std.conv : to;

        const rc = shrinkToBoard(_rc);

        // draw background
        buf.fillRect(rc, 0x119911);

        // draw row/col numbered lines
        const width = rc.right - rc.left;
        const height = rc.bottom - rc.top;
        const sx = cast(float) width / this.cols;
        const sy = cast(float) height / this.rows;
        const fy = cast(int) (sy * 0.4);
        foreach (r; 0 .. this.rows + 1)
        {
            const y = rc.top + sy * r + this.lineWidth / 2;
            if (r < this.rows)
            {
                const fontRc = Rect(rc.left - fy, cast(int) y + fy,
                                    rc.left, cast(int) y + fy * 2);
                this.drawText(buf, fontRc, r.to!dstring);
            }
            buf.drawLineF(PointF(rc.left, y),
                          PointF(rc.right, y),
                          lineWidth,
                          Color.black);
        }
        foreach (c; 0 .. this.cols + 1)
        {
            const x = cast(float) rc.left + sx * c + this.lineWidth / 2.0;
            if (c < this.cols)
            {
                const fontRc = Rect(cast(int) x + fy, rc.top + fy,
                                    cast(int) x + fy * 2, rc.top);
                this.drawText(buf, fontRc, c.to!dstring);
            }
            buf.drawLineF(PointF(x, rc.top),
                          PointF(x, rc.bottom),
                          lineWidth,
                          Color.black);
        }

        // draw circles
        assert(!board.empty, "Error: board is not initialized");
        const rmargin = 5.scaledByDPI;
        const rx = sx / 2 - rmargin;
        const ry = sy / 2 - rmargin;
        foreach (r; 0 .. this.rows)
        {
            foreach (c; 0 .. this.cols)
            {
                auto p = this.board[r, c];
                if (p != P.empty)
                {
                    buf.drawEllipseF(rc.left + c * sx + rx + rmargin,
                                     rc.top + r * sy + ry + rmargin,
                                     rx, ry, 0, Color.black,
                                     p == P.black ? Color.black : Color.white);
                }
            }
        }
    }
}
