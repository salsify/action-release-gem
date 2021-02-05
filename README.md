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
        uses: erikkessler1/action-release-gem@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          ARTIFACTORY_AUTH_STRING: ${{ secrets.ARTIFACTORY_AUTH_STRING }}
```

_Note: since this action examines your git history to detect changes, you must set a `fetch-depth` of at least 2 with
`actions/checkout` for that history to be present._

### Environment Variables

- `GITHUB_TOKEN` (required): Used to create the GitHub release
- `ARTIFACTORY_AUTH_STRING` (required for private gems): Used to authenticate with gems.salsify.com
- `RUBYGEMS_API_KEY` (required for public gems): Used to authenticate with rubygems.org

### Outputs

- `conclusion`: Indicates if the gem was released or not (values: 'success', 'skipped')
- `release-id`: The id of the GitHub release
- `version`: The version of the gem
