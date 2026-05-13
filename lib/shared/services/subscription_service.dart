import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  Future<void> initialize() async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

    String apiKey = '';
    if (Platform.isAndroid) {
      apiKey = dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';
    } else if (Platform.isIOS) {
      apiKey = dotenv.env['REVENUECAT_IOS_KEY'] ?? '';
    }

    if (apiKey.isNotEmpty) {
      PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
    }
  }

  Future<bool> isSubscribed() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // Check for 'premium' entitlement defined in RevenueCat dashboard
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking subscription: $e');
      }
      return false;
    }
  }

  Future<List<Package>> getAvailablePackages() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching packages: $e');
      }
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result.customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Purchase failed: $e');
      }
      return false;
    }
  }
}

final subscriptionService = SubscriptionService();
