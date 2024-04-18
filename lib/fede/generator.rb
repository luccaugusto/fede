require 'yaml'
require 'date'

class Fede
  class FeedGenerator
    def initialize(site_config, data_directory)
      @config = parse_yaml site_config
      @feed_file = get_setting 'feed_file'
      @data = parse_data data_directory
      @episode_list = []
      @ep_name = get_setting 'ep_name'
      @ep_pub_date = get_setting 'ep_pub_date'
      @ep_url = get_setting 'ep_url'
      @ep_desc = get_setting 'ep_desc'
      @ep_img = get_setting 'ep_img'
      @ep_details = get_setting 'ep_details'
      @season_name = get_setting 'season_name'
      @season_episode_list = get_setting 'season_episode_list'
      load_episode_list
    end

    def generate
      output_feed
      puts "#{@feed_file} written!"
    end

    def append(item_count = 1)
      last_n_episodes = []
      item_count.times.sort_by(&:-@).each do |i|
        last_n_episodes << generate_episode_item(@episode_list[-i - 1])
      end
      do_append last_n_episodes
    end

    def append_available_files
      episodes = []
      @episode_list.each do |ep|
        next unless File.file? ep['url']

        episodes << ep
      end
      do_append episodes
    end

    def do_append(last_n_episodes)
      File.open(@feed_file, 'r+') do |file|
        insert_position = Kernel.loop do
          pos = file.pos
          break pos if file.gets.include?('</channel>') || file.eof?
        end
        file.seek(insert_position, IO::SEEK_SET)
        footer = file.read
        file.seek(insert_position, IO::SEEK_SET)
        episodes_string = last_n_episodes.reduce('') { |prev, ep| "#{prev}#{ep.to_s(2)}" }
        file.write("#{episodes_string}#{footer}")
      end
      puts "Last #{last_n_episodes.length} episode(s) appended to #{@feed_file}!"
    rescue Errno::ENOENT
      puts "Cannot append if feed doesn't exist"
    end

    private

    def parse_data(path)
      data = {}
      Dir.entries(path).each do |file|
        next if ['.', '..'].include? file

        data[file.split('.')[0]] = YAML.load_file "#{path}/#{file}"
      end
      data
    end

    def parse_yaml(file)
      YAML.load_file file
    end

    def get_setting(setting_name)
      setting = @config['podcast'][setting_name] || @config[setting_name]
      if setting.nil?
        raise StandardError, "Error: setting #{setting_name} is not defined in the config file, cannot continue"
      end

      setting
    end

    def output_feed
      build_date = DateTime.now.strftime(get_setting('datetime_format_string'))
      base_url = get_setting 'url'
      managing_editor = get_setting 'managing_editor'
      editor_email = get_setting 'editor_email'
      desc = get_setting 'description'

      feed = XMLFeed.new
      channel = XMLNode.new 'channel'
      atom_link = XMLNode.new 'atom:link'
      atom_link.set_propperty 'href', "#{base_url}/#{@feed_file}"
      atom_link.set_propperty 'rel', 'self'
      atom_link.set_propperty 'type', 'application/rss+xml'
      channel.add_child atom_link
      channel.add_child XMLNode.new 'title', content: get_setting('title')
      channel.add_child XMLNode.new 'pubDate', content: @episode_list[0]['pub_date']
      channel.add_child XMLNode.new 'lastBuildDate', content: build_date
      channel.add_child XMLNode.new 'link', content: base_url
      channel.add_child XMLNode.new 'language', content: 'pt'
      channel.add_child(
        XMLNode.new(
          'copyright',
          cdata: true,
          content: "#{get_setting('title')} #{DateTime.now.year}, #{get_setting('copyright')}."
        )
      )
      channel.add_child XMLNode.new('docs', content: base_url)
      channel.add_child XMLNode.new('managingEditor', content: "#{editor_email} (#{managing_editor})")
      channel.add_child XMLNode.new('itunes:summary', cdata: true, content: desc)
      image = XMLNode.new 'image'
      image.add_child XMLNode.new('url', content: "#{base_url}#{get_setting('logo')}")
      image.add_child XMLNode.new('title', content: get_setting('title'))
      image.add_child XMLNode.new('link', cdata: true, content: base_url)
      channel.add_child image
      channel.add_child XMLNode.new('itunes:author', content: get_setting('author'))
      category = XMLNode.new 'itunes:category'
      category.set_propperty 'text', 'Society &amp; Culture'
      channel.add_child category
      channel.add_child XMLNode.new('itunes:keywords', content: get_setting('keywords'))
      channel.add_child XMLNode.new('itunes:image', propperties: { href: "#{base_url}#{get_setting('logo')}" })
      channel.add_child XMLNode.new('itunes:explicit', content: true)
      owner = XMLNode.new 'itunes:owner'
      owner.add_child XMLNode.new('itunes:email', content: get_setting('email'))
      owner.add_child XMLNode.new('itunes:name', content: get_setting('title'))
      channel.add_child owner
      channel.add_child(XMLNode.new('description', content: desc, cdata: true))
      channel.add_child(
        XMLNode.new(
          'itunes:subtitle',
          content: get_setting('short_description'),
          cdata: true
        )
      )
      channel.add_child XMLNode.new('itunes:type', content: 'episodic')
      channel.add_child XMLNode.new('itunes:new-feed-url', content: "#{base_url}/#{@feed_file}")
      channel.add_children generate_all_episode_items

      feed.nodes << channel
      File.open(@feed_file, 'w') { |file| file.write(feed) }
    end

    def generate_episode_item(episode)
      description = format_description episode[@ep_desc], details: episode[@ep_details], indent_level: 3
      subtitle = format_subtitle episode[@ep_desc]

      current_item = XMLNode.new 'item'
      current_item.add_child XMLNode.new('guid', content: "#{get_setting('url')}#{episode[@ep_url]}")
      current_item.add_child XMLNode.new('title', content: episode[@ep_name])
      current_item.add_child XMLNode.new('pubDate', content: episode[@ep_pub_date])
      current_item.add_child(XMLNode.new('link', cdata: true, content: "#{get_setting('url')}#{episode[@ep_url]}"))
      current_item.add_child XMLNode.new(
        'itunes:image',
        propperties: { href: "#{get_setting('url')}#{episode_image(episode)}" }
      )
      current_item.add_child XMLNode.new('description', cdata: true, content: description)
      current_item.add_child(
        XMLNode.new(
          'enclosure',
          propperties: {
            length: episode_bytes_length(episode),
            type: 'audio/mpeg',
            url: "#{get_setting('url')}#{episode[@ep_url]}"
          }
        )
      )
      current_item.add_child XMLNode.new 'itunes:duration', content: episode_duration(episode)
      current_item.add_child XMLNode.new 'itunes:explicit', content: true
      current_item.add_child XMLNode.new(
        'itunes:keywords',
        content: get_setting('keywords')
      )
      current_item.add_child XMLNode.new 'itunes:subtitle', content: subtitle, cdata: true
      current_item.add_child XMLNode.new 'itunes:episodeType', content: 'full'

      current_item
    end

    def generate_all_episode_items
      episode_list = []
      @episode_list.map do |episode|
        next if episode['hide']

        episode_list << generate_episode_item(episode)
      rescue StandardError => e
        puts "Failed to generate item for #{episode[@ep_name]}: #{e}"
      end
      episode_list
    end

    def format_description(description, details: '', indent_level: 0, strip_all: false)
      indentation = "\t" * indent_level
      description = "#{description}\n#{indentation}#{details}".gsub '</br>', "\n#{indentation}"
      description.gsub! '<p>', "\n#{indentation}"
      description.gsub! '</p>', ''
      description.gsub! '<ul>', ''
      description.gsub! '<li>', "\n#{indentation} + "
      description.gsub! '</li>', ''
      description.gsub! '</ul>', "\n#{indentation}"

      if strip_all
        description.gsub!(/<.?[^>]+>/, '')
      else
        # strip rest of html tags (a tags are allowed)
        description.gsub!(%r{<[^a][^a]/?[^>]+>}, '')
      end
      description.gsub!(" \n", "\n")
      description.strip
    end

    def format_subtitle(subtitle)
      desc = format_description(subtitle, strip_all: true)
      desc.length > 255 ? "#{desc.slice(0, 252)}..." : desc
    end

    def episode_bytes_length(episode)
      return episode['bytes_length'] if episode['bytes_length']

      File.new("#{Dir.getwd}#{episode[@ep_url]}").size
    end

    def episode_duration(episode)
      return episode['duration'] if episode['duration']

      raise 'FFMPEG not found. ffmpeg is needed to fech episode length' unless which('ffmpeg')

      cmd = "ffmpeg -i #{Dir.getwd}#{episode[@ep_url]} 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/\.[0-9]*,//"
      `#{cmd}`.strip!
    end

    def episode_image(episode)
      episode[@ep_img] || get_setting('logo')
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      nil
    end

    def load_episode_list
      episodes
      episodes_from_seasons
      @episode_list.sort_by! do |episode|
        DateTime.strptime(
          episode[@ep_pub_date],
          get_setting('datetime_format_string')
        )
      end
    end

    def episodes
      episode_data = get_setting 'episode_data'
      puts 'No episodes found' && return if episode_data.nil?

      episode_data.each do |file|
        puts "No data found for #{file}" && next unless @data[file]

        @episode_list += @data[file]
      end
    end

    def episodes_from_seasons
      season_data = get_setting 'season_data'
      puts 'No seasons found' && return if season_data.nil?

      season_data.each do |file|
        puts "No data found for #{file}" && next unless @data[file]

        @data[file].each do |season|
          @episode_list += season[@season_episode_list]
        end
      end
    end
  end
end
