class Role

  attr_accessor :name, :rules
  
  @@roles = {}
  
  def self.add_role(role)
    @@roles[role.name.to_sym] = role
  end
  
  def self.all_roles
    @@roles
  end
  
  def self.find(role_sym)
    @@roles[role_sym]
  end

  def self.clear
    @@roles = {}  
  end  

  def initialize(role)
    @name = role[:name]
    @rules = role[:rules]
    
    # Helper for each initialized role
    # is_role? for a role with name 'role'
    # eg: is_admin? when admin role is instantiated
    Role.class_eval <<-METHOD
                      def is_#{@name}?
                        @name == '#{@name}'
                      end
                      METHOD
    
    Role.add_role self
  end
  
  def accessible_controllers
    controllers = []
    @rules.each do |rule|
      if rule.allows?
        controllers << rule.controller
      end
    end
    controllers.uniq
  end

  def allowed_actions_in(controller)
    actions = []
    @rules.each do |rule|
      if rule.controller == controller.to_s and rule.allows?
        actions << rule.action
      end
    end
    actions.uniq
  end

  def denied_actions_in(controller)
    actions = []
    @rules.each do |rule|
      if rule.controller == controller.to_s and rule.denies?
        actions << rule.action
      end
    end
    actions.uniq
  end
  
  def is_allowed_to?(action, controller)
    @rules.each do |rule|
      if rule.action == action.to_s and rule.controller == controller.to_s
        return rule.allows?
      end
    end
    false
  end
  
  def merge_rules(new_rules)
    self.rules ||= []
    new_set = new_rules
    overwritten_set = remove_set = []
    
    self.rules.each do |rule|
      new_rules.each do |included_rule|
        if included_rule.action == rule.action and included_rule.controller == rule.controller
          overwritten_set << included_rule
          remove_set << rule
          new_set.delete(included_rule)
        end
      end
    end
    self.rules = self.rules - remove_set + overwritten_set + new_set
    self.rules
  end
  
end


  
