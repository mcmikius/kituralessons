package com.scade.phoenix;

import android.content.Intent;
import android.app.Activity;
import android.view.View;
import android.view.Window;
import android.view.Surface;
import android.os.Bundle;
import android.os.StrictMode;
import android.view.WindowManager;
import android.content.res.Configuration;

public class MainActivity extends Activity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
    StrictMode.setVmPolicy(builder.build());

    // setting display view as content view
    PhoenixApplication app = (PhoenixApplication)getApplication();
    app.setMainActivity(this);

    // app.getDisplayView().setOnSystemUiVisibilityChangeListener
    //   (new View.OnSystemUiVisibilityChangeListener() {
    //       @Override
    //       public void onSystemUiVisibilityChange(int visibility) {
    //         // Note that system bars will only be "visible" if none of the
    //         // LOW_PROFILE, HIDE_NAVIGATION, or FULLSCREEN flags are set.
    //         if ((visibility & View.SYSTEM_UI_FLAG_FULLSCREEN) == 0) {
    //           android.util.Log.i("Phoenix", "#################### bar is
    //           visible");
    //         } else {
    //           android.util.Log.i("Phoenix", "#################### bar is
    //           unvisible");
    //         }
    //       }
    //     });

    // if (/*Build.VERSION.SDK_INT < 16*/true) {
    //   getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
    //                        WindowManager.LayoutParams.FLAG_FULLSCREEN);
    // }

    setContentView(app.getDisplayView());
  }

  @Override
  protected void onPause() {
    PhoenixApplication app = (PhoenixApplication)getApplication();
    app.onPause();

    super.onPause();
  }

  @Override
  protected void onResume() {
    PhoenixApplication app = (PhoenixApplication)getApplication();
    app.onResume();

    super.onResume();
  }

  @Override
  protected void onDestroy() {
    PhoenixApplication app = (PhoenixApplication)getApplication();
    app.setMainActivity(null);

    // removing display view from activity window
    setContentView(new View(getApplicationContext()));

    super.onDestroy();
  }

  public boolean isGrantPermission(String permission) {
    return
      android.support.v4.content.ContextCompat.checkSelfPermission(this, permission)
      == android.content.pm.PackageManager.PERMISSION_GRANTED;
  }

  public boolean isStatusBarVisible() {
    int flags = getWindow().getAttributes().flags;

    return (flags & WindowManager.LayoutParams.FLAG_FULLSCREEN) !=
        WindowManager.LayoutParams.FLAG_FULLSCREEN;
  }

  public boolean isPortraitScreenOrientation() {
    int rotation = getWindowManager().getDefaultDisplay().getRotation();

    return rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180;
  }

  public void setImagePicker(ImagePicker imagePicker) {
    this.imagePicker = imagePicker;
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode,
                                  Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    if (requestCode == ImagePicker.REQUEST_IMAGE_CAPTURE &&
        imagePicker != null) {
      imagePicker.onPeekImage(resultCode, data);
    }
  }

  private ImagePicker imagePicker;
}
