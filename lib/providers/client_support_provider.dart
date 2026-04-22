import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/client_support.dart';
import 'auth_provider.dart';

/// Tjekker klient-versionen mod serveren én gang pr. app-session.
/// Returnerer null hvis check fejler (fx offline) - appen fortsætter uden at blokere.
final clientSupportProvider = FutureProvider<ClientSupportResponse?>((ref) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final apiService = ref.read(apiServiceProvider);
    return await apiService.checkClientSupport(currentVersion);
  } catch (_) {
    return null;
  }
});
