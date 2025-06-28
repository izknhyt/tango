import 'package:user_messaging_platform/user_messaging_platform.dart';
import 'consent_manager.dart';

class UmpConsentClient implements ConsentClient {
  final ConsentInformation _info =
      UserMessagingPlatform.instance.consentInfo;

  @override
  bool get isRequestLocationInEeaOrUnknown =>
      _info.isRequestLocationInEeaOrUnknown;

  @override
  Future<void> requestConsentInfoUpdate() {
    return _info.requestConsentInfoUpdate(ConsentRequestParameters());
  }

  @override
  Future<bool> isConsentFormAvailable() {
    return _info.isConsentFormAvailable();
  }
}

class UmpConsentFormPresenter implements ConsentFormPresenter {
  final ConsentForm _form = UserMessagingPlatform.instance.consentForm;

  @override
  Future<void> show() async {
    try {
      await _form.loadAndShowConsentFormIfRequired();
    } catch (_) {
      try {
        await _form.show();
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
