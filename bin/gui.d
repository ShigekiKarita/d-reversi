import dlangui;

mixin APP_ENTRY_POINT;

enum : int {
    ACTION_FILE_OPEN = 5500,
        ACTION_FILE_SAVE,
        ACTION_FILE_CLOSE,
        ACTION_FILE_EXIT,
        }


class CanvasTab {
    CanvasWidget canvas;

    this(string name = "canvas") {
        this.canvas = new CanvasWidget(name);
        canvas.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        canvas.onDrawListener = delegate(CanvasWidget canvas, DrawBuf buf, Rect rc) {
            //Log.w("canvas.onDrawListener clipRect=" ~ to!string(buf.clipRect));
            buf.fill(0xFFFFFF);
            int x = rc.left;
            int y = rc.top;
            buf.fillRect(Rect(x+20, y+20, x+150, y+200), 0x80FF80);
            buf.fillRect(Rect(x+90, y+80, x+250, y+250), 0x80FF80FF);
            canvas.font.drawText(buf, x + 40, y + 50, "fillRect()"d, 0xC080C0);
            buf.drawFrame(Rect(x + 400, y + 30, x + 550, y + 150), 0x204060, Rect(2,3,4,5), 0x80704020);
            canvas.font.drawText(buf, x + 400, y + 5, "drawFrame()"d, 0x208020);
            canvas.font.drawText(buf, x + 300, y + 100, "drawPixel()"d, 0x000080);
            for (int i = 0; i < 80; i++)
                buf.drawPixel(x+300 + i * 4, y+140 + i * 3 % 100, 0xFF0000 + i * 2);
            canvas.font.drawText(buf, x + 300, y + 420, "drawLine()"d, 0x800020);
            for (int i = 0; i < 40; i+=3)
                buf.drawLine(Point(x+200 + i * 4, y+290), Point(x+150 + i * 7, y+420 + i * 2), 0x008000 + i * 5);
            // poly line test
            //Rect newClipRect = Rect(x + 110, y + 100, x + 350, y + 320);
            //buf.fillRect(newClipRect, 0xC08080FF);
            //Rect oldClip = buf.clipRect;
            //buf.clipRect = newClipRect;
            PointF[] poly = [vec2(x+130, y+150), vec2(x+240, y+80), vec2(x+170, y+170), vec2(x+380, y+270), vec2(x+220, y+400), vec2(x+130, y+330)];
            buf.polyLineF(poly, 18.0f, 0x80804020, true, 0x80FFFF00);
            //buf.fillTriangleF(vec2(x+230, y+50), vec2(x+400, y+250), vec2(x+130, y+200), 0xC0FF0000);
            //buf.fillTriangleF(vec2(x+230, y+250), vec2(x+200, y+350), vec2(x+80, y+200), 0xC000FF00);
            //buf.fillTriangleF(vec2(x+430, y+250), vec2(x+280, y+150), vec2(x+200, y+300), 0xC00000FF);
            //buf.fillTriangleF(vec2(x+80, y+150), vec2(x+280, y+250), vec2(x+80, y+200), 0xC0008080);
            //buf.clipRect = oldClip;
            canvas.font.drawText(buf, x + 190, y + 260, "polyLineF()"d, 0x603010);
            PointF[] poly2 = [vec2(x+430, y+250), vec2(x+540, y+180), vec2(x+470, y+270), vec2(x+580, y+300),
                              vec2(x+620, y+400), vec2(x+480, y+350), vec2(x+520, y+450), vec2(x+480, y+430)];
            buf.fillPolyF(poly2, 0x80203050);
            //buf.polyLineF(poly2, 2.0f, 0x80000000, true);
            canvas.font.drawText(buf, x + 500, y + 460, "fillPolyF()"d, 0x203050);

            buf.drawEllipseF(x+300, y+600, 200, 150, 3, 0x80008000, 0x804040FF);
            canvas.font.drawText(buf, x + 300, y + 600, "fillEllipseF()"d, 0x208050);

            buf.drawEllipseArcF(x+540, y+600, 150, 180, 45, 130, 3, 0x40008000, 0x804040FF);
            canvas.font.drawText(buf, x + 540, y + 580, "drawEllipseArcF()"d, 0x208050);
        };
    }

    auto widget() { return this.canvas; }
}

class ListTab {
    HorizontalLayout widget;

    this(string name = "list") {
        // two long lists
        // left one is list with widgets as items
        // right one is list with string list adapter
        this.widget = new HorizontalLayout(name);
        this.widget.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        ListWidget list = new ListWidget("list1", Orientation.Vertical);
        list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        StringListAdapter stringList = new StringListAdapter();
        WidgetListAdapter listAdapter = new WidgetListAdapter();
        listAdapter.add((new TextWidget()).text("This is a list of widgets"d).styleId("LIST_ITEM"));
        stringList.add("This is a list of strings from StringListAdapter"d);
        stringList.add("If you type with your keyboard,"d);
        stringList.add("then you can find the"d);
        stringList.add("item in the list"d);
        stringList.add("neat!"d);
        for (int i = 1; i < 1000; i++) {
            dstring label = "List item "d ~ to!dstring(i);
            listAdapter.add((new TextWidget()).text("Widget list - "d ~ label).styleId("LIST_ITEM"));
            stringList.add("Simple string - "d ~ label);
        }
        list.ownAdapter = listAdapter;
        listAdapter.resetItemState(0, State.Enabled);
        listAdapter.resetItemState(5, State.Enabled);
        listAdapter.resetItemState(7, State.Enabled);
        listAdapter.resetItemState(12, State.Enabled);
        assert(list.itemEnabled(5) == false);
        assert(list.itemEnabled(6) == true);
        list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        list.selectItem(0);

        this.widget.addChild(list);

        ListWidget list2 = new StringListWidget("list2");
        list2.ownAdapter = stringList;
        list2.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        list2.selectItem(0);
        this.widget.addChild(list2);

        VerticalLayout itemedit = new VerticalLayout();
        itemedit.addChild(new TextWidget(null, "New item text:"d));
        EditLine itemtext = new EditLine(null, "Text for new item"d);
        itemedit.addChild(itemtext);
        Button btn = new Button(null, "Add item"d);
        itemedit.addChild(btn);
        this.widget.addChild(itemedit);
        btn.click = delegate(Widget src)
            {
                stringList.add(itemtext.text);
                listAdapter.add((new TextWidget()).text(itemtext.text).styleId("LIST_ITEM"));
                return true;
            };
    }
}


/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    /////////////////////
    // Global Settings //
    /////////////////////

    // fonts with size less than specified value will not be antialiased
    FontManager.minAnitialiasedFontSize = 0; // 0 means always antialiased
    // turn on subpixel font rendering (ClearType)
    FontManager.subpixelRenderingMode = SubpixelRenderingMode.BGR; //SubpixelRenderingMode.None; //
    // select translation file - for english language
    Platform.instance.uiLanguage = "en";
    // load theme from file "theme_default.xml"
    Platform.instance.uiTheme = "theme_default";
    // Platform.instance.uiTheme = "theme_dark";

    // main window
    Window window = Platform.instance.createWindow(
        "d-reversi", null,
        WindowFlag.Resizable | WindowFlag.ExpandSize,
        800, 700);
    VerticalLayout contentLayout = new VerticalLayout();

    // menu bar
    MenuItem mainMenuItems = new MenuItem();
    MenuItem optionItem = new MenuItem(new Action(4, "option"d));
    MenuItem aboutItem = new MenuItem(new Action(41, "about"d));
    optionItem.add(aboutItem);
    mainMenuItems.add(optionItem);
    MainMenu mainMenu = new MainMenu(mainMenuItems);
    contentLayout.addChild(mainMenu);
    mainMenu.menuItemClick = delegate(MenuItem item) {
        Log.d("mainMenu.onMenuItemListener", item.label);
        const Action a = item.action;
        if (a) {
            return contentLayout.dispatchAction(a);
        }
        return false;
    };
    contentLayout.onAction = delegate(Widget source, const Action a) {
        if (a.id == ACTION_FILE_EXIT) {
            window.close();
            return true;
        } else if (a.id == 31) {
            window.minimizeWindow();
            return true;
        } else if (a.id == 32) {
            window.maximizeWindow();
            return true;
        } else if (a.id == 33) {
            window.restoreWindow();
            return true;
        } else if (a.id == 41) {
            window.showMessageBox(
                UIString.fromRaw("About"d),
                UIString.fromRaw("\nhttp://github.com/ShigekiKarita/d-reversi"d));
            return true;
        }
        return false;
    };

    // tab bar
    TabWidget tabs = new TabWidget("TABS");
    contentLayout.addChild(tabs);
    tabs.tabClose = delegate(string tabId) {
        tabs.removeTab(tabId);
    };
    tabs.tabChanged = delegate(string newTabId, string oldTabId) {
        window.windowCaption = tabs.tab(newTabId).text.value ~ " - d-reversi"d;
    };
    tabs.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

    auto canvas = new CanvasTab;
    tabs.addTab(canvas.widget, "canvas"d);

    auto list = new ListTab;
    tabs.addTab(list.widget, "log"d);


    // show window
    window.mainWidget = contentLayout;
    tabs.selectTab("canvas");
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
