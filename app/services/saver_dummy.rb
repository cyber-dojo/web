
class SaverDummy

  def initialize(_externals)
  end

  def method_missing(m, *args, &block)
    File.open(filename, 'a') { |fd|
      fd.write([m,*args].to_json + "\n")
    }
  end

  private

  def filename
    "/tmp/cyber-dojo-#{id}.json"
  end

  def id
    ENV['CYBER_DOJO_TEST_ID']
  end

end
