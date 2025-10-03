import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// Az önce oluşturduğumuz state dosyasını buraya dahil ediyoruz.
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  // Cubit ilk oluşturulduğunda hangi state ile başlaması gerektiğini söylüyoruz.
  // Elbette, başlangıç durumu LoginInitial olacak.
  LoginCubit() : super(LoginInitial());

  // Bu, UI (arayüz) tarafından çağrılacak olan ana fonksiyonumuz.
  // Kullanıcının girdiği e-posta ve şifreyi parametre olarak alacak.
  Future<void> login({required String email, required String password}) async {
    // 1. "Yükleniyor" durumuna geç ve arayüze haber ver.
    emit(LoginLoading());

    try {
      // 2. Sunucuya gidiyormuş gibi 2 saniye bekle (simülasyon).
      await Future.delayed(const Duration(seconds: 2));

      // 3. Giriş kurallarını kontrol et (şimdilik basit bir kontrol).
      if (email.isEmpty || password.isEmpty) {
        // Eğer alanlar boşsa, "Hata" durumuna geç ve hata mesajını gönder.
        emit(const LoginFailure('Lütfen tüm alanları doldurun.'));
      } else if (email == 'test@rotax.com' && password == '1234') {
        // Eğer bilgiler doğruysa, "Başarılı" durumuna geç.
        emit(LoginSuccess());
      } else {
        // Eğer bilgiler yanlışsa, "Hata" durumuna geç.
        emit(const LoginFailure('E-posta veya şifre hatalı.'));
      }
    } catch (e) {
      // 4. Beklenmedik bir hata olursa (örn: internet koptu), onu da yakala.
      emit(LoginFailure('Bir hata oluştu: ${e.toString()}'));
    }
  }
}