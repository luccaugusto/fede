class Fede
  def self.setup(config_file:, data_dir:, mode:)
    @generator = Fede::FeedGenerator.new config_file, data_dir
    if mode.include? 'append'
      append mode
    elsif mode == 'generate'
      generate
    elsif mode == 'append-available'
      append_available
    else
      puts "Invalid mode #{mode}. Valid modes are 'generate' or 'append'"
    end
  end

  def self.append_available
    @generator.append_available_files
  end

  def self.generate
    @generator.generate
  end

  def self.append(mode)
    mode_info = mode.split('-')
    @generator.append(mode_info.length > 1 ? Integer(mode_info[1]) : 1)
  end
end

require 'fede/generator'
require 'fede/xml_feed'
require 'fede/xml_node'
