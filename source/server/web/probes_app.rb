require_relative 'app_base'

module WebApp
  # The three probes, and the app at / that answers whatever no prefix claims.
  # The probes cannot have a mount of their own: /alive, /ready and /status are
  # three top-level siblings sharing no prefix, and rack mounts by prefix.
  class ProbesApp < AppBase

    MOUNT_PATH = '/'.freeze

    helpers do

      def service_ready?(service)
        # Whether a dependency reports ready. The service clients raise (rather
        # than return false) when the service is unreachable, so a raise is
        # caught and reported as not-ready - one down dependency must not fail
        # the whole probe.
        service.ready? == true
      rescue StandardError
        false
      end

    end

    get '/alive/?' do
      content_type :json
      { 'alive?' => true }.to_json
    end

    # Deliberately a static true, NOT runner.ready? && saver.ready? &&
    # spooler.ready?. This is the load balancer's readiness probe: it gates
    # traffic and, with wait-for-steady-state, deploys. Those three are shared
    # backends every web task talks to, so coupling readiness to them fails all
    # tasks at once on a single dependency blip. The load balancer is then left
    # with no healthy target and returns 503 for every route (including the many
    # that never touch the down service), and a deploy cannot reach steady
    # state, so a fix cannot even be shipped. Descheduling web does not heal the
    # dependency, it only widens the outage. Readiness here means just "this web
    # process can serve and will degrade gracefully"; a down dependency surfaces
    # as a graceful per-action error and via /status, never here.
    get '/ready/?' do
      content_type :json
      { 'ready?' => true }.to_json
    end

    # Deep, per-dependency readiness for dashboards, monitors and deploy
    # smoke-checks. Unlike /ready this one reaches the downstream services, so
    # it must never be wired to the load balancer's health check: a dependency
    # blip would deschedule every web task at once. The overall verdict is the
    # HTTP status (200 all ready, 503 any not); the body names which dependency
    # is down.
    get '/status/?' do
      content_type :json
      services = {
        'runner'  => service_ready?(runner),
        'saver'   => service_ready?(saver),
        'spooler' => service_ready?(spooler)
      }
      status(services.values.all? ? 200 : 503)
      { 'status' => services }.to_json
    end

    # - - - - - - - - - - - - - - - -
    # Forking a group, at the path the fork button used before it moved to the
    # /fork prefix. A review page loaded before that change holds JavaScript
    # posting here, and such a tab can stay open for hours. ForkApp is where
    # forking lives; this repeats its one-line body and can go once no browser
    # is still holding the old page. It sits here rather than beside its
    # /kata/fork twin because /group claims no mount of its own.

    post '/group/fork' do
      content_type :json
      { 'group_fork' => saver.group_fork(id, index) }.to_json
    end

  end
end
