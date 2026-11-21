import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/api_constants.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/shop/business/cubit/shop_cubit.dart';
import 'features/shop/data/repositories/shop_repository.dart';
import 'features/shop/data/webservices/dummy_json_webservice.dart';

void main() {
  final repository = DummyJsonShopRepository(
    DummyJsonWebService(accessToken: ApiConstance.accessToken),
  );
  runApp(EcommerceApp(repository: repository));
}

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key, required this.repository});

  final ShopRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShopCubit(repository)..loadInitial(),
      child: MaterialApp(
        title: 'Everyday Shop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF315C4B),
            surface: const Color(0xFFF7F8F5),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F8F5),
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
