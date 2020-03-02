import 'dart:io';

import 'package:example/network_image.dart';
import 'package:flutter/material.dart';
import 'package:http_cache_client/http_cache_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = Directory((await getTemporaryDirectory()).path + "/http");
  AppNetworkImage.client = Client().withDiskCache(DiskCache(directory: dir));
  runApp(MyApp());
}
