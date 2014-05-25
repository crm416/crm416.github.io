module Jekyll
  class AnchorBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      @tag = markup
      super
    end

    def render(context)
      contents = super

      # pipe param through liquid to make additional replacements possible
      content = Liquid::Template.parse(contents).render context

      #strip out special chars and replace spaces with hyphens
      safeContent = content.rstrip.gsub(/[^\w\s]/,'').gsub(/[\s]/,'-')

      output = "<#{@tag} id='#{safeContent}'>"
      output += content.strip
      output += "<a class='anchor-wrap' href=\"##{safeContent}\" title=\"Permalink to this headline\">¶</a></#{@tag}>"

      output
    end
  end
end

Liquid::Template.register_tag("anchor", Jekyll::AnchorBlock)