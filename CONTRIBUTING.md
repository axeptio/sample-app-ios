# Contributing to Axeptio iOS SDK Sample Apps

This repository follows [Conventional Commits](https://www.conventionalcommits.org/) and uses semantic versioning aligned with the Axeptio iOS SDK.

## Development Setup

### Prerequisites
- Node.js 22+ (use `nvm use` to switch to the correct version)
- npm 10+
- Xcode 16+ (the sample app targets iOS 18; the SDK itself only requires iOS 15)
- SwiftLint (optional)

### Getting Started
```bash
# Use correct Node.js version
nvm use

# Install dependencies
npm install

# Initialize Git hooks
npm run prepare
```

## Commit Message Format

Use the interactive commit tool:
```bash
npm run commit
```

Or follow the conventional commit format manually:
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types
- **feat**: New sample app features or SDK integration improvements
- **fix**: Bug fixes in sample apps or SDK integration
- **sdk**: SDK version updates or integration changes
- **docs**: Documentation changes
- **chore**: Build process, dependency updates, maintenance
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring without functionality changes
- **test**: Adding or updating tests
- **ci**: CI/CD configuration changes

### Scopes
- `sample-swift`: Swift sample app changes
- `sample-objc`: *(legacy)* the Objective-C sample was removed in 2.2.0; the scope remains accepted by commitlint for historical commits
- `sdk-integration`: SDK integration changes
- `build`: Build system changes
- `docs`: Documentation changes
- `tests`: Test-related changes
- `deps`: Dependency updates

### Examples
```bash
feat(sample-swift): add vendor consent API testing interface
fix(sdk-integration): resolve build issues with Xcode 16
sdk(deps): upgrade to Axeptio SDK 2.4.0
docs(readme): update setup instructions for new SDK version
```

> A scope is **mandatory** — commitlint rejects a scopeless message such as `docs: bump SDK to 2.4.0`.

## Versioning Strategy

This repository's version tracks the Axeptio iOS SDK version it demonstrates:
- Sample app v2.2.0 → demonstrates SDK v2.2.0
- Sample app v2.4.0 → demonstrates SDK v2.4.0

Concretely, a version bump must be applied in **four** places, which are easy to let drift apart:
- `package.json` → `version`
- `sampleSwift/sampleSwift.xcodeproj/project.pbxproj` → `MARKETING_VERSION` (Debug **and** Release)
- `sampleSwift/sampleSwift/Info.plist` → `CFBundleShortVersionString` and `CFBundleVersion`
- the SDK pin itself: `project.pbxproj` → the `axeptio-ios-sdk` `XCRemoteSwiftPackageReference` (`kind = exactVersion`)

The on-screen "Axeptio iOS SDK vX.Y.Z" label in the app reads `CFBundleShortVersionString` at runtime, so it follows the bump automatically.

## Release Process

Releases are produced by **semantic-release**, configured in `.releaserc.json`, driven by the conventional-commit history:

```bash
# Preview what would be released without publishing
npm run release:dry-run

# Perform the release
npm run release
```

### What Happens During Release
1. Commits since the last tag are analysed to determine the next version
2. `CHANGELOG.md` is generated from the conventional commits
3. `package.json` / `package-lock.json` are updated to the new version
4. A git tag is created (e.g. `v2.4.0`)
5. A GitHub release is published
6. The release commit — `CHANGELOG.md`, `package.json`, `package-lock.json` — is pushed back to the release branch

> ⚠️ `@semantic-release/git` commits those three files **only**. It does not touch the iOS project files, so `MARKETING_VERSION`, `Info.plist` and the SDK pin from the list above still have to be updated in the PR that precedes the release. Run `npm run version:sync` after bumping `package.json` to propagate the first two.

## Pre-commit Validation

`.husky/pre-commit` runs `npm run lint:check && npm run build:check` — SwiftLint (`--strict`, configured by `.swiftlint.yml`) followed by an Xcode build. Both degrade to a skip message when the tool is absent, so the hook still works without Xcode or SwiftLint installed.

It deliberately does **not** run `npm run pre-commit`, even though that script exists: that chains `test:check`, which is the XCUITest suite — ~30 minutes against the live consent widget over the network. That suite runs nightly via `.github/workflows/ui-tests.yml`, not on every commit.

`.husky/commit-msg` validates the commit message format via commitlint.

## Version Synchronization

Run manually to sync versions across all project files:
```bash
npm run version:sync
```

This ensures:
- Sample app versions match package.json
- SDK dependency versions are consistent
- iOS project files and Info.plist files are updated

## Troubleshooting

### SwiftLint Issues
```bash
# Run SwiftLint manually
npm run lint

# Auto-fix SwiftLint issues (if supported)
swiftlint --fix
```

### Build Issues
```bash
# Test Xcode build
npm run build

# Run tests
npm run test
```

### Husky Hook Issues
```bash
# Reinstall hooks
npx husky install

# Test commit message validation
echo "test: invalid message" | npx commitlint
```