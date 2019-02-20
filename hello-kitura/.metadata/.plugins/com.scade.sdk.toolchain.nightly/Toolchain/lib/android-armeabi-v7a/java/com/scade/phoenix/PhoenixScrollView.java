package com.scade.phoenix;

import android.content.Context;
import android.graphics.Rect;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewParent;
import android.widget.AbsoluteLayout;
import android.widget.FrameLayout;
import android.widget.ScrollView;
import android.widget.HorizontalScrollView;


public class PhoenixScrollView extends PhoenixView {

    public interface ScrollImpl {
        // Enables/disables handling touch events in parent scrolls
        void disableParentScrolls(boolean disable);

        boolean isInterceptTouchEvent();
    }


    private class VerticalScrollImpl extends ScrollView implements ScrollImpl {

        public VerticalScrollImpl(PhoenixScrollView phoenixScrollView, Context context) {
            super(context);
            this.phoenixScrollView = phoenixScrollView;
        }

      @Override
      protected void onOverScrolled (int scrollX, int scrollY, boolean clampedX, boolean clampedY) {
        if (phoenixScrollView.hasOnScrollListener()) {
          onScroll(phoenixScrollView.getNativeView(), scrollX, scrollY);
        }

        super.onOverScrolled(scrollX, scrollY, clampedX, clampedY);
      }

        @Override
        public void onAnimationEnd() {
            super.onAnimationEnd();
            onPhoenixAnimationEnd();
        }

        @Override
        public boolean onInterceptTouchEvent(MotionEvent ev) {
          m_isInterceptTouchEvent = super.onInterceptTouchEvent(ev);

          //android.util.Log.i("Phoenix", "onInterceptTouchEvent: " + m_isInterceptTouchEvent);

          return m_isInterceptTouchEvent;
        }

        // Called on touch event
        @Override
        public boolean onTouchEvent(MotionEvent event) {
          boolean res = false;

          if (event.getActionMasked() == MotionEvent.ACTION_DOWN) {
            m_isFailureTouchState = false;
          }

          if (!m_isFailureTouchState) {
            res = handleTouchEvent(event);
            m_isFailureTouchState = !res;
          }

          //android.util.Log.i("Phoenix", "------- ScrollView: " + m_isFailureTouchState + " " + res);

          return res || super.onTouchEvent(event);
        }

        // Enables/disables handling touch events in parent scrolls
        @Override
        public void disableParentScrolls(boolean disable) {
            for (ViewParent view = getParent(); view != null; view = view.getParent()) {
                if (!(view instanceof ScrollView))
                    continue;

                view.requestDisallowInterceptTouchEvent(disable);
            }
        }

        @Override
        public boolean isInterceptTouchEvent() {
          return m_isInterceptTouchEvent;
        }

      private final PhoenixScrollView phoenixScrollView;
      private boolean m_isInterceptTouchEvent = false;
      private boolean m_isFailureTouchState = false;
    }

    private class HorizontalScrollImpl extends HorizontalScrollView implements ScrollImpl {

        public HorizontalScrollImpl(PhoenixScrollView phoenixScrollView, Context context) {
            super(context);
            this.phoenixScrollView = phoenixScrollView;
        }

        @Override
        public void onAnimationEnd() {
            super.onAnimationEnd();
            onPhoenixAnimationEnd();
        }


      @Override
      protected void onOverScrolled (int scrollX, int scrollY, boolean clampedX, boolean clampedY) {
        if (phoenixScrollView.isPaging()) {
          int page = (int)Math.ceil(scrollX / getLayoutParams().width);
          if (page >= 0 && page != currentPage) {
            onPageChanged(phoenixScrollView.getNativeView(), page, currentPage);
            currentPage = page;
          }
        }

        if (phoenixScrollView.hasOnScrollListener()) {
          onScroll(phoenixScrollView.getNativeView(), scrollX, scrollY);
        }

        super.onOverScrolled(scrollX, scrollY, clampedX, clampedY);
      }

      @Override
      public boolean onInterceptTouchEvent(MotionEvent ev) {
        m_isInterceptTouchEvent = super.onInterceptTouchEvent(ev);

        //android.util.Log.i("Phoenix", "onInterceptTouchEvent: " + m_isInterceptTouchEvent);

        return m_isInterceptTouchEvent;
      }

      // Called on touch event
      @Override
      public boolean onTouchEvent(MotionEvent event) {

        if (event.getActionMasked() == MotionEvent.ACTION_DOWN) {
          // disable intercepting touch events in parent scroll bars
          disableParentScrolls(true);
        }

        if (event.getActionMasked() == MotionEvent.ACTION_UP ||
            event.getActionMasked() == MotionEvent.ACTION_CANCEL) {
          // enable intercepting touch events in parent scroll bars
          disableParentScrolls(false);
        }

        boolean res = false;

        if (event.getActionMasked() == MotionEvent.ACTION_DOWN) {
          m_isFailureTouchState = false;
        }

        if (!m_isFailureTouchState) {
          res = handleTouchEvent(event);
          m_isFailureTouchState = !res;
        }

        return res || super.onTouchEvent(event);
      }

      

      // Enables/disables handling touch events in parent scrolls
      @Override
      public void disableParentScrolls(boolean disable) {
        for (ViewParent view = getParent(); view != null; view = view.getParent()) {
          if (!(view instanceof HorizontalScrollView))
            continue;

          view.requestDisallowInterceptTouchEvent(disable);
        }
      }

      @Override
      public boolean isInterceptTouchEvent() {
        return m_isInterceptTouchEvent;
      }

      private int currentPage = 0;
      private final PhoenixScrollView phoenixScrollView;
      private boolean m_isInterceptTouchEvent = false;
      private boolean m_isFailureTouchState = false;
    }


    private FrameLayout impl;

    public PhoenixScrollView(PhoenixApplication a,
                             long nView,
                             boolean vertical,
                             boolean horizontal,
                             boolean paging) {

        super(a, nView);
        this.paging = paging;

        if (vertical) {
            impl = new VerticalScrollImpl(this, app);
        } else {
            impl = new HorizontalScrollImpl(this, app);
        }

        // adding layout view to scroll view. This layout view will we used as parent
        // for phoenix views
        impl.addView(new AbsoluteLayout(app));
    }

    @Override
    protected int handleTouchEventResult(int state) {
      return
        state == TOUCH_EVENT_LISTENER_STATE_FAILED && ((ScrollImpl)impl).isInterceptTouchEvent() ?
        -1 : state; 
    }
	
    public void setContentSize(int width, int height) {
        AbsoluteLayout layout = (AbsoluteLayout)impl.getChildAt(0);
        layout.setLayoutParams(new FrameLayout.LayoutParams(width, height));
        invalidate();
    }


    // Returns scroll X position in scroll view
    public int getScrollX() {
        return impl.getScrollX();
    }


    // Returns scroll Y position in scroll view
    public int getScrollY() {
        return impl.getScrollY();
    }


    // Returns reference to Android view for phoenix view
    @Override
    protected View getView() {
        return impl;
    }


    // Adds child view
    @Override
    public void addView(PhoenixView v) {
        super.addView(v);

        // insert child view into AbsoluteLayout inside ScrollView
        AbsoluteLayout layout = (AbsoluteLayout)impl.getChildAt(0);
        layout.addView(v.getView());
    }


    // Removes child view
    @Override
    public void removeView(PhoenixView v) {
        super.removeView(v);

        // removing child view from AbsoluteLayout inside ScrollView
        AbsoluteLayout layout = (AbsoluteLayout)impl.getChildAt(0);
        layout.removeView(v.getView());
    }


   public native void onPageChanged(long nativeView, int newPage, int oldPage);

   public native void onScroll(long nativeView, int scrollX, int scrollY);
  

  public boolean isPaging() {
    return paging;
  }

    // Sets scroll position in scroll view
    void scrollTo(int x, int y) {
        if (impl instanceof VerticalScrollImpl) {
            VerticalScrollImpl vImpl = (VerticalScrollImpl)impl;
            impl.scrollTo(x, y);
        } else {
            HorizontalScrollImpl hImpl = (HorizontalScrollImpl)impl;
            impl.scrollTo(x, y);
        }
    }

  void setScrollBarEnabled(boolean flag, boolean hasHorizontalScroller, boolean hasVerticalScroller) {
    if (hasVerticalScroller) {
      impl.setVerticalScrollBarEnabled(flag);
    } else if (hasHorizontalScroller) {
      impl.setHorizontalScrollBarEnabled(flag);
    }
  }

  void setHasOnScrollListener(boolean flag) {
    m_hasOnScrollListener = flag;
  }

  public boolean hasOnScrollListener() {
    return m_hasOnScrollListener;
  }

  private final boolean paging;

  private boolean m_hasOnScrollListener = false;
}
