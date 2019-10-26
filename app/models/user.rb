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

  def total_earned
    #Find the order items that belong to a particular user 
    earnings = 0
    self.products.order_items.each do |order_item|
      earnings += order_item.total 
    end 
    return earnings 
  end 

end
