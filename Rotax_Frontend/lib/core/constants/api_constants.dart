class ApiConstants {
  // Base URL - Web'de nginx proxy kullanır, localhost:3000 üzerinden /api/* backend'e yönlendirilir
  // Böylece CORS sorunu olmaz
  static const String baseUrl = '';
  
  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String userInfo = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String changePassword = '/api/auth/change-password';
  
  // Driver Endpoints
  static const String driverDashboard = '/api/driver/dashboard';
  static const String driverStatus = '/api/driver/status';
  static const String driverProfile = '/api/driver/profile';
  static const String driverProfilePicture = '/api/driver/profile/picture';
  static const String driverOffers = '/api/driver/offers';
  static String driverAcceptOffer(int cargoId) => '/api/driver/offers/$cargoId/accept';
  static String driverPickedUp(int cargoId) => '/api/driver/cargos/$cargoId/status/picked-up';
  static String driverDelivered(int cargoId) => '/api/driver/cargos/$cargoId/status/delivered';
  
  // Distributor Endpoints
  static const String distributorDashboard = '/api/distributor/dashboard';
  static const String distributorProfile = '/api/distributor/profile';
  static const String distributorProfilePicture = '/api/distributor/profile/picture';
  static const String distributorCargos = '/api/distributor/cargos';
  static String distributorCargoDetail(int cargoId) => '/api/distributor/cargos/$cargoId';
  static String distributorCancelCargo(int cargoId) => '/api/distributor/cargos/$cargoId/cancel';
  
  // Wallet Endpoints
  static const String wallet = '/api/wallet';
  static const String walletSummary = '/api/wallet/summary';
  static const String walletDeposit = '/api/wallet/deposit';
  static const String walletWithdraw = '/api/wallet/withdraw';
  static const String walletTransactions = '/api/wallet/transactions';
  static const String walletCalculatePrice = '/api/wallet/calculate-price';
  
  // Public Endpoints
  static String publicTrack(String trackingCode) => '/api/public/track/$trackingCode';
  static String publicTrackNote(String trackingCode) => '/api/public/track/$trackingCode/note';
  static String publicTrackReview(String trackingCode) => '/api/public/track/$trackingCode/review';
  
  // Admin Endpoints
  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminUsers = '/api/admin/users';
  static String adminUserDetail(int userId) => '/api/admin/users/$userId';
  static String adminUserToggleStatus(int userId) => '/api/admin/users/$userId/toggle-status';
  static String adminUserToggleLock(int userId) => '/api/admin/users/$userId/toggle-lock';
  static const String adminCargos = '/api/admin/cargos';
  static String adminCargoDetail(int cargoId) => '/api/admin/cargos/$cargoId';
  static String adminCancelCargo(int cargoId) => '/api/admin/cargos/$cargoId/cancel';
  static const String adminPendingDocuments = '/api/admin/documents/pending';
  static String adminApproveDocument(int documentId) => '/api/admin/documents/$documentId/approve';
  static String adminRejectDocument(int documentId) => '/api/admin/documents/$documentId/reject';
  static const String adminPendingWithdrawals = '/api/admin/withdrawals/pending';
  static String adminApproveWithdrawal(int transactionId) => '/api/admin/withdrawals/$transactionId/approve';
  static String adminRejectWithdrawal(int transactionId) => '/api/admin/withdrawals/$transactionId/reject';
}
