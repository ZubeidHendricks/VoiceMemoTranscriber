# VoiceMemoTranscriber

Generated from niche `transcribe-voice` (AI Audio, tier A, score 79).

**Utility:** Record/import audio → text + summary
**Primary ASO keyword:** `transcribe audio`
**Also target:** `voice to text`, `audio transcription`, `meeting notes`, `transcribe`
**Paywall hook:** Unlimited minutes, summaries, export

> Whisper API + LLM summary. Students/professionals pay per use. Strong retention.

## Build it

```bash
brew install xcodegen        # once
cd VoiceMemoTranscriber
xcodegen generate
open VoiceMemoTranscriber.xcodeproj
```

The app runs immediately on a MockPurchaseProvider (real paywall UI, fake
purchases). To go live:

1. Replace `revenueCatKey` in `Sources/App.swift` with your RevenueCat key.
2. In App Store Connect create products `transcribe-voice_yearly` and `transcribe-voice_weekly`,
   map them into a RevenueCat offering, entitlement id `premium`.
3. Build the real feature in `Sources/ContentView.swift`.
4. **Guideline 4.3:** make the function, UI, screenshots and keywords genuinely
   distinct from any sibling app. Re-niche, never reskin.

Bundle id: `com.zubeid.transcribevoice`

## Ship to TestFlight

This app ships with a Fastlane lane + GitHub Actions workflow. One-time account
setup (API key, signing) is documented in the kit's `Tools/appgen/DEPLOYMENT.md`.
Once your GitHub secrets are set, trigger the **TestFlight** workflow (or push a
`v*` tag), or run locally:

```bash
bundle install
bundle exec fastlane beta
```
