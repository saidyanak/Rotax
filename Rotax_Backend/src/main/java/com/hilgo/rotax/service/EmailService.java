package com.hilgo.rotax.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    /**
     * Asenkron olarak şifre sıfırlama e-postası gönderir.
     * @param to E-postanın gönderileceği adres
     * @param name Kullanıcının adı
     * @param token Şifre sıfırlama token'ı
     */
    @Async // E-posta gönderimini asenkron yaparak API yanıt süresini iyileştirir
    public void sendPasswordResetEmail(String to, String name, String token) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

            String resetUrl = frontendUrl + "/reset-password?token=" + token;
            String htmlMsg = String.format("""
                <h3>Merhaba %s,</h3>
                <p>Rotax hesabınız için şifre sıfırlama talebinde bulundunuz. Aşağıdaki linke tıklayarak şifrenizi yenileyebilirsiniz:</p>
                <p><a href="%s">Şifremi Sıfırla</a></p>
                <p>Eğer bu talebi siz yapmadıysanız, bu e-postayı görmezden gelebilirsiniz.</p>
                <br>
                <p>Teşekkürler,</p>
                <p>Rotax Ekibi</p>
                """, name, resetUrl);

            helper.setText(htmlMsg, true); // true, içeriğin HTML olduğunu belirtir
            helper.setTo(to);
            helper.setSubject("Rotax - Şifre Sıfırlama Talebi");
            helper.setFrom(fromEmail);

            mailSender.send(mimeMessage);
            log.info("Şifre sıfırlama e-postası başarıyla gönderildi: {}", to);

        } catch (MessagingException e) {
            log.error("Şifre sıfırlama e-postası gönderilirken hata oluştu: {}", to, e);
        }
    }

    /**
     * Asenkron olarak yeni kullanıcı kayıt onay e-postası gönderir.
     * @param to E-postanın gönderileceği adres
     * @param name Kullanıcının adı
     */
    @Async
    public void sendRegistrationConfirmationEmail(String to, String name) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

            String htmlMsg = String.format("""
                <h3>Hoş Geldin %s!</h3>
                <p>Rotax platformuna başarıyla kayıt oldunuz. Hesabınızı kullanmaya başlayabilirsiniz.</p>
                <p>Harika teslimatlar dileriz!</p>
                <br>
                <p>Teşekkürler,</p>
                <p>Rotax Ekibi</p>
                """, name);

            helper.setText(htmlMsg, true);
            helper.setTo(to);
            helper.setSubject("Rotax'a Hoş Geldiniz!");
            helper.setFrom(fromEmail);

            mailSender.send(mimeMessage);
            log.info("Kayıt onay e-postası başarıyla gönderildi: {}", to);

        } catch (MessagingException e) {
            log.error("Kayıt onay e-postası gönderilirken hata oluştu: {}", to, e);
        }
    }

    /**
     * Asenkron olarak reddedilen belge hakkında bildirim e-postası gönderir.
     * @param to E-postanın gönderileceği adres
     * @param name Kullanıcının adı
     * @param documentType Reddedilen belgenin türü
     * @param rejectionReason Reddetme sebebi
     */
    @Async
    public void sendDocumentRejectionEmail(String to, String name, String documentType, String rejectionReason) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");

            String htmlMsg = String.format("""
                <h3>Merhaba %s,</h3>
                <p>Rotax platformuna yüklemiş olduğunuz belgenizle ilgili bir güncelleme var.</p>
                <p><strong>Belge Türü:</strong> %s</p>
                <p><strong>Durum:</strong> <span style="color:red;">Reddedildi</span></p>
                <p><strong>Sebep:</strong> %s</p>
                <p>Lütfen profil sayfanızdan gerekli düzeltmeleri yaparak belgenizi yeniden yükleyiniz.</p>
                <br>
                <p>Teşekkürler,</p>
                <p>Rotax Ekibi</p>
                """, name, documentType, rejectionReason);

            helper.setText(htmlMsg, true);
            helper.setTo(to);
            helper.setSubject("Rotax - Belge Değerlendirme Sonucu");
            helper.setFrom(fromEmail);

            mailSender.send(mimeMessage);
            log.info("Belge reddetme e-postası başarıyla gönderildi: {}", to);

        } catch (MessagingException e) {
            log.error("Belge reddetme e-postası gönderilirken hata oluştu: {}", to, e);
        }
    }
}
