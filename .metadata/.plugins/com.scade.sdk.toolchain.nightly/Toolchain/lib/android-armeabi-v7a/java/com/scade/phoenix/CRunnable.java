package com.scade.phoenix;

import android.os.Handler;
import android.os.Looper;

public class CRunnable implements Runnable{

	native public void cRun();

	private long cRunableRef = 0;
	
	public CRunnable(long cRef) {
		cRunableRef = cRef;
	}
	
	public void runOnUiThread() {
		if(Looper.myLooper() == Looper.getMainLooper()) {
			this.cRun();
		} else {
			synchronized (this) {
				Handler h = new Handler(Looper.getMainLooper());
				h.post(this);
				try {
					this.wait();
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
			
		}
	}
	
	@Override
	public void run() {
		this.cRun();
		synchronized(this) {
	      this.notify();
		}
	}


}
