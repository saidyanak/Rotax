part of "login_cubit.dart";

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

// 1 Başlangıç durumu
final class LoginInitial extends LoginState {}

// 2 Yükleniyor durumu
final class LoginLoading extends LoginState {}

// 3 Başarılı giriş durumu
final class LoginSuccess extends LoginState {}

// 4 Hata durumu
final class LoginFailure extends LoginState {
  final String errorMessage;

  const LoginFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}