
# A runner whose access to the avatar's source files is via a data-container
# containing files for *all* katas/... sub folders.
#
# o) A test-run saves the *changed* visible-files to the avatar's katas/id/ sub-folder.
# o) The shell file then
#     - tar-pipes all of katas/id/ from the data-container into the run-containers /sandbox
#     - executes cyber-dojo.sh in the run-container's sandbox
#     - tar-pipes all of the run-container's /sandbox back to katas/id/ in the data-container
#
# o) State is retained across tests.
# o) Untouched files retain the same date-time stamp.
# o) cyber-dojo.sh can do incremental makes.
#
# The tar-piping is to isolate the avatar's sub-dir in the katas-data-container.

class DockerTarPipeRunner

  def initialize(dojo)
    @dojo = dojo
  end

  # queries

  def path
    "#{File.dirname(__FILE__)}/"
  end

  def parent
    @dojo
  end

  def pulled?(image_name)
    image_names.include?(image_name)
  end

  # modifiers

  def pull(image_name)
    sudo = parent.env('runner_sudo')
    command = [ sudo, 'docker', 'pull', image_name].join(space = ' ').strip
    output,_ = shell.exec(command)
    make_cache # DROP?
  end

  def run(avatar, delta, files, image_name)
    sandbox = avatar.sandbox
    katas.sandbox_save(sandbox, delta, files)
    katas_sandbox_path = katas.path_of(sandbox)
    max_seconds = parent.env('runner_timeout')
    # See sudo comments in docker/web/Dockerfile
    sudo = parent.env('runner_sudo')
    args = [ katas_sandbox_path, image_name, max_seconds, quoted(sudo) ].join(space = ' ')
    output, exit_status = shell.cd_exec(path, "./docker_tar_pipe_runner.sh #{args}")
    output_or_timed_out(output, exit_status, max_seconds)
  end

  private

  include ExternalParentChainer
  include Runner

  def image_names
    @image_names ||= make_cache
  end

  def make_cache
    # [docker images] must be made by a user that has sufficient rights.
    # See docker/web/Dockerfile
    sudo = parent.env('runner_sudo')
    command = [sudo, 'docker', 'images'].join(space = ' ').strip
    output, _ = shell.exec(command)
    # This will put all cyberdojofoundation image names into the runner cache,
    # even nginx and web. This is harmless.
    lines = output.split("\n").select { |line| line.start_with?('cyberdojofoundation') }
    lines.collect { |line| line.split[0] }
  end

  def quoted(s)
    "'" + s + "'"
  end

end
