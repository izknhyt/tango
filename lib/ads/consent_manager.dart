import 'package:user_messaging_platform/user_messaging_platform.dart';

abstract class ConsentClient {
  bool get isRequestLocationInEeaOrUnknown;
  Future<void> requestConsentInfoUpdate(ConsentRequestParameters params);
  Future<bool> isConsentFormAvailable();
}

abstract class ConsentFormPresenter {
  Future<void> show();
}

class UmpConsentClient implements ConsentClient {
  @override
  bool get isRequestLocationInEeaOrUnknown =>
      ConsentInformation.instance.isRequestLocationInEeaOrUnknown;

  @override
  Future<void> requestConsentInfoUpdate(ConsentRequestParameters params) {
    return ConsentInformation.instance.requestConsentInfoUpdate(params);
  }

  @override
  Future<bool> isConsentFormAvailable() {
    return ConsentInformation.instance.isConsentFormAvailable();
  }
}

class UmpConsentFormPresenter implements ConsentFormPresenter {
  @override
  Future<void> show() async {
    try {
      await UserMessagingPlatform.instance.showConsentFormIfRequired();
    } catch (_) {
      try {
        await UserMessagingPlatform.instance.showConsentForm();
      } catch (_) {}
    }
  }
}

Future<void> maybeShowConsentForm({
  ConsentClient? consentClient,
  ConsentFormPresenter? presenter,
}) async {
  final client = consentClient ?? UmpConsentClient();
  final form = presenter ?? UmpConsentFormPresenter();
  try {
    await client.requestConsentInfoUpdate(const ConsentRequestParameters());
  } catch (_) {}
  if (client.isRequestLocationInEeaOrUnknown &&
      await client.isConsentFormAvailable()) {
    await form.show();
  }
}
