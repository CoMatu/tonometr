import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

class YandexBannerAdWidget extends StatefulWidget {
  final String adUnitId;
  const YandexBannerAdWidget({super.key, required this.adUnitId});

  @override
  State<YandexBannerAdWidget> createState() => _YandexBannerAdWidgetState();
}

class _YandexBannerAdWidgetState extends State<YandexBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isBannerAlreadyCreated = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Platform.isAndroid && !_isBannerAlreadyCreated && !hasError) {
      _loadAd();
    }
  }

  BannerAdSize _getAdSize() {
    final screenWidth = MediaQuery.of(context).size.width.round();
    return BannerAdSize.sticky(width: screenWidth);
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      adSize: _getAdSize(),
      adRequest: const AdRequest(),
      onAdLoaded: () {
        if (!mounted) {
          _bannerAd?.destroy();
          return;
        }
        setState(() {
          _isBannerAlreadyCreated = true;
          hasError = false;
        });
      },
      onAdFailedToLoad: (error) {
        setState(() {
          _isBannerAlreadyCreated = false;
          hasError = true;
        });
      },
      onAdClicked: () {},
      onLeftApplication: () {},
      onReturnedToApplication: () {},
      onImpression: (impressionData) {},
    );
    _bannerAd!.loadAd(adRequest: const AdRequest());
  }

  @override
  void dispose() {
    _bannerAd?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }
    final height = 100.0;
    return SizedBox(
      height: height,
      width: double.infinity,
      child:
          _isBannerAlreadyCreated && _bannerAd != null
              ? AdWidget(bannerAd: _bannerAd!)
              : Container(), // Оставляем место даже если ошибка
    );
  }
}
