## fede

A dirty (but perfectly functional) XML feed generator. Uses yaml files for configuration.

## Motivation
I needed a nice, simple way to generate a RSS feed for my podcast [Papo De Sauna](https://pds.luccaaugusto.xyz), which is built in [Jekyll](https://jekyllrb.com). This is a very simple script, that uses data from yaml files, like jekyll, and outputs a xml rss feed.

## How it works
This program takes 2 inputs: the config file and the data directory. The config file is a yaml file that specifies how your data is organized. The data directory is the directory that contains all your yaml data files. These data files can be a plain list of episodes, or organized in season blocks. See examples bellow.
Additionally, a third parameter `mode` can be passed, being either `append`, `generate` or `append-available`. By default this program runs in generate mode, generating the feed from scratch. On append mode the last `n` items will be output to the end of the feed. This `n` value can be specified with the parameter, like so `append-3`, default `n = 1`.

### Running:
+ Default execution: `fede example/config.yml example/data`
+ Append mode: `fede example/config.yml example/data append`
+ Multi Append mode: `fede example/config.yml example/data append-3 # this will append the last 3 items`
+ Append available mode: `fede example/config.yml example/data append-available`

### Data dir:
```
example/data
├── monologues.yml
└── seasons.yml
```

### Config example:
```yaml
# example/config.yml
# You can use these settings outside of podcast, in case you want
# to use them in the podcast and in the site. Overwrite them by
# setting them inside podcast
title: Sauna Talks Website
email: opapodesauna@gmail.com
short_description: A very moist *wink *wink conversation
description: >-
  In the Sauna, part of the Sauna. In the Sauna, part of the Sauna.
  In the Sauna, part of the Sauna. In the Sauna, part of the Sauna.
  In the Sauna...
url: "https://pds.luccaaugusto.xyz"

# what is inside podcast won't affect other configs
# if you're using it with other application, like jekyll, allowing for
# a single config file
podcast:
  title: Sauna Talks # this will overwrite the global title settings
  logo: "/images/pds-logo.jpg"
  managing_editor: 'Lucca Augusto'
  copyright: 'all rights reserved'
  editor_email: 'lucca@luccaaugusto.xyz'
  datetime_format_string: '%a, %d %b %Y %H:%M:%S %z'
  author: 'Papo De Sauna'
  language: 'pt-BR'

  # itunes keywords
  keywords: "sauna, entertainment, comedy, philosophy"

  # output feed to this file in the current directory
  feed_file: 'fede.xml'

  # specify in episode_data and season_data which files
  # in the <data> dir will be parsed

  # all files in this array will be parsed as a plain list of episodes
  episode_data:
    - monologues

  # all files in this array will be parsed as a list of seasons each
  # containing a list of episodes
  season_data:
    - seasons

  # data description configs
  # Change this to whatever you want to name the fields in your data files
  ep_name: episode_name
  ep_pub_date: pub_date
  ep_url: url
  ep_desc: desc
  ep_img: img
  ep_details: details
  season_name: season_name
  season_episode_list: episodes
```

### Episode data example:
```yaml
# examples/data/monologues.yml
# these are all the required attributes for an episode to be valid
#
# bytes_length and duration are optional if you have ffmpeg and the
# episode files at runtime. If you're running this in a CICD pipeline
# chances are you don't, so it's more flexible to just use these
# attributes here
- episode_name: "First Monologue"
  duration: 00:29:40
  bytes_length: 42069
  pub_date: Tue, 08 Sep 2020 14:00:00 +0000
  url: /monologos/first-monologue.mp3
  desc: "This is our first monologue,
    pretty cool if you ask me :)"

- episode_name: "Second Monologue"
  duration: 00:42:00
  bytes_length: 321413
  pub_date: Tue, 15 Sep 2020 14:00:00 +0000
  url: /monologos/second-monologue.mp3
  desc: "This is our second monologue, extra extra cool
    all the cool kids are saying :)"
```

### Season data example:
```yaml
# examples/data/seasons.yml
# this is the how the seasons file should look like
# note that we are using three optional parameters here,
# img, details and hide
# if img is not present, the logo will be used
# if details is not present, the description is just the desc field
# if hide is set to true, the episode won't be on the feed
- season_name: season 1
  episodes:
    - episode_name: Episode One
      duration: 01:39:22
      bytes_length: 984321
      pub_date: Mon, 29 Aug 2022 21:45:00 +0000
      url: /episodes/episode-one.mp3
      desc: First episode (boring) description,
        this is the subtitle for the episode basically, no html tags here bro
      img: /images/eps/episode-one.jpg
      details: "Extra info, this plus the desc field is the full description for your
        episode. Feel free to add <a> tags here, Fede will not strip those"
- season_name: season 2
  episodes:
    - episode_name: Second Episode One
      duration: 01:05:36
      bytes_length: 1235432
      pub_date: Tue, 30 Aug 2022 21:45:00 +0000
      url: /episodes/second-episode-one.mp3
      desc: "Second first episode (boring) description,
        this is the subtitle for the episode basically, no html tags here bro"
      img: /images/eps/second-episode-one.jpg
      details: "Extra info, this plus the desc field is the full description for your
        episode. Feel free to add <a> tags here, Fede will not strip those"

    - episode_name: Site Exclusive Episode
      hide: true # the hide parameter will prevent this episode from being in the feed
      duration: 01:25:16
      bytes_length: 654234
      pub_date: Wed, 31 Aug 2022 21:45:00 +0000
      url: /episodes/exclusive-episode.mp3
      desc: "This episode is exclusive to our website, it won't show on the feed"
      img: /images/eps/second-episode-one.jpg
```

## Features
+ (somewhat) Configurable
+ Simple

## TODO:
- [x] make a `append` mode, that will just put the last episode in the feed
- [ ] Use Rake to automate build
- [X] Cover all fields with the data description configs
- [ ] Publish Gem
