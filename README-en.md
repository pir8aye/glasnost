# Launching Glasnost with Docker

```
docker run -it -p 80:80 --restart on-failure:10 ontofractal/glasnost:latest
```

# Admin interface

Glasnost now has a basic admin interface to update configuration without rebooting your Glasnost instance.

Glasnost does not load configuration at startup. Until it's confirmed as saved, an admin key (which changes after each Glasnost reload) is available on the `/admin` page. Save the admin key to use it later. After confirming that you've saved the key, visit `/admin` page and enter a configuration URL and the key to resync the data from Steem/Golos blockchains.You can reload the config at any time. After Glasnost configuration, it takes some time, usually a few seconds to several minutes to synchronize the data with the blockchain.

## Configuration settings

use the following properties of the JSON config object for blockchain selection and "about the blog" page:

* `"source_blockchain"`: `steem` or `golos`
* `"about_blog_author"`: account_name (needs to be included in `authors: [...]`) in `steem` or `golos`, who posted a post with a description of the blog
* `"about_blog_permlink"`: post`s permlink (not full url) with the description of the blog
* `"language"`: Glasnost website interface language
* `"default_blockchain"`: default author's source blockchain
*  `"upgrade_insecure_requests"`: true|false

Other settings like PORT, STEEM_URL and GOLOS_URL can be configured in the Dockerfile.

## Validate configuration JSON

Configuration should be valid JSON, check for validity it is possible on [jsonlint.com](http://jsonlint.com/).

# Minimal config

```
{
  "authors": [{
    "account_name": "ontofractal",
    "source_blockchain": "steem",
    "filters": {}
  ],
  "about_blog_permlink": "anons-open-sors-platformy-dlya-razrabotki-prilozhenii-na-blokcheine-golos-fidbek-privetstvuetsya",
  "about_blog_author": "ontofractal",
  "source_blockchain": "golos"
}
```

`source_blockchain` has a higher priority than `default_blockchain`

## Custom menu configuration

You can add several top level menu items and dropdown items for each of them At this moment top level items can't be configured to links. Use the following structure for dropdown items: `["title", "link"]`.
```
{
  "menu": [{
    "item": "Golos",
    "dropdown_items": [
      [
        "Анонс Glasnost",
        "https://golos.io/ru--otkrytyij-kod/@glasnost/glasnost-v0-1-zapusk-open-sors-servera-dlya-prilozhenii-na-platforme-golos"
      ]
    ]
  }, {
    "item": "Steem",
    "dropdown_items": [
      [
        "Glasnost announcement",
        "http://glasnost.steempunks.com/authors/ontofractal/ann-introducing-glasnost-alpha-open-source-blog-and-app-server-for-steem-golos-blockchains"
      ]
    ]
  }],
}

```

## Filter`s settings

In the `authors` objects, the` filters` property must exist even if it's an empty object `{}`, but the properties for  individual filters may be absent.

Whitelisting for tags and titles are applied first: all posts that do not match whitelisting rules are discarded. Whitelist filter is ignored if absent. Blacklist rules are applied next: all posts that match any of the blacklist rules are discarded.

### Example of filters for @ontofractal

```
{
  "account_name": "ontofractal",
  "filters": {
    "tags": {
      "blacklist": ["ru--statistika"],
      "whitelist": []
    },
    "title": {
      "blacklist": [],
      "whitelist": ["Lesson \\d"]
    },
    "created": {
      "only_after": "2017-01-01",
      "only_before": ""
    }
  }
}
```

### Tags filter

Use usual arrays to whitelist/blacklist tags.

### Created date filter

Empty  `""` or non-existent values of `only_after` и `only_before` properties are ignored.  Date format should conform to the [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) standard and contain only the date part (no time or offset).

### Title filter

Strings should be valid regular expressions without opening and closing `/`. Invalid regular expressions will fail silently.

# Stopping Glasnost docker container

1. `docker ps`
2.  find the container name `CONTAINER_NAME` (in the column` NAMES`)
3. `docker stop CONTAINER_NAME`
4. `docker rm CONTAINER_NAME`
