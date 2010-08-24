Turnstile::Authorization.setup do
  
  privilege :read do
    allows_to :show, :index
    denies_to :destroy, :create
  end
  
  role :admin do
    can :read => :stuff
  end
  
end