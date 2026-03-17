import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/config/constants.dart';
import 'package:etbp_mobile/config/router.dart';

class EtbpApp extends ConsumerWidget {
  const EtbpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
