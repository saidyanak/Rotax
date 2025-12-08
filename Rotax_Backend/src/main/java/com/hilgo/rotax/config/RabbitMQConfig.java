package com.hilgo.rotax.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    // Exchange isimleri
    public static final String CARGO_EXCHANGE = "rotax.cargo.exchange";
    public static final String NOTIFICATION_EXCHANGE = "rotax.notification.exchange";

    // Queue isimleri
    public static final String CARGO_MATCHING_QUEUE = "rotax.cargo.matching.queue";
    public static final String CARGO_STATUS_QUEUE = "rotax.cargo.status.queue";
    public static final String DRIVER_NOTIFICATION_QUEUE = "rotax.driver.notification.queue";

    // Routing key'ler
    public static final String CARGO_MATCHING_ROUTING_KEY = "cargo.matching";
    public static final String CARGO_STATUS_ROUTING_KEY = "cargo.status";
    public static final String DRIVER_NOTIFICATION_ROUTING_KEY = "driver.notification";

    // =============== EXCHANGES ===============

    @Bean
    public TopicExchange cargoExchange() {
        return new TopicExchange(CARGO_EXCHANGE);
    }

    @Bean
    public TopicExchange notificationExchange() {
        return new TopicExchange(NOTIFICATION_EXCHANGE);
    }

    // =============== QUEUES ===============

    /**
     * Kargo eşleştirme kuyruğu
     * Python matching service bu kuyruktan kargoları alır
     */
    @Bean
    public Queue cargoMatchingQueue() {
        return QueueBuilder.durable(CARGO_MATCHING_QUEUE)
                .withArgument("x-message-ttl", 300000) // 5 dakika TTL
                .build();
    }

    /**
     * Kargo durum güncelleme kuyruğu
     * Kargo durumu değiştiğinde bu kuyruğa mesaj gönderilir
     */
    @Bean
    public Queue cargoStatusQueue() {
        return QueueBuilder.durable(CARGO_STATUS_QUEUE).build();
    }

    /**
     * Sürücü bildirim kuyruğu
     * Sürücülere gönderilecek bildirimler için
     */
    @Bean
    public Queue driverNotificationQueue() {
        return QueueBuilder.durable(DRIVER_NOTIFICATION_QUEUE).build();
    }

    // =============== BINDINGS ===============

    @Bean
    public Binding cargoMatchingBinding(Queue cargoMatchingQueue, TopicExchange cargoExchange) {
        return BindingBuilder.bind(cargoMatchingQueue)
                .to(cargoExchange)
                .with(CARGO_MATCHING_ROUTING_KEY);
    }

    @Bean
    public Binding cargoStatusBinding(Queue cargoStatusQueue, TopicExchange cargoExchange) {
        return BindingBuilder.bind(cargoStatusQueue)
                .to(cargoExchange)
                .with(CARGO_STATUS_ROUTING_KEY);
    }

    @Bean
    public Binding driverNotificationBinding(Queue driverNotificationQueue, TopicExchange notificationExchange) {
        return BindingBuilder.bind(driverNotificationQueue)
                .to(notificationExchange)
                .with(DRIVER_NOTIFICATION_ROUTING_KEY);
    }

    // =============== MESSAGE CONVERTER ===============

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory);
        rabbitTemplate.setMessageConverter(jsonMessageConverter());
        return rabbitTemplate;
    }
}
