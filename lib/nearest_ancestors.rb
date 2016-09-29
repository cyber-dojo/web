
# Problem at app/lib/delta_maker.rb L47 app/models/avatar.rb
#            app/lib/stub_runner.rb uses katas as an external

module NearestAncestors # mix-in

  def nearest_ancestors(symbol)
    my = self
    loop {
      fail "#{my.class.name} does not have a parent" unless my.respond_to? :parent
      my = my.parent
      return my.send(symbol) if my.respond_to? symbol
    }
  end

end
