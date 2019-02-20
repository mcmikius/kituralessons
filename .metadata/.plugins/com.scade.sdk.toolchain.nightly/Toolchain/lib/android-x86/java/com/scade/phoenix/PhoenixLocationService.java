package com.scade.phoenix;

import java.util.Arrays;

import android.app.AlertDialog;
import android.app.Service;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.Settings;
import android.util.Log;
 
public class PhoenixLocationService extends Service implements LocationListener {
 
  private final Context mContext;
 
  private Location m_location; // location
 
  // The minimum distance to change Updates in meters
  private static final long MIN_DISTANCE_CHANGE_FOR_UPDATES = 10; // 10 meters
 
  // The minimum time between updates in milliseconds
  private static final long MIN_TIME_BW_UPDATES = 1000 * 60 * 1; // 1 minute
 
  // Declaring a Location Manager
  protected LocationManager m_locationManager;
 
  public PhoenixLocationService(Context context) {
    this.mContext = context;
  }
 
  public void checkLocation() {
    if (m_location == null) {
      try {
        m_locationManager = (LocationManager) mContext.getSystemService(LOCATION_SERVICE);

        for (String provider : Arrays.asList(LocationManager.NETWORK_PROVIDER, LocationManager.GPS_PROVIDER)) {
          if (m_locationManager.isProviderEnabled(provider)) {
            m_locationManager.requestLocationUpdates(provider, MIN_TIME_BW_UPDATES,
                                                   MIN_DISTANCE_CHANGE_FOR_UPDATES, this);
            m_location = m_locationManager.getLastKnownLocation(provider);
            break;
          }
        }
      } catch (Exception e) {
      }
    }
  }

  public Location getLocation() {
    return m_location;
  }
     
  /**
   * Stop using GPS listener
   * Calling this function will stop using GPS in your app
   * */
  public void stopUsingGPS(){
    if (m_locationManager != null) {
      m_locationManager.removeUpdates(PhoenixLocationService.this);
    }       
  }
     
  @Override
  public void onLocationChanged(Location location) {
    m_location = location;
  }
 
  @Override
  public void onProviderDisabled(String provider) {
  }
 
  @Override
  public void onProviderEnabled(String provider) {
  }
 
  @Override
  public void onStatusChanged(String provider, int status, Bundle extras) {
  }
 
  @Override
  public IBinder onBind(Intent arg0) {
    return null;
  }
 
}
