
require 'json'
require_relative '../../lib/all'
require_relative '../../app/helpers/all'
require_relative '../../app/lib/all'
require_relative '../../app/models/all'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals

  def dojo; @dojo ||= Dojo.new(self); end

  def languages; dojo.languages; end
  def exercises; dojo.exercises; end
  def custom;    dojo.custom;    end
  def katas;     dojo.katas;     end

  # The runner_choice, image_name, id, avatar_name
  # properties are caches of their corresponding kata entries.
  # They are used in kata_controller/run_tests() and
  # prevent an extra call to the storer service.

  def runner_choice
    params['runner_choice'] || kata.runner_choice
  end
  def image_name   ; params['image_name'   ]; end
  def id           ; params['id'           ]; end
  def avatar_name  ; params['avatar'       ]; end

  def was_tag    ; params['was_tag'   ].to_i; end
  def now_tag    ; params['now_tag'   ].to_i; end
  def tag        ; params['tag'       ].to_i; end

  def kata       ; katas[id]           ; end
  def avatars    ; kata.avatars        ; end
  def avatar     ; avatars[avatar_name]; end

end
