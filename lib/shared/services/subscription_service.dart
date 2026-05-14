import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  Future<void> initialize() async {
    // RevenueCat disabled based on user feedback
    /*
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
    */
  }

  Future<bool> isSubscribed() async {
    return true; // Bypassed for now
    /*
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
    */
  }

  Future<bool> purchaseTrial() async {
    // Simulated trial start
    await Future.delayed(const Duration(seconds: 1));
    return true;
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
      final result = await Purchases.purchase(PurchaseParams.package(package));
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
