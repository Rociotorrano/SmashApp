package com.example.smashapp

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import com.google.android.gms.ads.MobileAds

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MobileAds.initialize(this) {}
    }
}
