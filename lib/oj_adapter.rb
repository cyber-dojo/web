# frozen_string_literal: true

module OjAdapter # mix-in

  def json_plain(obj)
    #Oj.dump(obj, { :mode => :strict })
    JSON.generate(obj)
  end

  def json_pretty(obj)
    #Oj.generate(obj, OJ_PRETTY_OPTIONS)
    JSON.pretty_generate(obj)
  end

  def json_parse(s)
    #Oj.strict_load(s)
    JSON.parse!(s)
  end

  OJ_PRETTY_OPTIONS = {
    :space => ' ',
    :indent => '  ',
    :object_nl => "\n",
    :array_nl => "\n"
  }

end
