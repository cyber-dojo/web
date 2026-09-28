require_relative 'dashboard'
require_relative 'app_base'

class App < AppBase
  def initialize(externals)
    super()
    @externals = externals
  end

  def target
    Dashboard.new(@externals)
  end

  probe(:alive?) # curl/k8s
  probe(:ready?) # curl/k8s
  get_json(:sha) # identity
end
