# GTAds华为广告支持插件
<p>
<a href="https://pub.flutter-io.cn/packages/gtads_huawei"><img src=https://img.shields.io/pub/v/gtads_huawei?color=orange></a>
<a href="https://pub.flutter-io.cn/packages/gtads_huawei"><img src=https://img.shields.io/pub/likes/gtads_huawei></a>
<a href="https://pub.flutter-io.cn/packages/gtads_huawei"><img src=https://img.shields.io/pub/points/gtads_huawei></a>
</p>
<p>
<a href="http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=VhD0AZSmzvsD3fu7CeQFkzpBQHMHANb1&authKey=W7JGJ0HKklyhP1jyBvbTF2Dkw0cq4UmhVSx2zXVdIm6n48Xrto%2B7%2B1n9jbkAadyF&noverify=0&group_code=649574038"><img src=https://img.shields.io/badge/flutter%E4%BA%A4%E6%B5%81%E7%BE%A4-649574038-blue></a>
<a href="http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=9I9lyXewEsEnx0f00EOF_9hEcFmG5Bmg&authKey=AJfQ8%2FhOLcoJ0p5B16EITjFav1IIs3UAerZSUsWZfa0evuklgxibHti51AYlZgI3&noverify=0&group_code=769626410"><img src=https://img.shields.io/badge/flutter%E4%BA%A4%E6%B5%81%E7%BE%A42-769626410-blue></a>
</p>

# 📢 相关插件

- [GTAds](https://github.com/gstory0404/GTAds) 聚合广告插件，必须引入

# 使用

### pubspec.yaml
```dart
 //广告基础库 必须引入
 gtads: ^1.3.0
 //优量汇广告
 gtads_huawei: ^1.0.0
```

### 引入
```dart
import 'package:gtads_huawei/gtads_huawei.dart';
```

### 使用
仅需通过以下方法插入广告至聚合插件，无需关注具体广告的调用
```dart
//别名
GTAds.addProvider(GTAdsHuaweiProvider("huawei"));
```

> 广告位使用参考[GTAds](https://github.com/zhangruiyu/gtads_huawei/blob/main/example/lib/main.dart)

