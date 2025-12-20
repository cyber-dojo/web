
class KataController < ApplicationController
  def edit
    @env = ENV
    @id = @title = id
    @events = saver.kata_events(id)
    last = saver.kata_event(id, -1) # most recent event
    @files = last['files']
    @stdout = last['stdout'] || { 'content' => '', 'truncated' => false }
    @stderr = last['stderr'] || { 'content' => '', 'truncated' => false }
    @status = last['status'] || ''
  end

  # - - - - - - - - - - - - - - - - - -

  def run_tests
    kata = Kata.new(self, id)
    t1 = time.now
    result, files, @created, @changed = kata.run_tests(params)
    t2 = time.now

    duration = Time.mktime(*t2) - Time.mktime(*t1)
    @id = id
    @stdout = result['stdout']
    @stderr = result['stderr']
    @status = result['status']
    @log = result['log']
    @outcome = result['outcome']

    if files.key?('outcome.special')
      @outcome = "#{@outcome}_special"
      @created.delete('outcome.special')
      @changed.delete('outcome.special')
      files.delete('outcome.special')
    end

    begin
      # index is maintained in the browser. If saver's JSON events are currently
      #  [..., {'index':23 }] 
      # then index == 24. Saver uses it to detect out-of-order events.
      # Historically, ran_tests() only ever created a single new saved event. Eg
      #  [..., {'index':24, 'colour':'red'}] CASE-1
      # However it might now create two events, a file-edit, and a red/amber/green. Eg
      #  [..., {'index':24, 'event':'file-edit'},
      #        {'index':25,'colour':'red'}]  CASE-2
      # So ran_tests() now returns the new "next index", which is:
      # - 25 in the first case
      # - 26 in the second case
      # The index of the red/amber/green light is always new_index - 1.
      # The browser used to simply increment its index after a ran_tests()
      # but now it has to set it directly from light.index+1

      new_index = ran_tests(@id, index, files, @stdout, @stderr, @status, {
        duration: duration,
        colour: @outcome,
        predicted: params['predicted'],
        revert_if_wrong: params['revert_if_wrong']
      })
    rescue SaverService::Error => error
      new_index = index + 1 # Act as if CASE-1 occurred.
      @saved = false
      $stdout.puts(error.message);
      $stdout.flush
      @out_of_sync = error.message.include?('Out of order event')
    end

    @light = {
      'index' => new_index - 1,
      'colour' => @outcome,
      'predicted' => params['predicted'],
      'revert_if_wrong' => params['revert_if_wrong']
    }

    respond_to do |format|
      format.js {
        render layout:false
      }
    end
  end

  # - - - - - - - - - - - - - - - - - -

  def revert # An auto-revert for an incorrect prediction from the test page.
    # Eg [14=green], [15=incorrect prediction], [index=16 ==> revert to 14]
    args = [id, index - 2]
    json = source_event(id, index - 2, :revert, args)
    saver.kata_reverted(id, index, @files, @stdout, @stderr, @status, {
      colour: @colour,
      revert: args
    });
    render json: json
  end

  # - - - - - - - - - - - - - - - - - -

  def checkout # A [checkout!] from the review page.
    from = {
      id:source_id,
      index:source_index,
      avatarIndex:source_avatar_index,
    }
    json = source_event(from[:id], from[:index], :checkout, from)
    saver.kata_checked_out(id, index, @files, @stdout, @stderr, @status, {
        colour: @colour,
      checkout: from
    });
    render json: json
  end

  private

  def ran_tests(id, index, files, stdout, stderr, status, summary)
    if summary[:predicted] === 'none'
      saver.kata_ran_tests(id, index, files, stdout, stderr, status, summary)
    elsif summary[:predicted] === summary[:colour]
      saver.kata_predicted_right(id, index, files, stdout, stderr, status, summary)
    else
      saver.kata_predicted_wrong(id, index, files, stdout, stderr, status, summary)
    end
  end

  # - - - - - - - - - - - - - - - - - -

  def source_event(src_id, src_index, name, value)
    event = saver.kata_event(src_id, src_index)
    @files = event['files']
    @stdout = event['stdout']
    @stderr = event['stderr']
    @status = event['status']
    @colour = event['colour']
    {
       files: @files.map{ |filename,file| [filename, file['content']] }.to_h,
      stdout: @stdout,
      stderr: @stderr,
      status: @status,
       light: {
         colour: @colour,
          index: index,
          name => value
       }
    }
  end

  # - - - - - - - - - - - - - - - - - -

  def id
    params[:id]
  end

  def index
    params[:index].to_i
  end

  def source_id
    params[:src_id]
  end

  def source_index
    params[:src_index].to_i
  end

  def source_avatar_index
    param = params[:src_avatar_index]
    (param != '') ? param.to_i : ''
  end
end
