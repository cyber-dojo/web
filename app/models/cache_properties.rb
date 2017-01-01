
module CacheProperties # mix-in

  def cache_path
    '/tmp/cyber-dojo/caches'
  end

  def cache_filename
    @key.split('_')[0] + '.json'
  end

end
