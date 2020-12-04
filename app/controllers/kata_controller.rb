
class KataController < ApplicationController

  def edit
    # who/what
    @id = kata.id
    @title = @id
    # shared review code
    @was_index = -1
    @now_index = -1
    @manifest = model.kata_manifest(@id)
    # all current events
    @events = model.kata_events(@id)
    # most recent event
    last = model.kata_event(@id, -1)
    @index = last['index']
    @files = last['files']
    @stdout = stdout(last)
    @stderr = stderr(last)
    @status = status(last)
    # settings
    @theme = kata.theme
    @colour = kata.colour
    @predict = kata.predict
    @env = ENV
  end

  # - - - - - - - - - - - - - - - - - -

  def run_tests
    t1 = time.now
    result,files,@created,@deleted,@changed = kata.run_tests
    t2 = time.now

    duration = Time.mktime(*t2) - Time.mktime(*t1)
    @id = kata.id
    @index = params[:index].to_i + 1
    @stdout = result['stdout']
    @stderr = result['stderr']
    @status = result['status']
    @log = result['log']
    @outcome = result['outcome']
    @light = {
      'index' => @index,
      'time' => t1,
      'colour' => @outcome,
      'predicted' => params['predicted'],
    }

    @out_of_sync = false
    begin
      model.kata_ran_tests(@id, @index, files, @stdout, @stderr, @status, {
        'duration' => duration,
        'colour' => @outcome,
        'predicted' => params['predicted']
      })
    rescue ModelService::Error => error
      if model.kata_exists?(@id)
        @out_of_sync = true
        $stdout.puts(error.message);
        $stdout.flush
      else
        raise
      end
    end

    respond_to do |format|
      format.js {
        render layout:false
      }
    end
  end

  # - - - - - - - - - - - - - - - - - -

  def revert
    event = model.kata_event(src_id, src_index)
    files = event['files']
    stdout = event['stdout']
    stderr = event['stderr']
    status = event['status']
    colour = event['colour']

    model.kata_ran_tests(id, index, files, stdout, stderr, status, {
        'time' => time.now,
      'colour' => colour.to_s,
      'revert' => [src_id, src_index]
    });

    render json: {
       files: files.map{ |filename,file| [filename, file['content']] }.to_h,
      stdout: stdout,
      stderr: stderr,
      status: status,
       light: {
        colour: colour,
         index: index,
        revert: [src_id,src_index]
      }
    }
  end

  # - - - - - - - - - - - - - - - - - -

  def checkout
    event = model.kata_event(src_id, src_index)
    files = event['files']
    stdout = event['stdout']
    stderr = event['stderr']
    status = event['status']
    colour = event['colour']

    model.kata_ran_tests(id, index, files, stdout, stderr, status, {
        'time' => time.now,
      'colour' => colour.to_s,
      'checkout' => checkout_hash
    });

    render json: {
       files: files.map{ |filename,file| [filename, file['content']] }.to_h,
      stdout: stdout,
      stderr: stderr,
      status: status,
       light: {
        colour: colour,
         index: index,
        checkout: checkout_hash
      }
    }
  end

  # - - - - - - - - - - - - - - - - - -

  def set_colour
    kata.colour = params['value']
  end

  def set_theme
    kata.theme = params['value']
  end

  def set_predict
    kata.predict = params['value']
  end

  private

  def id
    params[:id]
  end

  def index
    params[:index].to_i + 1
  end

  def checkout_hash
    { id:src_id, avatarIndex:src_avatar_index, index:src_index }
  end

  def src_id
    params[:src_id]
  end

  def src_index
    params[:src_index].to_i
  end

  def src_avatar_index
    param = params[:src_avatar_index]
    (param != '') ? param.to_i : ''
  end

  # - - - - - - - - - - - - - - - - - -

  def stdout(event)
    if event.has_key?('stdout')
      event['stdout']['content']
    else
      ''
    end
  end

  def stderr(event)
    if event.has_key?('stderr')
      event['stderr']['content']
    else
      ''
    end
  end

  def status(event)
    if event.has_key?('status')
      event['status']
    else
      '0'
    end
  end

end
