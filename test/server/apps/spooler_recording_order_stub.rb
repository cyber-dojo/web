require_source 'spooler_service'

# A SpoolerService that marks a shared order list when the run_tests write
# happens, and then performs the real write. Lets a test see whether the write
# happened before or after the response was returned. Injected by poking
# externals' @spooler.
class SpoolerRecordingOrderStub < Web::SpoolerService

  def initialize(externals, order)
    super(externals)
    @order = order
  end

  def kata_ran_tests(*)
    @order << :spooler_write
    super
  end

end
