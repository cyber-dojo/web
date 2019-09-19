# frozen_string_literal: true

module ApplicationHelper # mix-in

  module_function

  def js_partial(partial)
    # :nocov:
    escape_javascript(render partial:partial)
    # :nocov:
  end

end
