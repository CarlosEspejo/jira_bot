require 'spec_helper'
require 'jira_data'

describe JiraData do
  it "should have a uri" do
    j = JiraData.new 'example.com'
    j.uri.must_equal 'example.com'
  end

  it "should have stop words" do
    JiraData.new.stop_words.count.wont_equal 0
  end
end
