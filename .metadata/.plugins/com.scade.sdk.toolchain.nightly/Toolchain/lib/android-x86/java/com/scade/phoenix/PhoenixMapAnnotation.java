package com.scade.phoenix;

import android.graphics.*;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;

public class PhoenixMapAnnotation {

  public PhoenixMapAnnotation(Bitmap bitmap) {
    this.bitmap = bitmap;
  }

  public Bitmap getBitmap() {
    return bitmap;
  }

  public void setLocation(LatLng location) {
    this.location = location;
  }

  public LatLng getLocation() {
    return location;
  }

  public void setMarker(Marker marker) {
    this.marker = marker;
  }

  public Marker getMarker() {
    return marker;
  }

  public boolean isRendered() {
    return rendered;
  }

  public void setRendered(boolean rendered) {
    this.rendered = rendered;
  }

  private Bitmap bitmap;
  private LatLng location;
  private Marker marker;
  private boolean rendered = false;
}
