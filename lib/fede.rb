class Fede
  def self.setup(config_file:, data_dir:, mode:)
    @generator = Fede::FeedGenerator.new config_file, data_dir
    if mode.include? 'append'
      mode_info = mode.split('-')
      append mode_info.length > 1 ? Integer(mode_info[1]) : 1
    elsif mode == 'generate'
      generate
    else
      puts "Invalid mode #{mode}. Valid modes are 'generate' or 'append'"
    end
  end

  def self.generate
    @generator.generate
  end

  def self.append(item_count = 1)
    @generator.append item_count
  end
end

require 'fede/generator'
require 'fede/xml_feed'
require 'fede/xml_node'
