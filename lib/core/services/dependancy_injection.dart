// import 'package:admin_app/UI/login/models/login_model.dart';
// import 'package:get_it/get_it.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// GetIt _getIt = GetIt.instance;

// Future<void> setupLocator() async {
//   // Initialize Hive
//   await Hive.initFlutter();

//   // Register Hive Adapters
//   Hive.registerAdapter(LoginModelAdapter()); // Register the adapter

//   // Open Hive Boxes
//   var loginBox = await Hive.openBox<LoginModel>('LoginBox');

//   // Register instances in GetIt
//   _getIt.registerSingleton<HiveInterface>(Hive); // Register Hive instance
//   _getIt.registerSingleton<Box<LoginModel>>(loginBox); // Register loginBox

//   // You can register more boxes like this
//   // var anotherBox = await Hive.openBox<AnotherModel>('anotherBox');
//   // _getIt.registerSingleton<Box<AnotherModel>>(anotherBox);
// }
