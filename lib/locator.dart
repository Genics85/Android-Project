import 'package:get_it/get_it.dart';
import 'package:go_find_me/blocs/authenticationBloc.dart';
import 'package:go_find_me/blocs/contributionBloc.dart';

import 'package:go_find_me/services/api.dart';
import 'package:go_find_me/services/placesService.dart';
import 'package:go_find_me/services/sharedPref.dart';
import 'package:go_find_me/services/sharing_service.dart';

GetIt sl = GetIt.instance;

setuplocator() {
  sl.registerLazySingleton(() => Api());
  sl.registerLazySingleton(() => PlacesService());
  sl.registerLazySingleton(() => SharedPreferencesService());
  sl.registerLazySingleton(() => SharingService());
}
