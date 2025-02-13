class Product < ApplicationRecord
  validates :name, presence: true, uniqueness: {scope: :user_id}
  validates_length_of :name, minimum: 1, maximum: 50
  validates :price, numericality: {greater_than: 0}
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0}
  validates :user_id, presence: true
  validates :img_url, presence: true
  validates :description, presence: true
  
  belongs_to :user
  has_many :order_items, dependent: :nullify
  has_many :reviews, dependent: :nullify
  has_and_belongs_to_many :categories

    
  def self.random_products(num)
    return Product.all.shuffle.first(num)
  end
  
  def self.deals_under(price)  
    return Product.where("price < ?", price).shuffle
  end

  def quantity_available?(quantity)
   if quantity > self.stock
      return false
    else
      return true
    end
  end

  def update_quantity(quantity, status)
    if status == "paid" 
      self.stock -= quantity 
    elsif status == "cancelled"
      self.stock += quantity 
    end 
    return self.stock
  end

  def avg_rating
    reviews = self.reviews
    if reviews.empty?
      return nil
    else
      ratings = reviews.map { |review| review.rating }
      return (ratings.sum.to_f / ratings.length).round(1)
    end
  end

  def self.active
    return self.where(active:true)
  end 

  def self.search(search)
    products = []
    self.active.each do |product|
      products << product if product.name.downcase.include?(search.downcase)
    end
    return products
  end
end
