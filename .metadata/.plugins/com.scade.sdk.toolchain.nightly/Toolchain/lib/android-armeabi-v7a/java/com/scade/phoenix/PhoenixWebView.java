package com.scade.phoenix;

import android.webkit.*;
import android.view.View;

public class PhoenixWebView extends PhoenixView {

  private class MyWebViewClient extends WebViewClient {

    public MyWebViewClient(PhoenixWebView webView) {
      m_webView = webView;
    }

    // @Override
    // boolean shouldOverrideUrlLoading (WebView view, WebResourceRequest request) {
    //   return false;
    // }

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
      return !onShouldLoad(m_webView.getNativeView(), url);
    }

    @Override
    public void onPageCommitVisible(WebView view, String url) {
      onLoad(m_webView.getNativeView(), url);
      //android.util.Log.i("Phoenix", "onPageCommitVisible: '" + url + "'");
    }

    @Override
    public void onReceivedError (WebView view, WebResourceRequest request, WebResourceError error) {
      onLoadFailed(m_webView.getNativeView(), request.getUrl().toString(),
                   error.getDescription().toString());
      //android.util.Log.i("Phoenix", "onReceivedError" + error.getDescription());
    }

    @Override
    public void onReceivedHttpError (WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
      onLoadFailed(m_webView.getNativeView(), request.getUrl().toString(),
                   errorResponse.getReasonPhrase().toString());
      //android.util.Log.i("Phoenix", "onReceivedHttpError" + errorResponse.getReasonPhrase());
    }

    // @Override
    // public void onBackPressed() {
    //   if (mWebView.canGoBack()) {
    //     mWebView.goBack();
    //   } else {
    //     super.onBackPressed();
    //   }
    // }

    private final PhoenixWebView m_webView;
  }

  PhoenixWebView(PhoenixApplication a, long nView) {
    super(a, nView);
    m_impl = new WebView(app);
    m_impl.setWebViewClient(new MyWebViewClient(this));
    m_impl.getSettings().setJavaScriptEnabled(true);
    //m_impl.onCreate(new android.os.Bundle());
    m_impl.onResume();
  }

  public void loadUrl(String url) {
    m_impl.loadUrl(url);
  }

  public void eval(final long handlerId, String script) {
    m_impl.evaluateJavascript(script, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String result) {
          //android.util.Log.i("Phoenix", "evaluateJavascript: '" + s + "'");
          onEval(getNativeView(), handlerId, result);
        }
      });
  }

  public native void onLoad(long nativeView, String url);

  public native boolean onShouldLoad(long nativeView, String url);

  public native void onLoadFailed(long nativeView, String url, String message);

  public native void onEval(long nativeView, long handlerId, String result);

  protected View getView() {
    return m_impl;
  }

  private final WebView m_impl;
}

