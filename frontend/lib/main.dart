import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/auth_provider.dart';
import 'router.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
      ],
      child: const KairosApp(),
    ),
  );
}

class KairosApp extends StatelessWidget {
  const KairosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return MaterialApp.router(
      title: 'KAIROS',
      debugShowCheckedModeBanner: false,
      theme: KairosTheme.dark,
      darkTheme: KairosTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: createRouter(auth),
    );
  }
}
