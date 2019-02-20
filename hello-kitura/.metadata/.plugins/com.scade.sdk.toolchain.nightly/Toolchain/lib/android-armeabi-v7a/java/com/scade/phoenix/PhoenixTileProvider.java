package com.scade.phoenix;

import java.io.*;
import java.util.concurrent.*;
import android.graphics.*;
import android.content.*;
import android.util.*;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;


public class PhoenixTileProvider implements TileProvider {

  static class Point {
    final double x;
    final double y;

    public Point(double x, double y) {
      this.x = x;
      this.y = y;
    }

    public boolean isSame(Point p) {
      return eq(x, p.x) && eq(y, p.y);
    }
  }

  static class Size {
    final double width;
    final double height;

    public Size(double width, double height) {
      this.width = width;
      this.height = height;
    }
  }

  static class Rect {
    final Point origin;
    final Size size;;

    public Rect(Point origin, Size size) {
      this.origin = origin;
      this.size = size;
    }

    public Rect(double x, double y, double width, double height) {
      this.origin = new Point(x, y);
      this.size = new Size(width, height);
    }

    public Rect(final Point left, final Point right) {
      this.origin = new Point(Math.min(left.x, right.x), Math.min(left.y, right.y));
      this.size = new Size(Math.abs(left.x - right.x),
                           Math.abs(left.y - right.y));
    }

    public Point getCenter() {
      return new Point(origin.x + size.width / 2.0, origin.y + size.height / 2.0);
    }
    
  }

  public PhoenixTileProvider(MainActivity mainActivity, long nativePointer,
                             double x, double y, double width, double height) {

    this.mainActivity = mainActivity;
    this.nativePointer = nativePointer;
    m_bounds = new Rect(x, y, width, height);

    mScaleFactor = 2.2f;
    //mScaleFactor = 1.0f;
    m_tileSize = (int)(TILE_SIZE_DP * mScaleFactor);

    Paint borderPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    borderPaint.setStyle(Paint.Style.STROKE);
    mBorderTile = Bitmap.createBitmap(m_tileSize, m_tileSize, android.graphics.Bitmap.Config.ARGB_8888);

    // Canvas canvas = new Canvas(mBorderTile);
    // canvas.drawRect(0, 0, m_tileSize, m_tileSize, borderPaint);
  }

  @Override
  public Tile getTile(int x, int y, int zoom) {
    final Point p1 = to2DPoint(x, y, zoom);
    final Point p2 = to2DPoint(x + 1, y + 1, zoom);
    final Rect rect = new Rect(p1, p2);

    if (!isIntersects(rect)) {
      return null;
    }
    
    final int xParam = x;
    final int yParam = y;
    final int zoomParam = zoom;
    final Rect rectParam = new Rect(p1, rect.size);

    double diffY = 0.0;
    if (!p1.isSame(rect.origin)) {
      diffY = 2.0 * (p1.y - m_bounds.getCenter().y);
    }

    final double diffYParam = diffY;


    //return getTileOnUIThread(xParam, yParam, zoomParam, rectParam);

    FutureTask<Tile> futureResult = new FutureTask<Tile>(new Callable<Tile>() {
        @Override
        public Tile call() throws Exception {
          return getTileOnUIThread(xParam, yParam, zoomParam, rectParam, diffYParam);
        }
      });

    mainActivity.runOnUiThread(futureResult);
    Tile res = null;
    try {
      res = futureResult.get();
    } catch (Exception e) {
    }
    
    return res;
  }

  private Tile getTileOnUIThread(final int x, final int y, final int zoom, final Rect rect,
                                 final double diffY) {
    Bitmap coordTile = drawTileCoords(x, y, zoom, rect, diffY);
    ByteArrayOutputStream stream = new ByteArrayOutputStream();
    coordTile.compress(Bitmap.CompressFormat.PNG, 0, stream);
    byte[] bitmapData = stream.toByteArray();

    return new Tile(m_tileSize, m_tileSize, bitmapData);
  }

  public native void render(Canvas canv, long nativePointer,
                            double x, double y, double width, double height,
                            double tileWidth, double tileHeight, double diffY);

  private Bitmap drawTileCoords(int x, int y, int zoom, Rect rect, double diffY) {
    Bitmap copy = null;
    synchronized (mBorderTile) {
      copy = mBorderTile.copy(android.graphics.Bitmap.Config.ARGB_8888, true);
    }
    Canvas canvas = new Canvas(copy);




    // Paint circlePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    // circlePaint.setStyle(Paint.Style.FILL);
    // circlePaint.setARGB(255, 255, 0, 0);
    // canvas.save();

    // canvas.scale((float)(m_tileSize / rect.size.width),
    //              (float)(-1.0 * m_tileSize / rect.size.height));
    // canvas.translate((float)(-rect.origin.x), (float)(-rect.origin.y));
    
    // canvas.drawCircle(2345622, 7293814, 10, circlePaint);
    // canvas.restore();

    render(canvas, nativePointer, rect.origin.x, rect.origin.y,
           rect.size.width, rect.size.height, m_tileSize, m_tileSize, diffY);


    //String tileCoords = "(" + x + ", " + y + ")";
    // String tileCoords = "(" + (long)x + ", " + (long)y + ")";
    // String zoomLevel = "zoom = " + zoom;
    // float bound = m_tileSize / 2.0f;

    // Paint rectPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    // rectPaint.setStyle(Paint.Style.FILL);
    // canvas.drawRect(0, 0, bound, bound, rectPaint);

    // Paint mTextPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    // mTextPaint.setTextAlign(Paint.Align.CENTER);
    // mTextPaint.setTextSize(18 * mScaleFactor);
    // canvas.drawText(tileCoords, bound, bound, mTextPaint);
    // canvas.drawText(zoomLevel, bound, m_tileSize / 3, mTextPaint);

    return copy;
  }

  private Point to2DPoint(int x, int y, int zoom) {
    //http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Java
    double latExp = Math.PI - (2.0 * Math.PI * y) / Math.pow(2.0, zoom);
    double lat =  Math.toDegrees(Math.atan(Math.sinh(latExp)));
    double lng = x / Math.pow(2.0, zoom) * 360.0 - 180;

    //http://wiki.openstreetmap.org/wiki/Mercator#Java
    double xPoint = Math.toRadians(lng) * RADIUS;
    double yPoint = Math.log(Math.tan(Math.PI / 4 + Math.toRadians(lat) / 2)) * RADIUS;

    return new Point(xPoint, yPoint);
  }

  private boolean isIntersects(final Rect rect) {
    boolean res = 
      le(rect.origin.x, m_bounds.origin.x + m_bounds.size.width) &&
      ge(rect.origin.x + rect.size.width, m_bounds.origin.x) &&
      le(rect.origin.y, m_bounds.origin.y + m_bounds.size.height) &&
      ge(rect.origin.y + rect.size.height, m_bounds.origin.y);

    return res;
  }

  private static boolean ge(double left, double right) {
    return (left - right) >= eps;
  }

  private static boolean le(double left, double right) {
    return (right - left) >= eps;
  }

  private static boolean eq(double left, double right) {
    return Math.abs(left - right) <= eps;
  }

  private static final int TILE_SIZE_DP = 256;

  private static final double eps = 0.000001;

  private static final double RADIUS = 6378137.0;

  private final float mScaleFactor;

  private final int m_tileSize;

  private final Bitmap mBorderTile;

  private final Rect m_bounds;

  private final long nativePointer;

  private final MainActivity mainActivity;
}
