# frozen_string_literal: true

module Liner # mix-in

  def lined(event)
    result = {}
    result['files'] = lined_files(event['files'])
    if event.has_key?('stdout')
      result['stdout'] = lined_file(event['stdout'])
    end
    if event.has_key?('stderr')
      result['stderr'] = lined_file(event['stderr'])
    end
    if event.has_key?('status')
      result['status'] = event['status']
    end
    result
  end

  # - - - - - - - - - - - - - - - - -

  def lined_files(files)
    Hash[files.map{ |filename,file|
      [filename,lined_file(file)]
    }]
  end

  # - - - - - - - - - - - - - - - - -

  def lined_file(file)
    content = file['content']
    lined = {
      'content' => (content=='') ? [ '' ] : content.lines
    }
    if file.has_key?('truncated')
      lined['truncated'] = file['truncated']
    end
    lined
  end

  # = = = = = = = = = = = = = = = = =

  def unlined(event)
    result = {}
    result['files'] = unlined_files(event['files'])
    if event.has_key?('stdout')
      result['stdout'] = unlined_file(event['stdout'])
    end
    if event.has_key?('stderr')
      result['stderr'] = unlined_file(event['stderr'])
    end
    if event.has_key?('status')
      result['status'] = event['status']
    end
    result
  end

  # - - - - - - - - - - - - - - - - -

  def unlined_files(files)
    Hash[files.map{ |filename,file|
      [filename,unlined_file(file)]
    }]
  end

  # - - - - - - - - - - - - - - - - -

  def unlined_file(file)
    unlined = {
      'content' => file['content'].join
    }
    if file.has_key?('truncated')
      unlined['truncated'] = file['truncated']
    end
    unlined
  end

end
