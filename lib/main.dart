import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/properties_provider.dart';
import 'providers/units_provider.dart';
import 'providers/leases_provider.dart';
import 'providers/maintenance_provider.dart';
import 'providers/agents_provider.dart';
import 'providers/disputes_provider.dart';
import 'providers/conversations_provider.dart';
import 'providers/plans_provider.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/units_screen.dart';
import 'screens/properties_screen.dart';
import 'screens/leases_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => PropertiesProvider()),
        ChangeNotifierProvider(create: (_) => UnitsProvider()),
        ChangeNotifierProvider(create: (_) => LeasesProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => AgentsProvider()),
        ChangeNotifierProvider(create: (_) => DisputesProvider()),
        ChangeNotifierProvider(create: (_) => ConversationsProvider()),
        ChangeNotifierProvider(create: (_) => PlansProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex Property Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/units': (context) => UnitsScreen(),
        '/properties': (context) => PropertiesScreen(),
        '/leases': (context) => LeasesScreen(),
        // TODO: Add other routes as screens are created
        // '/properties': (context) => PropertiesScreen(),
        // '/leases': (context) => LeasesScreen(),
        // '/maintenance': (context) => MaintenanceScreen(),
        // '/agents': (context) => AgentsScreen(),
        // '/disputes': (context) => DisputesScreen(),
        // '/conversations': (context) => ConversationsScreen(),
        // '/plans': (context) => PlansScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.token != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}
