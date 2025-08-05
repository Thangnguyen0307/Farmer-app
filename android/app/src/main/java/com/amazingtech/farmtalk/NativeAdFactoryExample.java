package com.amazingtech.farmtalk;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;
import com.google.android.gms.ads.nativead.MediaView;

import java.util.Map;

import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class NativeAdFactoryExample implements GoogleMobileAdsPlugin.NativeAdFactory {
    private final Activity activity;

    public NativeAdFactoryExample(Activity activity) {
        this.activity = activity;
    }

    @Override
    public NativeAdView createNativeAd(NativeAd nativeAd, Map<String, Object> customOptions) {
        LayoutInflater inflater = LayoutInflater.from(activity);
        NativeAdView adView = (NativeAdView) inflater.inflate(R.layout.native_ad_layout, null);

        // Headline
        TextView headlineView = adView.findViewById(R.id.ad_headline);
        headlineView.setText(nativeAd.getHeadline());
        adView.setHeadlineView(headlineView);

        // Body
        TextView bodyView = adView.findViewById(R.id.ad_body);
        if (nativeAd.getBody() != null) {
            bodyView.setText(nativeAd.getBody());
            adView.setBodyView(bodyView);
        } else {
            bodyView.setVisibility(View.GONE);
        }

        // Advertiser
        TextView advertiserView = adView.findViewById(R.id.ad_advertiser);
        if (nativeAd.getAdvertiser() != null) {
            advertiserView.setText(nativeAd.getAdvertiser());
            adView.setAdvertiserView(advertiserView);
        } else {
            advertiserView.setVisibility(View.GONE);
        }

        // Icon
        ImageView iconView = adView.findViewById(R.id.ad_app_icon);
        if (nativeAd.getIcon() != null) {
            iconView.setImageDrawable(nativeAd.getIcon().getDrawable());
            adView.setIconView(iconView);
        } else {
            iconView.setVisibility(View.GONE);
        }

        // Media image
        MediaView mediaView = adView.findViewById(R.id.ad_media);
        adView.setMediaView(mediaView);

        // CTA button
        Button ctaButton = adView.findViewById(R.id.ad_call_to_action);
        if (nativeAd.getCallToAction() != null) {
            ctaButton.setText(nativeAd.getCallToAction());
            adView.setCallToActionView(ctaButton);
        } else {
            ctaButton.setVisibility(View.GONE);
        }

        adView.setNativeAd(nativeAd);
        return adView;
    }
}
