
package com.scade.phoenix;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.net.Uri;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.view.Display;
import android.view.Gravity;
import android.view.inputmethod.InputMethodManager;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.TimeZone;
import org.swift.swiftfoundation.SwiftFoundation;

// Global object that holds state of Phoenix application
public class PhoenixApplication extends Application {

  // Actual display view
  private DisplayView display;

  // Proxy for displaying crash reports instead
  private FrameLayout displayProxy;

  private boolean isStarted = false;

  private MainActivity mainActivity;

  public void onCreate() {
    android.util.Log.i("Phoenix", "PhoenixApplication.onCreate");

    // loading native libraries
    System.loadLibrary("c++_shared");
    System.loadLibrary("ScadeKit");

    // creating display view for Phoenix
    display = new DisplayView(this);
    displayProxy = new FrameLayout(this);
    FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT, android.view.Gravity.FILL);
    displayProxy.addView(display, params);

    WindowManager wManager =
        (WindowManager)getSystemService(Context.WINDOW_SERVICE);
    Display display = wManager.getDefaultDisplay();
    int width = display.getWidth();
    int height = display.getHeight();
    android.util.Log.i("Phoenix", "PhoenixApplication.onCreate width = " +
                                      width + ", height = " + height);

    // initializing swift foundation library and copying assets
    android.util.Log.i("Phoenix",
                       "PhoenixApplication.onCreate before foundation init");
    try {
      SwiftFoundation.Initialize(this, true);
    } catch (Exception err) {
      String errMsg = "Can't initialize swift foundation: " + err.toString();
      android.util.Log.e("Phoenix", errMsg);
    }

    android.util.Log.i("Phoenix",
                       "PhoenixApplication.onCreate after foundation init");

    // initializing Phoenix
    init(this, getBasePath());

    android.util.Log.i("Phoenix", "PhoenixApplication.onCreate end");
  }

  public void onTerminate() {
    // do we need Phoenix terminate? It looks like onTerminate
    // amost never called by Android
    // terminate();
  }

  // Returns reference to display view
  public View getDisplayView() { return displayProxy; }

  // Returns path to data directory. Called from Phoenix native code
  public String getBasePath() { return getApplicationInfo().dataDir; }

  public void getLocationOnScreen(int[] loc) {
    display.getLocationOnScreen(loc);
  }

  // Creates directory with specified path. Called from native Phoenix runtime.
  public boolean createDirectory(String path) {
    java.io.File file = new java.io.File(path);
    if (file.exists())
      return true;

    try {
      file.mkdir();
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  public void registerFont(String file) { PhoenixPaint.registerFont(file); }

  // Opens specified URL in browser. Called from native Phoenix runtime.
  public void openUrl(String url) {
    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
  }

  // Starts transition to specified phoenix view. Called from native Phoenix
  // runtime
  public void startTransition(PhoenixView from, PhoenixView to, long duration,
                              boolean fromRight, CRunnable runnable) {

    float displayWidth = (float)display.getWidth();

    View fromView = from.getView();
    View toView = to.getView();

    float fromViewEnd = fromRight ? -displayWidth : displayWidth;
    float toViewStart = fromRight ? displayWidth : -displayWidth;

    // creating translate animations for from and to views
    TranslateAnimation fromAnimation =
        new TranslateAnimation(0.0f, fromViewEnd, 0.0f, 0.0f);
    TranslateAnimation toAnimation =
        new TranslateAnimation(toViewStart, 0.0f, 0.0f, 0.0f);
    fromAnimation.setDuration(duration);
    toAnimation.setDuration(duration);

    final CRunnable r = runnable;
    fromAnimation.setAnimationListener(new Animation.AnimationListener() {
      public void onAnimationRepeat(Animation animation) {}
      public void onAnimationStart(Animation animation) {}
      public void onAnimationEnd(Animation animation) { r.run(); }
    });

    // starting animation
    fromView.startAnimation(fromAnimation);
    toView.startAnimation(toAnimation);
  }

  // Adds Phoenix view into display view
  public void addPhoenixView(PhoenixView view) { display.addPhoenixView(view); }

  // Removes Phoenix view from display view
  public void removePhoenixView(PhoenixView view) {
    display.removePhoenixView(view);
  }

  // Dumps tree of views to string
  public String dumpViewsTree() { return display.dumpViewsTree(); }

  public MainActivity getMainActivity() { return mainActivity; }

  public void setMainActivity(MainActivity mainActivity) {
    this.mainActivity = mainActivity;
  }

  public boolean isStatusBarVisible() {
    return getMainActivity().isStatusBarVisible();
  }

  public boolean isPortraitScreenOrientation() {
    return getMainActivity().isPortraitScreenOrientation();
  }

  // Reads list of scripts from scripts_list.txt
  private LinkedList<String> readAssetsList() {
    try {
      AssetManager assetManager = getAssets();
      InputStream in = assetManager.open("assets_list.txt");
      InputStreamReader reader = new InputStreamReader(in);
      BufferedReader breader = new BufferedReader(reader);

      LinkedList<String> res = new LinkedList<String>();

      while (true) {
        String line = breader.readLine();
        if (line == null)
          break;

        if (line.equals(""))
          continue;

        res.add(line);
      }

      breader.close();
      reader.close();
      in.close();

      return res;
    } catch (Exception e) {
      android.util.Log.e("Phoenix",
                         "Can't read scripts list: " + e.getMessage());
      return null;
    }
  }

  // Copies assets from specified path to data directory
  private void copyAssets() {
    // reading list of assets
    LinkedList<String> files = readAssetsList();
    if (files == null)
      return;

    // copying all assets
    Iterator<String> it = files.iterator();
    while (it.hasNext()) {
      String fileName = it.next();

      String outPath = getBasePath() + "/" + fileName;
      File file = new File(outPath);

      // creating parent directories if not exist
      File dir = file.getParentFile();
      dir.mkdirs();

      // copying file
      // android.util.Log.i("Phoenix", "before copy file: " + fileName);
      copyFile(fileName);
      // android.util.Log.i("Phoenix", "after copy file: " + fileName);
    }
  }

  // Copies file from assets to data directory
  private void copyFile(String filename) {
    AssetManager assetManager = getAssets();
    String newFileName = getBasePath() + "/" + filename;

    try {
      InputStream in = assetManager.open(filename);
      OutputStream out = new FileOutputStream(newFileName);

      byte[] buffer = new byte[1024];
      int read;
      while ((read = in.read(buffer)) != -1) {
        out.write(buffer, 0, read);
      }

      in.close();
      out.flush();
      out.close();
    } catch (Exception e) {
      android.util.Log.e("Phoenix", "Can't copy file from '" + filename +
                                        "' to '" + newFileName +
                                        "':" + e.getMessage());
    }
  }

  // Returns list of files contained in directory and its subdirectories.
  // Called from native code
  public String[] listFiles(String dir) {
    ArrayList<String> res = new ArrayList<String>();
    if (!doListFiles(dir, res)) {
      return null;
    }

    return res.toArray(new String[res.size()]);
  }

  private boolean doListFiles(String dir, ArrayList<String> list) {
    File dirFile = new File(dir);
    File[] files = dirFile.listFiles();
    if (files == null) {
      return false;
    }

    for (File f : files) {
      if (f.isDirectory()) {
        if (!doListFiles(f.getAbsolutePath(), list)) {
          return false;
        }
      } else {
        list.add(f.getAbsolutePath());
      }
    }

    return true;
  }

  // Displays application crash message in separate activity.
  public void displayCrashReport(String text) {
    LinearLayout layout = new LinearLayout(this);
    layout.setOrientation(LinearLayout.VERTICAL);

    android.widget.TextView errorTextView = new android.widget.TextView(this);
    errorTextView.setBackgroundColor(android.graphics.Color.BLUE);
    errorTextView.setTextColor(android.graphics.Color.WHITE);
    errorTextView.setTextIsSelectable(true);
    errorTextView.setHorizontallyScrolling(true);

    final String errorText =
        "Scade application has crashed.\nPlease report this bug to "
        + "application developers.\n"
        + "\n"
        + "Crash details:\n"
        + "\n" + text;
    errorTextView.setText(errorText);

    LinearLayout.LayoutParams errorTextLParams = new LinearLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT, 0, 1);
    layout.addView(errorTextView, errorTextLParams);

    // exit button
    android.widget.Button exitButton = new android.widget.Button(this);
    exitButton.setText("Exit");
    exitButton.setOnClickListener(new View.OnClickListener() {
      public void onClick(View v) { throw new RuntimeException(errorText); }
    });

    layout.addView(exitButton);

    displayProxy.removeAllViews();
    displayProxy.addView(layout);
  }

  // Sets display size and starts app if not started
  public void setDisplaySizeAndStartIfNotStarted(int width, int height) {
    if (isStarted) {
      setDisplaySize(width, height);
    } else {
      start(width, height);
      isStarted = true;
    }
  }

  // Hides software keyboard if it's shown
  public void hideKeyboard() {
    if (mainActivity == null) {
      return;
    }

    View view = mainActivity.getCurrentFocus();
    if (view == null) {
      return;
    }

    InputMethodManager imm =
        (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
    imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
  }

  // Exits from application
  public void exit() { System.exit(0); }

  // Returns current timezone
  public String getCurrentTimezone() { return TimeZone.getDefault().getID(); }

  // Returns true if google maps API key is set
  public boolean isGoogleMapsApiKeySet() throws java.lang.Exception {
    PackageManager pManager = getPackageManager();
    ApplicationInfo appInfo = pManager.getApplicationInfo(
        getPackageName(), PackageManager.GET_META_DATA);
    android.os.Bundle bundle = appInfo.metaData;
    return !bundle.getString("com.google.android.geo.API_KEY").isEmpty();
  }

  public void onResume() {
    onEnterForeground();
  }

  public void onPause() {
    onEnterBackground();
  }

  // Initializes Phoenix and starts lua scripts.
  native private void init(Context ctx, String basePath);

  // Starts Phoenix app
  native private void start(int width, int height);

  // Terminates Phoenix
  native private void terminate();

  // Notifies Phoenix about changing display size
  native private void setDisplaySize(int width, int height);

  // Returns display scale factor used by native part
  native public float getScaleFactor();

  native private void onEnterBackground();

  native private void onEnterForeground();
}
