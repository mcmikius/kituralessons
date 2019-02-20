
package com.scade.phoenix;

import android.content.Context;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;
import android.view.MotionEvent;
import android.widget.AbsoluteLayout;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;


// Display view for Phoenix content. Handles display resize
// and notifies Phoenix application
class DisplayView extends AbsoluteLayout {

    public DisplayView(PhoenixApplication app) {
        super(app);
        application = app;
    }

    // Adds Phoenix view into list of root views, and corresponding
    // android view into this display view. Called from display_android.cpp
    public void addPhoenixView(PhoenixView view) {
        super.addView(view.getView());
        rootViews.add(view);
    }


    // Removes Phoenix view from list of root views, and corresponding android
    // view from this display view. Called from display_android.cpp
    public void removePhoenixView(PhoenixView view) {
        super.removeView(view.getView());
        rootViews.remove(view);
    }


    // Dumps tree of views to string
    public String dumpViewsTree() {
        // building View -> PhoenixView map
        HashMap<View, PhoenixView> viewMap = new HashMap<View, PhoenixView>();

        Iterator<PhoenixView> it = rootViews.iterator();
        while (it.hasNext()) {
            addViewToMap(viewMap, it.next());
        }


        // dumping tree
        ByteArrayOutputStream bstr = new ByteArrayOutputStream();
        PrintStream str = new PrintStream(bstr);
        it = rootViews.iterator();
        while (it.hasNext()) {
            dumpView(1, str, viewMap, it.next().getView());
        }

        return bstr.toString();
    }


    // Called when view layout changed
    protected void onSizeChanged(int width, int height, int oldWidth, int oldHeight) {
        super.onSizeChanged(width, height, oldWidth, oldHeight);

        // notifying phoenix if display size changed
        if (width != 0 && height != 0 && (width != oldWidth || height != oldHeight)) {
            // we can't change layout in onSizeChanged, so we post call
            // to setDisplaySize in event queue
            final int cwidth = width;
            final int cheight = height;
            Handler handler = new Handler();
            handler.post(new Runnable() {
                @Override
                public void run() {
                    application.setDisplaySizeAndStartIfNotStarted(cwidth, cheight);
                }
            });
        }
    }


    // Adds view and its childs to map
    private void addViewToMap(HashMap<View, PhoenixView> map, PhoenixView view) {
        map.put(view.getView(), view);

        Iterator<PhoenixView> it = view.getChilds().iterator();
        while (it.hasNext()) {
            addViewToMap(map, it.next());
        }
    }


    // Dumps tree and its childs to stream
    private void dumpView(int offset, PrintStream str, HashMap<View, PhoenixView> map, View view) {
        PhoenixView pView = map.get(view);

        for (int i = 0; i < offset; i++) {
            str.print("  ");
        }

        // dumping phoenix view name
        if (pView != null) {
            str.print(pView.getDump() + " -> ");
        }

        // dumping android view class and address
        str.print(view.getClass().getName() + ":" + System.identityHashCode(view));

        // dumping android view frame
        str.print(" {" + view.getLeft() + ", " + view.getTop() + ", "
                  + view.getWidth() + ", " + view.getHeight() + "}");

        // dumping android view properties
        int vis = view.getVisibility();
        if (vis == View.INVISIBLE) {
            str.print(" invisible");
        } else if (vis == View.GONE) {
            str.print(" gone");
        }

        if (pView != null) {
            str.print(" np = ");
            long nParent = pView.getNativeParent();
            if (nParent == 0) {
                str.print("null");
            } else {
                str.print(pView.getNativeName(nParent));
            }
        }

        str.println();

        // dumping childs

        if (!(view instanceof ViewGroup))
            return;

        ViewGroup grp = (ViewGroup)view;
        for (int i = 0; i < grp.getChildCount(); i++) {
            dumpView(offset + 1, str, map, grp.getChildAt(i));
        }
    }


    private PhoenixApplication application;     // Reference to Phoenix application object

    // List of Phoenix views in display
    private LinkedList<PhoenixView> rootViews = new LinkedList<PhoenixView>();
}
