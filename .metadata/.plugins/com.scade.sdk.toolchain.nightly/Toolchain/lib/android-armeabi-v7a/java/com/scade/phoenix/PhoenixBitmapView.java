package com.scade.phoenix;

import android.content.*;
import android.graphics.*;
import android.view.*;
import android.widget.*;
import com.scade.phoenix.MainActivity;


public class PhoenixBitmapView extends PhoenixView {

  private class Impl extends AbsoluteLayout {

    public Impl(Context context) {
      super(context);
    }

    // Called when view needs redrawing
    @Override
    protected void onDraw(Canvas canvas) {
      logOnDraw(getNativeView(), width, height);

      assert getNativeView() != 0;

      if (useSkiaRender()) {
        if (bitmap != null && width > 0 && height > 0) {
          if (!isAnimating() || !isSetHiddenAfterAnimation()) {
            // don't redraw bitmap for hidden animating view
            // This is required because ScadeSDK can change hidden
            // flag after start of animation, but is designed so that old image
            // should be used for animation
            drawBitmap(bitmap, getNativeView(), width, height);
          }

          Rect srcRect = new Rect(0, 0, width, height);
          Rect dstRect = new Rect(0, 0, getWidth(), getHeight());
          canvas.drawBitmap(bitmap, srcRect, dstRect, null);
        }
      } else {
        if (width > 0 && height > 0) {
          drawBitmapToCanvas(canvas, getNativeView(), width, height);
        }

        // Paint paint = new Paint();
        // paint.setColor(Color.BLUE);
        // paint.setStrokeWidth(3);
        // paint.setStyle(Paint.Style.STROKE);
 
        // // Path path = new Path();
        // // path.moveTo(50, 50);
        // // path.lineTo(50, 500);
        // // path.lineTo(200, 500);
        // // path.lineTo(200, 300);
        // // path.lineTo(350, 300);
   
        // float[] intervals = new float[]{5, 5};
        // float phase = 0;
   
        // DashPathEffect dashPathEffect = 
        //   new DashPathEffect(intervals, phase);
 
        // paint.setPathEffect(dashPathEffect);

        // //canvas.drawPath(path, paint);
        // canvas.drawLine(10, 10, 190, 10, paint);


        // Paint paint1 = new Paint();      
        // paint1.setColor(Color.WHITE); 
        // paint1.setStyle(Paint.Style.FILL); 
        // canvas.drawPaint(paint1);


        // Paint paint = new Paint();      
        // paint.setColor(Color.BLACK); 
        // paint.setStyle(Paint.Style.STROKE); 
        // canvas.drawLine(100, 0, 100, 1000, paint);
        // canvas.drawLine(0, 100, 1000, 100, paint);

        //canvas.drawLine(100 + 71, 0, 100 + 71, 1000, paint);
        //canvas.drawLine(200 + 76, 0, 200 + 76, 1000, paint);

        // java.util.List<PhoenixAttributedString.Segment> segments =
        //   new java.util.LinkedList<PhoenixAttributedString.Segment>();

        // PhoenixAttributedString.Segment segment = null;

        // segment = new PhoenixAttributedString.Segment();
        // segment.content = "One";
        // segment.fontSize = 40;
        // segment.setX(100);
        // segment.setY(100);
        // segments.add(segment);

        // segment = new PhoenixAttributedString.Segment();
        // segment.content = "Two";
        // segment.fontSize = 40;
        // //segment.setX(200);
        // segment.setY(200);
        // segments.add(segment);

        // segment = new PhoenixAttributedString.Segment();
        // segment.content = "You are ";
        // segment.fontSize = 40;
        // segment.fillColor = Color.BLACK;
        // segment.setX(100);
        // segment.setY(100);
        // segments.add(segment);

        // segment = new PhoenixAttributedString.Segment();
        // segment.content = "not";
        // segment.fillColor = Color.RED;
        // segment.fontSize = 60;
        // segments.add(segment);

        // segment = new PhoenixAttributedString.Segment();
        // segment.content = "a ";
        // segment.fontSize = 40;
        // segment.fillColor = Color.BLACK;
        // segments.add(segment);

        // segment = new PhoenixAttributedString.Segment();
        // segment.content = "banana ";
        // segment.fontSize = 40;
        // segment.fillColor = Color.BLACK;
        // segments.add(segment);

        // segment = new PhoenixAttributedString.Segment();
        // segment.content = "end ";
        // segment.fontSize = 60;
        // segment.fillColor = Color.RED;
        // segment.fontName = "serif";
        // segments.add(segment);

        // segment = new PhoenixAttributedString.Segment();
        // segment.content = "gyq";
        // segment.fontSize = 40;
        // segment.fillColor = Color.BLACK;
        // segments.add(segment);

        // (new PhoenixAttributedString(false, 0, segments)).render(canvas);
        // //(new PhoenixAttributedString(true, 200, segments)).render(canvas);
      }
    }


    // Called on touch event
    @Override
    public boolean onTouchEvent(MotionEvent event) {

      // the next two checks are needed to make nested scroll views
      // work. We need disable events interception in all parent scrolls
      // after touch down
      // we don't need enable scrolls after receiving ACTION_CANCEL
      // because in that case handling of touch events transferred to
      // the first scroll in parents chain. We will enable scrolls
      // after receiving ACTION_UP or ACTION_CANCEL in that scroll

      switch (event.getActionMasked()) {
      case MotionEvent.ACTION_DOWN:
        disableParentScrolls(true);
        break;
      case MotionEvent.ACTION_UP:
        disableParentScrolls(false);
        break;
      case MotionEvent.ACTION_MOVE:
        break;
      default:
        return super.onTouchEvent(event);
      }

      return handleTouchEvent(event) || super.onTouchEvent(event);
      // android.util.Log.i("Phoenix", "------- Bitmap start onTouchEvent: " + event.getActionMasked());
      // boolean res = handleTouchEvent(event) || super.onTouchEvent(event);
      // android.util.Log.i("Phoenix", "------- Bitmap   end onTouchEvent: " + event.getActionMasked());
      // return res;
    }


    @Override
    public void onAnimationEnd() {
      super.onAnimationEnd();
      onPhoenixAnimationEnd();
    }


    // Disables intercepting touch events in all parent scrolls
    // except of the most nested
    void disableParentScrolls(boolean disable) {
      for (ViewParent view = getParent(); view != null; view = view.getParent()) {
        if (!(view instanceof PhoenixScrollView.ScrollImpl))
          continue;

        PhoenixScrollView.ScrollImpl impl = (PhoenixScrollView.ScrollImpl)view;
        impl.disableParentScrolls(disable);
        break;
      }
    }
  }

  private Impl impl;
  private int width;
  private int height;
  private Bitmap bitmap;
  private PhoenixApplication app;
	
  public native void logOnDraw(long cBmpView, int w, int h);
  public native void drawBitmap(Bitmap bmp, long cBmpView, int w, int h);
  public native void drawBitmapToCanvas(Canvas canv, long cBmpView, int w, int h);
  public native boolean useSkiaRender();
	

  public PhoenixBitmapView(PhoenixApplication a, long nView) {
    super(a, nView);
    impl = new Impl(a);
    impl.setWillNotDraw(false);
    app = a;
  }


  // Called after real applying new size and position of view
  @Override
  public void doSetBounds(int top, int left, int w, int h) {
    // save width and height of bitmap. We use them instead of
    // getWidth()/getHeight() in onDraw event because Android may
    // delay resizing of View and call onDraw with old size
    float scale = app.getScaleFactor();
    int newWidth = Math.round((float)w / scale);
    int newHeight = Math.round((float)h / scale);

    if (newWidth > 0 && newHeight > 0 &&
        (newWidth != width || newHeight != height)) {

      if (useSkiaRender()) {
        bitmap = Bitmap.createBitmap(newWidth, newHeight, Bitmap.Config.ARGB_8888);
      }
    }

    width = newWidth;
    height = newHeight;
  }


  // Returns reference to Android view for phoenix view
  @Override
  protected View getView() {
    return impl;
  }

  // Adds child view
  @Override
  public void addView(PhoenixView view) {
    super.addView(view);
    impl.addView(view.getView());
  }


  // Removes child view
  @Override
  public void removeView(PhoenixView view) {
    super.removeView(view);
    impl.removeView(view.getView());
  }
}
