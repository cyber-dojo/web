require_relative '../../test/all'
require_relative '../../config/environment'
require 'json'

class AppControllerTestBase < ActionDispatch::IntegrationTest

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  # - - - - - - - - - - - - - - - -

  def in_kata(options={}, &block)
    create_language_kata(options)
    @files = plain(kata.event(-1)['files'])
    @index = 0
    block.call(kata)
  end

  def create_language_kata(options = {})
    manifest = starter_manifest
    manifest['version'] = (options[:version] || 1)
    @id = model.kata_create(manifest)
    nil
  end

  def kata
    Kata.new(self, @id)
  end

  # - - - - - - - - - - - - - - - -

  def sub_file(filename, from, to)
    refute_nil @files
    assert @files.keys.include?(filename), @files.keys.sort
    content = @files[filename]
    assert content.include?(from)
    @files[filename] = content.sub(from, to)
  end

  # - - - - - - - - - - - - - - - -

  def change_file(filename, content)
    refute_nil @files
    assert @files.keys.include?(filename), @files.keys.sort
    @files[filename] = content
  end

  # - - - - - - - - - - - - - - - -

  def post_run_tests(options = {})
    post '/kata/run_tests', params:run_test_params(options)
    @index += 1
    assert_response :success, response.body
  end

  # - - - - - - - - - - - - - - - -

  def run_test_params(options = {})
    {
      'format'           => 'js',
      'id'               => (options['id'] || kata.id),
      'image_name'       => kata.manifest['image_name'],
      'max_seconds'      => (options['max_seconds'] || kata.manifest['max_seconds']),
      'index'            => @index,
      'file_content'     => @files
    }
  end

  # - - - - - - - - - - - - - - - -

  def json
    ActiveSupport::JSON.decode(html)
  end

  def html
    @response.body
  end

end
