package com.scade.phoenix;

import java.util.*;
import android.graphics.*;
import android.view.animation.*;
import android.animation.*;
import android.view.*;
import android.widget.*;
import android.util.*;

public abstract class PhoenixView {

  private Animation currentAnimation;     // Current view animation

  // new size and position which should be set after end of animation
  private boolean setBoundsAfterAnimation = false;
  private int newLeft;
  private int newTop;
  private int newWidth;
  private int newHeight;

  // new hiddent flag which should be set after end of animation
  private boolean setHiddenAfterAnimation = false;
  private boolean newHidden;

  // animation callback
  CRunnable animationCallback;

  // List of child views
  LinkedList<PhoenixView> childs = new LinkedList<PhoenixView>();

  PhoenixView parent = null;

  // Pointer to native view object
  private long nativeView;

  protected PhoenixApplication app;

  // Returns reference to Android view for phoenix view
  protected abstract View getView();


  // Called after real applying new size and position to view
  protected void doSetBounds(int x, int y, int width, int height) {}


  public PhoenixView(PhoenixApplication app, long nView) {
    this.app = app;
    this.nativeView = nView;
  }


  // Returns view name
  public String getName() {
    return getNativeName(getNativeView());
  }


  // Dumps view to string and returns it
  public String getDump() {
    return getNativeDump(getNativeView());
  }


  // Returns view name from native view object
  public native String getNativeName(long nativeView);


  // Returns view dump from native view object
  public native String getNativeDump(long nativeView);


  // Returns native parent from native view object
  private native long getNativeParent(long nativeView);


  // Returns native parent for this view
  public long getNativeParent() {
    return getNativeParent(getNativeView());
  }


  // Returns pointer to native view object
  protected long getNativeView() {
    return nativeView;
  }


  // Adds child view
  public void addView(PhoenixView view) {
    view.parent = this;
    childs.add(view);
  }


  // Removes child view
  public void removeView(PhoenixView view) {
    view.parent = null;
    childs.remove(view);
  }


  // Returns list of child views
  public LinkedList<PhoenixView> getChilds() {
    return childs;
  }


  // Invalidates view
  public final void invalidate() {
    getView().invalidate();
  }


  // Sets view position/size in parent
  public void setBounds(int left, int top, int width, int height) {
    if (currentAnimation != null) {
      // animation is begin executed at this time. Delaying
      // setting of new position and size
      newLeft = left;
      newTop = top;
      newWidth = width;
      newHeight = height;
      setBoundsAfterAnimation = true;
      return;
    }

    getView().setLayoutParams(new AbsoluteLayout.LayoutParams(width, height, left, top));
    doSetBounds(left, top, width, height);
  }


  // Returns view position/size in parent
  // TODO: is getFrame actually used?
  public Rect getFrame() {
    AbsoluteLayout.LayoutParams p = (AbsoluteLayout.LayoutParams)getView().getLayoutParams();

    return p != null ?
      new Rect(p.x, p.y, p.x + p.width, p.y + p.height) : new Rect();
  }


  // Sets hidden flags for view
  public void setHidden(boolean val) {
    if (currentAnimation != null) {
      // animation is begin executed at this time. Delaying
      // setting of new position and size
      setHiddenAfterAnimation = true;
      newHidden = val;
      return;
    }

    getView().setVisibility(val ? View.INVISIBLE : View.VISIBLE);
  }


  // Starts specified animation on view
  private boolean doStartAnimation(Animation animation) {
    if (getView().getAnimation() != null) {
      // can't start multiple animations for Android
      return false;
    }

    getView().startAnimation(animation);

    // setting current animation for child views
    Iterator<PhoenixView> it = childs.iterator();
    while (it.hasNext()) {
      it.next().setCurrentAnimation(animation);
    }

    return true;
  }


  // Performs animation on bitmap view
  public void performAnimation(float dx, float dy, long duration) {
    // starting animation
    TranslateAnimation animation = new TranslateAnimation(0.0f, dx, 0.0f, dy);
    animation.setDuration(duration);
    doStartAnimation(animation);
  }


  // Should be called in child classes after end of animation on view implementation
  protected void onPhoenixAnimationEnd() {
    // removing current animation
    currentAnimation = null;

    // executing all pending resize after end of animation
    if (setBoundsAfterAnimation) {
      setBounds(newLeft, newTop, newWidth, newHeight);
      setBoundsAfterAnimation = false;
    }

    // setting pending hidden flag after end of animation
    if (setHiddenAfterAnimation) {
      setHidden(newHidden);
      setHiddenAfterAnimation = false;
    }

    // notifying child view about end of animation
    Iterator<PhoenixView> it = childs.iterator();
    while (it.hasNext()) {
      it.next().onPhoenixAnimationEnd();
    }

    // executing animation callback
    if (animationCallback != null) {
      animationCallback.run();
      animationCallback = null;
    }
  }


  // Sets current animation for phoenix view
  private void setCurrentAnimation(Animation anim) {
    currentAnimation = anim;
  }


  // Returns true if animation is being executed for phoenix view
  protected boolean isAnimating() {
    return currentAnimation != null;
  }


  // Returns true if hidden flag should be set on view after end of animation
  protected boolean isSetHiddenAfterAnimation() {
    return setHiddenAfterAnimation;
  }

  public Animator createValueAnimator(final int action,
                                      final long duration,
                                      final long startDelay,
                                      final int repeatCount,
                                      final float [] values,
                                      final float [] anchor,
                                      CRunnable callback) {
    Animator res = null;

    int animCount = repeatCount == -1 ? ValueAnimator.INFINITE : (repeatCount - 1);
    TimeInterpolator timeInterpolator = new LinearInterpolator();
    PhoenixAnimatorListener animationListener = new PhoenixAnimatorListener(callback);

    if (action == 4/*rotate*/) {
      float anchorX = 0;
      float anchorY = 0;
      if (anchor != null && anchor.length == 2) {
        Rect r = getFrame();
        anchorX = anchor[0] * r.width();
        anchorY = anchor[1] * r.height();
      }

      float[] degreeValues = new float[values.length];
      for (int i = 0; i < values.length; ++i) {
        degreeValues[i] = (float)Math.toDegrees(values[i]);
      }

      ObjectAnimator animRotate = ObjectAnimator.ofFloat(getView(), View.ROTATION, degreeValues);
      animRotate.setRepeatCount(animCount);
      animRotate.setInterpolator(timeInterpolator);


      float[] xAnchorValues = {anchorX, anchorX};
      ObjectAnimator animX = ObjectAnimator.ofFloat(getView(), "pivotX", xAnchorValues);
      animX.setRepeatCount(animCount);
      animX.setInterpolator(timeInterpolator);

      float[] yAnchorValues = {anchorY, anchorY};
      ObjectAnimator animY = ObjectAnimator.ofFloat(getView(), "pivotY", yAnchorValues);
      animY.setRepeatCount(animCount);
      animY.setInterpolator(timeInterpolator);
      
      AnimatorSet animSet = new AnimatorSet();
      animSet.playTogether(animX, animY, animRotate);

      animationListener.addResetViewCustomProperty(getView(), "pivotX");
      animationListener.addResetViewCustomProperty(getView(), "pivotY");
      animationListener.addResetViewProperty(getView(), View.ROTATION);
      
      res = animSet;
      
    } else if (action == 3/*translate*/) {

      //android.util.Log.i("Phoenix", "TranslateAnimation: total = " + values.length);

      int valueCount = values.length / 2;
      float[] xValues = new float[valueCount];
      float[] yValues = new float[valueCount];

      for (int i = 0, totalIndex = 0; i < valueCount; ++i, totalIndex += 2) {
        xValues[i] = values[totalIndex];
        yValues[i] = values[totalIndex + 1];
      }

      ObjectAnimator animX = ObjectAnimator.ofFloat(getView(), View.TRANSLATION_X, xValues);
      animX.setRepeatCount(animCount);
      animX.setInterpolator(timeInterpolator);

      ObjectAnimator animY = ObjectAnimator.ofFloat(getView(), View.TRANSLATION_Y, yValues);
      animY.setRepeatCount(animCount);
      animY.setInterpolator(timeInterpolator);
      
      AnimatorSet animSet = new AnimatorSet();
      animSet.playTogether(animX, animY);

      animationListener.addResetViewProperty(getView(), View.TRANSLATION_X);
      animationListener.addResetViewProperty(getView(), View.TRANSLATION_Y);
      
      res = animSet;
      
    } else {
      Property<View,Float> key = View.TRANSLATION_X;
      switch (action) {
      case 0: // x
        key = View.TRANSLATION_X;
        break;
      case 1: // y
        key = View.TRANSLATION_Y;
        break;
      case 2: // opacity
        key = View.ALPHA;
        break;
      }

      ObjectAnimator anim = ObjectAnimator.ofFloat(getView(), key, values);
      anim.setRepeatCount(animCount);
      anim.setInterpolator(timeInterpolator);

      animationListener.addResetViewProperty(getView(), key);

      res = anim;
    }

    res.setDuration(duration);
    res.setStartDelay(startDelay);
    res.addListener(animationListener);

    return res;
  }


  public Animator createGroupAnimator(final long duration,
                                      final long startDelay,
                                      final int repeatCount,
                                      final Animator[] animators) {

    AnimatorSet res = new AnimatorSet();
    res.playTogether(animators);

    return res;
  }

  public Animator createFrameAnimator(final long animationPtr,
                                      final long duration,
                                      final long startDelay,
                                      final int repeatCount,
                                      CRunnable callback) {
    PhoenixFrameAnimator res = new PhoenixFrameAnimator(animationPtr);
    res.setDuration(Math.max(1, duration));
    res.setStartDelay(startDelay);
    res.setRepeatCount(repeatCount);
    res.addListener(new PhoenixAnimatorListener(callback));

    return res;
  }

  // Starts value animation on view
  public boolean performValueAnimation(final int action,
                                       long duration,
                                       long startDelay,
                                       boolean additive,
                                       boolean freeze,
                                       int repeatCount,
                                       float [] from,
                                       float [] by,
                                       float [] to,
                                       float [] anchor,
                                       CRunnable callback) {

    Animation animation = null;

    switch (action) {
    case 0:     // X 
      {
        float fromX = (from == null) ? 0 : from[0];
        float toX = to[0];

        //android.util.Log.i("Phoenix", "x animation: " + fromX + " " + toX);
        animation = new TranslateAnimation(fromX, toX, 0, 0);
      }
      break;
    case 1:     // Y
      {
        float fromY = (from == null) ? 0 : from[0];
        float toY = to[0];

        animation = new TranslateAnimation(0, 0, fromY, toY);
      }
      break;
    case 4:     // ALPHA
      {
        float curValue = getView().getAlpha();
        float fromValue = (from == null) ? curValue : from[0];
        float toValue = to[0];

        if (additive) {
          if (from != null) {
            fromValue += curValue;
          }

          toValue += curValue;
        }

        animation = new AlphaAnimation(fromValue, toValue);
        break;
      }

    case 5:     // TRANSLATION
      {
        float fromX = (from == null) ? 0 : from[0];
        float fromY = (from == null) ? 0 : from[1];
        float toX = to[0];
        float toY = to[1];

        // TODO: additive flag meaning for TRANSLATION animation?

        animation = new TranslateAnimation(fromX, toX, fromY, toY);
        break;
      }

    case 6:     // SCALE
      {
        float curValue = getView().getScaleX();
        float fromValue = (from == null) ? curValue : from[0];
        float toValue = to[0];

        if (additive) {
          if (from != null) {
            fromValue += curValue;
          }

          toValue += curValue;;
        }

        if (anchor != null && anchor.length == 2) {
          animation = new ScaleAnimation(fromValue,
                                         toValue,
                                         fromValue,
                                         toValue,
                                         Animation.RELATIVE_TO_SELF,
                                         anchor[0],
                                         Animation.RELATIVE_TO_SELF,
                                         anchor[1]);
        } else {
          animation = new ScaleAnimation(fromValue, toValue, fromValue, toValue);
        }
        break;
      }

    case 7:     // ROTATION
      {
        float curValue = getView().getRotation();
        float fromValue = (from == null) ? curValue : (from[0] / (float)Math.PI * 180.0f);
        float toValue = to[0] / (float)Math.PI * 180.0f;

        if (additive) {
          toValue += curValue;;

          if (from != null) {
            fromValue += curValue;
          }
        }

        if (anchor != null && anchor.length == 2) {
          animation = new RotateAnimation(fromValue,
                                          toValue,
                                          Animation.RELATIVE_TO_SELF,
                                          anchor[0],
                                          Animation.RELATIVE_TO_SELF,
                                          anchor[1]);
        } else {
          animation = new RotateAnimation(fromValue, toValue);
        }
        break;
      }

    case 2:     // WIDTH
    case 3:     // HEIGHT
      // TODO: need use valueanimator + listener

    case 8:
      // transform
      // TODO
    case 9:
      // position
      // TODO
    case 10:
      // size
      // TODO
    default:
      assert false;
    }

    assert animation != null;

    animation.setDuration(duration);
    animation.setStartOffset(startDelay);
    animation.setRepeatCount(repeatCount);
    animation.setInterpolator(new LinearInterpolator());

    // adding freeze callback
    if (callback != null) {
      //animation.setFillAfter(true);
      animationCallback = callback;
    }

    return doStartAnimation(animation);
  }


  // Removes current animation
  void removeAnimation() {
    getView().clearAnimation();
  }


  // Moves phoenix view to top (changes z order)
  void bringToFront() {
    getView().bringToFront();
  }

  protected boolean handleTouchEvent(MotionEvent event) {
    return processTouchEvent(event.getActionMasked(), event.getX(), event.getY(), true) >= 0;
  }

  private int processTouchEvent(int action, float x, float y, boolean isFailedPrevState) {
    int notifyResult = -1;
    switch (action) {
    case MotionEvent.ACTION_DOWN:
      notifyResult = handleTouchDown(nativeView, x, y, isFailedPrevState);
      break;
    case MotionEvent.ACTION_UP:
      notifyResult = handleTouchUp(nativeView, x, y, isFailedPrevState);
      break;
    case MotionEvent.ACTION_MOVE:
      notifyResult = handleTouchMove(nativeView, x, y, isFailedPrevState);
      break;
    }

    notifyResult = handleTouchEventResult(notifyResult);

    //android.util.Log.i("Phoenix", "processTouchEvent: " + this + " " + notifyResult + " " + isFailedPrevState);

    if (notifyResult >= 0 && parent != null) {
      Rect frame = getFrame();
      parent.processTouchEvent(action, x + frame.left, y + frame.top,
                               isFailedPrevState && notifyResult == TOUCH_EVENT_LISTENER_STATE_FAILED);
    }

    return notifyResult;
  }

  protected int handleTouchEventResult(int state) {
    return state;
  }

  // protected boolean isPropogateTouchEventToParent(int state, float x, float y) {
  //   // return !(state == TOUCH_EVENT_LISTENER_STATE_BEGAN ||
  //   //          state == TOUCH_EVENT_LISTENER_STATE_CHANGED ||
  //   //          state == TOUCH_EVENT_LISTENER_STATE_ENDED);
  //   return true;
  // }

  // Notifies Phoenix about touch down event
  native private int handleTouchDown(long nativeView, float x, float y, boolean isFailedPrevState);

  // Notifies Phoenix about touch move event
  native private int handleTouchMove(long nativeView, float x, float y, boolean isFailedPrevState);

  // Notifies Phoenix about touch up event
  native private int handleTouchUp(long nativeView, float x, float y, boolean isFailedPrevState);


  protected static final int TOUCH_EVENT_LISTENER_STATE_POSSIBLE = 0;
  protected static final int TOUCH_EVENT_LISTENER_STATE_BEGAN    = 1;
  protected static final int TOUCH_EVENT_LISTENER_STATE_CHANGED  = 2;
  protected static final int TOUCH_EVENT_LISTENER_STATE_ENDED    = 3;
  protected static final int TOUCH_EVENT_LISTENER_STATE_FAILED   = 4;
}

