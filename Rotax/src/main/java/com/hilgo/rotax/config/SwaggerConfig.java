package com.hilgo.rotax.config; // Kendi paket adınıza göre düzenleyin

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List; // List import'unu eklemeyi unutmayın

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        // Güvenlik şeması için kullanılacak referans adı
        final String securitySchemeName = "Bearer Authentication";

        return new OpenAPI()
                // 1. API için genel bilgileri ayarlar
                .info(new Info()
                        .title("Rotax Lojistik Platformu API")
                        .version("v1.0")
                        .description("Bu API dokümantasyonu, Rotax projesi kapsamında Sürücü (Driver), Dağıtıcı (Distributor) ve Admin operasyonlarını yöneten REST servislerini kapsamaktadır.")
                        .contact(new Contact()
                                .name("Hilgo Yazılım")
                                .email("iletisim@hilgo.com"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("http://springdoc.org")))

                // 2. JWT Güvenlik Şemasını Tanımlar
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName, createBearerScheme()))

                // 3. Tanımlanan güvenlik şemasını tüm endpoint'lere uygular (DÜZELTİLMİŞ KISIM)
                .security(List.of(new SecurityRequirement().addList(securitySchemeName)));
    }

    private SecurityScheme createBearerScheme() {
        return new SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT")
                .in(SecurityScheme.In.HEADER)
                .name("Authorization");
    }
}