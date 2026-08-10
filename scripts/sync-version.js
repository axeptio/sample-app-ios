#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Get version from package.json
const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const version = packageJson.version;

console.log(`Syncing version ${version} across project files...`);

// Matches a semver version, including prerelease/build identifiers such as
// "2.4.0-beta.1". A bare [\d.]+ silently fails to match those, which is how
// MARKETING_VERSION previously got stuck several releases behind.
const VERSION_PATTERN = '[0-9]+\\.[0-9]+\\.[0-9]+(?:-[0-9A-Za-z.-]+)?(?:\\+[0-9A-Za-z.-]+)?';

// Update Info.plist files
const infoPlistPaths = [
  'sampleSwift/sampleSwift/Info.plist'
];

for (const plistPath of infoPlistPaths) {
  if (fs.existsSync(plistPath)) {
    let content = fs.readFileSync(plistPath, 'utf8');

    if (!content.includes('<key>CFBundleShortVersionString</key>')) {
      // Insert into the ROOT dict, i.e. the last </dict> before </plist>.
      // Replacing the first </dict> instead would bury the version keys inside
      // whichever nested dict happens to come first (e.g. NSAppTransportSecurity),
      // producing a structurally valid plist whose version keys iOS never reads.
      const versionSection =
        `\t<key>CFBundleShortVersionString</key>\n\t<string>${version}</string>\n` +
        `\t<key>CFBundleVersion</key>\n\t<string>${version}</string>\n</dict>`;

      const rootDictClose = content.lastIndexOf('</dict>');
      if (rootDictClose === -1) {
        console.error(`✗ ${plistPath} has no closing </dict>; skipping`);
        continue;
      }
      content =
        content.slice(0, rootDictClose) +
        versionSection +
        content.slice(rootDictClose + '</dict>'.length);
    } else {
      content = content.replace(
        new RegExp(`(<key>CFBundleShortVersionString</key>\\s*<string>)${VERSION_PATTERN}(</string>)`, 'g'),
        `$1${version}$2`
      );

      content = content.replace(
        new RegExp(`(<key>CFBundleVersion</key>\\s*<string>)${VERSION_PATTERN}(</string>)`, 'g'),
        `$1${version}$2`
      );
    }

    fs.writeFileSync(plistPath, content);
    console.log(`✓ Updated ${plistPath}`);
  } else {
    console.log(`! Skipped ${plistPath} (not found)`);
  }
}

// Update Xcode project versions
const projectPaths = [
  'sampleSwift/sampleSwift.xcodeproj/project.pbxproj'
];

for (const projectPath of projectPaths) {
  if (fs.existsSync(projectPath)) {
    let content = fs.readFileSync(projectPath, 'utf8');

    // pbxproj only accepts a bare token for simple values; anything containing a
    // hyphen (i.e. any prerelease version) has to be quoted.
    const marketingValue = /^[0-9.]+$/.test(version) ? version : `"${version}"`;

    content = content.replace(
      new RegExp(`MARKETING_VERSION = "?${VERSION_PATTERN}"?;`, 'g'),
      `MARKETING_VERSION = ${marketingValue};`
    );

    fs.writeFileSync(projectPath, content);
    console.log(`✓ Updated ${projectPath}`);
  } else {
    console.log(`! Skipped ${projectPath} (not found)`);
  }
}

// Check Package.resolved for SDK version consistency
const packageResolvedPaths = [
  'sampleSwift/sampleSwift.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved'
];

for (const resolvedPath of packageResolvedPaths) {
  if (fs.existsSync(resolvedPath)) {
    const resolvedContent = JSON.parse(fs.readFileSync(resolvedPath, 'utf8'));
    const axeptioSDK = resolvedContent.pins?.find(pin => 
      pin.identity === 'axeptio-ios-sdk' || pin.location?.includes('axeptio-ios-sdk')
    );
    
    if (axeptioSDK && axeptioSDK.state?.version) {
      const sdkVersion = axeptioSDK.state.version;
      if (sdkVersion !== version) {
        console.warn(`⚠️  Version mismatch in ${resolvedPath}:`);
        console.warn(`   Sample app version: ${version}`);
        console.warn(`   SDK version: ${sdkVersion}`);
        console.warn(`   Consider updating SDK dependency to match sample app version.`);
      } else {
        console.log(`✓ SDK version matches in ${resolvedPath}`);
      }
    }
  }
}

console.log(`✓ Version sync completed for ${version}`);