part of 'internet_cubit.dart';

class InternetState {}

class InternetLoading extends InternetState {}

class InternetEnabled extends InternetState {
  final ConnectionType connectionType;
  InternetEnabled({required this.connectionType});
}

class InternetDisabled extends InternetState {}
