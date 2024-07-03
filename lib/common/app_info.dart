import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class AppInfo {
  AppInfo._();

  static const name = 'trainers_stopwatch';
  static const description = 'Multiple Precision Chronometers.';
  static const version = '1.0.0+32';

  static get pageUrl => 'https://rralves.dev.br/en/$name/';
  static const email = 'alvesdev67@gmail.com';
  static const privacyPolicyUrl = 'https://rralves.dev.br/en/privacy-policy-en/';
  
  static Future<void> launchUrl(String url) async {
    final uri = Uri.parse(url);

    // copy link to clipboard
    await copyUrl(url);

    // open link in browser
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri);
    } else {
      log("URL can't be launched.");
    }
  }

  static Future<void> copyUrl(String url) async {
    // copy link to clipboard
    await Clipboard.setData(ClipboardData(text: url));
  }

  static Future<void> launchMailto() async {
    Uri url = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': '[] - <Your Subject text>'},
    );
    await launcher.launchUrl(url);
  }
}
