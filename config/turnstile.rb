Turnstile::Authorization.setup do
  
  privilege :manage do
    allows_to :create, :new
    allows_to :destroy
  end
      
  privilege :read do
    allows_to :show, :index
    denies_to :destroy, :create
  end

  privilege :change do
    allows_to :update, :edit    
  end
     

  role :editor do
    can :change => :stuff     
    can :change => :other_stuff
  end

  role :reader do
    can :read => :stuff
  end
      
  role :admin do
    inherits :reader
    inherits :editor
    can :manage => :stuff
  end
           
end
