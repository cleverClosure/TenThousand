# CI/CD Workflows

This directory contains GitHub Actions workflows for automated testing, building, and releasing TenThousand.

## Workflows

### 1. CI Workflow (`ci.yml`)

**Triggers:**
- Push to `main`, `master`, or `develop` branches
- Pull requests to `main`, `master`, or `develop` branches
- Manual dispatch

**Jobs:**
- **test**: Builds the project and runs all 103 unit tests with code coverage
- **lint**: Runs SwiftLint for code quality checks

**Outputs:**
- Test results and code coverage reports (uploaded as artifacts)
- GitHub Actions summary with test status

### 2. PR Checks (`pr-checks.yml`)

**Triggers:**
- Pull request opened, synchronized, or reopened

**Jobs:**
- **pr-validation**: Runs SwiftLint on changed files only, builds, and tests
- **code-coverage**: Generates code coverage report for the PR

**Features:**
- Only lints files changed in the PR (efficient)
- Provides clear PR summary with pass/fail status
- Fails the PR if tests fail

### 3. Release Workflow (`release.yml`)

**Triggers:**
- Push tags matching `v*.*.*` (e.g., `v1.0.0`)
- Manual dispatch with version input

**Jobs:**
- **build-release**: Runs tests, creates archive, exports app

**Outputs:**
- Release artifact (TenThousand.zip) uploaded for 90 days
- Version-tagged build

**Note:** This creates unsigned builds for CI/CD. For App Store or notarized distribution, build and sign locally with valid certificates.

## SwiftLint Configuration

The `.swiftlint.yml` file enforces:
- Code conventions from `CODE_CONVENTIONS.md`
- No magic literals (enforced via custom rules)
- Force unwrap detection (error level)
- Proper code organization with MARK comments
- Access control best practices

### Custom Rules

- **no_magic_numbers_in_frames**: Detects `.frame(width: 320)` patterns
- **no_magic_numbers_in_padding**: Detects `.padding(16)` patterns
- **no_magic_numbers_in_corner_radius**: Detects `.cornerRadius(12)` patterns
- **private_enum_const**: Prefers `private enum Const` over `private struct Const`

## Running Locally

### Run tests
```bash
xcodebuild test \
  -project TenThousand.xcodeproj \
  -scheme TenThousand \
  -destination 'platform=macOS'
```

### Run SwiftLint
```bash
brew install swiftlint
swiftlint lint
```

### Fix auto-fixable issues
```bash
swiftlint --fix
```

## GitHub Actions Requirements

These workflows require:
- **macOS runner** (macos-14 with Xcode 15.4 default, also supports 15.0-16.2)
- **No secrets required** for basic CI/CD
- **Code signing certificates** for production releases (not included in CI)

## Workflow Status

Monitor workflow runs at:
```
https://github.com/<owner>/TenThousand/actions
```

## Adding New Workflows

When adding new workflows:
1. Create a `.yml` file in this directory
2. Follow the naming convention: `kebab-case.yml`
3. Include clear job names and step descriptions
4. Add error handling and status summaries
5. Document in this README

## Troubleshooting

### Tests failing locally but passing in CI
- Check Xcode version matches CI (15.4 or 15.0+)
- Ensure dependencies are up to date
- Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### SwiftLint warnings
- Run `swiftlint` locally to see all warnings
- Use `swiftlint --fix` to auto-fix issues
- Review `.swiftlint.yml` for rule configuration

### Code signing errors in CI
- CI builds are unsigned (CODE_SIGNING_REQUIRED=NO)
- This is expected and safe for CI/CD
- Production releases require local signing with valid certificates
