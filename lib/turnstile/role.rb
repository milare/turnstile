# Role class
# Provides all needed methods to handle a role and its rules
class Role

  attr_accessor :name, :rules
  
  # Class variable to keep control of all roles
  @@roles = {}
  
  # Class variable to keep the default role, it means that if 
  # there is no current_role than the default is used
  @@default = nil
  
  # Class methods
  # Adds a role to the roles hash
  def self.add_role(role)
    @@roles[role.name.to_sym] = role
  end
  
  def self.all_roles
    @@roles
  end
  
  # Find a role by its name
  # Role.find(:admin)
  # returns Role or nil
  def self.find(role_sym)
    @@roles[role_sym]
  end
  
  def self.first
    @@roles.first
  end

  # Remove all role from memory, used for tests so far
  def self.clear
    @@roles = {}  
  end  

  def self.set_default_role(role)
    @@default = role
  end
  
  def self.default_role
    @@default
  end

  def initialize(role)
    @name = role[:name]
    @rules = role[:rules]
    
    # Helper for each initialized role
    # is_role? for a role with name 'role'
    # is_admin? when admin role is instantiated
    Role.class_eval <<-METHOD
                      def is_#{@name}?
                        @name == '#{@name}'
                      end
                      METHOD
    
    Role.add_role self
  end
  
  
  # Return all(array) controllers that an user can access
  def accessible_controllers
    controllers = []
    @rules.each do |rule|
      if rule.allows?
        controllers << rule.controller
      end
    end
    controllers.uniq
  end

  # Return the allowed actions in a controller for the current_role
  def allowed_actions_in(controller)
    actions = []
    @rules.each do |rule|
      if rule.controller == controller.to_s and rule.allows?
        actions << rule.action
      end
    end
    actions.uniq
  end

  # Return the denied actions in a controller for the current_role
  def denied_actions_in(controller)
    actions = []
    @rules.each do |rule|
      if rule.controller == controller.to_s and rule.denies?
        actions << rule.action
      end
    end
    actions.uniq
  end
  
  # Return if a role is allowed to perform an action in a controller
  # current_role.is_allowed_to? :create, :posts
  def is_allowed_to?(action, controller)
    @rules.each do |rule|
      if rule.action == action.to_s and rule.controller == controller.to_s
        return rule.allows?
      end
    end
    false
  end
  
  # Merges a set of rules with the current_role rules
  # current_role.merge_rules(set_of_rules[])
  # Used to apply rules to an user and for inheritance
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


  
