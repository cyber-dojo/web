
# A runner whose access to the avatar's source files is via a docker data-container
# containing files for _all_ katas/... sub folders.
# The tar-piping is to _isolate_ the avatar's sub-dir in the katas-data-container.
#
# o) A test-run mirrors the *changed/deleted* visible-files (in the browser)
#       to the avatar's katas/id/ sub-folder.
# o) The shell file then
#     - tar-pipes all of katas/id/ from the data-container into the run-container's /sandbox
#     - executes cyber-dojo.sh in the run-container's sandbox
#     - tar-pipes all of the run-container's /sandbox _back_ to katas/id/ in the data-container
#
# o) State _is_ retained across tests.
# o) Untouched files _retain_ the same date-time stamp.
# o) cyber-dojo.sh _can_ do incremental makes (for example).

class DockerTarPipeRunner

  def initialize(dojo)
    @dojo = dojo
  end

  def parent
    @dojo
  end

  def path
    "#{File.dirname(__FILE__)}/"
  end

  def pulled?(image_name)
    image_names.include?(image_name)
  end

  def pull(image_name)
    command = [ sudo, 'docker', 'pull', image_name].join(space).strip
    _output,_exit_status = shell.exec(command)
  end

  def run(id, name, delta, files, image_name)
    storer.sandbox_save(id, name, delta, files)
    katas_sandbox_path = storer.sandbox_path(id, name)
    args = [ katas_sandbox_path, image_name, max_seconds, quoted(sudo) ].join(space)
    output, exit_status = shell.cd_exec(path, "./docker_tar_pipe_runner.sh #{args}")
    output_or_timed_out(output, exit_status, max_seconds)
  end

  def max_seconds
    parent.env('runner_timeout')
  end

  private

  include ExternalParentChainer
  include Runner

  def image_names
    # [docker images] must be made by a user that has sufficient rights.
    # See docker/web/Dockerfile
    command = [sudo, 'docker', 'images'].join(space).strip
    output, _ = shell.exec(command)
    # This will (harmlessly) get all cyberdojofoundation image names too.
    lines = output.split("\n").select { |line| line.start_with?('cyberdojo') }
    lines.collect { |line| line.split[0] }
  end

  def quoted(s)
    "'" + s + "'"
  end

  def space
    ' '
  end

  def sudo
    # See sudo comments in docker/web/Dockerfile
    parent.env('runner_sudo')
  end

end
