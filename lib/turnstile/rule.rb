# Rule class
# A simple to class to manipulate the array of rules
class Rule
  
  attr_accessor :action, :controller, :allow, :active
  
  def initialize(rules)

    @action = rules[:action]
    @controller = rules[:controller]
    @allow = rules[:allow]
    @active = rules[:active]
  end
  
  # The current rule allows or denies some action?
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
