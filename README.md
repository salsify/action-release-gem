# Release Gem

This action allows you to release a Ruby gem when its version changes.

## Usage

The following example would release the gem when the version changes and create a GitHub release with changes sourced
from CHANGELOG.md:

```yaml
jobs:
  release:
    name: Check and Release New Version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 2
      - uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.6

      - name: Release Gem
        id: release-gem
        uses: @salsify/release-gem@v1

      - name: Create Release
        id: create-release
        if: steps.release-gem.outputs.conclusion == 'success'
        uses: actions/create-release@v1
        with:
          tag_name: v${{ steps.release-gem.outputs.version }}
          release_name: v${{ steps.release-gem.outputs.version }}
          body_path: ${{ steps.release-gem.outputs.changes }}
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

_Note: since this action examines your git history to detect changes, you must set a `fetch-depth` of at least 2 with
`actions/checkout` for that history to be present._

_Note: this will release the gem via `bundle exec rake release`, so your environment must have any necessary secrets/credentials setup._

### Outputs

- `changes`: Path to changes for the current version from CHANGELOG.md
- `conclusion`: Indicates if the gem was released or not (values: 'success', 'success')
- `version`: The version of the gem
