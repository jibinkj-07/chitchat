import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';
import '../../utils/app_colors.dart';
part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  final Connectivity connectivity;
  late StreamSubscription streamSubscription;

  InternetCubit({required this.connectivity}) : super(InternetLoading()) {
    internetMonitoring();
  }

  void internetMonitoring() {
    streamSubscription =
        connectivity.onConnectivityChanged.listen((internetState) {
      if (internetState == ConnectivityResult.wifi) {
        internetEnabled(ConnectionType.wifi);
      } else if (internetState == ConnectivityResult.mobile) {
        internetEnabled(ConnectionType.mobile);
      } else if (internetState == ConnectivityResult.none) {
        internetDisabled();
      }
    });
  }

  void internetEnabled(ConnectionType connectionType) => emit(
        InternetEnabled(connectionType: connectionType),
      );

  void internetDisabled() => emit(InternetDisabled());

  @override
  Future<void> close() {
    streamSubscription.cancel();
    return super.close();
  }
}
