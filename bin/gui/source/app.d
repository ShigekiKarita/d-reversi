import dlangui;

static assert(
    ENABLE_OPENGL,
    "this module using floating point drawing which is not supported in minimal config");

class MainWidget : VerticalLayout {
    this() {
        this(null);
    }
    this(string id) {
        import board : BoardWidget;

        super(id);
        this.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        addChild(new BoardWidget(8, 8));
    }

    override bool animating() { return true; }
}

/// Entry point for dlangui based application
mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args)
{
    import board : scaledByDPI;

    // portrait "mode" window
    Window window = Platform.instance.createWindow(
        "d-reversi", null,
        WindowFlag.Resizable | WindowFlag.ExpandSize,
        600.scaledByDPI, 600.scaledByDPI);
        window.mainWidget = new MainWidget();
        window.show();
        return Platform.instance.enterMessageLoop();
}
