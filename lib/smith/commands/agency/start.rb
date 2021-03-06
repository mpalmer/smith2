# -*- encoding: utf-8 -*-

require_relative '../common'

module Smith
  module Commands
    class Start < CommandBase

      include Common

      def execute
        start do |value|
          responder.succeed(value)
        end
      end

      def start(&blk)
        #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        #!!!!!!!!!!!! See note about target at end of this file !!!!!!!!!!!!!
        #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        # Sort out any groups. If the group option is set it will override
        # any other specified agents.
        if options[:group]
          begin
            agents_to_start = agent_group(options[:group])
            if agents_to_start.empty?
              blk.call("Agent group is empty. No agents started: #{options[:group]}")
            else
              start_agents(agents_to_start, &blk)
            end
          rescue RuntimeError => e
            blk.call(e.message)
          end
        else
          start_agents(target, &blk)
        end
      end

      private

      def start_agents(agents_to_start, &blk)
        if agents_to_start.empty?
          blk.call("Start what? No agent specified.")
        else
          worker = ->(agent_name, iter) do
            running_agents = agents.find_by_name(agent_name)
            if !running_agents.empty? && running_agents.first.singleton
              iter.return("Agent already running: #{agent_name}")
            else
              agent = agents.create(agent_name)
              agent.start
              iter.return((agent.state == 'starting') ? "#{agent_name}: #{agent.uuid}" : '')
            end
          end

          done = ->(started_agents) do
            blk.call(started_agents.compact.join("\n"))
          end

          EM::Iterator.new(agents_to_start).map(worker, done)
        end
      end

      def options_spec
        banner "Start an agent/agents or group of agents."

        opt    :group, "Start everything in the specified group", :type => :string, :short => :g
      end
    end
  end
end


# A note about target.
#
# Target is a method and if you assign something to it strange things happen --
# even if the code doesn't get run! I'm not strictly sure what's going on but I
# think it's something to do with variable aliasing a method of the same
# name. So even though the code isn't being run it gets compiled and that
# somehow aliases the method. This looks like a bug in yarv to me.
