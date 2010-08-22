class Role
  
  attr_reader :name, :rules
  
  @@roles = []
  
  def self.add_role(role)
    @@roles << role
  end
  
  def self.all_roles
    @@roles
  end
  
  def initialize(role)
    @name = role[:name]
    @rules = role[:rules]
    @parameterized_name = role[:name].gsub(/ /,'_')
    
    # Helper for each initialized role
    # is_role? for a role with name 'role'
    # eg: is_admin? when admin role is instantiated
    Role.class_eval <<-METHOD
                      def is_#{@parameterized_name}?
                        @name == '#{@name}'
                      end
                      METHOD
    
    Role.add_role self
  end
  
  def set_rules(rules)
    @rules = rules
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
  
end


  
