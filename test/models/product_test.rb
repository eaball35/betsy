require "test_helper"

describe Product do
  before do
    @product = products(:lemon_shirt)
  end

  it "can be instantiated" do
    assert(@product.valid?)
  end

  it "will have the required fields" do
    [:name, :price, :stock, :img_url, :user_id, :categories, :description ].each do |field|
      expect(@product).must_respond_to field
    end
  end

  describe "relationships" do
    it "can have many order items" do   
      product = Product.create(
        name: "Orange Soap Dispenser",
        price: 20.00,
        stock: 15,
        img_url: "http:\\fakeurl.com",
        user: users(:betsy),
        description: "A soap dispenser shaped like an orange."
      )

      product.order_items << OrderItem.create(quantity: 2, product: product, order: Order.first)
      product.order_items << OrderItem.create(quantity: 3, product: product, order: Order.last)

      expect(product.order_items.count).must_equal 2
    end
    
    it "can have many categories" do
      expect(@product.categories.count).must_equal 1
      expect(@product.categories.first).must_equal categories(:lemon)
      
      @product.categories << categories(:strawberry)
      expect(@product.categories.count).must_equal 2
      expect(@product.categories.last).must_equal categories(:lemon)
      expect(@product.categories.first).must_equal categories(:strawberry)
    end

    it "can have one user" do
      expect(@product.user).must_equal users(:ada)
    end
  end

  describe "validations" do
    describe 'name' do 
      it "must have a name" do
        @product.name = nil

        refute(@product.valid?)
        expect(@product.errors.messages).must_include :name
        expect(@product.errors.messages[:name]).must_include "can't be blank"
      end

      it "must be unique in the scope of user_id" do
        invalid_product = Product.create(name: "Lemon Shirt", price: 55, stock: 2, img_url: "img.com", user_id: users(:ada).id, description: "Here is another description", category_ids: [categories(:strawberry).id])

        refute(invalid_product.valid?)
        expect(invalid_product.errors.messages).must_include :name
        expect(invalid_product.errors.messages[:name]).must_include "has already been taken"
      end

      it "must be less than 50 characters" do
        @product.name = "This is a supppppppper long product name. It should not be this long, this should just use the description if it's going to be this long."

        refute(@product.valid?)
        expect(@product.errors.messages).must_include :name
        expect(@product.errors.messages[:name]).must_include "is too long (maximum is 50 characters)"
      end

    end

    it "must have a price" do
      @product.price = nil

      refute(@product.valid?)
      expect(@product.errors.messages).must_include :price
      expect(@product.errors.messages[:price]).must_include "can't be blank"
    end
    
    it "must have a quantity" do
      @product.stock = nil

      refute(@product.valid?)
      expect(@product.errors.messages).must_include :stock
      expect(@product.errors.messages[:stock]).must_include "can't be blank"
    end

    it "must have a user_id" do
      @product.user_id = nil

      refute(@product.valid?)
      expect(@product.errors.messages).must_include :user_id
      expect(@product.errors.messages[:user_id]).must_include "can't be blank"
    end

    it "must have a img_url" do
      @product.img_url = nil

      refute(@product.valid?)
      expect(@product.errors.messages).must_include :img_url
      expect(@product.errors.messages[:img_url]).must_include "can't be blank"
    end
    
    it "must have a description" do
      @product.description = nil

      refute(@product.valid?)
      expect(@product.errors.messages).must_include :description
      expect(@product.errors.messages[:description]).must_include "can't be blank"
    end
  end

  describe 'custom methods' do
    describe 'random_products' do
      it 'returns random given number of products' do
        product = products(:lemon_shirt)
        expect(Product.random_products(1).count).must_equal 1
        product2 = products(:strawberry_shoes)
        product3 = products(:banana_sweatshirt)
        
        random_products = Product.random_products(2)
        expect(random_products.count).must_equal 2
        
        random_products.each do |product|
          expect(product).must_be_instance_of Product
        end
      end

      it 'returns [] if no products' do
        Product.destroy_all
        expect(Product.random_products(1)).must_equal []
      end
    end
    
    describe 'deals_under' do
      it 'returns products under given price' do
        product = products(:lemon_shirt)
        product2 = products(:strawberry_shoes)
        product3 = products(:banana_sweatshirt)

        expect(Product.deals_under(10).count).must_equal 0
        expect(Product.deals_under(30).count).must_equal 2
        expect(Product.deals_under(100).count).must_equal 3

        Product.deals_under(100).each do |product|
          expect(product).must_be_instance_of Product
        end
      end

      it 'returns [] if no products' do
        Product.destroy_all
        expect(Product.deals_under(100)).must_equal []
      end
    end
    
    describe 'quantity_available?' do
    end
  end
end
