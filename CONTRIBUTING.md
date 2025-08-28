# Contributing to Axeptio iOS SDK Sample Apps

This repository follows [Conventional Commits](https://www.conventionalcommits.org/) and uses semantic versioning aligned with the Axeptio iOS SDK.

## Development Setup

### Prerequisites
- Node.js 22+ (use `nvm use` to switch to the correct version)
- npm 10+
- Xcode 15+
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
- `sample-objc`: Objective-C sample app changes
- `sdk-integration`: SDK integration changes
- `build`: Build system changes
- `docs`: Documentation changes
- `tests`: Test-related changes
- `deps`: Dependency updates

### Examples
```bash
feat(sample-swift): add vendor consent API testing interface
fix(sdk-integration): resolve build issues with Xcode 15
sdk(deps): upgrade to Axeptio SDK 2.0.14
docs(readme): update setup instructions for new SDK version
```

## Versioning Strategy

This repository's version tracks the Axeptio iOS SDK version it demonstrates:
- Sample app v2.0.13 → demonstrates SDK v2.0.13
- Sample app v2.0.14 → demonstrates SDK v2.0.14

## Release Process

### Creating a Release
```bash
# Patch release (bug fixes)
npm run release:patch

# Minor release (new features)
npm run release:minor

# Major release (breaking changes)
npm run release:major

# Custom release
npm run release
```

### What Happens During Release
1. Version bumped in `package.json`
2. `CHANGELOG.md` generated from conventional commits
3. Version synced across iOS project files and Info.plist files
4. Git tag created (e.g., `2.0.14`)
5. Release commit created

## Pre-commit Validation

The following checks run automatically before each commit:
- SwiftLint validation (if available)
- Xcode build verification (if available)
- Unit tests execution (if available)
- Commit message format validation

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