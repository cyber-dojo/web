module DashboardApp
  class Event
    def initialize(summary, previous_index = 0)
      @summary = summary
      @summary['previous_index'] = previous_index
    end

    def index
      @summary['index']
    end

    def major_index
      @summary['major_index']
    end

    def minor_index
      @summary['minor_index']
    end

    def previous_index
      @summary['previous_index']
    end

    def light?
      colours = %i[red red_special amber amber_special green green_special]
      index != 0 && colours.include?(colour)
    end

    def time
      Time.mktime(*time_a)
    end

    def time_a
      @summary['time']
    end

    def predicted
      @summary['predicted'] || 'none'
    end

    def colour
      (@summary['colour'] || '').to_sym
    end

    def revert
      @summary['revert']
    end

    def checkout
      @summary['checkout']
    end

    def filename
      @summary['filename'] || @summary['new_filename']
    end
  end
end
