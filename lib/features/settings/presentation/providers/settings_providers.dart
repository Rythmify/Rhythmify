import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/settings/data/datasources/settings_datasources_impl.dart';
import 'package:rythmify/features/settings/data/datasources/settings_remote_datasources.dart';
import 'package:rythmify/features/settings/data/repositories/settings_repo_impl.dart';
import 'package:rythmify/features/settings/domain/repositories/settings_repo_interface.dart';

final settingsDatasourceProvider = Provider<SettingsRemoteDatasources>((ref) {
  return SettingsDatasourcesImpl(apiClient);
});

final settingsRepositoryProvider = Provider<SettingsRepoInterface>((ref) {
  return SettingsRepoImpl(ref.watch(settingsDatasourceProvider));
});
