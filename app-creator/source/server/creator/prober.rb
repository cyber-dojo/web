module CreatorApp
  class Prober
    def initialize(externals)
      @externals = externals
    end

    def sha(_args)
      ENV['SHA']
    end

    def alive?(_args)
      true
    end

    def ready?(_args)
      [
        @externals.custom_start_points,
        @externals.exercises_start_points,
        @externals.languages_start_points,
        @externals.runner,
        @externals.saver
      ].all?(&:ready?)
    end
  end
end
