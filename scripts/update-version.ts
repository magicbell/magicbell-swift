import { replaceInFile, ReplaceInFileConfig } from 'replace-in-file';

import pkgJson from '../package.json';

const version = pkgJson.version

// Warning:
// Make sure to bundle replacements in the same file into one, otherwise the `Promise.all`
// later on can lead to race conditions, overwriting previously applied replacements

const replacements = [
  // Cocoapods instructions
  {
    files: 'README.md',
    from: [
      // Cocoapods instructions
      /pod 'MagicBell', '>=\d\.\d\.\d'/g,
      // Swift Package Manager instructions
      /.upToNextMajor\(from: "\d\.\d\.\d"\)/g,
      // Carthage instructions
      /github "magicbell-io\/magicbell-swift" "\d\.\d\.\d"/g
    ],
    to: [
      `pod 'MagicBell', '>=${version}'`,
      `.upToNextMajor(from: "${version}")`,
      `github "magicbell-io/magicbell-swift" "${version}"`
    ],
  },
  // SDK version in Swift code
  {
    files: 'Source/MagicBellClient.swift',
    from: /public static let version = "\d\.\d\.\d"/g,
    to: `public static let version = "${version}"`,
  }
]

await Promise.all(
  replacements.map(options => replaceInFile(options))
).catch(e => {
  process.stdout.write(`Error updating version via update-version.ts: ${e}\n`);
  process.exit(1);
})
