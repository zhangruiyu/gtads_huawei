import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtads_huawei/src/flutter_huaweiad_callback.dart';
import 'package:gtads_huawei/src/flutter_huaweiad_stream.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const codec = StandardMethodCodec();
  final eventMethodChannel = MethodChannel(HuaweiAdEventEvent.name);
  late List<MethodCall> platformCalls;

  setUp(() {
    platformCalls = <MethodCall>[];
    messenger.setMockMethodCallHandler(eventMethodChannel, (call) async {
      platformCalls.add(call);
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(eventMethodChannel, null);
  });

  test('multiple request listeners share one native EventChannel listener',
      () async {
    var requestAReadyCount = 0;
    var requestBReadyCount = 0;

    final requestA = FlutterHuaweiAdStream.initAdStream(
      requestId: 'request-a',
      flutterHuaweiadRewardCallBack: FlutterHuaweiadRewardCallBack(
        onReady: () => requestAReadyCount++,
      ),
    );
    final requestB = FlutterHuaweiAdStream.initAdStream(
      requestId: 'request-b',
      flutterHuaweiadRewardCallBack: FlutterHuaweiadRewardCallBack(
        onReady: () => requestBReadyCount++,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
        platformCalls.where((call) => call.method == 'listen'), hasLength(1));

    await emitEvent(messenger, codec, <String, Object>{
      'adType': 'rewardAd',
      'onAdMethod': 'onReady',
      'requestId': 'request-a',
    });

    expect(requestAReadyCount, 1);
    expect(requestBReadyCount, 0);

    await requestA.cancel();
    await requestB.cancel();
  });

  test(
      'legacy event without requestId is delivered only to the latest listener',
      () async {
    var requestAReadyCount = 0;
    var requestBReadyCount = 0;

    final requestA = FlutterHuaweiAdStream.initAdStream(
      requestId: 'request-a',
      flutterHuaweiadRewardCallBack: FlutterHuaweiadRewardCallBack(
        onReady: () => requestAReadyCount++,
      ),
    );
    final requestB = FlutterHuaweiAdStream.initAdStream(
      requestId: 'request-b',
      flutterHuaweiadRewardCallBack: FlutterHuaweiadRewardCallBack(
        onReady: () => requestBReadyCount++,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    await emitEvent(messenger, codec, <String, Object>{
      'adType': 'rewardAd',
      'onAdMethod': 'onReady',
    });

    expect(requestAReadyCount, 0);
    expect(requestBReadyCount, 1);

    await requestA.cancel();
    await requestB.cancel();
  });
}

Future<void> emitEvent(
  TestDefaultBinaryMessenger messenger,
  MethodCodec codec,
  Map<String, Object> event,
) async {
  final completer = Completer<void>();
  await messenger.handlePlatformMessage(
    HuaweiAdEventEvent.name,
    codec.encodeSuccessEnvelope(event),
    (ByteData? _) => completer.complete(),
  );
  await completer.future;
  await Future<void>.delayed(Duration.zero);
}
