module Turnstile
  module Authorization
  
    @@permissions = {}
  
    def self.reset
      @@permissions = {}
      @@roles = {}
    end
    
    def self.find_permission(permission_name)
      @@permissions[permission_name]
    end
  
    def privilege(name, &block)
      @current_permission = name
      @@permissions[@current_permission] = {}
      yield if block_given?
    end
  
    def allows_to(*actions)
      @@permissions[@current_permission][:allow] ||= []
      actions.each do |action|
        @@permissions[@current_permission][:allow] << action
      end
    end

    def denies_to(*actions)
      @@permissions[@current_permission][:deny] ||= []
      actions.each do |action|
        @@permissions[@current_permission][:deny] << action
      end
    end
  
    def role(role, &block)
      @current_role = Role.find(role)
      @current_role ||= Role.new(:name => role, :rules => [])
      yield if block_given?
    end
  
    def inherits(role)
     parent = Role.find(role)
     parent ? @current_role.merge_rules(parent.rules) : @current_role.rules
    end
    
    def can(rules_set)
      rules = []
      rules_set.keys.each do |permission|
        actions = Authorization.find_permission(permission)
        controller = rules_set[permission]
        if actions[:allow]
          actions[:allow].each do |action|
            rules << Rule.new(:action => action.to_s, :controller => controller.to_s, :allow => true, :active => true)
          end
        end
        if actions[:deny]
          actions[:deny].each do |action|
            rules << Rule.new(:action => action.to_s, :controller => controller.to_s, :allow => false, :active => true)
          end
        end
      end
      @current_role.merge_rules(rules)
    end
  
  end
end