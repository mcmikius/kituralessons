package com.scade.phoenix;

import android.animation.*;
import android.util.*;

public class PhoenixFrameAnimator extends TimeAnimator implements TimeAnimator.TimeListener {

  PhoenixFrameAnimator(final long nativePtr) {
    this.nativePtr = nativePtr;
    setTimeListener(this);
  }

  @Override
  public void onTimeUpdate(TimeAnimator animation, long totalTime,
                           long deltaTime) {
    long startDelay = getStartDelay();
    long duration = getDuration();
    if (totalTime >= startDelay) {

      float timepoint = 1.0f * (totalTime - startDelay) / duration;
      float realTimePoint = timepoint - ((float)Math.floor(timepoint));

      boolean isStop = repeatCount > 0 && (totalTime >= startDelay + repeatCount * duration);
      if (isStop) {
        realTimePoint = 1;
      }

      //android.util.Log.i("Phoenix", "TotalTime: " + totalTime + " " + realTimePoint);

      tick(nativePtr, realTimePoint);

      if (isStop) {
        end();
      }
    }
  }

  public void setRepeatCount(int repeatCount) {
    this.repeatCount = repeatCount;
  }

  native private void tick(long nativeView, float time);

  private final long nativePtr;

  private int repeatCount = 1;
}

