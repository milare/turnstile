# Turnstile::Authorization
# Module that is used as interface to the application
module Turnstile
  module Authorization
  
    # Keep track of all permissions defined
    # A permission is defined in the setup with such as:
    # 
    #  privilege :manage do
    #   allows_to :create, :new
    #  end
    @@permissions = {}
  
    # used in tests so far, to perform the setup
    def self.read_config_file
      require File.expand_path(File.dirname(__FILE__) + '/../../config/initializers/turnstile')
    end
    
    # Run the config file with all definitions
    def self.setup(&block)
      yield if block_given?    
    end
    
    # Used by tests to reset all configurations done
    def self.reset
      @@permissions = {}
      Role.clear
    end
    
    # Finds a permission
    # Turnstile::Authorization.find_permission(:manage)
    def self.find_permission(permission_name)
      @@permissions[permission_name]
    end
    
    # From setup defines the default role
    # If the role is not found tries to define 
    # common names for guests
    # The default role is used when there is no current role
    def default_is(role_str)
      role = Role.find(role_str.to_sym)
      if !role
        role ||= Role.find(:guest)
        role ||= Role.find(:visitor)
        if !role
          Role.set_default_role(role)
        else
          Role.set_default_role(Role.first)
        end
      else
        Role.set_default_role(role)
      end
    end
    
    
    # Method used in each controller that requires authorization
    # Actually it handles the requests performed by the controller
    # and then check if the current_role id allowed to perfom the action
    def verify_role_permissions!
      if request || request.params
        action = request.params[:action] ? request.params[:action] : nil
        controller = request.params[:controller] ? request.params[:controller] : nil
        if action and controller
          if !current_role.is_allowed_to? action, controller
            flash[:alert] = "Unauthorized action"
            redirect_to root_path
          end
        else
          redirect_to root_path  
        end
      else
        redirect_to root_path
      end
    end
    
    # Returns the default role in this scope
    def default_role
      Role.default_role
    end
    
    # Helper to get current_role
    # TODO: Find a way to get the current_user role in a dynamic way
    # This way like current_user.user_role is too hardcoded
    def current_role
      current_role = current_user ? Role.find(current_user.user_role.to_sym) : nil
      current_role ||= Role.default_role
    end
    
    # Set the current_role
    def current_role=(role)
      current_role = role
    end
  
    # Methods to define a permission
    #  privilege :manage do
    #   allows_to :create, :new
    #   denies_to :destroy
    #  end
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
  
    # Methods to set a privilege(permission) to a role
    #  role :admin do
    #   can :manage => :posts
    #   inherits :reader
    #  end
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
