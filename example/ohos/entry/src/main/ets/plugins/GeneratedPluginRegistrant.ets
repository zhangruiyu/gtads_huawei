import { FlutterEngine, Log } from '@ohos/flutter_ohos';
import GtadsHuaweiPlugin from 'gtads_huawei';
import IntegrationTestPlugin from 'integration_test';

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Ohos platform.
 */

const TAG = "GeneratedPluginRegistrant";

export class GeneratedPluginRegistrant {

  static registerWith(flutterEngine: FlutterEngine) {
    try {
      flutterEngine.getPlugins()?.add(new GtadsHuaweiPlugin());
      flutterEngine.getPlugins()?.add(new IntegrationTestPlugin());
    } catch (e) {
      Log.e(
        TAG,
        "Tried to register plugins with FlutterEngine ("
          + flutterEngine
          + ") failed.");
      Log.e(TAG, "Received exception while registering", e);
    }
  }
}
