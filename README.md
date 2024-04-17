## fede

A dirty (but perfectly functional) XML feed generator. Uses yaml files for configuration.

## Motivation
I needed a nice, simple way to generate a RSS feed for my podcast [Papo De Sauna](https://pds.luccaaugusto.xyz), which is built in [Jekyll](https://jekyllrb.com). This is a very simple script, that uses data from yaml files, like jekyll, and outputs a xml rss feed.

## How it works
This program takes 2 inputs: the config file and the data directory. The config file is a yaml file that specifies how your data is organized. The data directory is the directory that contains all your yaml data files. These data files can be a plain list of episodes, or organized in season blocks. See examples bellow.

### Running:
`fede config.yml data`

### Data dir:
```
data
├── monologues.yml
└── seasons.yml
```

### Config example:
```yaml
# config.yml

# everything is inside podcast so that it won't affect other configs
# if you're using it with other application, like jekyll, allowing for
# a single config file
podcast:
  managing_editor: 'Lucca Augusto'
  editor_email: 'lucca@luccaaugusto.xyz'
  datetime_format_string: '%a, %d %b %Y %H:%M:%S %z'
  author: 'Papo De Sauna'
  language: 'pt-BR'

  # itunes keywords
  keywords: "sauna, entretenimento, humor, filosofia"

  # output feed to this file in the current directory
  feed_file: 'pds.xml'

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
  episode_name_attribute: episode_name
  season_name_attribute: season_name
  season_episode_list_attribute: episodes
```

### Episode data example:
```yaml
# monologues.yml
- episode_name: "First Monologue"
  pub_date: Tue, 08 Sep 2020 14:00:00 +0000
  yt-link: https://www.youtube.com/watch?v=dQw4w9WgXcQ
  igtv-link: https://www.instagram.com/tv/420_wTF69yo/
  url: /monologos/first-monologue.mp3
  desc: "This is our first monologue,
  	pretty cool if you ask me :)"

- episode_name: "Second Monologue"
  pub_date: Tue, 15 Sep 2020 14:00:00 +0000
  yt-link: https://www.youtube.com/watch?v=dQw4w9WgXcQ
  igtv-link: https://www.instagram.com/tv/420_wTF69yo/
  url: /monologos/first-monologue.mp3
  desc: "This is our second monologue, extra extra cool
  	all the cool kids are saying :)"
```

### Season data example:
```yaml
# seasons.yml
- season_name: season 1
  episodes:
    - episode_name: Episode One
      pub_date: Tue, 30 Aug 2022 21:45:00 +0000
      url: /episodes/episode-one.mp3
      desc: "First episode (boring) description,
	  	this is the subtitle for the episode basically, no html tags here bro"
      yt-link: https://www.youtube.com/watch?v=dQw4w9WgXcQ
      deezer: https://deezer.page.link/EfgJJTVYMpVdnKXy5
      spotify: https://open.spotify.com/track/4PTG3Z6ehGkBFwjybzWkR8?si=a9dd0641f9334fd9
      img: /images/eps/episode-one.jpg
      details: "Extra info, this plus the desc field is the full description for your
	  	episode. Feel free to add <a> tags here, Fede will not strip those"
- season_name: season 2
  episodes:
    - episode_name: Second Episode One
      pub_date: Tue, 30 Aug 2023 21:45:00 +0000
      url: /episodes/second-episode-one.mp3
      desc: "First episode (boring) description,
	  	this is the subtitle for the episode basically, no html tags here bro"
      yt-link: https://www.youtube.com/watch?v=dQw4w9WgXcQ
      deezer: https://deezer.page.link/EfgJJTVYMpVdnKXy5
      spotify: https://open.spotify.com/track/4PTG3Z6ehGkBFwjybzWkR8?si=a9dd0641f9334fd9
      img: /images/eps/second-episode-one.jpg
      details: "Extra info, this plus the desc field is the full description for your
	  	episode. Feel free to add <a> tags here, Fede will not strip those"
```

## Features
+ (somewhat) Configurable
+ Simple

## TODO:
[ ] make a `append` mode, that will just put the last episode in the feed
[ ] Use Rake to automate build
[ ] Cover all fields with the data description configs
[ ] Publish Gem
