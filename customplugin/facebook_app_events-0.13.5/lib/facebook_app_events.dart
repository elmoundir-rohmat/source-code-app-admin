import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

const channelName = 'facebook_app_events';

class FacebookAppEvents {
  static const _channel = MethodChannel(channelName);

  // See: https://github.com/facebook/facebook-android-sdk/blob/master/facebook-core/src/main/java/com/facebook/appevents/AppEventsConstants.java
  static const eventNameActivatedApp = 'fb_mobile_activate_app';
  static const eventNameDeactivatedApp = 'fb_mobile_deactivate_app';
  static const eventNameCompletedRegistration =
      'fb_mobile_complete_registration';
  static const eventNameViewedContent = 'fb_mobile_content_view';
  static const eventNameRated = 'fb_mobile_rate';
  static const eventNameInitiatedCheckout = 'fb_mobile_initiated_checkout';
  static const eventNameAddedToCart = 'fb_mobile_add_to_cart';
  static const eventNameAddedToWishlist = 'fb_mobile_add_to_wishlist';
  static const eventNameSubscribe = "Subscribe";
  static const eventNameStartTrial = "StartTrial";
  static const eventNameAdImpression = "AdImpression";
  static const eventNameAdClick = "AdClick";

  static const _paramNameValueToSum = "_valueToSum";
  static const paramNameAdType = "fb_ad_type";
  static const paramNameCurrency = "fb_currency";
  static const paramNameOrderId = "fb_order_id";
  static const paramNameRegistrationMethod = "fb_registration_method";
  static const paramNamePaymentInfoAvailable = "fb_payment_info_available";
  static const paramNameNumItems = "fb_num_items";
  static const paramValueYes = "1";
  static const paramValueNo = "0";

  /// Parameter key used to specify a generic content type/family for the logged event, e.g.
  /// "music", "photo", "video".  Options to use will vary depending on the nature of the app.
  static const paramNameContentType = "fb_content_type";

  /// Parameter key used to specify data for the one or more pieces of content being logged about.
  /// Data should be a JSON encoded string.
  /// Example:
  ///   "[{\"id\": \"1234\", \"quantity\": 2, \"item_price\": 5.99}, {\"id\": \"5678\", \"quantity\": 1, \"item_price\": 9.99}]"
  static const paramNameContent = "fb_content";

  /// Parameter key used to specify an ID for the specific piece of content being logged about.
  /// This could be an EAN, article identifier, etc., depending on the nature of the app.
  static const paramNameContentId = "fb_content_id";

  /// Clears the current user data
  Future<void> clearUserData() {
    return _channel.invokeMethod<void>('clearUserData');
  }

  /// Clears the currently set user id.
  Future<void> clearUserID() {
    return _channel.invokeMethod<void>('clearUserID');
  }

  /// Explicitly flush any stored events to the server.
  Future<void> flush() {
    return _channel.invokeMethod<void>('flush');
  }

  /// Returns the app ID this logger was configured to log to.
  Future<String?> getApplicationId() {
    return _channel.invokeMethod<String>('getApplicationId');
  }

  Future<String?> getAnonymousId() {
    return _channel.invokeMethod<String>('getAnonymousId');
  }
  Future<void> logSearch({
    required String itemname,
  }) {
    final args = <String, dynamic>{
      'parameter': itemname,
    };
    return _channel.invokeMethod<void>('search', args);
  }
  /// Log an app event with the specified [name] and the supplied [parameters] value.
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
    double? valueToSum,
  }) {
    final args = <String, dynamic>{
      'name': name,
      'parameters': parameters,
      _paramNameValueToSum: valueToSum,
    };

    return _channel.invokeMethod<void>('logEvent', _filterOutNulls(args));
  }

  /// Sets user data to associate with all app events.
  /// All user data are hashed and used to match Facebook user from this
  /// instance of an application. The user data will be persisted between
  /// application instances.
  /// See deprecation note: https://github.com/facebook/facebook-android-sdk/blob/9da80baea0d23a82ce797e17bd4bc0e0d75b3912/facebook-core/src/main/java/com/facebook/appevents/AppEventsLogger.kt#L579
  @Deprecated(
      'Deprecated starting v0.13.0 of this plugin and will be removed in v12 of Facebook SDK')
  Future<void> setUserData({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? city,
    String? state,
    String? zip,
    String? country,
  }) {
    final args = <String, dynamic>{
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
    };

    return _channel.invokeMethod<void>('setUserData', args);
  }

  /// Logs an app event that tracks that the application was open via Push Notification.
  Future<void> logPushNotificationOpen({
    required Map<String, dynamic> payload,
    String? action,
  }) {
    final args = <String, dynamic>{
      'payload': payload,
      'action': action,
    };

    return _channel.invokeMethod<void>('logPushNotificationOpen', args);
  }

  /// Sets a user [id] to associate with all app events.
  /// This can be used to associate your own user id with the
  /// app events logged from this instance of an application.
  /// The user ID will be persisted between application instances.
  Future<void> setUserID(String id) {
    return _channel.invokeMethod<void>('setUserID', id);
  }

  /// Update user properties as provided by a map of [parameters]
  /// See deprecation note: https://github.com/facebook/facebook-android-sdk/blob/9da80baea0d23a82ce797e17bd4bc0e0d75b3912/facebook-core/src/main/java/com/facebook/appevents/AppEventsLogger.kt#L639
  @Deprecated(
      'Deprecated starting v0.13.0 of this plugin and will be removed in v12 of Facebook SDK')
  Future<void> updateUserProperties({
    required Map<String, dynamic> parameters,
    String? applicationId,
  }) {
    final args = <String, dynamic>{
      'parameters': parameters,
      'applicationId': applicationId,
    };

    return _channel.invokeMethod<void>('updateUserProperties', args);
  }

  // Below are shorthand implementations of the predefined app event constants

  /// Log this event when an app is being activated.
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnameactivatedapp
  /// See deprecation note: https://github.com/facebook/facebook-android-sdk/blob/9da80baea0d23a82ce797e17bd4bc0e0d75b3912/facebook-core/src/main/java/com/facebook/appevents/AppEventsLogger.kt#L381
  @Deprecated(
      'Deprecated starting v0.13.0 of this plugin and will be removed in v12 of Facebook SDK')
  Future<void> logActivatedApp() {
    return logEvent(name: eventNameActivatedApp);
  }

  /// Log this event when an app is being deactivated.
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnamedeactivatedapp
  /// See deprecation note: https://github.com/facebook/facebook-android-sdk/blob/9da80baea0d23a82ce797e17bd4bc0e0d75b3912/facebook-core/src/main/java/com/facebook/appevents/AppEventsLogger.kt#L391
  @Deprecated(
      'Deprecated starting v0.13.0 of this plugin and will be removed in v12 of Facebook SDK')
  Future<void> logDeactivatedApp() {
    return logEvent(name: eventNameDeactivatedApp);
  }

  /// Log this event when the user has completed registration with the app.
  /// Parameter [registrationMethod] is used to specify the method the user has
  /// used to register for the app, e.g. "Facebook", "email", "Google", etc.
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnamecompletedregistration
  Future<void> logCompletedRegistration({String? registrationMethod}) {
    return logEvent(
      name: eventNameCompletedRegistration,
      parameters: {
        paramNameRegistrationMethod: registrationMethod,
      },
    );
  }

  /// Log this event when the user has rated an item in the app.
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnamerated
  Future<void> logRated({double? valueToSum}) {
    return logEvent(
      name: eventNameRated,
      valueToSum: valueToSum,
    );
  }

  /// Log this event when the user has viewed a form of content in the app.
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnameviewedcontent
  Future<void> logViewContent({
    Map<String, dynamic>? content,
    String? id,
    String? type,
    String? currency,
    double? price,
  }) {
    return logEvent(
      name: eventNameViewedContent,
      parameters: {
        paramNameContent: content != null ? json.encode(content) : null,
        paramNameContentId: id,
        paramNameContentType: type,
        paramNameCurrency: currency,
      },
      valueToSum: price,
    );
  }

  /// Log this event when the user has added item to cart
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnameaddedtocart
  Future<void> logAddToCart({
    Map<String, dynamic>? content,
    required String id,
    required String type,
    required String currency,
    required double price,
  }) {
    return logEvent(
      name: eventNameAddedToCart,
      parameters: {
        paramNameContent: content != null ? json.encode(content) : null,
        paramNameContentId: id,
        paramNameContentType: type,
        paramNameCurrency: currency,
      },
      valueToSum: price,
    );
  }


  /// Log this event when the user has added item to cart
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnameaddedtowishlist
  Future<void> logAddToWishlist({
    Map<String, dynamic>? content,
    required String id,
    required String type,
    required String currency,
    required double price,
  }) {
    return logEvent(
      name: eventNameAddedToWishlist,
      parameters: {
        paramNameContent: content != null ? json.encode(content) : null,
        paramNameContentId: id,
        paramNameContentType: type,
        paramNameCurrency: currency,
      },
      valueToSum: price,
    );
  }

  /// Re-enables auto logging of app events after user consent
  /// if disabled for GDPR-compliance.
  ///
  /// See: https://developers.facebook.com/docs/app-events/gdpr-compliance
  Future<void> setAutoLogAppEventsEnabled(bool enabled) {
    return _channel.invokeMethod<void>('setAutoLogAppEventsEnabled', enabled);
  }

  /// Set Data Processing Options
  /// This is needed for California Consumer Privacy Act (CCPA) compliance
  ///
  /// See: https://developers.facebook.com/docs/marketing-apis/data-processing-options
  Future<void> setDataProcessingOptions(
    List<String> options, {
    int? country,
    int? state,
  }) {
    final args = <String, dynamic>{
      'options': options,
      'country': country,
      'state': state,
    };

    return _channel.invokeMethod<void>('setDataProcessingOptions', args);
  }

  Future<void> logPurchase({
    double? amount,
    String? currency,
    Map<String, dynamic>? parameters,
  }) {
    final args = <String, dynamic>{
      'amount': amount,
      'currency': currency,
      'parameters': parameters,
    };
    return _channel.invokeMethod<void>('logPurchase', _filterOutNulls(args));
  }

  Future<void> logInitiatedCheckout({
    double? totalPrice,
    String? currency,
    String? contentType,
    String? contentId,
    int? numItems,
    bool paymentInfoAvailable = false,
  }) {
    return logEvent(
      name: eventNameInitiatedCheckout,
      valueToSum: totalPrice,
      parameters: {
        paramNameContentType: contentType,
        paramNameContentId: contentId,
        paramNameNumItems: numItems,
        paramNameCurrency: currency,
        paramNamePaymentInfoAvailable: paymentInfoAvailable ? paramValueYes : paramValueNo,
      },
    );
  }

  /// Sets the Advert Tracking propeety for iOS advert tracking
  /// an iOS 14+ feature, android should just return a success.
  Future<void> setAdvertiserTracking({
    required bool enabled,
  }) {
    final args = <String, dynamic>{'enabled': enabled};

    return _channel.invokeMethod<void>('setAdvertiserTracking', args);
  }

  /// The start of a paid subscription for a product or service you offer.
  /// See:
  ///   - https://developers.facebook.com/docs/marketing-api/app-event-api/
  ///   - https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/
  Future<void> logSubscribe({
    double? price,
    String? currency,
    required String orderId,
  }) {
    return logEvent(
      name: eventNameSubscribe,
      valueToSum: price,
      parameters: {
        paramNameCurrency: currency,
        paramNameOrderId: orderId,
      },
    );
  }

  /// The start of a free trial of a product or service you offer (example: trial subscription).
  /// See:
  ///   - https://developers.facebook.com/docs/marketing-api/app-event-api/
  ///   - https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/
  Future<void> logStartTrial({
    double? price,
    String? currency,
    required String orderId,
  }) {
    return logEvent(
      name: eventNameStartTrial,
      valueToSum: price,
      parameters: {
        paramNameCurrency: currency,
        paramNameOrderId: orderId,
      },
    );
  }

  /// Log this event when the user views an ad.
  Future<void> logAdImpression({
    required String adType,
  }) {
    return logEvent(
      name: eventNameAdImpression,
      parameters: {
        paramNameAdType: adType,
      },
    );
  }

  /// Log this event when the user clicks an ad.
  Future<void> logAdClick({
    required String adType,
  }) {
    return logEvent(
      name: eventNameAdClick,
      parameters: {
        paramNameAdType: adType,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  //
  // PRIVATE METHODS BELOW HERE

  /// Creates a new map containing all of the key/value pairs from [parameters]
  /// except those whose value is `null`.
  Map<String, dynamic> _filterOutNulls(Map<String, dynamic> parameters) {
    final Map<String, dynamic> filtered = <String, dynamic>{};
    parameters.forEach((String key, dynamic value) {
      if (value != null) {
        filtered[key] = value;
      }
    });
    return filtered;
  }
}
final facebookAppEvents = FacebookAppEvents();