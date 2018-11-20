module canvas;

import dlangui;


// helper for scaling relative to average 96dpi FullHD, IDK but maybe a bad idea after all
T scaledByDPI(T)(T val)
{
    return val *= (SCREEN_DPI() / cast(T)96);
}

class Board : CanvasWidget
{
    const int rows, cols;
    const int margin;
    const float lineWidth;

    this(int rows, int cols)
    {
        super("board");
        this.rows = rows;
        this.cols = cols;
        this.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        minHeight = 400.scaledByDPI;
        this.margin = 100.scaledByDPI;
        this.lineWidth = 3.scaledByDPI;
        this.clickable(true);

        this.mouseEvent = delegate bool(Widget w1, MouseEvent e)
            {
                if (e.lbutton.isDown)
                {
                    auto rc = xy2rc(e.x, e.y);
                    if (valid(rc))
                        Log.d("clicked", [e.x, e.y], rc.int2);
                }
                return true;
            };
    }

    struct RC
    {
        float row, col;

        int[2] int2() { return [cast(int) row, cast(int) col]; }
    }

    auto valid(RC rc) { return 0 <= rc.row && rc.row < this.rows && 0 <= rc.col && rc.col < this.cols; }

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
        import std.conv : to;

        const rc = shrinkToBoard(_rc);

        // draw background
        buf.fillRect(rc, 0x119911);

        // draw row/col numbered lines
        const width = rc.right - rc.left;
        const height = rc.bottom - rc.top;
        const sx = width / this.cols;
        const sy = height / this.rows;
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

        // auto cx = (rc.right + rc.left) / 2.0;
        // auto cy = (rc.top + rc.bottom) / 2.0;
        // auto rx = (rc.right - rc.left) / 2.0;
        // auto ry = (rc.top - rc.bottom) / 2.0;
        // buf.drawEllipseF(cx, cy, rx, ry, 0, Color.black, Color.black);
    }
}
