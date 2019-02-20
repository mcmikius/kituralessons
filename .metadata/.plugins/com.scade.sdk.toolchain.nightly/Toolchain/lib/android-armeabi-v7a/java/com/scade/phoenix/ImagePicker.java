package com.scade.phoenix;

import android.content.Intent;
import android.app.Activity;
import android.provider.MediaStore;
import android.os.Bundle;
import android.graphics.Bitmap;
import android.net.Uri;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.graphics.BitmapFactory;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Matrix;
import android.media.ExifInterface;

import java.io.*;

public class ImagePicker {

  public ImagePicker(PhoenixApplication app, long nativePtr) {
    this.app = app;
    this.nativePtr = nativePtr;

    app.getMainActivity().setImagePicker(this);
  }

  public void request(long requestId, boolean isCameraCapture) {
    currentRequestId = requestId;

    Intent intent = null;
    if (isCameraCapture) {
      intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
      intent.putExtra("return-data", true);
      intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(getTemporalFile(app)));
    } else {
      intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
    }
    app.getMainActivity().startActivityForResult(intent, REQUEST_IMAGE_CAPTURE);
  }

  public void onPeekImage(int resultCode, Intent intent) {
    boolean isOk = false;
    if (resultCode == Activity.RESULT_OK) {
      File imageFile = getTemporalFile(app);
      boolean isCamera = (intent == null
                          || intent.getData() == null
                          || intent.getData().toString().contains(imageFile.toString()));
      try {
        // InputStream stream = null;
        // if (isCamera) {
        //   stream = new FileInputStream(imageFile);

        //   getRotation(app, Uri.fromFile(imageFile), true);
          
        // } else {
        //   stream = app.getContentResolver().openInputStream(intent.getData());

        //   getRotation(app, intent.getData(), false);
        // }

        // BufferedInputStream bis = new BufferedInputStream(stream);
        // ByteArrayOutputStream buf = new ByteArrayOutputStream();

        // int result = bis.read();
        // while (result != -1) {
        //     buf.write((byte) result);
        //     result = bis.read();
        // }
        // stream.close();

        // onSuccess(nativePtr, currentRequestId, buf.toByteArray());

        Uri selectedImage = isCamera ? Uri.fromFile(imageFile) : intent.getData();
        int rotation = getRotation(app, selectedImage, isCamera);
        Bitmap bitmap = rotate(decodeBitmap(app, selectedImage),rotation);
        ByteArrayOutputStream byteOutptuStream = new ByteArrayOutputStream();  
        bitmap.compress(Bitmap.CompressFormat.JPEG, 90, byteOutptuStream); 
        byte[] byteArray = byteOutptuStream.toByteArray();
        byteOutptuStream.close();

        isOk = true;
        onSuccess(nativePtr, currentRequestId, byteArray);
      } catch (Exception ex) {
      }
    }

    if (!isOk) {
      onCancel(nativePtr, currentRequestId);
    }
  }

  public native void onSuccess(long nativePtr, long requestId, byte[] data);

  public native void onCancel(long nativePtr, long requestId);

  private File getTemporalFile(Context context) {
    return new File(context.getExternalCacheDir(), TEMP_IMAGE_NAME);
  }

  private Bitmap decodeBitmap(Context context, Uri uri) throws Exception {
    Bitmap result = null;
    AssetFileDescriptor fd = context.getContentResolver().openAssetFileDescriptor(uri, "r");
    result = BitmapFactory.decodeFileDescriptor(fd.getFileDescriptor());
    fd.close();

    return result;
  }

  private Bitmap rotate(Bitmap bitmap, int degrees) {
    Matrix matrix = new Matrix();
    matrix.postRotate(degrees);

    return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
  }

  private int getRotation(Context context, Uri imageUri, boolean fromCamera) {
    int rotation;
    if (fromCamera) {
      rotation = getRotationFromCamera(context, imageUri);
    } else {
      rotation = getRotationFromGallery(context, imageUri);
    }
    return rotation;
  }

  private int getRotationFromCamera(Context context, Uri imageFile) {
    int rotate = 0;
    try {

      context.getContentResolver().notifyChange(imageFile, null);
      ExifInterface exif = new ExifInterface(imageFile.getPath());
      int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                                             ExifInterface.ORIENTATION_NORMAL);

      switch (orientation) {
      case ExifInterface.ORIENTATION_ROTATE_270:
        rotate = 270;
        break;
      case ExifInterface.ORIENTATION_ROTATE_180:
        rotate = 180;
        break;
      case ExifInterface.ORIENTATION_ROTATE_90:
        rotate = 90;
        break;
      default:
        rotate = 0;
        break;
      }
    } catch (Exception e) {
    }
    return rotate;
  }

  private int getRotationFromGallery(Context context, Uri imageUri) {
    int result = 0;
    String[] columns = {MediaStore.Images.Media.ORIENTATION};
    Cursor cursor = null;
    try {
      cursor = context.getContentResolver().query(imageUri, columns, null, null, null);
      if (cursor != null && cursor.moveToFirst()) {
        int orientationColumnIndex = cursor.getColumnIndex(columns[0]);
        result = cursor.getInt(orientationColumnIndex);
      }
    } catch (Exception e) {
    } finally {
      if (cursor != null) {
        cursor.close();
      }
    }
    return result;
  }

  private long currentRequestId;
  private final long nativePtr;
  private final PhoenixApplication app;

  static final int REQUEST_IMAGE_CAPTURE = 1;
  static final String REQUEST_IMAGE_ID = "com.scade.phoenix.ImagePicker::requestId";

  private static final String TEMP_IMAGE_NAME = "com.scade.phoenix.ImagePicker_tempImage";
}

