require_relative 'http_helper'

class RunnerService

  def initialize(_parent)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def image_pulled?(image_name, kata_id)
    runner_http_get(__method__, image_name, kata_id)
  end

  def image_pull(image_name, kata_id)
    runner_http_post(__method__, image_name, kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_new(image_name, kata_id)
    if stateful?(image_name)
      runner_http_post(__method__, image_name, kata_id)
    end
  end

  def kata_old(image_name, kata_id)
    if stateful?(image_name)
      runner_http_post(__method__, image_name, kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_new(image_name, kata_id, avatar_name, starting_files)
    if stateful?(image_name)
      runner_http_post(__method__, image_name, kata_id, avatar_name, starting_files)
    end
  end

  def avatar_old(image_name, kata_id, avatar_name)
    if stateful?(image_name)
      runner_http_post(__method__, image_name, kata_id, avatar_name)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run(image_name, kata_id, avatar_name, max_seconds, delta, files)
    set_hostname_port_for(image_name)
    args = {
       image_name:image_name,
          kata_id:kata_id,
      avatar_name:avatar_name,
      max_seconds:max_seconds
    }
    if stateful?(image_name)
      args[:deleted_filenames] = delta[:deleted]
      new_files     = files.select { |filename| delta[:new    ].include? filename }
      changed_files = files.select { |filename| delta[:changed].include? filename }
      args[:changed_files] = new_files.merge(changed_files)
    else
      args[:visible_files] = files
    end
    sss = http_post_hash(__method__, args)
    [sss['stdout'], sss['stderr'], sss['status'], sss['colour']]
  end

  private

  def runner_http_get(method, *args)
    set_hostname_port_for(image_name = args[0])
    http_get(method, *args)
  end

  def runner_http_post(method, *args)
    set_hostname_port_for(image_name = args[0])
    http_post(method, *args)
  end

  include HttpHelper
  attr_reader :hostname, :port

  def set_hostname_port_for(image_name)
    @hostname = stateful?(image_name) ? 'runner' : 'runner_stateless'
    @port = stateful?(image_name) ? 4557 : 4597
  end

  def stateful?(image_name)
    !tagless(image_name).end_with?('stateless')
  end

  def tagless(image_name)
    # http://stackoverflow.com/questions/37861791/
    # https://github.com/docker/docker/blob/master/image/spec/v1.1.md
    # Simplified, no hostname
    alpha_numeric = '[a-z0-9]+'
    separator = '[_.-]+'
    component = "#{alpha_numeric}(#{separator}#{alpha_numeric})*"
    name = "#{component}(/#{component})*"
    tag = '[\w][\w.-]{0,127}'
    md = /^(#{name})(:#{tag})?$/o.match(image_name)
    return image_name if md.nil?
    md[1]
  end

end
