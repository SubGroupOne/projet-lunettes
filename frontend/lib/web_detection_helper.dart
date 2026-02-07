import 'dart:js' as js;
import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;

class WebDetectionHelper {
  static Future<bool> init() async {
    try {
      final result = await js.context.callMethod('initFaceLandmarker');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> detect(html.VideoElement video) async {
    try {
      final result = await js.context.callMethod('detectFace', [video]);
      return result as String?;
    } catch (e) {
      return null;
    }
  }

  static List<html.VideoElement> findVideos() {
    List<html.VideoElement> results = [];
    
    // 1. Check main document
    results.addAll(html.document.querySelectorAll('video').whereType<html.VideoElement>());
    
    // 2. Check within all platform views (common for Flutter Web)
    final views = html.document.querySelectorAll('flt-platform-view');
    for (var view in views) {
      if (view.shadowRoot != null) {
        results.addAll(view.shadowRoot!.querySelectorAll('video').whereType<html.VideoElement>());
      }
    }
    
    return results;
  }
}
