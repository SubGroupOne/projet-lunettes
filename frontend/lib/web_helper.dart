// lib/web_helper.dart
// Utilisé uniquement sur Flutter Web
import 'dart:html' as html;

void openUrl(String url) {
  html.window.open(url, '_blank');
}