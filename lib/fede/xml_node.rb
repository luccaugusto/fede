class Fede
  class XMLNode
    attr_reader :children, :propperties

    def initialize(tag_name, content: nil, cdata: false, propperties: {})
      @tag_name = tag_name
      @content = content
      @cdata = cdata
      @propperties = propperties
      @children = []
    end

    def parent?
      !@children.empty?
    end

    def set_propperty(name, value)
      @propperties[name] = value
    end

    def add_child(child)
      @children << child
    end

    def add_children(children)
      raise TypeError 'Children must be an Array of nodes' unless children.is_a? Array

      @children += children
    end

    def open_tag(indent_level)
      if @cdata
        "<#{@tag_name}>\n#{"\t" * indent_level}<![CDATA["
      elsif @propperties.empty?
        "<#{@tag_name}>"
      else
        prop_string = @propperties.reduce('') { |prev, values| "#{prev} #{values[0]}='#{values[1]}'" }
        "<#{@tag_name} #{prop_string.strip}#{@content ? '' : ' /'}>"
      end
    end

    def to_s(indent_level = 1)
      result_str = "#{"\t" * indent_level}#{open_tag(indent_level + 1)}"
      if parent?
        result_str += "\n"
        @children.each { |child| result_str += child.to_s(indent_level + 1) }
        result_str += "#{"\t" * indent_level}</#{@tag_name}>"
      elsif @propperties.empty?
        result_str += "#{@content}#{@cdata ? "]]>\n#{"\t" * indent_level}" : ''}</#{@tag_name}>"
      end
      "#{result_str}\n"
    end
  end
end
