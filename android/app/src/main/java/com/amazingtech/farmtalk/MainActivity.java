package com.amazingtech.farmtalk;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    GoogleMobileAdsPlugin.registerNativeAdFactory(
      flutterEngine,
      "native_ad_factory",
      new NativeAdFactoryExample(this)
    );
  }

  @Override
  public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "native_ad_factory");
    super.cleanUpFlutterEngine(flutterEngine);
  }
}
