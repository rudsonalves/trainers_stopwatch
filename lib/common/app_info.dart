// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class AppInfo {
  AppInfo._();

  static const name = 'trainers_stopwatch';
  static const description = 'Multiple Precision Chronometers.';
  static const version = '1.0.6+40';

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
