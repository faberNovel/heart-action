[![tag badge](https://img.shields.io/github/v/tag/faberNovel/heart-action)](https://github.com/faberNovel/heart-action/tags)
[![license badge](https://img.shields.io/github/license/faberNovel/heart-action)](./LICENSE)

# Heart: evaluate webpages

Evaluate webpages directly from your CI with [Google Lighthouse](https://pagespeed.web.dev/), <a href="https://www.ecoindex.fr/" hreflang="fr">GreenIT</a>, [Mozilla Observatory](https://observatory.mozilla.org/) or [SSLLabs Server](https://www.ssllabs.com/ssltest/).

Retrieve the evaluations in a [MySQL](https://www.mysql.com/) database or in a [Slack](https://slack.com/) channel.

This GitHub Action make use of the CLI tool [Heart](https://heart.fabernovel.com).

## Usage

```yaml
- uses: faberNovel/heart-action@v2
  with:
    # [Required]
    # Service name that analyze the URL.
    # Available values: greenit, lighthouse, observatory, ssllabs-server.
    analysis_service: lighthouse

    # [Required]
    # Configuration used by the analysis service. File path to a JSON file or JSON-inlined string.
    # The configuration format depends of each service, and is detailed in the READMEs of Heart: https://github.com/faberNovel/heart/tree/master/modules
    # Example for the Google Lighthouse service: https://github.com/faberNovel/heart/tree/master/modules/lighthouse.
    config: conf/lighthouse.json OR '{"url":"heart.fabernovel.com"}'

    # [Optional]
    # Check if the score of the result reaches the given threshold (between 0 and 100).
    threshold: 80

    # [Optional]
    # Comma-separated list of listener services that will not be triggered once the analysis is done.
    # This parameter is mutually exclusive with the listener_services_only one.
    # Available values: mysql, slack.
    listener_services_except: slack

    # [Optional]
    # Comma-separated list of listener services that will be triggered once the analysis is done.
    # This parameter is mutually exclusive with the listener_services_except one.
    # Available values: mysql, slack.
    listener_services_only: mysql,slack

    # [Optional]
    # Only required if you you use "mysql" as a listener_services_except or listener_services_only.
    # Location and credentials of your MySQL database, in a URL format.
    mysql_database_url: mysql://root@127.0.0.1:3306

    # [Optional]
    # Only required if you you use "observatory" as analysis_service.
    # Location of the Observatory API.
    # See https://github.com/mozilla/http-observatory#creating-a-local-installation-tested-on-ubuntu-15
    observatory_api_url: https://http-observatory.security.mozilla.org/api/v1/

    # [Optional]
    # Only required if you you use "observatory" as analysis_service.
    # Location of the Observatory website to view the the results.
    # See https://github.com/mozilla/http-observatory#creating-a-local-installation-tested-on-ubuntu-15
    observatory_analyze_url: https://observatory.mozilla.org/analyze/

    # [Optional]
    # Only required if you you use "slack" as a listener_services_except or listener_services_only.
    # Slack API token.
    slack_api_token: ${{ secrets.SLACK_API_TOKEN }}

    # [Optional]
    # Only required if you you use "slack" as a listener_services_except or listener_services_only.
    # Slack channel where the analysis results will be send.
    slack_channel_id: 'heart'

    # [Optional]
    # Display additional information when running Heart
    verbose: false
```

## Examples

### One analysis service, one URL

```yaml
on:
  schedule:
    # Every sunday at 1AM
    - cron:  '0 1 * * 0'

jobs:
  analyze:
    runs-on: ubuntu-latest
    name: 🔬 Analyse heart.fabernovel.com with Mozilla Observatory

    steps:
      - uses: faberNovel/heart-action@v2
        with:
          analysis_service: observatory
          config: '{"host":"heart.fabernovel.com"}'
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}

```

### One analysis service, several URLs

```yaml
on:
  schedule:
    # Every sunday at 1AM
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
      - uses: faberNovel/heart-action@v2
        with:
          analysis_service: lighthouse
          config: ${{ matrix.lighthouse_configuration }}
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}
        # prevent jobs from being blocked by a previous failed job.
        continue-on-error: true

```

### Several analysis services, one URL

```yaml
on:
  schedule:
    # Every sunday at 1AM
    - cron:  '0 1 * * 0'

jobs:
  greenit:
    runs-on: ubuntu-latest
    name: 🔬 Analyze with GreenIT

    steps:
      - uses: faberNovel/heart-action@v2
        with:
          analysis_service: greenit
          config: analysis/conf/greenit.json
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}

  lighthouse:
    runs-on: ubuntu-latest
    name: 🔬 Analyze with Google Lighthouse

    steps:
      - uses: faberNovel/heart-action@v2
        with:
          analysis_service: lighthouse
          config: analysis/conf/lighthouse.json
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}

```

### Several analysis services, several URLs

```yaml
on:
  schedule:
    # Every sunday at 1AM
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
      - uses: faberNovel/heart-action@v2
        with:
          analysis_service: greenit
          config: ${{ matrix.greenit_configuration }}
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
      - uses: faberNovel/heart-action@v2
        with:
          analysis_service: lighthouse
          config: ${{ matrix.lighthouse_configuration }}
          listener_services: slack
          slack_api_token: ${{ secrets.SLACK_API_TOKEN }}
        # prevent jobs from being blocked by a previous failed job.
        continue-on-error: true

```
