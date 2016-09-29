
# Problem at app/lib/stub_runner.rb uses katas as an external
# StubRunner set in
# app_controller_test_base.rb
# app_helpers_test_base.rb
# app_models_test_base.rb
# app_lib/stub_runner_test.rb

module NearestAncestors # mix-in

  def nearest_ancestors(symbol, my = self)
    loop {
      fail "#{my.class.name} does not have a parent" unless my.respond_to? :parent
      my = my.parent
      return my.send(symbol) if my.respond_to? symbol
    }
  end

end
