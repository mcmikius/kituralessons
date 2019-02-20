package com.scade.phoenix;

import java.util.*;

import android.content.Context;
import android.graphics.*;
import android.location.Location;
import android.view.View;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;


public class PhoenixMap extends PhoenixView {
  private MapView m_impl = null;
  private GoogleMap m_map = null;
  private PhoenixLocationService m_locationService;
  private Set<PhoenixMapAnnotation> m_annotations = new HashSet<PhoenixMapAnnotation>();
  private Set<PhoenixTileProvider> m_overlays = new HashSet<PhoenixTileProvider>();

  // saved value to apply after map is ready
  boolean m_savedPosition = false;
  double m_savedLatitude = 0.0;
  double m_savedLongitude = 0.0;
  float m_savedZoom = 0.0f;
  boolean m_enabledLocation = false;

  int m_savedMapType = 0;

  PhoenixMap(PhoenixApplication app, long nView) {
    super(app, nView);
    m_impl = new MapView(app);
    m_impl.setBackgroundColor(android.graphics.Color.RED);
    m_impl.onCreate(new android.os.Bundle());
    m_impl.onResume();
    m_impl.getMapAsync(new OnMapReadyCallback() {
        public void onMapReady(GoogleMap m) {
          m_map = m;

          m_map.setMyLocationEnabled(m_enabledLocation);

          if (m_savedPosition) {
            moveTo(m_savedLatitude, m_savedLongitude, m_savedZoom);
          }

          if (m_savedMapType != 0) {
            setMapType(m_savedMapType);
          }


          for (PhoenixMapAnnotation ann : m_annotations) {
            registerAnnotation(ann);
          }

          for (PhoenixTileProvider ov : m_overlays) {
            registerOverlay(ov);
          }
          // m_map.addMarker(new MarkerOptions()
          //                 //.anchor(0.0f, 0.0f)
          //                 .position(new LatLng(54.647825, 21.071088)));

          //android.util.Log.i("Phoenix", "================== map ready ====================");
        }
      });
    m_locationService = new PhoenixLocationService(app);
  }

  // Returns reference to Android view for phoenix view
  protected View getView() {
    return m_impl;
  }


  // Moves map to specified position
  public void moveTo(double latitude, double longitude, float zoom) {
    if (m_map != null) {
      LatLng latLng = new LatLng(latitude, longitude);
      CameraUpdate cameraUpdate = CameraUpdateFactory.newLatLngZoom(latLng, zoom);
      m_map.animateCamera(cameraUpdate);
    } else {
      m_savedPosition = true;
      m_savedLatitude = latitude;
      m_savedLongitude = longitude;
      m_savedZoom = zoom;
    }
  }


  // Sets map type
  public void setMapType(int type) {
    if (m_map != null) {
      m_map.setMapType(type);
    } else {
      m_savedMapType = type;
    }
  }


  // Sets my location enabled/disabled
  public void setMyLocationEnabled(boolean enabled) {
    if (enabled) {
      m_locationService.checkLocation();
    } else {
      m_locationService.stopUsingGPS();
    }

    m_enabledLocation = enabled;
    if (m_map != null) {
      m_map.setMyLocationEnabled(m_enabledLocation);
    }
  }


  // Returns camera position
  public CameraPosition getCameraPosition() {
    if (m_map != null) {
      return m_map.getCameraPosition();
    } else {
      return null;
    }
  }


  // Returns current location of device
  public LatLng getMyLocation() {
    LatLng res = null;
    Location loc = m_locationService.getLocation();
    if (loc != null) {
      res = new LatLng(loc.getLatitude(), loc.getLongitude());
    }
    return res;
  }

  public void addAnnotation(Bitmap bitmap, double latitude, double longitude) {
    PhoenixMapAnnotation result = null;
    for (PhoenixMapAnnotation ann : m_annotations) {
      if (ann.getBitmap() == bitmap) {
        result = ann;
        break;
      }
    }

    if (result == null) {
      result = new PhoenixMapAnnotation(bitmap);
      m_annotations.add(result);
    }

    result.setLocation(new LatLng(latitude, longitude));
    
    if (m_map != null) {
      registerAnnotation(result);
    }

    result.setRendered(false);
  }

  public void addOverlay(long nativePtr, double x, double y, double width, double height) {
    MainActivity activity = ((PhoenixApplication)m_impl.getContext()).getMainActivity();
    PhoenixTileProvider tileProvider = new PhoenixTileProvider(activity, nativePtr, x, y, width, height);
    if (m_map == null) {
      m_overlays.add(tileProvider);
    } else {
      registerOverlay(tileProvider);
    }
    
  }

  private void registerAnnotation(PhoenixMapAnnotation ann) {
    if (!ann.isRendered()) {
      if (ann.getMarker() != null) {
        ann.getMarker().remove();
      }

      Marker marker = m_map.addMarker(new MarkerOptions()
                                      //.anchor(1.0f, 1.0f)
                                      .icon(BitmapDescriptorFactory.fromBitmap(ann.getBitmap()))
                                      .position(ann.getLocation()));
                    
      ann.setMarker(marker);
      ann.setRendered(true);

      // m_map.addMarker(new MarkerOptions()
      //                 //.anchor(0.0f, 0.0f)
      //                 .position(new LatLng(54.647825, 21.071088)));
    }
  }

  private void registerOverlay(PhoenixTileProvider tileProvider) {
    m_map.addTileOverlay(new TileOverlayOptions().tileProvider(tileProvider));
  }

}

