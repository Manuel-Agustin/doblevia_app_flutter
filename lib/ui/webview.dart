import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/foundation.dart';

/*class MyWebViewPage extends StatefulWidget {
  final String url;
  final bool isOnline;
  final String? title;
  const MyWebViewPage({super.key, required this.url, required this.isOnline, this.title});

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  bool _webViewLoading = true;
  late WebViewController _controller;
  bool _downloading = false;
  double _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  /*@override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _openDialog(HttpAuthRequest httpRequest) async {
    final TextEditingController usernameTextController =
    TextEditingController();
    final TextEditingController passwordTextController =
    TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${httpRequest.host}: ${httpRequest.realm ?? '-'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Usuari'),
                  autofocus: true,
                  controller: usernameTextController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Contrasenya'),
                  controller: passwordTextController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Explicitly cancel the request on iOS as the OS does not emit new
            // requests when a previous request is pending.
            TextButton(
              onPressed: () {
                httpRequest.onCancel();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                httpRequest.onProceed(
                  WebViewCredential(
                    user: usernameTextController.text,
                    password: passwordTextController.text,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Autenticar-te'),
            ),
          ],
        );
      },
    );
  }

  void _load() async {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() => _webViewLoading = true);
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() => _webViewLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.endsWith('.pdf')) {
              if (kDebugMode) debugPrint('dvlog: blocking navigation to $request}');
              if (Platform.isAndroid) {
                if (!await launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication)) {
                  throw 'Could not launch ${request.url}';
                }
              } else {
                _downloadFile(request.url);
              }
              return NavigationDecision.prevent;
            }

            debugPrint('requesting navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            _openDialog(request);
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(widget.isOnline ? Uri.parse(widget.url) : Uri.dataFromString(
          await rootBundle.loadString(widget.url),
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8')
      ));

    // setBackgroundColor is not currently supported on macOS.
    if (kIsWeb || !Platform.isMacOS) {
      controller.setBackgroundColor(const Color(0x80000000));
    }

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  Future<void> _downloadFile(String url) async {
    Dio dio = Dio();
    final Random random = Random();

    if (kDebugMode) debugPrint('dvlog: permission requested');
    //if (await Permission.manageExternalStorage.request().isGranted) {
    String dirloc = (await getApplicationDocumentsDirectory()).path;
    var randId = random.nextInt(10000);

    try {
      await dio.download(url, "$dirloc$randId.pdf",
          onReceiveProgress: (receivedBytes, totalBytes) {
            if (kDebugMode) debugPrint('dvlog: PROGRESS $receivedBytes/$totalBytes');
            setState(() {
              _downloading = true;
              _downloadProgress = receivedBytes / totalBytes;
            });
          });
    } catch (e) {
      if (kDebugMode) print(e);
    }

    if (kDebugMode) debugPrint('dvlog: dowload completed');
    setState(() {
      _downloading = false;
    });

    //} else {
    //  if (kDebugMode) debugPrint('dvlog: permission denied');
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text(widget.title ?? widget.url, overflow: TextOverflow.fade),
      ),
      body: PopScope(
          child: Stack(children: [
            WebViewWidget(controller: _controller),
            _webViewLoading ? Container(color: Colors.white38, child: const Center(child: CircularProgressIndicator())) : Container(),
            _downloading ? Container(color: Colors.white38, child: Center(child: CircularProgressIndicator(value: _downloadProgress))) : Container(),
          ]),
          onPopInvokedWithResult: (b, d) async {
            WebViewController c = _controller;
            if (await c.canGoBack()) {
              c.goBack();
            } else {
              _goBack();
            }
          }
      )
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }*/
}*/



class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({super.key, required this.url, required this.title});
  final String url;
  final String? title;

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  WebViewEnvironment? webViewEnvironment;

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  void _getWebViewEnvironment() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      assert(availableVersion != null,
      'Failed to find an installed WebView2 runtime or non-stable Microsoft Edge installation.');

      webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(userDataFolder: 'custom_path'));
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
  }

  @override
  void initState() {
    super.initState();

    _getWebViewEnvironment();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              id: 1,
              title: "Special",
              action: () async {
                debugPrint("dvlog: Menu item Special clicked!");
                debugPrint('dvlog: ${await webViewController?.getSelectedText()}');
                await webViewController?.clearFocus();
              })
        ],
        settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          debugPrint("dvlog: onCreateContextMenu");
          debugPrint('dvlog: ${hitTestResult.extra}');
          debugPrint('dvlog: ${await webViewController?.getSelectedText()}');
        },
        onHideContextMenu: () {
          debugPrint("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = contextMenuItemClicked.id;
          debugPrint("dvlog: onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = kIsWeb ||
        ![TargetPlatform.iOS, TargetPlatform.android]
            .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          webViewController?.loadUrl(
              urlRequest:
              URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: widget.title == null ? null : AppBar(title: Text('${widget.title}')),
        body: SafeArea(
            child: Column(children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      webViewEnvironment: webViewEnvironment,
                      initialUrlRequest:
                      URLRequest(url: WebUri(widget.url)),
                      initialUserScripts: UnmodifiableListView<UserScript>([]),
                      initialSettings: settings,
                      contextMenu: contextMenu,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) async {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) async {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        debugPrint('dvlog: override url: ${navigationAction.request.url.toString()}');
                        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
                          final shouldPerformDownload =
                              navigationAction.shouldPerformDownload ?? false;
                          final url = navigationAction.request.url;
                          if (shouldPerformDownload && url != null) {
                            await _downloadFile(url.toString());
                            return NavigationActionPolicy.DOWNLOAD;
                          }
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                      onDownloadStartRequest: (controller, downloadStartRequest) async {
                          debugPrint(
                              'dvlog: dowload request: ${downloadStartRequest
                                  .url.toString()}');
                          await _downloadFile(
                              downloadStartRequest.url.toString(),
                              downloadStartRequest.suggestedFilename);
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController?.endRefreshing();
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onReceivedError: (controller, request, error) {
                        pullToRefreshController?.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController?.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                          urlController.text = this.url;
                        });
                      },
                      onUpdateVisitedHistory: (controller, url, isReload) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        print(consoleMessage);
                      },
                    ),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
            ])));
  }

  Future<void> _downloadFile(String url, [String? filename]) async {
    await launchUrl(Uri.parse('$url?u=45641055Q&p=24GD87vb26\$61'));
  }
}
