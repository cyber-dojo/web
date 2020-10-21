require_relative 'app_services_test_base'

class ModelServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D1E'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJX',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(ModelService::Error) { model.ready? }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ0',
  'ready?' do
    assert model.ready?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ1',
  'group_create' do
    name = custom_start_points.names.sample
    manifest = custom_start_points.manifest(name)
    gid = model.group_create(manifest)
    assert model.group_exists?(gid), "model.group_exists?(#{gid})"
    actual = model.group_manifest(gid)
    assert_equal manifest['image_name'], actual['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ2',
  'kata_create' do
    name = custom_start_points.names.sample
    manifest = custom_start_points.manifest(name)
    kid = model.kata_create(manifest)
    assert model.kata_exists?(kid), "model.kata_exists?(#{kid})"
    actual = model.kata_manifest(kid)
    assert_equal manifest['image_name'], actual['image_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'eJ3',
  'group_join' do
    name = custom_start_points.names.sample
    manifest = custom_start_points.manifest(name)
    gid = model.group_create(manifest)
    kid = model.group_join(gid)
    assert model.kata_exists?(kid), "model.kata_exists?(#{kid})"
    actual = model.kata_manifest(kid)
    assert_equal manifest['image_name'], actual['image_name']
  end

end
