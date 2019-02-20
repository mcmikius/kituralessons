package com.scade.phoenix;

import java.util.*;
import java.nio.ByteBuffer;
import android.util.*;
import android.hardware.camera2.*;
import android.view.*;
import android.graphics.*;
import android.content.Context;
import android.util.Log;
import android.hardware.camera2.params.StreamConfigurationMap;

public class PhoenixVideoCapture extends PhoenixView implements TextureView.SurfaceTextureListener {
  private TextureView m_view = null;

  private CameraManager m_manager;
  private CameraCaptureSession m_session;
  private String m_cameraId;
  private Size m_cameraSize;
  private CameraDevice m_device = null;

  private long m_duration = 1000;
  private long m_millis = 0;


  public PhoenixVideoCapture(PhoenixApplication app, long nView) {
    super(app, nView);

    m_view = new TextureView(app);
    m_view.setSurfaceTextureListener(this);

    try {
      m_manager = (CameraManager)app.getMainActivity().getSystemService(Context.CAMERA_SERVICE);
      for (String cameraId : m_manager.getCameraIdList()) {
        CameraCharacteristics cc = m_manager.getCameraCharacteristics(cameraId);
        if (CameraCharacteristics.LENS_FACING_BACK == cc.get(CameraCharacteristics.LENS_FACING)) {
          StreamConfigurationMap cm = cc.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
          Size[] jpegSizes = cm.getOutputSizes(ImageFormat.JPEG);
          if (jpegSizes != null) {
            m_cameraId = cameraId;
            m_cameraSize = jpegSizes[jpegSizes.length - 1];
          }
        }
      }
    } catch (CameraAccessException e) {
      Log.e("Phoenix", "Can't get camera info: " + e.getMessage());
    }
  }

  // Returns reference to Android view for phoenix view
  @Override
  protected View getView() {
    return m_view;
  }


  @Override
  public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
  }

  @Override
  public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
  }

  @Override
  public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
    return true;
  }

  @Override
  public void onSurfaceTextureUpdated(SurfaceTexture surface) {
    if (System.currentTimeMillis() >= m_millis) {
      Bitmap bitmap = m_view.getBitmap();
      int size = bitmap.getRowBytes() * bitmap.getHeight();
      ByteBuffer byteBuffer = ByteBuffer.allocate(size);
      bitmap.copyPixelsToBuffer(byteBuffer);
      onCapture(getNativeView(), bitmap.getWidth(), bitmap.getHeight(), bitmap.getRowBytes(), byteBuffer.array());
      
      //Log.i("Phoenix", "onSurfaceTextureUpdated: " + bmp.getConfig() + " -> " + bmp.getWidth() + "\\" + bmp.getHeight());

      m_millis = System.currentTimeMillis() + m_duration;
    }
  }

  public void start() {
    try {
      if (m_device == null) {
        if (app.getMainActivity().isGrantPermission(android.Manifest.permission.CAMERA)) {
          m_manager.openCamera(m_cameraId, m_cameraCallback, null);
        } else {
          Log.i("Phoenix", "Application not granted CAMERA permission");
        }
      }
    } catch (CameraAccessException e) {
      Log.i("Phoenix", "Can't start camera: " + m_cameraId);
    }
  }

  public void stop() {
    if (m_device != null) {
      m_device.close();
      m_device = null;
    }
  }

  public void setFPS(int value) {
    m_duration = 1000 / Math.max(value, 1);
  }

  public native void onCapture(long nativeView, int width, int height, int bytesPerRow, byte[] buffer);

  private void createCameraPreviewSession() {
    SurfaceTexture texture = m_view.getSurfaceTexture();
    texture.setDefaultBufferSize(m_cameraSize.getWidth(), m_cameraSize.getHeight());
    Surface surface = new Surface(texture);
    
    try {
      final CaptureRequest.Builder builder = m_device.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
      builder.addTarget(surface);
      m_device.createCaptureSession(Arrays.asList(surface),
                                    new CameraCaptureSession.StateCallback() {
                                      @Override
                                      public void onConfigured(CameraCaptureSession session) {
                                        m_session = session;
                                        try {
                                          m_session.setRepeatingRequest(builder.build(),null,null);
                                        } catch (CameraAccessException e) {
                                          Log.i("Phoenix", "Can't configure capture session");
                                        }
                                      }

                                      @Override
                                      public void onConfigureFailed(CameraCaptureSession session) {
                                      }
                                    },
                                    null);
    } catch (CameraAccessException e) {
      Log.i("Phoenix", "Can't createCaptureRequest");
    }
  }

  private CameraDevice.StateCallback m_cameraCallback = new CameraDevice.StateCallback() {
      @Override
      public void onOpened(CameraDevice camera) {
        m_device = camera;
        createCameraPreviewSession();
        //Log.i("Phoenix", "Open camera  with id:" + camera.getId());
      }

      @Override
      public void onDisconnected(CameraDevice camera) {
        m_device.close();
        //Log.i("Phoenix", "disconnect camera with id:" + camera.getId());
        m_device = null;
      }
      @Override
      public void onError(CameraDevice camera, int error) {
        Log.i("Phoenix", "error! camera id:" + camera.getId() + " error:" + error);
      } 
    };

}

