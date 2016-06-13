#!/bin/bash ../test_wrapper.sh

require_relative './languages_test_base'

class LanguagesDockerfilesTests < LanguagesTestBase

  # All tests skipped. Dockerfiles moved into dedicated gihub repo
  # (to separate from manifests used in [./cyber-dojo volume create ...]

  test 'F6B9D6',
  'no known flaws in Dockerfiles of each base language/' do
    skip "Dockerfiles moved into dedicated github repo"
    Dir.glob("#{languages.path}/*/").sort.each do |dir|
      check_Dockerfile(dir)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B892AA',
  'no known flaws in Dockerfiles of each language/test/' do
    skip "Dockerfiles moved into dedicated github repo"
    manifests.each do |filename|
      dir = File.dirname(filename)
      check_Dockerfile(dir)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def check_Dockerfile(dir)
    @language = dir
    assert Dockerfile_exists_and_is_well_formed?(dir), dir
    assert build_docker_image_exists_and_is_well_formed?(dir), dir
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def Dockerfile_exists_and_is_well_formed?(dir)
    dir += '/_docker_context/'
    dockerfile = dir + 'Dockerfile'
    unless File.exists?(dockerfile)
      message = "#{dir} dir has no Dockerfile"
      return false_puts_alert(message)
    end
    content = IO.read(dockerfile)
    lines = content.strip.split("\n")
    help = 'https://docs.docker.com/articles/dockerfile_best-practices/'
    if lines.any? { |line| line.start_with?('RUN apt-get upgrade') }
      message =
        "#{dockerfile} don't use\n" +
        "RUN apt-get upGRADE\n" +
        "See #{help}"
      return false_puts_alert(message)
    end
    if lines.any? { |line| line.strip == 'RUN apt-get update' }
      message =
        "#{dockerfile} don't use single line\n" +
        "RUN apt-get update\n" +
        "See #{help}"
      return false_puts_alert(message)
    end
    if lines.any? { |line| line.start_with?('RUN apt-get install') }
      message =
        "#{dockerfile} don't use\n" +
        "RUN apt-get install...\n" +
        "use\n" +
        "RUN apt-get update && apt-get install --yes ...'\n" +
        "See #{help}"
      return false_puts_alert(message)
    end
    true_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def build_docker_image_exists_and_is_well_formed?(dir)
    dir += '/_docker_context/'
    filename = dir + build_docker_image
    unless File.exists?(filename)
      message = "#{dir} dir has no #{build_docker_image}"
      return false_puts_alert(message)
    end
    content = IO.read(filename)
    unless /docker build -t cyberdojofoundation/.match(content)
      message = "#{filename} does not contain 'docker build -t cyberdojofoundation/..."
      return false_puts_alert message
    end
    true_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def manifests
    Dir.glob("#{languages.path}*/*/manifest.json").sort
  end

  def build_docker_image
    'build-docker-image.sh'
  end

  def false_puts_alert(message)
    puts_alert message
    false
  end

  def puts_alert(message)
    puts alert + '  ' + message
  end

  def alert
    "\n>>>>>>> #{language_dir} <<<<<<<\n"
  end

  def true_dot
    print '.'
    true
  end

end
