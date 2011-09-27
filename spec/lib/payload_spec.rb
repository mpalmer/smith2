# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'pp'

describe Smith::Messaging::Payload do

  include Smith::Messaging

  before(:all) do
    @message = "This is a message using the default encoder"
  end

  context "Default Encoder" do
    it 'should encode a message' do
      Marshal.load(Payload.new(:default).content(@message).encode).should == @message
    end

    it "should decode a message" do
      Payload.decode(Marshal.dump(@message)).should == @message
    end

    it "should encode a nil message" do
      Marshal.load(Payload.new(:default).content(nil).encode).should == nil
    end

    it "should decode a nil message" do
      Payload.decode(Marshal.dump(nil)).should == nil
    end
  end

  context "Agency Command Encoder" do
    let(:message1) { {:command => "list"} }
    let(:message2) { {:command => "list", :options => ["--all", "--l"]} }
    let(:message3) { {:command => :list} }
    let(:message4) { {:incorrect_command => 'list'} }

    it "should encode and decode a correct message when the message type is specified as a symbol" do
      Payload.decode(Payload.new(:agency_command).content(message1).encode, :agency_command).should == message1.merge(:target => [])
      Payload.decode(Payload.new(:agency_command).content(message2).encode, :agency_command).should == message2.merge(:target => [])
    end

    it "should encode and decode a correct message when the message type is specified as a class" do

      Payload.decode(Payload.new(Encoder::AgencyCommand).content(message1).encode, Encoder::AgencyCommand).should == message1.merge(:target => [])
      Payload.decode(Payload.new(Encoder::AgencyCommand).content(message2).encode, Encoder::AgencyCommand).should == message2.merge(:target => [])
    end

    it "should access the decoded message fields using accessor mesthods." do
      decoded_message = Payload.decode(Payload.new(:agency_command).content(message2).encode, :agency_command)
      decoded_message.command.should == 'list'
      decoded_message.options.should == ["--all", "--l"]
    end

    it "should throw an TypeException when an message of incorect type is used" do
      expect { Payload.decode(Payload.new(:agency_command).content(message3).encode, :agency_command) }.to raise_error(TypeError)
    end

    it "should throw an RequiredFieldNotSetError when a message with an incorrect field is used" do
      expect { Payload.decode(Payload.new(:agency_command).content(message4).encode, :agency_command) }.to raise_error(Beefcake::Message::RequiredFieldNotSetError)
    end
  end
end