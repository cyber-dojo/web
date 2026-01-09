require_relative '../../lib/files_from'

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
  # Main [test] event
 
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
      # index is maintained in the browser and holds the next-available event index.
      # For example, if saver's JSON events are currently
      #  [..., {'index':23 }] 
      # then index == 24. Saver uses it to detect out-of-order events.
      # Historically, ran_tests() only ever created a single new saved event. Eg
      #  [..., {'index':24, 'colour':'red'}] CASE-1
      # However it might now create two events, a file-edit, and a red/amber/green. Eg
      #  [..., {'index':24, 'event':'file-edit'},
      #        {'index':25,'colour':'red'}]  CASE-2
      # So ran_tests() now returns the next_index, which is:
      #  - 25 in CASE-1
      #  - 26 in CASE-2
      # The index of the traffic-light is always next_index - 1.
      # Once upon a time, the browser used to simply increment its index after a ran_tests()
      # but now, because of CASE-2, it has to set it directly from light.index+1
      # index is also set directly in the inter-test-event (ITE) functions
      # See app/views/kata/_file_create_rename_delete.html.erb

      result = ran_tests(@id, index, files, @stdout, @stderr, @status, {
        duration: duration,
        colour: @outcome,
        predicted: params['predicted'],
        revert_if_wrong: params['revert_if_wrong']
      })
      next_index = result['next_index']
      major_index = result['major_index']
      minor_index = result['minor_index']
    rescue SaverService::Error => error
      next_index = index + 1 # Act as if CASE-1 occurred.
      major_index = index + 1
      minor_index = ''
      @saved = false
      $stdout.puts(error.message)
      $stdout.flush
      @out_of_sync = error.message.include?('Out of order event')
    end

    @light = {
      'index' => next_index - 1,
      'major_index' => major_index,
      'minor_index' => minor_index,
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
  # Inter-Test-Events
  
  def file_create
    filename = params[:filename]
    next_index = saver.kata_file_create(id, index, params_files, filename)
    render json: next_index
  end

  def file_delete
    filename = params[:filename]
    next_index = saver.kata_file_delete(id, index, params_files, filename)
    render json: next_index
  end

  def file_rename
    old_filename = params[:old_filename]
    new_filename = params[:new_filename]
    next_index = saver.kata_file_rename(id, index, params_files, old_filename, new_filename)
    render json: next_index
  end

  def file_edit
    next_index = saver.kata_file_edit(id, index, params_files)
    render json: next_index
  end

  # - - - - - - - - - - - - - - - - - -
  # A revert, eg for an incorrect prediction with auto-revert from the test page.

  def revert
    # Eg [14=green], [15=red (amber=incorrect)], [index=16 ==> revert to 14]
    # Eg [14=green], [15=file-edit], [16=red (amber=incorrect)], [index=17 ==> revert to 14]
    events = saver.kata_events(id)
    previous_index = index - 2
    while !light?(events[previous_index])
      previous_index -= 1
    end

    args = [id, previous_index]
    json = source_event(id, previous_index, :revert, args)

    result = saver.kata_reverted(id, index, @files, @stdout, @stderr, @status, {
      colour: @colour,
      revert: args
    });
    light = json[:light]
    light['index'] = result['next_index'] - 1
    light['major_index'] = result['major_index']
    light['minor_index'] = result['minor_index']

    render json: json
  end

  # - - - - - - - - - - - - - - - - - -
  # Checkout from the review page.

  def checkout 
    from = {
      id:source_id,
      index:source_index,
      avatarIndex:source_avatar_index,
    }
    json = source_event(from[:id], from[:index], :checkout, from)
    result = saver.kata_checked_out(id, index, @files, @stdout, @stderr, @status, {
        colour: @colour,
      checkout: from
    });
    light = json[:light]
    light['index'] = result['next_index'] - 1
    light['major_index'] = result['major_index']
    light['minor_index'] = result['minor_index']

    render json: json
  end

  private

  include FilesFrom

  def light?(event)
    create_index = 0
    if event['index'] == create_index
      return true
    end
    case event['colour']
    when 'red', 'amber', 'green'
      true
    when 'red_special', 'amber_special', 'green_special'
      true 
    else 
      false
    end
  end

  def params_files
    data = Rack::Utils.parse_nested_query(params[:data])
    files_from(data['file_content'])
  end

  def ran_tests(id, index, files, stdout, stderr, status, summary)
    if summary[:predicted] === 'none'
      saver.kata_ran_tests(id, index, files, stdout, stderr, status, summary)
    elsif summary[:predicted] === summary[:colour]
      saver.kata_predicted_right(id, index, files, stdout, stderr, status, summary)
    else
      saver.kata_predicted_wrong(id, index, files, stdout, stderr, status, summary)
    end
  end

  def source_event(src_id, src_index, name, value)
    event = saver.kata_event(src_id, src_index)
    @files = event['files']
    @stdout = event['stdout']
    @stderr = event['stderr']
    @status = event['status']
    if src_index == 0
      @colour = 'create'
    else
      @colour = event['colour']
    end
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
    # Used in checkout (not in revert)
    params[:src_id]
  end

  def source_index
    # Used in checkout (not in revert)
    params[:src_index].to_i
  end

  def source_avatar_index
    # Used in checkout (not in revert)
    param = params[:src_avatar_index]
    (param != '') ? param.to_i : ''
  end
end
