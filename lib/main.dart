import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/provider/auth_provider.dart';
import 'package:recipe_book/provider/catergory_meal_provider.dart';
import 'package:recipe_book/provider/catergory_provider.dart';
import 'package:recipe_book/provider/favorites_provider.dart';
import 'package:recipe_book/provider/interest_firebase_provider.dart';
import 'package:recipe_book/provider/meal_detail.dart';
import 'package:recipe_book/provider/random_meal.dart';
import 'package:recipe_book/provider/search_provider.dart';
import 'package:recipe_book/provider/selection_provider.dart';
import 'package:recipe_book/screens/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => InterestProvider()),
        ChangeNotifierProvider(create: (_) => SelectionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryMealProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => RandomMealProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MaterialApp(

        debugShowCheckedModeBanner: false,
        title: 'Recipe Book',
        home: SplashScreen(),
      ),
    );
  }
}
