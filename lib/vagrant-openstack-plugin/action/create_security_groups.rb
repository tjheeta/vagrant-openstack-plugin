require "log4r"

module VagrantPlugins
  module OpenStack
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class CreateSecurityGroups
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::create_security_groups")
        end

        def call(env)
          # http://docs.openstack.org/admin-guide-cloud/content/securitygroup_api_abstractions.html
          openstack = env[:openstack_compute]
          network = env[:openstack_network]
          require 'pp'

          # These are the rules defined in the Vagrantfile
          security_group_rules = env[:machine].provider_config.security_group_rules

          # This loop creates all the security groups needed first
          # Use the cached security groups and update them if a new one is created
          current_tenant_id = network.instance_variable_get("@current_tenant")["id"]
          current_security_groups = network.list_security_groups(:tenant_id => current_tenant_id)
          security_group_rules.each do |rule| 
              secgroup = current_security_groups.data[:body]['security_groups'].select { |v| v['name'] == rule["name"] }.first rescue nil
              if secgroup.nil?
                  #openstack.create_security_group(rule["name"], "")
                  network.create_security_group(:name => rule["name"])
                  current_security_groups = network.list_security_groups(:tenant_id => current_tenant_id)
              end
          end

          # This group creates the actual rules as part of the security_group
          security_group_rules.each do |rule|
              secgroup = current_security_groups.data[:body]['security_groups'].select { |v| v['name'] == rule["name"] }.first
              # The rules may reference other groups to allow access to instead of cidr
              remote_group_ids = []
              if rule["remote_groups"]
                  rule["remote_groups"].each do |s|
                      begin 
                          tmp=current_security_groups.data[:body]['security_groups'].select { |v| v['name'] == s }.first
                          remote_group_ids.push(tmp["id"])
                      rescue
                          pp "The remote group #{s} that was specified in #{rule} doesn't exist. Was it created?"
                          raise Errors::VagrantOpenStackError
                      end
                  end
              else
                  remote_group_ids.push(nil)
              end
              # Should only rescue 409 errors, conflict
              remote_group_ids.each do |remote_group_id|
                  begin
                      network.create_security_group_rule(
                      secgroup["id"],
                      "ingress",
                      :port_range_min => rule["port_range_min"],
                      :port_range_max => rule["port_range_max"],
                      :protocol => rule["protocol"],
                      :remote_ip_prefix => rule["remote_ip_prefix"] ? rule["remote_ip_prefix"] : nil,
                      :remote_group_id => remote_group_id ? remote_group_id : nil,
                      :tenant_id => current_tenant_id
                      )
                  rescue Excon::Errors::Conflict
                      pp "Rule already made: #{rule}"
                      #pp rule
                      #pp secgroup["id"]
                      #pp secgroup["name"]
                      #pp current_tenant_id
                  end
              end
          end

          #raise Errors::VagrantOpenStackError

          @app.call(env)
        end

      end
    end
  end
end
