require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rule do
  
  before :each do
    @rule = Rule.new(:action => 'action', :controller => 'controller', :allow => true, :active => true)
  end
  
  it "should instantiate a new rule" do
    @rule.class.should == Rule
  end
  
  it "should check if a rule is active" do
    @rule.is_active?.should be_true
  end
  
  it "should check if it allows or denies a rule" do
    @rule.allow_or_deny?.should == :allow
    new_rule = Rule.new(:action => 'action', :controller => 'controller', :allow => false, :active => true)
    new_rule.allow_or_deny?.should == :deny
  end
  
  it "should return if a rule allows something" do
    @rule.allows?.should be_true
  end
  
  it "should return if a rule denies something" do
    @rule.denies?.should be_false
  end
  
end