# [2.5.0](https://github.com/axeptio/sample-app-ios/compare/v2.4.0...v2.5.0) (2026-09-08)


### Bug Fixes

* **build:** address Copilot review round 1 on release workflow ([3a478c2](https://github.com/axeptio/sample-app-ios/commit/3a478c228e3d96052180fabddf659b72d3e0d452))
* **build:** address Copilot review round 2 on release workflow ([261e9d7](https://github.com/axeptio/sample-app-ios/commit/261e9d78633900aea1bc06f0be32c148e7945524))
* **build:** address Copilot review round 3 on release workflow ([bfbe0be](https://github.com/axeptio/sample-app-ios/commit/bfbe0beba9973e70f07667b7654524d23c83bc0c))
* **build:** force axeptio-bot identity on the release commit ([3d1583d](https://github.com/axeptio/sample-app-ios/commit/3d1583d0b4c322efaddd1f9151a4315e7dd92842))
* **build:** install without generating a local package-lock.json ([14ee2f0](https://github.com/axeptio/sample-app-ios/commit/14ee2f0664fb8b56c1fb47504be52008b3e23790))
* **build:** name python3 as a pick-simulator dependency ([bd7e615](https://github.com/axeptio/sample-app-ios/commit/bd7e6151d119ed471b10d98d119bf382a9d298ad))
* **build:** resolve the simulator instead of pinning a device name ([9bb09c2](https://github.com/axeptio/sample-app-ios/commit/9bb09c22321cde2683630870a414475e4c5690cb))
* **build:** restrict release workflow_dispatch to develop ([2b71677](https://github.com/axeptio/sample-app-ios/commit/2b7167731587df0dc1a14e8da8b16835172fbc5b))
* **build:** stop committing package-lock.json during release ([b4e23ec](https://github.com/axeptio/sample-app-ios/commit/b4e23ec5437e85b2393c821f8ca60655578b397f))
* **sdk-integration:** address Copilot review round 1 ([23a0daf](https://github.com/axeptio/sample-app-ios/commit/23a0daffd22478fe102276161966b71ad03f0f7a))
* **tests:** route the rapid-tap test through the accept helper ([5a82466](https://github.com/axeptio/sample-app-ios/commit/5a824664dd5ae0d7d9055977f49294128d121bf5)), closes [#48](https://github.com/axeptio/sample-app-ios/issues/48) [#48](https://github.com/axeptio/sample-app-ios/issues/48)
* **tests:** stop the accept helper pressing the dismiss button ([00b2bc4](https://github.com/axeptio/sample-app-ios/commit/00b2bc484ae834f9ede82bd089bcf8ee20836196))


### Features

* **sdk-integration:** align sample app with Axeptio iOS SDK 2.5.0 ([6ebae04](https://github.com/axeptio/sample-app-ios/commit/6ebae0434feaa5adba0139f6f4fa1975f93ade7f))

# 2.4.0 (2026-08-10)

Aligns the sample app and its documentation with Axeptio iOS SDK `2.4.0`, covering the full gap since `2.2.0` (the 2.3.0 and 2.4.0 lines).

The SDK's public API is unchanged between 2.2.0 and 2.4.0 — this release is about behavioural alignment and documentation accuracy.

### ⚠ BREAKING CHANGES

* **sdk-integration:** the SDK's `allowPopupDisplayWithRejectedDeviceTrackingPermissions` default changed from `false` to `true` in 2.3.0, so the consent banner is now shown to ATT-denied users unless the app opts out explicitly. This changes behaviour **without a compile error**. The sample app is unaffected (it always passes the value explicitly), but integrators upgrading from 2.2.x are — see the new "Migrating to 2.4.0" section in the README.

### Features

* **sdk:** bump AxeptioIOSSDK to `2.4.0` (SPM, exact pin; resolves tag `v2.4.0`).
* **sample-swift:** wire up `onError`, which since 2.4.0 reports webview load failures and invalid configuration instead of failing silently.
* **sample-swift:** add stable `accessibilityIdentifier`s to the main screen's controls so UI tests address them by identifier rather than by button title.
* **docs:** document codeless consent forwarding to Firebase, AppsFlyer, Adjust and Singular, the `AXEPTIO_CMP_DECISION` field-diagnostics log, web view consent continuity, and the native SwiftUI `AxeptioStore` / `.axeptioConsent()` API.
* **docs:** add a "Migrating to 2.4.0" guide — none was published upstream for the 2.3.0 or 2.4.0 releases.

### Bug Fixes

* **sample-swift:** remove the host-app Google Consent Mode relay. Since 2.3.0 the SDK forwards Firebase consent itself, so the relay was setting every GCM v2 signal twice.
* **sample-swift:** reference Firebase Analytics at startup so the SDK's runtime lookup can find `FIRAnalytics` in the static GoogleAppMeasurement archive.
* **sample-swift:** use `[weak self]` in the `onPopupClosedEvent` handler, removing a retain cycle.
* **sample-swift:** read the displayed SDK version from the bundle instead of a hardcoded string that had drifted four releases behind.
* **sample-swift:** replace the deprecated `WidgetType.pr` with `.pullRequest`.
* **build:** move `CFBundleShortVersionString` / `CFBundleVersion` out of the `NSAppTransportSecurity` dict in `Info.plist`, where iOS never read them as the app version.
* **build:** fix `sync-version.js` — it inserted version keys at the first `</dict>` rather than the root dict (the cause of the malformed `Info.plist`), and its `[\d.]+` patterns could not match prerelease versions, which is why `MARKETING_VERSION` was stuck at 2.1.4.
* **docs:** correct every `initialize()` snippet to the two-step `configure()` + `initialize()` API that has been current since 2.2.0, fix an inverted consent mapping in the Google Consent Mode example, fix `AxeptioSDK.initialize` → `Axeptio.shared.initialize`, `import Axeptio` → `import AxeptioSDK`, and the missing `display:` label on `setDisplayPopUpOnEnterForeground`.
* **docs:** remove ~100 lines of dead commented-out documentation and an orphaned `-->` that leaked into the rendered README.

### Chores

* **build:** add code-signing material (`*.p12`, `*.cer`, `*.key`, `*.pem`, `*.certSigningRequest`) to `.gitignore` and untrack the stale `build.log`.
* **docs:** correct `CONTRIBUTING.md`, which documented `release:patch|minor|major` scripts that do not exist and described standard-version behaviour rather than the configured semantic-release.

# 2.2.0-beta.1 (2026-04-10)

Beta release aligning the public sample app with Axeptio iOS SDK `2.2.0-beta.1`.

> Superseded by the `2.2.0` stable pin — the sample app was moved to `AxeptioIOSSDK` `2.2.0` (stable) in commit `4fb80f6` without a separate changelog entry.

### ⚠ BREAKING CHANGES

* **sample-objc:** the Objective-C sample app has been removed. Consumers needing an Obj-C reference should stay on the `master` branch (SDK 2.1.x).

### Features

* **sdk:** bump AxeptioIOSSDK to `2.2.0-beta.1` (SPM, exact pin).
* **sample-swift:** add SwiftUI integration demo (`SwiftUISampleView`) reachable from a new "SwiftUI Demo" entry in the main sample.
* **sample-swift:** migrate initialization to the new two-step `configure()` + `initialize(targetService:clientId:cookiesVersion:widgetType:)` flow and re-enable `setForceShowConsentDebug()`.
* **sample-swift:** align default `cookiesVersion` with the Flutter SDK (`google cmp partner program sandbox-en-EU`).

# [2.1.0](https://github.com/axeptio/sample-app-ios/compare/v2.0.15...v2.1.0) (2026-03-18)


### Bug Fixes

* add missing allowPopupWithRejectedATT parameter to ConfigurationViewController ([7bdd219](https://github.com/axeptio/sample-app-ios/commit/7bdd219fdec239cdc776654df53dad9944ba2248))
* address Copilot PR review comments ([90d7def](https://github.com/axeptio/sample-app-ios/commit/90d7deff1ed240a091e0c52b86066c982e70abc0))
* clarify Podfile iOS 18 target is sample-app-only, not SDK requirement ([18d948e](https://github.com/axeptio/sample-app-ios/commit/18d948e843d79e0cfea569a078fbe49f6ccf8cdd))
* correct SDK minimum iOS version in README (iOS 15, not iOS 18) ([3e2bedb](https://github.com/axeptio/sample-app-ios/commit/3e2bedb05f6c4e5e383fc4b864666b0276434f35))
* restore top banner image ([6a8a27e](https://github.com/axeptio/sample-app-ios/commit/6a8a27e1e281205777fa86eb5406763d01c9abc6))
* **sample-swift:** correct ATT integration and setupUI() timing ([d32088e](https://github.com/axeptio/sample-app-ios/commit/d32088e66f7f89339c517ceeb5cb3ad9eb166d94))
* track forceShowConsent in editing state instead of reading from singleton ([4de5891](https://github.com/axeptio/sample-app-ios/commit/4de5891db94af53681804500a28daa00fbb94d8e))
* update widget type segmented control when selecting preset ([9331dec](https://github.com/axeptio/sample-app-ios/commit/9331dec78231d9025b00c3f8696ce0a0e9a5b0a6)), closes [#36](https://github.com/axeptio/sample-app-ios/issues/36)


### Features

* add comprehensive TCF Vendor Management APIs documentation ([be6efef](https://github.com/axeptio/sample-app-ios/commit/be6efef337a8a2c48162bf46515561f94db1cec3))
* add enhanced initialization parameters ([c9ff38c](https://github.com/axeptio/sample-app-ios/commit/c9ff38c128e8d666bb1f91d414a51034a59ddba6))
* add simple Config button to access settings ([5ecf9aa](https://github.com/axeptio/sample-app-ios/commit/5ecf9aaa735c1845295dbb1ad5ab29812f707c72))
* **build:** update minimum iOS version to 18 (Apple-supported only) ([071fa1c](https://github.com/axeptio/sample-app-ios/commit/071fa1c3c8f10f8c65c85e99c7662794dc602e52))
* update sample app to SDK 2.1.2 with enhanced configuration ([b702d8e](https://github.com/axeptio/sample-app-ios/commit/b702d8ec84d3c3892e895b594a5882dad88726b8))
