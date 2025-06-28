import 'consent_manager_io.dart'
    if (dart.library.html) 'consent_manager_web.dart' as impl;

abstract class ConsentClient {
  bool get isRequestLocationInEeaOrUnknown;
  Future<void> requestConsentInfoUpdate();
  Future<bool> isConsentFormAvailable();
}

abstract class ConsentFormPresenter {
  Future<void> show();
}

Future<void> maybeShowConsentForm({
  ConsentClient? consentClient,
  ConsentFormPresenter? presenter,
}) =>
    impl.maybeShowConsentForm(
      consentClient: consentClient,
      presenter: presenter,
    );
