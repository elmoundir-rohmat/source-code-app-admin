import 'package:get_it/get_it.dart';
import '../services/remote_config_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() async {
  var remoteConfigService = await RemoteConfigService.getInstance();
  locator.registerSingleton(remoteConfigService);
}