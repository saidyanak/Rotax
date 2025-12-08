package com.hilgo.rotax.messaging;

import com.hilgo.rotax.config.RabbitMQConfig;
import com.hilgo.rotax.dto.messaging.CargoMatchingMessage;
import com.hilgo.rotax.dto.messaging.CargoStatusMessage;
import com.hilgo.rotax.dto.messaging.DriverNotificationMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

/**
 * RabbitMQ mesaj gönderici servisi
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CargoMessageProducer {

    private final RabbitTemplate rabbitTemplate;

    /**
     * Yeni kargo oluşturulduğunda eşleştirme için mesaj gönder
     */
    public void sendCargoForMatching(CargoMatchingMessage message) {
        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.CARGO_EXCHANGE,
                    RabbitMQConfig.CARGO_MATCHING_ROUTING_KEY,
                    message
            );
            log.info("Kargo eşleştirme mesajı gönderildi: Cargo ID {}", message.getCargoId());
        } catch (Exception e) {
            log.error("Kargo eşleştirme mesajı gönderilemedi: Cargo ID {}, Hata: {}", 
                    message.getCargoId(), e.getMessage());
        }
    }

    /**
     * Kargo durumu değiştiğinde mesaj gönder
     */
    public void sendCargoStatusUpdate(CargoStatusMessage message) {
        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.CARGO_EXCHANGE,
                    RabbitMQConfig.CARGO_STATUS_ROUTING_KEY,
                    message
            );
            log.info("Kargo durum mesajı gönderildi: Cargo ID {}, Yeni durum: {}", 
                    message.getCargoId(), message.getNewStatus());
        } catch (Exception e) {
            log.error("Kargo durum mesajı gönderilemedi: Cargo ID {}, Hata: {}", 
                    message.getCargoId(), e.getMessage());
        }
    }

    /**
     * Sürücüye bildirim gönder
     */
    public void sendDriverNotification(DriverNotificationMessage message) {
        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.NOTIFICATION_EXCHANGE,
                    RabbitMQConfig.DRIVER_NOTIFICATION_ROUTING_KEY,
                    message
            );
            log.info("Sürücü bildirimi gönderildi: Driver ID {}, Type: {}", 
                    message.getDriverId(), message.getNotificationType());
        } catch (Exception e) {
            log.error("Sürücü bildirimi gönderilemedi: Driver ID {}, Hata: {}", 
                    message.getDriverId(), e.getMessage());
        }
    }
}
