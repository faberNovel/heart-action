# Heart: evaluate webpages

Evaluate webpages directly from your CI with [Google Lighthouse](https://pagespeed.web.dev/), <a href="https://www.ecoindex.fr/" hreflang="fr">GreenIT</a>, [Mozilla Observatory](https://observatory.mozilla.org/) or [SSLLabs Server](https://www.ssllabs.com/ssltest/).

And retrive it in a [Slack](https://slack.com/) channel or in a [Google Bigquery](https://cloud.google.com/bigquery]) database.

This GitHub Action make use of the CLI tool [Heart](https://heart.fabernovel.com).

## Usage

```yaml
- uses: faberNovel/heart-action@v3
  with:
    # [Required]
    # Service name that analyze the URL.
    # Available values: greenit,lighthouse,observatory,ssllabs-server
    analysis_service: observatory

    # [Required]
    # Set the JSON configuration used by the analysis service.
    # Either with a file path OR an inline string.
    file: conf/observatory.json
    inline: '{"host":"heart.fabernovel.com"}'

    # [Optional]
    # Check if the score of the result reaches the given threshold (between 0 and 100).
    threshold: 80

    # [Optional]
    # Services names that process the result of the analyze, separated by commas.
    # Available values: bigquery,slack
    listener_services: slack

    # [Optional]
    # Only required if you set "bigquery" as listener_services
    google_application_credentials:

    # [Optional]
    # If you use your own instance of Mozilla Observatory, use this setting to set the server API URL.
    # See https://github.com/mozilla/http-observatory#running-a-local-scanner-with-docker
    observatory_api_url: https://http-observatory.security.mozilla.org/api/v1/

    # [Optional]
    # If you use your own instance of Mozilla Observatory, use this setting to set the website URL.
    # See https://github.com/mozilla/http-observatory#running-a-local-scanner-with-docker
    observatory_analyze_url: https://observatory.mozilla.org/analyze/

    # [Optional]
    # Only required if you set "slack" as listener_services
    slack_api_token:

    # [Optional]
    # Customize the Slack channel where the notifications are send (default: #heart)
    slack_channel_id: '#heart-analysis'
```

## Examples

### One analysis service, one URL

```yaml
on:
  schedule:
    # All sunday at 1AM
    - cron:  '0 1 * * 0'

jobs:
  analyze:
    runs-on: ubuntu-latest
    name: 🔬 Analyse heart.fabernovel.com with Mozilla Observatory

    steps:
      - uses: faberNovel/heart-action@v3
        with:
          analysis_service: observatory
          inline: '{"host":"heart.fabernovel.com"}'
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}

```

### One analysis service, several URLs

```yaml
on:
  schedule:
    # All sunday at 1AM
    - cron:  '0 1 * * 0'

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    name: 🔬 Analyze with Google Lighthouse
    strategy:
      matrix:
        lighthouse_configuration: [
            "conf/home/desktop.json",
            "conf/home/mobile.json",
            "conf/product/desktop.json",
            "conf/product/mobile.json",
            "conf/search/desktop.json",
            "conf/search/mobile.json",
            "conf/accessibility/desktop.json",
            "conf/accessibility/mobile.json",
        ]
    
    steps:
      - uses: faberNovel/heart-action@v3
        with:
          analysis_service: lighthouse
          file: ${{ matrix.lighthouse_configuration }}
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}
        # prevent jobs from being blocked by a previous failed job.
        continue-on-error: true

```

### Several analysis services, one URL

```yaml
on:
  schedule:
    # All sunday at 1AM
    - cron:  '0 1 * * 0'

jobs:
  greenit:
    runs-on: ubuntu-latest
    name: 🔬 Analyze with GreenIT

    steps:
      - uses: faberNovel/heart-action@v3
        with:
          analysis_service: greenit
          file: analysis/conf/greenit.json
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}

  lighthouse:
    runs-on: ubuntu-latest
    name: 🔬 Analyze with Google Lighthouse

    steps:
      - uses: faberNovel/heart-action@v3
        with:
          analysis_service: lighthouse
          file: analysis/conf/lighthouse.json
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}

```

### Several analysis services, several URLs

```yaml
on:
  schedule:
    # All sunday at 1AM
    - cron:  '0 1 * * 0'

jobs:
  greenit:
    runs-on: ubuntu-latest
    name: 🔬 Analyze with GreenIT
    strategy:
      matrix:
        greenit_configuration: [
            "conf/greenit/home/desktop.json",
            "conf/greenit/home/mobile.json",
            "conf/greenit/product/desktop.json",
            "conf/greenit/product/mobile.json",
            "conf/greenit/search/desktop.json",
            "conf/greenit/search/mobile.json",
            "conf/greenit/accessibility/desktop.json",
            "conf/greenit/accessibility/mobile.json",
        ]

    steps:
      - uses: faberNovel/heart-action@v3
        with:
          analysis_service: greenit
          file: ${{ matrix.greenit_configuration }}
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}
        # prevent jobs from being blocked by a previous failed job.
        continue-on-error: true

  lighthouse:
    runs-on: ubuntu-latest
    name: 🔬 Analyze with Google Lighthouse
    strategy:
      matrix:
        lighthouse_configuration: [
            "conf/lighthouse/home/desktop.json",
            "conf/lighthouse/home/mobile.json",
            "conf/lighthouse/product/desktop.json",
            "conf/lighthouse/product/mobile.json",
            "conf/lighthouse/search/desktop.json",
            "conf/lighthouse/search/mobile.json",
            "conf/lighthouse/accessibility/desktop.json",
            "conf/lighthouse/accessibility/mobile.json",
        ]
    
    steps:
      - uses: faberNovel/heart-action@v3
        with:
          analysis_service: lighthouse
          file: ${{ matrix.lighthouse_configuration }}
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}
        # prevent jobs from being blocked by a previous failed job.
        continue-on-error: true

```
