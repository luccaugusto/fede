class Fede
  def self.setup(config_file, data_dir)
    @generator = Fede::FeedGenerator.new config_file, data_dir
  end

  def self.generate
    @generator.generate
  end

  def self.append
    @generator.append
  end
end

require 'fede/generator'
require 'fede/xml_feed'
require 'fede/xml_node'
