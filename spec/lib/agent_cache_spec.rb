# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'smith/agent_cache'

describe Smith::AgentCache do

  before(:each) do
    @cache = Smith::AgentCache.new
  end

  xit 'should create an empty cache' do
    @cache.should be_empty
  end

  xit 'should create a new AgentProcess' do
    agent_process = @cache.entry('new_agent').name.should == 'new_agent'
  end

  it 'should return agents given a particular state' do
    agent_process = @cache.entry('agent')

    @cache.state(:null).each do |agent_process|
      agent_process.should be_null
    end
  end

  xit 'should return the names of all agent_processes' do
    entries = ['first_agent', 'second_agent']
    entries.each {|a| @cache.entry(a) }

    @cache.names.should == entries
  end
end
