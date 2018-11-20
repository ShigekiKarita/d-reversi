import dlangui;

static assert(
    ENABLE_OPENGL,
    "this module using floating point drawing which is not supported in minimal config");

mixin APP_ENTRY_POINT;

/// Entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    import canvas : scaledByDPI;

    // portrait "mode" window
    Window window = Platform.instance.createWindow(
        "d-reversi", null,
        WindowFlag.Resizable, 600.scaledByDPI, 600.scaledByDPI);
    window.mainWidget = new BezierSamples();
    window.show();
    return Platform.instance.enterMessageLoop();
}

class BezierSamples : VerticalLayout {
    this() {
        this(null);
    }
    this(string id) {
        import canvas : Board;

        super(id);
        this.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        addChild(new Board(8, 8));
    }

    override bool animating() { return true; }
}
