package com.scade.phoenix;

import android.graphics.*;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;

public class PhoenixMapOverlay {

  public PhoenixMapOverlay(Bitmap bitmap, LatLng location, double width, double height) {
    this.bitmap = bitmap;
    this.location = location;
  }

  public void setBitmap(Bitmap bitmap) {
    this.bitmap = bitmap;
  }

  public Bitmap getBitmap() {
    return bitmap;
  }

  public LatLng getLocation() {
    return location;
  }

  public double getWidth() {
    return width;
  }

  public double getHeight() {
    return height;
  }

  public void setBounds(double width, double height) {
    this.width = width;
    this.height = height;
  }

  public void setLocation(LatLng location) {
    this.location = location;
  }

  public GroundOverlay getOverlay() {
    return overlay;
  }

  public void setOverlay(GroundOverlay overlay) {
    this.overlay = overlay;
  }

  private Bitmap bitmap;
  private LatLng location;
  private GroundOverlay overlay;
  private double width;
  private double height;
}
