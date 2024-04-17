class Fede
  class XMLFeed
    attr_accessor :nodes

    def initialize(nodes = [])
      @nodes = nodes
    end

    def self.header
      "<?xml version='1.0' encoding='UTF-8'?>\n<rss version='2.0' xmlns:atom='http://www.w3.org/2005/Atom'"\
      " xmlns:cc='http://web.resource.org/cc/' xmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'"\
      " xmlns:media='http://search.yahoo.com/mrss/' xmlns:content='http://purl.org/rss/1.0/modules/content/' xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>\n"
    end

    def self.footer
      "</rss>\n"
    end

    def to_s
      '' unless @nodes

      nodes_string = @nodes.reduce('') do |prev, node|
        "#{prev}#{node.to_s(1)}"
      end

      "#{header}#{nodes_string}#{footer}"
    end
  end
end
