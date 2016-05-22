
module CacheProperties # mix-in

  def cache_path
    File.expand_path('..', File.dirname(__FILE__)) + '/data/caches'
  end

  def cache_filename
    @key.split('_')[0] + '.json'
  end

end
