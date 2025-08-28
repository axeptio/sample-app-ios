#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Get version from package.json
const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const version = packageJson.version;

console.log(`Syncing version ${version} across project files...`);

// Update Info.plist files
const infoPlistPaths = [
  'sampleSwift/sampleSwift/Info.plist',
  'sampleObjectiveC/sampleObjectiveC/Info.plist'
];

for (const plistPath of infoPlistPaths) {
  if (fs.existsSync(plistPath)) {
    let content = fs.readFileSync(plistPath, 'utf8');
    
    // Check if CFBundleShortVersionString exists, if not add it
    if (!content.includes('<key>CFBundleShortVersionString</key>')) {
      // Add version keys before the closing </dict> tag
      const versionSection = `\t<key>CFBundleShortVersionString</key>\n\t<string>${version}</string>\n\t<key>CFBundleVersion</key>\n\t<string>${version}</string>\n</dict>`;
      content = content.replace('</dict>', versionSection);
    } else {
      // Update CFBundleShortVersionString
      content = content.replace(
        /<key>CFBundleShortVersionString<\/key>\s*<string>[\d.]+<\/string>/g,
        `<key>CFBundleShortVersionString</key>\n\t<string>${version}</string>`
      );
      
      // Update CFBundleVersion
      content = content.replace(
        /<key>CFBundleVersion<\/key>\s*<string>[\d.]+<\/string>/g,
        `<key>CFBundleVersion</key>\n\t<string>${version}</string>`
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
  'sampleSwift/sampleSwift.xcodeproj/project.pbxproj',
  'sampleObjectiveC/sampleObjectiveC.xcodeproj/project.pbxproj'
];

for (const projectPath of projectPaths) {
  if (fs.existsSync(projectPath)) {
    let content = fs.readFileSync(projectPath, 'utf8');
    
    // Update MARKETING_VERSION
    content = content.replace(
      /MARKETING_VERSION = [\d.]+;/g,
      `MARKETING_VERSION = ${version};`
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