require File.dirname(__FILE__) + '/../../config/environment.rb'

require 'make_time_helper'
require 'Folders'
require 'Uuid'

class ApplicationController < ActionController::Base
  before_filter :set_locale

  protect_from_forgery

  include MakeTimeHelper

  def id
    Folders::id_complete(root_dir, params[:id]) || ""
  end
    
  def dojo
    Dojo.new(root_dir)
  end
  
  def gather_info    
    language = dojo.language(params['language'])    
    
    { :created => make_time(Time.now),
      :id => Uuid.new.to_s,
      :language => language.name,
      :exercise => params['exercise'], # used only for display
      :unit_test_framework => language.unit_test_framework,
      :tab_size => language.tab_size
    }
  end

  def bind(filename)
    filename = Rails.root.to_s + filename
    ERB.new(File.read(filename)).result(binding)
  end  

  def set_locale
    if params[:locale].present?
      session[:locale] = params[:locale]
    end
    original_locale = I18n.locale
    I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
  end

private

  def root_dir
    Rails.root.to_s + (ENV['CYBERDOJO_TEST_ROOT_DIR'] ? '/test/cyberdojo' : '')
  end
  
end
