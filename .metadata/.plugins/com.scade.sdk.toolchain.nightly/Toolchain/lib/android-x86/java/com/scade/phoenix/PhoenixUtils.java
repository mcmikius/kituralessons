package com.scade.phoenix;

import java.nio.ByteBuffer;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;


// Phoenix utility functions
public class PhoenixUtils {
  // Creates new bitmap with specified width and height
  public static Bitmap createBitmap(int width, int height) {
    return Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
  }


  // Loads bitmap from file with specified path
  public static Bitmap loadBitmap(String path) {
    return BitmapFactory.decodeFile(path);
  }


  // Loads bitmap from base64 array
  public static Bitmap loadBitmapFromBase64(byte [] data) {
    byte [] imgData = Base64.decode(data, Base64.DEFAULT);
    return loadBitmapFromData(imgData);
  }


  // Loads bitmap from array
  public static Bitmap loadBitmapFromData(byte [] data) {
    return BitmapFactory.decodeByteArray(data, 0, data.length);
  }

  // Loads bitmap from raw bytes array
  public static Bitmap loadBitmapFromRawData(byte [] data, int width, int height) {
    Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    ByteBuffer buffer = ByteBuffer.wrap(data);
    bitmap.copyPixelsFromBuffer(buffer);

    return bitmap;
  }

}
