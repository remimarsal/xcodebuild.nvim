# Tuist Integration for xcodebuild.nvim

This document explains how to integrate Tuist with xcodebuild.nvim to significantly improve build times for your iOS/macOS projects.

## What is Tuist?

[Tuist](https://tuist.io/) is a command-line tool that helps developers manage large Xcode projects. It provides several benefits:

- **Faster build times**: Tuist has a caching system that can significantly speed up builds
- **Simpler project management**: Tuist generates Xcode projects from project definition files
- **Better modularity**: Tuist encourages modular project architecture
- **Improved productivity**: Less time waiting for builds means more time coding

## Prerequisites

Before integrating Tuist with xcodebuild.nvim, you need to:

1. Install Tuist on your machine:
   ```bash
   brew tap tuist/tuist
   brew install tuist
   ```

2. Set up your project to work with Tuist. If you haven't used Tuist before, follow these steps:
   - Go to your project root directory
   - Run `tuist init` to create initial project definition files
   - Configure your project according to Tuist's documentation
   - Generate Xcode project with `tuist generate`

## Configuration

To enable Tuist integration in xcodebuild.nvim, add the following to your Neovim configuration:

```lua
require("xcodebuild").setup({
  integrations = {
    tuist = {
      enabled = true, -- enable Tuist integration
      use_cache = true, -- use Tuist caching to speed up builds
      debug = false, -- enable debug logging for Tuist integration
      prefer_tuist_test = true, -- prefer using 'tuist test' over 'xcodebuild test'
      prefer_tuist_build = true, -- prefer using 'tuist build' over 'xcodebuild build'
    },
  },
})
```

## Command Mapping

When Tuist integration is enabled, xcodebuild.nvim will automatically map xcodebuild commands to their Tuist equivalents:

| xcodebuild Command | Tuist Command |
|-------------------|---------------|
| `xcodebuild build` | `tuist build` |
| `xcodebuild test` | `tuist test` |
| `xcodebuild clean` | `tuist clean` |
| `-scheme [scheme]` | `--scheme [scheme]` |
| `-destination id=[deviceId]` | `--device [deviceId]` |
| `-testPlan [plan]` | `--test-plan [plan]` |

## Build Performance Improvement

Tuist can significantly improve build performance through its caching mechanism. When building with Tuist, it will:

1. Check if there's a cached version of the build available
2. Only rebuild what has changed since the last build
3. Store build artifacts in a cache for future use

These optimizations can lead to build time reductions of 50-90% for incremental builds, making your development workflow much more efficient.

## Troubleshooting

If you encounter issues with the Tuist integration:

1. Ensure Tuist is correctly installed and available in your PATH
2. Verify your project is properly configured for Tuist
3. Enable debug logging by setting `debug = true` in the configuration
4. Check the Neovim logs for any error messages
5. Try running the equivalent Tuist commands manually in the terminal

## Limitations

- Some advanced xcodebuild flags might not have direct equivalents in Tuist
- Result bundle paths might be handled differently in Tuist
- Certain project-specific configurations might require customization

For more information about Tuist, visit [the official documentation](https://docs.tuist.io/).