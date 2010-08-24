require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
include Turnstile::Authorization

describe Turnstile::Authorization do
  
  before(:each) do
    Turnstile::Authorization.reset
  end
  
  it "should create a permission with some actions" do
    privilege :manage do
      allows_to :create, :new, :index
      denies_to :destroy
    end
    
    privilege :reader do
      allows_to :index, :show
      denies_to :destroy, :create
    end
    
    Turnstile::Authorization.find_permission(:manage).should == {:allow => [:create, :new, :index], :deny => [:destroy]}
    Turnstile::Authorization.find_permission(:reader).should == {:allow => [:index, :show], :deny => [:destroy, :create]}
  end
  
  it "should create rules using permissions" do
    
    privilege :manage do
      allows_to :create, :new, :index
      denies_to :destroy
    end
    
    role :admin do
      can :manage => :stuff
    end
    
    Role.find(:admin).is_allowed_to?(:create, :stuff).should be_true
    Role.find(:admin).is_allowed_to?(:destroy, :stuff).should be_false
    
  end
  
  it "should test role inheritance" do
    
      privilege :manage do
        allows_to :create, :new
        allows_to :destroy
      end
      
      privilege :read do
        allows_to :show, :index
        denies_to :destroy, :create
      end
      
      role :reader do
        can :read => :stuff
      end
      
      role :master do
        inherits :reader
        can :manage => :stuff
      end
      
      Role.find(:master).is_allowed_to?(:show, :stuff).should be_true
      Role.find(:master).is_allowed_to?(:destroy, :stuff).should be_true
      Role.find(:reader).is_allowed_to?(:create, :stuff).should be_false
  end
  
  it "should load rules and role from config file" do
    
    Turnstile::Authorization.read_config_file
    Role.find(:admin).name.should == :admin
    Turnstile::Authorization.find_permission(:read).should_not be_nil
    
  end
  
end