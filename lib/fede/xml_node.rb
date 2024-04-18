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

    def prop_string
      return '' if @propperties.empty?

      @propperties.reduce('') { |prev, values| "#{prev} #{values[0]}='#{values[1]}'" }
    end

    def children_string(indent_level)
      @children.reduce('') { |prev, value| "#{prev}#{value.to_s indent_level}" }
    end

    def tag_open
      "<#{@tag_name}#{prop_string}"
    end

    def tag_middle(indent_level)
      return '' unless parent? || @content

      if @cdata
        ">\n#{"\t" * (indent_level + 1)}<![CDATA[#{@content}]]>\n#{"\t" * indent_level}"
      elsif parent?
        ">\n#{children_string(indent_level + 1)}#{"\t" * indent_level}"
      else
        ">#{@content}"
      end
    end

    def tag_close
      parent? || @content ? "</#{@tag_name}>\n" : "/>\n"
    end

    def to_s(indent_level = 0)
      "#{"\t" * indent_level}#{tag_open}#{tag_middle(indent_level)}#{tag_close}"
    end
  end
end
