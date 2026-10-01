module CreatorApp
  module EscapeHtmlHelper
    def escape_html(text)
      Rack::Utils.escape_html(text)
    end
  end
end
