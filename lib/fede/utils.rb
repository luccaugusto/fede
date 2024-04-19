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
