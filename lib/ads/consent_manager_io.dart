import 'package:user_messaging_platform/user_messaging_platform.dart';
import 'consent_manager.dart';

class UmpConsentClient implements ConsentClient {
  @override
  bool get isRequestLocationInEeaOrUnknown =>
      ConsentInformation.instance.isRequestLocationInEeaOrUnknown;

  @override
  Future<void> requestConsentInfoUpdate() {
    return ConsentInformation.instance
        .requestConsentInfoUpdate(const ConsentRequestParameters());
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
    await client.requestConsentInfoUpdate();
  } catch (_) {}
  if (client.isRequestLocationInEeaOrUnknown &&
      await client.isConsentFormAvailable()) {
    await form.show();
  }
}
