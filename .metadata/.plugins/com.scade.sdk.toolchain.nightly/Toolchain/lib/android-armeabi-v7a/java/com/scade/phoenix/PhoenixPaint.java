package com.scade.phoenix;

import android.graphics.*;
import java.util.Map;
import java.util.HashMap;
import java.io.File;

// Android Paint class with interface extended to use from JNI
class PhoenixPaint extends Paint {

  // Sets bold font
  public void setTextBold(boolean bold) {
    // don't change bold flag if typeface is bold itself
    if (fontIsBold)
      return;

    Typeface font = getTypeface();
    boolean italic = font != null ? font.isItalic() : false;
    setTypeface(createTypeface(font, bold, italic));
  }


  // Sets italic font
  public void setTextItalic(boolean italic) {
    Typeface font = getTypeface();
    boolean bold = font != null ? font.isBold() : false;
    setTypeface(createTypeface(font, bold, italic));
  }


  // Sets text font for paint
  public void setFontName(String fontName) {
    Typeface font = Typeface.create(fontName, Typeface.NORMAL);

    if (font.isBold()) {
      fontIsBold = true;
    }

    Typeface f = getTypeface();
    boolean bold = fontIsBold ? true : (f != null ? f.isBold() : false);
    boolean italic = f != null ? f.isItalic() : false;

    super.setTypeface(createTypeface(font, bold, italic));
  }


  // Sets text decoration
  public void setTextDecoration(boolean underline, boolean lineThrough) {
    int flags = getFlags();

    if (underline)
      flags |= UNDERLINE_TEXT_FLAG;

    if (lineThrough)
      flags |= STRIKE_THRU_TEXT_FLAG;

    setFlags(flags);
  }


  // Sets gradient shader for paint
  public void setGradientShader(float x0, float y0, float x1, float y1,
                                int [] colors, float [] positions) {
    setShader(new LinearGradient(x0, y0, x1, y1, colors, positions, Shader.TileMode.REPEAT));
  }

  public void setStrokeDashArray(float[] array, float offset) {
    if (array.length >= 2) {
      setPathEffect(new DashPathEffect(array, offset));
    } else {
      setPathEffect(null);
    }
  }

  public static void registerFont(String file) {
    Typeface font = Typeface.createFromFile(file);
    if (font != null) {
      String fileName = (new File(file)).getName();
      int pos = fileName.lastIndexOf('.');
      if (pos != -1) {
        fonts.put(fileName.substring(0, pos), font);
      }
    }
  }

  public static Typeface getFont(String name) {
    Typeface res = fonts.get(name);
    if (res == null) {
      boolean isBold = name.toLowerCase().contains("bold");
      boolean isItalic = name.toLowerCase().contains("italic");
      int style = Typeface.NORMAL;
      if (isBold && isItalic) {
        style = Typeface.BOLD_ITALIC;
      } else if (isBold) {
        style = Typeface.BOLD;
      } else if (isItalic) {
        style = Typeface.ITALIC;
      }
      res = Typeface.create(name, style);
    }
    
    return res;
  }

  // Creates typeface with specified base typeface and falgs
  private Typeface createTypeface(Typeface font, boolean bold, boolean italic) {
    int flags = Typeface.NORMAL;

    if (bold) {
      if (italic) {
        flags = Typeface.BOLD_ITALIC;
      } else {
        flags = Typeface.BOLD;
      }
    } else {
      if (italic) {
        flags = Typeface.ITALIC;
      } else {
        flags = Typeface.NORMAL;
      }
    }

    return Typeface.create(font, flags);
  }


  private boolean fontIsBold;       // True if typeface is bold itself

  private static Map<String, Typeface> fonts = new HashMap<String, Typeface>();
}
