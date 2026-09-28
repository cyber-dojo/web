module CreatorApp
  module ScopedEnvVarHelper
    def scoped_env_var(name, value)
      old_value = ENV[name]
      ENV[name] = value
      yield
    ensure
      ENV[name] = old_value
    end
  end
end
