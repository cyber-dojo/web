
module CachePath # mix-in

  def cache_path
    File.expand_path('..', File.dirname(__FILE__)) + '/caches'
  end

end
