import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatelessWidget {
  final NativeAd ad;
  const NativeAdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: SizedBox(height: 350, child: AdWidget(ad: ad)),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}
