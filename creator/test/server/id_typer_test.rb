require_relative 'creator_test_base'
require_source 'id_typer'

class IdTyperTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest td500a: %w[
    |IdTyper#id_type re-raises a ServiceError
    |when its status is not 400
    |(only a 400 means "unknown id" and maps to nil)
  ] do
    externals = OpenStruct.new(saver: RaisingSaver.new(500))
    id_typer = IdTyper.new(externals)
    error = assert_raises(HttpJsonHash::ServiceError) do
      id_typer.id_type('anyId')
    end
    assert_equal 500, error.status, error.message
  end

  # - - - - - - - - - - - - - - - - -

  # A stand-in saver whose id_chain always raises a ServiceError of a
  # chosen status, so we can exercise IdTyper's non-400 re-raise path.
  class RaisingSaver
    def initialize(status)
      @status = status
    end

    # Raises a ServiceError carrying the configured status. Qualified because this
    # stub is nested inside the test class rather than inheriting from
    # CreatorTestBase, so it does not pick up its include of CreatorApp.
    def id_chain(id)
      raise CreatorApp::HttpJsonHash::ServiceError.new(
        '/id_chain', { id: }, 'id_chain', 'boom', @status, 'server error'
      )
    end
  end
end
