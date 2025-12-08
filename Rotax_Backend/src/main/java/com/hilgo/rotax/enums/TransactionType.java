package com.hilgo.rotax.enums;

public enum TransactionType {
    DEPOSIT,            // Bakiye yükleme
    WITHDRAWAL,         // Bakiye çekme
    CARGO_PAYMENT,      // Kargo ücreti ödeme (distributor'dan kesilen)
    DRIVER_EARNING,     // Sürücü kazancı
    COMMISSION,         // Sistem komisyonu
    REFUND,             // İade
    BONUS               // Bonus/Promosyon
}
