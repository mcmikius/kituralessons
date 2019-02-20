
package com.scade.phoenix;

import android.R.bool;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.PorterDuff;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.MotionEvent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsoluteLayout;
import android.widget.EditText;
import android.widget.TextView;
import com.scade.phoenix.MainActivity;
import java.lang.reflect.Field;


public class PhoenixTextInput extends PhoenixView {

  private class Impl extends EditText {

    public Impl(Context ctx) {
      super(ctx);
      setOnFocusChangeListener(new View.OnFocusChangeListener() {
          public void onFocusChange(View v, boolean hasFocus) {
            if (hasFocus)
              return;

            Context ctx = getContext();
            InputMethodManager imm = (InputMethodManager)ctx.getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
          }
        });
    }

    // Called on touch event
    @Override
    public boolean onTouchEvent(MotionEvent event) {
      // passsing touch events to EditText widget if enabled
      if (isEnabled()) {
        return super.onTouchEvent(event);
      }

      // passing event to main activity
      return handleTouchEvent(event) || super.onTouchEvent(event);
    }


    @Override
    public void onAnimationEnd() {
      super.onAnimationEnd();
      onPhoenixAnimationEnd();
    }
  }
	
  private Impl impl;

  // Notifies Phoenix text input object about text change
  native private void notifyTextChanged(long cTextInput, String text);

  // Notifies Phoenix text input object about edit finish
  native private void notifyEditFinish(long cTextInput, String text);
	
  public PhoenixTextInput(PhoenixApplication a, boolean multiline, long nView) {
    super(a, nView);

    impl = new Impl(app);

    setTextColorWithoutCursor(Color.BLACK);
    impl.setBackgroundColor(Color.TRANSPARENT);
    impl.setPadding(0, 0, 0, 0);

    if (multiline) {
      impl.setSingleLine(false);
      impl.setImeOptions(EditorInfo.IME_FLAG_NO_ENTER_ACTION);
    } else {
      impl.setSingleLine(true);
    }

    // listening for text change and notifying Phoenix
    impl.addTextChangedListener(new TextWatcher() {
        public void afterTextChanged(Editable s) {
          notifyTextChanged(getNativeView(), impl.getText().toString());
        }

        public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
        public void onTextChanged(CharSequence s, int start, int before, int count) {}
      });

    impl.setOnEditorActionListener(new TextView.OnEditorActionListener() {
        public boolean onEditorAction(TextView v, int actionId, android.view.KeyEvent event) {
          Context ctx = impl.getContext();
          InputMethodManager imm = (InputMethodManager)ctx.getSystemService(Context.INPUT_METHOD_SERVICE);
          imm.hideSoftInputFromWindow(v.getWindowToken(), 0);

          notifyEditFinish(getNativeView(), impl.getText().toString());
          return true;
        }
      });

  }
	
    
  public float getDescent() {
    return impl.getPaint().getFontMetrics().descent;
  }
    

  public void setEnabled(boolean enabled) {
    impl.setEnabled(enabled);
  }


  public void setInputType(int type) {
    impl.setInputType(type);
  }


  public void setText(String text) {
    impl.setText(text);
  }


  public String getText() {
    return impl.getText().toString();
  }


  public void setHint(String hint) {
    impl.setHint(hint);
  }


  public void setTextColor(int color) {
    setTextColorWithoutCursor(color);
    setCursorDrawableColor(impl, color);
  }


  public void setTextSize(int szType, float value) {
    impl.setTextSize(szType, value);
  }


  public void setFontName(String fontName) {
    Typeface typeface = PhoenixPaint.getFont(fontName);
    if (typeface != null) {
      impl.setTypeface(typeface);
    }                  
  }


  public void setTextDecoration(boolean isUnderLine, boolean isLineThrough) {
    if (isUnderLine) {
      impl.setPaintFlags(impl.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
    } else {
      impl.setPaintFlags(impl.getPaintFlags() & (~ Paint.UNDERLINE_TEXT_FLAG));
    }

    if (isLineThrough) {
      impl.setPaintFlags(impl.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
    } else {
      impl.setPaintFlags(impl.getPaintFlags() & (~ Paint.STRIKE_THRU_TEXT_FLAG));
    }
  }


  public void sizeToFit() {
    impl.measure(0, 0);
    int x = (int)impl.getX();
    int y = (int)impl.getY();
    int w = impl.getMeasuredWidth();
    int h = impl.getMeasuredHeight();
    impl.setLayoutParams(new AbsoluteLayout.LayoutParams(w, h, x, y));
  }


  // Calls measure method on impl taking into account width parameter
  public void performMeasure(int width) {
    if (width == 0) {
      impl.measure(0, 0);
    } else {
      impl.measure(
                   View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
                   0);
    }
  }


  // Returns text width in TextInput view
  public int getMeasuredWidth() {
    return impl.getMeasuredWidth();
  }


  // Return text height in TextInput view
  public float getTextHeight() {
    return impl.getTextSize();
  }


  // Returns measured height for text view
  public int getMeasuredHeight() {
    return impl.getMeasuredHeight();
  }


  // Returns offset of text baseline from top border
  public int getBaseline() {
    impl.measure(0, 0);
    int res = impl.getBaseline();
    return res;
  }


  // Returns reference to Android view for phoenix view
  @Override
  protected View getView() {
    return impl;
  }


  // Adds child Phoenix view
  @Override
  public void addView(PhoenixView v) {
    android.util.Log.e("Phoenix", "addView method called for PhoenixTextInput");
  }


  // Removes child Phoenix view
  @Override
  public void removeView(PhoenixView v) {
    android.util.Log.e("Phoenix", "removeView method called for PhoenixTextInput");
  }


  // Sets focus on Phoenix text input
  public void setFocus() {
    getView().requestFocus();

    InputMethodManager imm =
      (InputMethodManager)app.getSystemService(Context.INPUT_METHOD_SERVICE);
    imm.showSoftInput(getView(), InputMethodManager.SHOW_IMPLICIT);
  }


  // Sets alignment of text
  public void setAlignment(int align) {
    int gravity = Gravity.LEFT;
    switch (align) {
    case 0:
      gravity = Gravity.LEFT;
      break;
    case 1:
      gravity = Gravity.CENTER;
      break;
    case 2:
      gravity = Gravity.RIGHT;
      break;
    default:
      break;
    }

    impl.setGravity(gravity);
  }

  public void setKeyboardType(boolean isNumeric) {
    impl.setInputType(isNumeric ? InputType.TYPE_CLASS_NUMBER : InputType.TYPE_CLASS_TEXT);
  }

  private void setCursorDrawableColor(EditText editText, int color) {
    try {
      Field fCursorDrawableRes = TextView.class.getDeclaredField("mCursorDrawableRes");
      fCursorDrawableRes.setAccessible(true);
      int mCursorDrawableRes = fCursorDrawableRes.getInt(editText);
      Field fEditor = TextView.class.getDeclaredField("mEditor");
      fEditor.setAccessible(true);
      Object editor = fEditor.get(editText);
      Class<?> clazz = editor.getClass();
      Field fCursorDrawable = clazz.getDeclaredField("mCursorDrawable");
      fCursorDrawable.setAccessible(true);
      Drawable[] drawables = new Drawable[2];
      drawables[0] = editText.getContext().getResources().getDrawable(mCursorDrawableRes);
      drawables[1] = editText.getContext().getResources().getDrawable(mCursorDrawableRes);
      drawables[0].setColorFilter(color, PorterDuff.Mode.SRC_IN);
      drawables[1].setColorFilter(color, PorterDuff.Mode.SRC_IN);
      fCursorDrawable.set(editor, drawables);
    }
    catch (final Throwable ignored) {
      //android.util.Log.i("Phoenix", "set color error!!!");
    }
  }

  private void setTextColorWithoutCursor(int color) {
    impl.setTextColor(color);
    impl.setHintTextColor(Color.argb(127, Color.red(color), Color.green(color), Color.blue(color)));
  }
}
