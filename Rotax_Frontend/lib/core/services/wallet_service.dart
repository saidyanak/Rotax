import '../constants/api_constants.dart';
import 'api_service.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';

class WalletService {
  static Future<Wallet> getWallet() async {
    final response = await ApiService.get(ApiConstants.wallet);
    return Wallet.fromJson(response);
  }
  
  static Future<Map<String, dynamic>> getWalletSummary() async {
    return await ApiService.get(ApiConstants.walletSummary);
  }
  
  static Future<Transaction> deposit(double amount, String paymentMethod, {String? description}) async {
    final response = await ApiService.post(ApiConstants.walletDeposit, body: {
      'amount': amount,
      'paymentMethod': paymentMethod,
      'description': description,
    });
    return Transaction.fromJson(response);
  }
  
  static Future<Transaction> withdraw(double amount, String bankAccount, {String? description}) async {
    final response = await ApiService.post(ApiConstants.walletWithdraw, body: {
      'amount': amount,
      'bankAccount': bankAccount,
      'description': description,
    });
    return Transaction.fromJson(response);
  }
  
  static Future<Map<String, dynamic>> getTransactions({int page = 0, int size = 20}) async {
    return await ApiService.get(ApiConstants.walletTransactions, queryParams: {
      'page': page,
      'size': size,
    });
  }
  
  static Future<double> calculatePrice(double distance) async {
    final response = await ApiService.get(ApiConstants.walletCalculatePrice, queryParams: {
      'distance': distance,
    });
    return (response['price'] ?? 0).toDouble();
  }
}
