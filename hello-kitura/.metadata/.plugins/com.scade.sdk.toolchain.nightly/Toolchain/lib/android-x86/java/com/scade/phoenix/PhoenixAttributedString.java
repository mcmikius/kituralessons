package com.scade.phoenix;

import java.util.*;
import android.graphics.*;
import android.text.*;
import android.text.style.*;

public class PhoenixAttributedString {

  public PhoenixAttributedString(final int textAlignment, final boolean isMultiline,
                                 final int maxWidth, final Segment[] segments) {
    this.textAlignment = textAlignment;
    this.isMultiline = isMultiline;
    this.maxWidth = maxWidth;
    process(segments);
  }

  public PhoenixAttributedString(final int textAlignment, final Segment[] segments) {
    this(textAlignment, false, Integer.MAX_VALUE, segments);
  }

  public void render(Canvas canvas) {
    // Paint myPaint = new Paint();
    // myPaint.setColor(Color.rgb(0, 0, 0));
    // canvas.drawRect(getBounds(), myPaint);

    for (RenderSegment segment : renderSegments) {
      canvas.save();

      canvas.translate(segment.x + xOffset, segment.y);
      segment.layout.draw(canvas);

      canvas.restore();
    }
  }

  private void process(final Segment[] segments) {
    TextPaint paint = new TextPaint();
    paint.setAntiAlias(true);

    Layout.Alignment align = Layout.Alignment.ALIGN_NORMAL;
    if (isMultiline) {
      if (textAlignment == 1) {
        align = Layout.Alignment.ALIGN_CENTER;
      } else if (textAlignment == 2) {
        align = Layout.Alignment.ALIGN_OPPOSITE;
      }
    }
    int flag = Spanned.SPAN_EXCLUSIVE_EXCLUSIVE;
    float currX = 0;
    float currY = 0;
    float currWidth = 0;
    int start = 0;
    int end = 0;
    int yOffset = 0;
    float totalWidth = 0;
    int baseLineAlignment = 0;

    SpannableStringBuilder text = null;
    StaticLayout layout = null;

    for (Segment segment : segments) {
      if (isMultiline) {
        if (text == null) {
          text = new SpannableStringBuilder();
          currX = segment.x;
          currY = segment.y;
        }
      } else if (segment.xPresent || segment.yPresent) {
        if (text != null) {
          currWidth = createSegment(text, paint, align, baseLineAlignment, currX, currY);
          totalWidth += currWidth;
        }

        if (segment.xPresent) {
          currX = segment.x;
        } else {
          currX += currWidth;
        }

        if (segment.yPresent) {
          currY = segment.y;
        }

        text = new SpannableStringBuilder();
        start = 0;
        end = 0;
      }

      text.append(segment.content);
      end += segment.content.length();

      text.setSpan(new AbsoluteSizeSpan(segment.fontSize), start, end, flag);
      text.setSpan(new ForegroundColorSpan(segment.fillColor), start, end, flag);

      Typeface tf = PhoenixPaint.getFont(segment.fontName);
      //TODO: for Android 8 (api level 28) only!!!
      // if (tf != null) {
      //   text.setSpan(new TypefaceSpan(tf), start, end, flag);
      // }
      text.setSpan(new TypefaceSpan(segment.fontName), start, end, flag);
      text.setSpan(new StyleSpan(tf.getStyle()), start, end, flag);
      
      if (segment.isLineThrough) {
        text.setSpan(new StrikethroughSpan(), start, end, flag);
      }

      if (segment.isUnderLine) {
        text.setSpan(new UnderlineSpan(), start, end, flag);
      }

      baseLineAlignment = segment.baseLineAlignment;
      start = end;
    }

    if (text != null) {
      totalWidth += createSegment(text, paint, align, baseLineAlignment, currX, currY);
    }

    if (!isMultiline && textAlignment > 0) {
      if (textAlignment == 1) {
        xOffset -= totalWidth / 2;
      } else {
        xOffset -= totalWidth;
      }
      bounds.set(bounds.left + (int)xOffset, bounds.top, bounds.right, bounds.bottom);
    }
  }

  private float createSegment(SpannableStringBuilder text, TextPaint paint, Layout.Alignment align,
                              int baseLineAlignment, float currX, float currY) {
    StaticLayout layout = new StaticLayout(text, paint, maxWidth, align, 1, 0, false);
    float width = layout.getLineWidth(0);
    float height = layout.getHeight();
    float descent = layout.getLineDescent(0);
    float segmentY = currY;
    if (!isMultiline) {
      if (baseLineAlignment == 0) {
        segmentY -= height - descent;
      } else if (baseLineAlignment == 1) {
        segmentY -= height / 2;
      }
    } 
    renderSegments.add(new RenderSegment(layout, currX, segmentY));

    bounds.union((int)currX, (int)segmentY, (int)(currX + width), (int)(segmentY + height));

    // android.util.Log.i("Phoenix", "updateBounds: " + bounds.left + " " + bounds.top + " " +
    //                    bounds.width() + " " + bounds.height());

    return width;
  }

  public Rect getBounds() {
    return bounds;
  }
  
  public static class Segment {

    public Segment() {}

    public void setX(float x) {
      this.x = x;
      this.xPresent = true;
    }

    public void setY(float y) {
      this.y = y;
      this.yPresent = true;
    }

    public void setFontName(String fontName) {
      this.fontName = fontName;
    }

    public void setContent(String content) {
      this.content = content;
    }

    public void setFontSize(int fontSize) {
      this.fontSize = fontSize;
    }

    public void setUnderLine() {
      this.isUnderLine = true;
    }

    public void setLineThrough() {
      this.isLineThrough = true;
    }

    public void setBaselineAlignment(int value) {
      this.baseLineAlignment = value;
    }

    public void setFillColor(int value) {
      this.fillColor = value;
    }

    public float x;
    public boolean xPresent;

    public float y;
    public boolean yPresent;

    public String fontName;

    public String content;

    public int fontSize;

    public boolean isUnderLine;

    public boolean isLineThrough;

    public int baseLineAlignment;

    //public int anchor;

    public int fillColor = Color.BLACK;
  }

  private static class RenderSegment {

    public RenderSegment(final StaticLayout layout, final float x, final float y) {
      this.layout = layout;
      this.x = x;
      this.y = y;
    }

    public final StaticLayout layout;

    public final float x;

    public final float y;
  }

  private float xOffset = 0;
  private final int textAlignment;
  private final boolean isMultiline;
  private final int maxWidth;
  private final List<RenderSegment> renderSegments = new LinkedList<RenderSegment>();
  private final Rect bounds = new Rect();
}
