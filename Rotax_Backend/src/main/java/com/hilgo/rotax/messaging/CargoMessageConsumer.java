package com.hilgo.rotax.messaging;

import com.hilgo.rotax.config.RabbitMQConfig;
import com.hilgo.rotax.dto.messaging.CargoStatusMessage;
import com.hilgo.rotax.dto.messaging.DriverNotificationMessage;
import com.hilgo.rotax.dto.messaging.MatchingResultMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Service;

/**
 * RabbitMQ mesaj dinleyici servisi
 * 
 * NOT: Bu sınıf şu an sadece loglama yapıyor.
 * İleride gerçek işlemler eklenecek.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CargoMessageConsumer {

    private final CargoMessageProducer messageProducer;

    /**
     * Python matching service'den gelen eşleştirme sonuçlarını işler
     * 
     * NOT: Bu metot, Python service tarafından sonuçlar gönderildiğinde çalışacak
     * Şimdilik sadece loglama yapıyor
     */
    // @RabbitListener(queues = "rotax.matching.result.queue") // İleride aktif edilecek
    public void handleMatchingResult(MatchingResultMessage message) {
        log.info("Eşleştirme sonucu alındı: Cargo ID {}, Eşleşti: {}", 
                message.getCargoId(), message.isMatched());

        if (message.isMatched() && message.getMatchedDrivers() != null) {
            // Eşleşen sürücülere bildirim gönder
            for (MatchingResultMessage.MatchedDriver driver : message.getMatchedDrivers()) {
                DriverNotificationMessage notification = DriverNotificationMessage.builder()
                        .driverId(driver.getDriverId())
                        .title("Yeni Kargo Teklifi!")
                        .body("Yakınınızda bir kargo var. Uzaklık: " + 
                              String.format("%.1f", driver.getDistanceToPickup()) + " km")
                        .notificationType("CARGO_OFFER")
                        .cargoId(message.getCargoId())
                        .build();

                messageProducer.sendDriverNotification(notification);
                log.info("Sürücüye kargo teklifi gönderildi: Driver ID {}", driver.getDriverId());
            }
        } else {
            log.warn("Kargo için uygun sürücü bulunamadı: Cargo ID {}", message.getCargoId());
        }
    }

    /**
     * Kargo durum değişikliklerini işler
     * Örn: Distributor ve alıcıya bildirim gönderme
     */
    @RabbitListener(queues = RabbitMQConfig.CARGO_STATUS_QUEUE)
    public void handleCargoStatusUpdate(CargoStatusMessage message) {
        log.info("Kargo durum değişikliği: Cargo ID {}, {} -> {}", 
                message.getCargoId(), message.getPreviousStatus(), message.getNewStatus());

        // İleride burada:
        // - Distributor'a email/push notification
        // - Alıcıya SMS ile bildirim
        // - WebSocket ile canlı güncelleme
        // yapılabilir
    }

    /**
     * Sürücü bildirimlerini işler
     * Bu genellikle push notification veya websocket ile mobile app'e gönderilir
     */
    @RabbitListener(queues = RabbitMQConfig.DRIVER_NOTIFICATION_QUEUE)
    public void handleDriverNotification(DriverNotificationMessage message) {
        log.info("Sürücü bildirimi işleniyor: Driver ID {}, Title: {}", 
                message.getDriverId(), message.getTitle());

        // İleride burada:
        // - Firebase Cloud Messaging ile push notification
        // - WebSocket ile anlık bildirim
        // yapılacak
    }
}
