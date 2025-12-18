
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
      # Currently: index is assumed to be the index of the RAG that _will_
      # be stored in saver. For example, suppose saver already has events
      # with indexes [0,1,2,3] then index in the ran_tests() call will be 4.
      # This incoming index is useful - it can check for out of sequence events.
      # Put another way, the current assumption is that:
      #  1. ran_tests() only creates a single saver event
      #  2. previous_index == index-1
      # Now ran_tests() returns the next index, to allow ran_tests() to return 2 events.
      # Examples
      # [1,2,3] res_index = rand_test(..., index==4, ...)
      # Single event stored
      #   res_index == 5, events now == [1,2,3,4]
      #     Need @light = { previous_index:3, index:4}
      #     ==   @light = { previous_index:index-1, index:res_index-1}
      # Two events stored
      #   res_indes == 6, events now == [1,2,3,4,5]
      #     Need @light = { previous_index:3, index:5}
      #     ==   @light = { previous_index:index-1, index:res_index-1}
      #
      # source/app/views/kata/_index.html.erb holds the hidden input index value
      # cd.kata.incrementIndex() is called in source/app/views/kata/run_tests.js.erb 
      #  L128 in refreshFromTest()
      #  L145 in revert()
      # Also called in source/app/views/kata/edit.html.erb @ L34 
      # Also called in source/app/views/review/_checkout_button.html.erb @ L40
      #
      # TODO: start by hard-wiring previous_index in @light (dont use return of saver.ran_tests())
      # and use previous_index in Javascript instead of -1 delta.
      # 
      
      in_index = index
      out_index = ran_tests(@id, in_index, files, @stdout, @stderr, @status, {
        duration: duration,
        colour: @outcome,
        predicted: params['predicted'],
        revert_if_wrong: params['revert_if_wrong']
      })
    rescue SaverService::Error => error
      out_index = in_index
      @saved = false
      $stdout.puts(error.message);
      $stdout.flush
      @out_of_sync = error.message.include?('Out of order event')
    end

    @light = {
      'previous_index' => in_index - 1,
      'index' => out_index - 1,
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
