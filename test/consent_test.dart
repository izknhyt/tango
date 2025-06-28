import 'package:flutter_test/flutter_test.dart';
import 'package:tango/ads/consent_manager.dart';

class _FakeConsentClient implements ConsentClient {
  _FakeConsentClient(this.isEea, this.available);
  final bool isEea;
  final bool available;
  bool requested = false;

  @override
  bool get isRequestLocationInEeaOrUnknown => isEea;

  @override
  Future<bool> isConsentFormAvailable() async => available;

  @override
  Future<void> requestConsentInfoUpdate() async {
    requested = true;
  }
}

class _FakePresenter implements ConsentFormPresenter {
  int calls = 0;
  @override
  Future<void> show() async {
    calls++;
  }
}

void main() {
  test('skips when form unavailable', () async {
    final client = _FakeConsentClient(true, false);
    final presenter = _FakePresenter();
    await maybeShowConsentForm(
      consentClient: client,
      presenter: presenter,
    );
    expect(presenter.calls, 0);
    expect(client.requested, isTrue);
  });
}
