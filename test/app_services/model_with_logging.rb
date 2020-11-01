# frozen_string_literal: true

class ModelWithLogging

  def initialize(externals)
    @externals = externals
    @@log ||= []
  end

  def log
    @@log
  end

  def method_missing(method, *args)
    append_log([method.to_s])
    model.send(method, *args)
  end

  private

  def append_log(info)
    @@log << info
  end

  def model
    ModelService.new(@externals)
  end

end
