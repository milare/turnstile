require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Role do
  
  before :each do
    rules = []
    rules << Rule.new(:action => 'action1', :controller => 'controller1', :allow => true, :active => true)
    rules << Rule.new(:action => 'action2', :controller => 'controller1', :allow => false, :active => true)
    rules << Rule.new(:action => 'action3', :controller => 'controller1', :allow => true, :active => true)
    rules << Rule.new(:action => 'action4', :controller => 'controller2', :allow => false, :active => true)
    rules << Rule.new(:action => 'action5', :controller => 'controller2', :allow => true, :active => true)
    rules << Rule.new(:action => 'action6', :controller => 'controller3', :allow => false, :active => true)
    @role = Role.new(:name => 'role', :rules => rules)
  end
  
  it "should instantiate a new role" do
    @role.class.should == Role
  end
  
  it "should change the set of rules" do
    rules = []
    rules << Rule.new(:action => 'action1', :controller => 'controller1', :allow => true, :active => true)
    @role.set_rules(rules)
    @role.rules.should == rules
  end
  
  it "should list the controller that the user has access to" do
    @role.accessible_controllers.should == ['controller1', 'controller2']
  end
  
  it "should list the allowed actions in a controller" do
    @role.allowed_actions_in(:controller1).should == ['action1', 'action3']
  end
  
  it "should list the denied actions in a controller" do
    @role.denied_actions_in(:controller1).should == ['action2']
  end
  
  it "should return if a user is allowed to perform an action" do
    @role.is_allowed_to?(:action1,:controller1).should be_true
  end
  
  it "should return false if a user is not allowed to perform an action" do
    @role.is_allowed_to?(:action1,:controller2).should be_false
  end
  
  it "should eval a helper method is_role? for each role" do
    admin = Role.new(:name => 'admin', :rules => {:controller3 => [:action4, :action5]})
    admin.is_admin?.should be_true
    @role.is_admin?.should be_false
    @role.is_role?.should be_true
  end
  

end