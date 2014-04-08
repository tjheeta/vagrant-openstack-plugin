require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This deletes the running server, if there is one.
      class DeleteServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::delete_server")
        end

        def call(env)
          machine = env[:machine]
          id = machine.id || env[:openstack_compute].servers.all( :name => machine.name ).first.id

          if id
            env[:ui].info(I18n.t("vagrant_openstack.deleting_server"))
            server = env[:openstack_compute].servers.get(id)
            server.destroy
            env[:machine].id = nil
          end

          @app.call(env)
        end
      end
    end
  end
end
