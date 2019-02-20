package com.scade.phoenix;

import android.animation.*;
import android.util.*;
import android.view.*;
import java.util.*;

public class PhoenixAnimatorListener implements Animator.AnimatorListener {

  interface SetValueCallback {
    void call();
  }

  PhoenixAnimatorListener(final CRunnable completedCallback) {
    this.completedCallback = completedCallback;
    this.valueCallbacks = new ArrayList<SetValueCallback>();
  }

  public void addResetViewProperty(final View view, final Property<View, Float> property) {
    final float value = property.get(view);

    valueCallbacks.add(new SetValueCallback() {

        @Override
        public void call() {
          property.set(view, value);
        }
      });
  }

  public void addResetViewCustomProperty(final View view, final String name) {
    final float value = getPropertyValue(view, name);

    valueCallbacks.add(new SetValueCallback() {

        @Override
        public void call() {
          setPropertyValue(view, name, value);
        }
      });
  }

  private static float getPropertyValue(final View view, final String name) {
    float res = 0;
    if (name.equals("pivotX")) {
      res = view.getPivotX();
    } else if (name.equals("pivotY")) {
      res = view.getPivotY();
    }
    return res;
  }

  private static void setPropertyValue(final View view, final String name, float value) {
    if (name.equals("pivotX")) {
      view.setPivotX(value);
    } else if (name.equals("pivotY")) {
      view.setPivotY(value);
    }
  }

  @Override
  public void onAnimationEnd (Animator animation) {
    for (SetValueCallback valueCallback : valueCallbacks) {
      valueCallback.call();
    }
    completedCallback.run();
  }

  @Override
  public void onAnimationCancel (Animator animation) {
  }

  @Override
  public void onAnimationRepeat (Animator animation) {
  }

  @Override
  public void onAnimationStart (Animator animation) {
  }

  private final CRunnable completedCallback;
  private final ArrayList<SetValueCallback> valueCallbacks;
}

