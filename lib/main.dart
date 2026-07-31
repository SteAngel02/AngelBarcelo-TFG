import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Configuración de Firebase
import 'package:tfg_project/core/firebase_options.dart';

// Feature: Auth (Capas de Dominio, Data y Presentación)
import 'package:tfg_project/features/login/domain/auth_repository.dart';
import 'package:tfg_project/features/login/data/auth_repository_impl.dart';
import 'package:tfg_project/features/login/presentation/auth_provider.dart';
import 'package:tfg_project/features/login/presentation/screens/login_screen.dart';

// Feature: Avatar
import 'package:tfg_project/features/avatar/domain/avatar_repository.dart';
import 'package:tfg_project/features/avatar/data/avatar_repository_impl.dart';
import 'package:tfg_project/features/avatar/presentation/avatar_provider.dart';

// Feature: Misiones
import 'package:tfg_project/features/misiones/domain/mision_repository.dart';
import 'package:tfg_project/features/misiones/data/mision_repository_impl.dart';
import 'package:tfg_project/features/misiones/presentation/mision_provider.dart';

// Feature: Tienda
import 'package:tfg_project/features/tienda/domain/recompensa_repository.dart';
import 'package:tfg_project/features/tienda/data/recompensa_repository_impl.dart';
import 'package:tfg_project/features/tienda/presentation/tienda_provider.dart';

// Feature: Retos
import 'package:tfg_project/features/retos/domain/reto_repository.dart';
import 'package:tfg_project/features/retos/data/reto_repository_impl.dart';
import 'package:tfg_project/features/retos/presentation/reto_provider.dart';

// Feature: Sendas
import 'package:tfg_project/features/sendas/domain/sendas_repository.dart';
import 'package:tfg_project/features/sendas/data/sendas_repository_impl.dart';
import 'package:tfg_project/features/sendas/presentation/sendas_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// Pantalla principal una vez logueado
import 'package:tfg_project/core/inicio_screen.dart';
import 'package:tfg_project/core/widgets/border_overlay.dart';
import 'package:tfg_project/core/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialización de Firebase con las opciones de plataforma
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
  }

  try {
    // Inicialización del servicio centralizado de notificaciones
    await NotificationService().init();
    await NotificationService().scheduleDailyNotifications(0);
  } catch (e) {
    debugPrint('Error al inicializar Notificaciones: $e');
  }

  runApp(
    /* Usamos MultiProvider para organizar las dependencias. 
      Esto facilita añadir futuras features como Avatar o Misiones.
    */
    MultiProvider(
      providers: [
        // 1. Inyectamos la implementación real del repositorio (Capa de Data)
        Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),

        // 2. Creamos el Provider de Auth, que depende del repositorio anterior
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),

        // 3. Inyectamos la implementación del repositorio de Avatar
        Provider<AvatarRepository>(create: (_) => AvatarRepositoryImpl()),

        // 4. Creamos el Provider de Avatar, que depende del repositorio de Avatar
        ChangeNotifierProvider(
          create: (context) => AvatarProvider(context.read<AvatarRepository>()),
        ),

        // 5. Inyectamos la implementación del repositorio de Misiones
        Provider<MisionRepository>(create: (_) => MisionRepositoryImpl()),

        // 6. Creamos el Provider de Misiones
        ChangeNotifierProvider(
          create: (context) => MisionProvider(context.read<MisionRepository>()),
        ),

        // 7. Inyectamos la implementación del repositorio de Tienda
        Provider<RecompensaRepository>(
          create: (_) => RecompensaRepositoryImpl(FirebaseFirestore.instance),
        ),

        // 8. Creamos el Provider de Tienda
        ChangeNotifierProvider(
          create: (context) =>
              TiendaProvider(context.read<RecompensaRepository>()),
        ),

        // 9. Inyectamos la implementación del repositorio de Retos
        Provider<RetoRepository>(
          create: (_) =>
              RetoRepositoryImpl(firestore: FirebaseFirestore.instance),
        ),

        // 10. Creamos el Provider de Retos
        ChangeNotifierProvider(
          create: (context) =>
              RetoProvider(repository: context.read<RetoRepository>()),
        ),

        // 11. Inyectamos la implementación del repositorio de Sendas
        Provider<SendaRepository>(create: (_) => SendaRepositoryImpl()),

        // 12. Creamos el Provider de Sendas
        ChangeNotifierProvider(
          create: (context) => SendaProvider(context.read<SendaRepository>()),
        ),
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
      title: 'TFG RPG Gamificación',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return BorderOverlay(child: child ?? const SizedBox.shrink());
      },
      /*
        Utilizamos un Consumer para reaccionar al estado de autenticación.
        Si el usuario está identificado, lo enviamos a la HomeScreen; 
        de lo contrario, a la pantalla de Login.
      */
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const InicioScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
