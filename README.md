# Heart: evaluate web pages (GreenIT, performances, security)

This GitHub action make it easier the use of [Heart](https://heart.fabernovel.com) in your CI workflow.

## Usage

```yaml
- uses: faberNovel/heart-action@v3
  with:
    # [Required]
    # Service name that analyze the URL.
    # Available values: dareboost,greenit,lighthouse,observatory,ssllabs-server
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
    # Only required if you set "dareboost" as analysis_service
    dareboost_api_token: 

    # [Optional]
    # Only required if you set "bigquery" as listener_services
    google_application_credentials:

    # [Optional]
    # If you use your own instance of Mozilla Observatory, use this setting to set the server API URL.
    # See https://github.com/mozilla/http-observatory#running-a-local-scanner-with-docker
    observatory_api_url:

    # [Optional]
    # If you use your own instance of Mozilla Observatory, use this setting to set the website URL.
    # See https://github.com/mozilla/http-observatory#running-a-local-scanner-with-docker
    observatory_analyze_url:

    # [Optional]
    # Only required if you set "slack" as listener_services
    slack_api_token:

    # [Optional]
    # Customize the Slack channel where the notifications are send (default: #heart)
    slack_channel_id:
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
    name: 🔬 Analyse https://heart.fabernovel.com with Mozilla Observatory

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
    name: |
      🔬 Analyse the home, product, search and accessibility pages
      on both desktop and mobile with Google Lighthouse
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
    name: 🔬 Analyze the website with GreenIT

    steps:
      - uses: faberNovel/heart-action@v3
        with:
          analysis_service: greenit
          file: analysis/conf/greenit.json
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}

  lighthouse:
    runs-on: ubuntu-latest
    name: 🔬 Analyze the website with Google Lighthouse

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
    name: |
      🔬 Analyse the home, product, search and accessibility pages
      on both desktop and mobile with GreenIT
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

  lighthouse:
    runs-on: ubuntu-latest
    name: |
      🔬 Analyse the home, product, search and accessibility pages
      on both desktop and mobile with Google Lighthouse
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

```
