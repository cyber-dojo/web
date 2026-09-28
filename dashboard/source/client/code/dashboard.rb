class Dashboard
  def initialize(externals)
    @externals = externals
  end

  def ready?
    dashboard.ready?
  end

  private

  def dashboard
    @externals.dashboard
  end
end
