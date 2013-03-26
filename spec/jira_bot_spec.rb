require 'spec_helper'
require 'jira_bot'
require 'ostruct'

describe JiraBot do
  it "should create a instance" do
    JiraBot.new(username: ['JIRA_BOT_USER'], password: ENV['JIRA_BOT_PASSWD'], base_url: ENV['JIRA_BOT_URL']).must_be_instance_of JiraBot
  end

  it "should make a authenticated request" do

    party = MiniTest::Mock.new
    party.expect :get, OpenStruct.new(code: 200), ["http://example.com/dashboard/123", {:basic_auth=>{:username=>"joe", :password=>"smith"}}]

    jb = JiraBot.new(username: 'joe', password: 'smith', base_url: 'http://example.com', http: party)
    jb.get('/dashboard/123').code.must_equal 200
    party.verify
  end
end
