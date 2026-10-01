# k8s/curl probing + identity
module DashboardApp
  class Prober
    def initialize(externals)
      @externals = externals
    end

    def alive?(_args)
      true
    end

    def ready?(_args)
      saver.ready?
    end

    def sha(_args)
      ENV.fetch('SHA', nil)
    end

    private

    def saver
      @externals.saver
    end
  end
end
