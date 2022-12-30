import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebViewPage extends StatefulWidget {
  final String url;
  final bool isOnline;
  final String? title;
  const MyWebViewPage({Key? key, required this.url, required this.isOnline, this.title}) : super(key: key);

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  final Completer<WebViewController> _webViewController = Completer<WebViewController>();
  bool _webViewLoading = true;
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? widget.url, overflow: TextOverflow.fade),
        ),
        body: _webViewPage()
    );
  }

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString(widget.url);
    _controller.loadUrl( Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  Widget _webViewPage() {
    return WillPopScope(
        child: Stack(children: [
          WebView(
            onProgress: (progress) {
              setState(() {
                _webViewLoading = progress < 100;
              });
            },
            initialUrl: widget.isOnline ? widget.url : 'about:blank',
            backgroundColor: Colors.white,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              if (!_webViewController.isCompleted) _webViewController.complete(webViewController);
              _controller = webViewController;
              if (!widget.isOnline) _loadHtmlFromAssets();
            },
            gestureNavigationEnabled: true,
            zoomEnabled: false,
          ),
          _webViewLoading ? Container(color: Colors.white38, child: const Center(child: CircularProgressIndicator())) : Container(),
        ]),
        onWillPop: () async {
          WebViewController c = await _webViewController.future;
          if (await c.canGoBack()) {
            c.goBack();
          } else {
            if (!mounted) return false;
            Navigator.pop(context);
          }
          return true;
        }
    );
  }
}
