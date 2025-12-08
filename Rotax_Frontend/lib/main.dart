import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/constants/app_theme.dart';
import 'core/services/storage_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/driver_provider.dart';
import 'providers/distributor_provider.dart';
import 'providers/admin_provider.dart';

// Screens - Splash
import 'screens/splash/splash_screen.dart';

// Screens - Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

// Screens - Driver
import 'screens/driver/driver_home_screen.dart';
import 'screens/driver/driver_offers_screen.dart';
import 'screens/driver/driver_profile_screen.dart';

// Screens - Distributor
import 'screens/distributor/distributor_home_screen.dart';
import 'screens/distributor/distributor_cargos_screen.dart';
import 'screens/distributor/create_cargo_screen.dart';
import 'screens/distributor/cargo_detail_screen.dart';
import 'screens/distributor/distributor_profile_screen.dart';

// Screens - Wallet
import 'screens/wallet/wallet_screen.dart';
import 'screens/wallet/deposit_screen.dart';
import 'screens/wallet/withdraw_screen.dart';

// Screens - Public
import 'screens/public/tracking_screen.dart';

// Screens - Admin
import 'screens/admin/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageService.init();
  
  runApp(const RotaxApp());
}

class RotaxApp extends StatelessWidget {
  const RotaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => DistributorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Rotax Lojistik',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          // Splash & Auth
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          
          // Public
          '/tracking': (context) => const TrackingScreen(),
          
          // Driver
          '/driver/home': (context) => const DriverHomeScreen(),
          '/driver/offers': (context) => const DriverOffersScreen(),
          '/driver/profile': (context) => const DriverProfileScreen(),
          
          // Distributor
          '/distributor/home': (context) => const DistributorHomeScreen(),
          '/distributor/cargos': (context) => const DistributorCargosScreen(),
          '/distributor/create-cargo': (context) => const CreateCargoScreen(),
          '/distributor/profile': (context) => const DistributorProfileScreen(),
          
          // Wallet
          '/wallet': (context) => const WalletScreen(),
          '/wallet/deposit': (context) => const DepositScreen(),
          '/wallet/withdraw': (context) => const WithdrawScreen(),
          
          // Admin
          '/admin/home': (context) => const AdminHomeScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle cargo detail with arguments
          if (settings.name == '/distributor/cargo-detail') {
            final cargoId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => CargoDetailScreen(cargoId: cargoId),
            );
          }
          
          // Handle tracking with code
          if (settings.name?.startsWith('/tracking/') ?? false) {
            final code = settings.name!.split('/tracking/').last;
            return MaterialPageRoute(
              builder: (context) => TrackingScreen(initialCode: code),
            );
          }
          
          return null;
        },
      ),
    );
  }
}
