import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_services.dart';
import 'gen_l10n/app_localizations.dart';
import 'providers.dart';
import 'ui/screens/app_shell.dart';

/// Root widget: wires localization, the active theme bundle and session
/// accounting into a single MaterialApp.
class OpenTrackApp extends StatefulWidget {
  const OpenTrackApp({super.key});

  @override
  State<OpenTrackApp> createState() => _OpenTrackAppState();
}

class _OpenTrackAppState extends State<OpenTrackApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final analytics = AppServices.instance.analytics;
    switch (state) {
      case AppLifecycleState.resumed:
        analytics.beginSession();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        analytics.endSession();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final bundle = ref.watch(themeBundleProvider);
        final settings = ref.watch(settingsProvider);

        // Keep the on-device online/offline usage split in sync.
        ref.listen(isOnlineProvider, (_, online) {
          AppServices.instance.analytics.setOnlineMode(online);
        });

        return MaterialApp(
          title: 'OpenTrack India',
          debugShowCheckedModeBanner: false,
          themeMode: bundle.mode,
          theme: bundle.light,
          darkTheme: bundle.dark,
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            if (!settings.highContrast) return child;
            // Outdoor mode: bump type scale for readability in sunlight.
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.15)),
              child: child,
            );
          },
          home: const AppShell(),
        );
      },
    );
  }
}
