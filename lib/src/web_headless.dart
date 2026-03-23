@JS()
library;

import 'dart:js_interop';

@JS('navigator.userAgent')
external String get _userAgent;
@JS('navigator.webdriver')
external bool? get _webdriver;

bool isHeadlessWeb() {
  final ua = _userAgent.toLowerCase();
  return ua.contains('headless') ||
      ua.contains('puppeteer') ||
      ua.contains('playwright') ||
      ua.contains('phantomjs') ||
      ua.contains('selenium') ||
      (_webdriver == true);
}
// // Only compiled on web
// import 'dart:html' as html;

// bool isHeadlessWeb() {
//   final ua = html.window.navigator.userAgent.toLowerCase();
//   return ua.contains('headless') ||
//       ua.contains('puppeteer') ||
//       ua.contains('playwright') ||
//       ua.contains('phantomjs') ||
//       ua.contains('selenium') ||
//       html.window.navigator.webdriver == true;
// }
