class Rule
  
  attr_accessor :action, :controller, :allow, :active
  
  def initialize(rules)
    @action = rules[:action]
    @controller = rules[:controller]
    @allow = rules[:allow]
    @active = rules[:active]
  end
  
  def allow_or_deny?
    @allow == true ? :allow : :deny
  end
  
  def is_active?
    @active
  end
  
  def allows?
    @allow ? true : false
  end
  
  def denies?
    @allow ? false : true
  end
  
  
  
end