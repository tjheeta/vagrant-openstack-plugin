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
          current_security_groups = network.list_security_groups
          security_group_rules.each do |rule| 
              secgroup = current_security_groups.data[:body]['security_groups'].select { |v| v['name'] == rule[:name] }.first rescue nil
              if secgroup.nil?
                  openstack.create_security_group(rule[:name], "")
                  current_security_groups = network.list_security_groups
              end
          end
              
          # This group creates the actual rules as part of the security_group
          security_group_rules.each do |rule| 
              secgroup = current_security_groups.data[:body]['security_groups'].select { |v| v['name'] == rule[:name] }.first
              # The rules may reference other groups to allow access to instead of cidr
              secgroup_src_ids = []
              if rule[:secgroup_src]
                  rule[:secgroup_src].each do |s|
                      puts s
                      tmp=current_security_groups.data[:body]['security_groups'].select { |v| v['name'] == s }.first
                      secgroup_src_ids.push(tmp["id"])
                  end
              else
                  secgroup_src_ids.push(nil)
              end
              # Should only rescue 409 errors, conflict
              secgroup_src_ids.each do |secgroup_src|
                  begin
                      pp network.create_security_group_rule(
                      secgroup["id"],
                      "ingress",
                      :port_range_min => rule[:port_range_min],
                      :port_range_max => rule[:port_range_max],
                      :protocol => rule[:protocol],
                      :remote_ip_prefix => rule[:remote_ip_prefix] ? rule[:remote_ip_prefix] : nil,
                      :remote_group_id => secgroup_src ? secgroup_src : nil
                      ) 
                  rescue Excon::Errors::Conflict
                      pp "Rule already made:"
                      pp rule
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
