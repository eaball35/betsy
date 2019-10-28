class User < ApplicationRecord
  has_many :products

  validates :uid, uniqueness: true, presence: true 
  validates :merchant_name, uniqueness: true, :allow_nil => true
  validates_length_of :merchant_name, maximum: 50
  validates :username, uniqueness: true, presence: true 
  validates :email, uniqueness: true, presence: true, format: { with: /@/, message: "format must be valid." }

  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash[:uid]
    user.provider = "github"
    user.username = auth_hash["info"]["nickname"]
    user.email = auth_hash["info"]["email"]
    return user 
  end 

  #In this method we will find all the orders that belong to a user
  #We can pass those orders into the total_earned method


  def find_order_items
    current_user_id = self.id

    #Find all the order items that belong to the user 
    order_items = OrderItem.where(product_id: Product.find_by(user_id:current_user_id))

    #Find all the orders that belong to the current user
    
    all_orders = []
    order_items.each do |item|
      all_orders << OrderItem.where(order_id: item.id )
    end 

    return all_orders 
  end 


  #This will take all of a merchant's orders
  #It will look at each order's order items by calling 'orders.total'
  #By calling 'orders.total' we look at each order's order items
  #We call 'total' on each OrderItem in a given individual order

  def total_earned
    total = 0 
    if self.find_order_items != nil 
      self.find_order_items.each do |order|
        total += order.total
      end 
    end 
    return total 
  end 

  #Find the orders that contain a particular status 
  # earnings = 0
  # self.products.order_items.each do |order_item|
  #   earnings += OrderItem.total(status) 
  # end 
  # return earnings 

end
