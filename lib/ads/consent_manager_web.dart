import 'consent_manager.dart';

Future<void> maybeShowConsentForm({
  ConsentClient? consentClient,
  ConsentFormPresenter? presenter,
}) async {
  // Consent handling is not required on web.
}
