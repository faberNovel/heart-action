# Heart: evaluate web pages (GreenIT, performances, security)

This GitHub action make it easier the use of [Heart](https://heart.fabernovel.com) in your CI workflow.

## Usage

```yaml
- uses: faberNovel/heart-action@3
  with:
    # [Required]
    # Service name that analyze the URL.
    # Available values: dareboost,greenit,lighthouse,observatory,ssllabs-server
    analysisService: "observatory"

    # [Required]
    # Set the JSON configuration used by the analysis service.
    # Either with a file path or an inline string.
    file: "conf/observatory.json"
    inline: '{"host":"heart.fabernovel.com"}'

    # [Optional]
    # Check if the score of the result reaches the given threshold (between 0 and 100).
    threshold: "80"

    # [Optional]
    # Services names that process the result of the analyze, separated by commas.
    # Available values: bigquery,slack
    listenerServices: "slack"
```

## Examples

### Single analysis service, single URL

```yaml
jobs:
    steps:
      - uses: faberNovel/heart-action@3
        with:
          analysisService: "lighthouse"
          inline: '{"url":"https://heart.fabernovel.com"}'
          listenerServices: "slack"

```

### Single analysis service, multiple URLs

```yaml
jobs:
  lighthouse_configuration_matrix:
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
      - uses: faberNovel/heart-action@3
        with:
          analysisService: "lighthouse"
          file: ${{ matrix.lighthouse_configuration }}
          listenerServices: "slack"

```