package com.hilgo.rotax.service;

import com.hilgo.rotax.exception.FileStorageException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Objects;
import java.util.UUID;

@Service
public class FileStorageService {

    private final Path fileStorageLocation;

    public FileStorageService(@Value("${file.upload-dir}") String uploadDir) {
        this.fileStorageLocation = Paths.get(uploadDir).toAbsolutePath().normalize();

        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (Exception ex) {
            throw new FileStorageException("Could not create the directory where the uploaded files will be stored.", ex);
        }
    }

    public String storeFile(MultipartFile file) {
        // Dosya adını normalize et ve benzersiz yap
        String originalFileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String fileExtension = "";
        try {
            fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
        } catch (Exception e) {
            // uzantı yoksa boş kalsın
        }
        String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

        try {
            // Dosya adında geçersiz karakterler var mı kontrol et
            if (uniqueFileName.contains("..")) {
                throw new FileStorageException("Sorry! Filename contains invalid path sequence " + uniqueFileName);
            }

            // Dosyayı hedef konuma kopyala (aynı isimde dosya varsa üzerine yaz)
            Path targetLocation = this.fileStorageLocation.resolve(uniqueFileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            // Dosyanın erişilebilir URL'sini oluştur
            return ServletUriComponentsBuilder.fromCurrentContextPath()
                    .path("/uploads/")
                    .path(uniqueFileName)
                    .toUriString();

        } catch (IOException ex) {
            throw new FileStorageException("Could not store file " + uniqueFileName + ". Please try again!", ex);
        }
    }
}