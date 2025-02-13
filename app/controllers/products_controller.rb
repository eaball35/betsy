class ProductsController < ApplicationController
  before_action :find_product, only: [:show, :edit, :update]
  skip_before_action :require_login, only: [:index, :show]
  skip_before_action :find_order
  
  def index
    category_id = params[:category_id]
    
    if category_id.nil?
      if params[:search].nil?
        @products = Product.active
      else
        @products = Product.search(params[:search].first)
        @search_result = params[:search].first  
        params[:search] = nil
      end
    elsif category_id
      @category = Category.find_by(id: category_id)
      if @category
        @products = @category.products.active
      else
        head :not_found
      end
    end
  end
  
  def show
    if @product.nil?
      head :not_found
      return
    end
  end
  
  def new
    @product = Product.new
  end
  
  def create
    @product = Product.new(product_params)
    
    if params[:multiselect]
      params[:multiselect].each do |id|
        new_category = Category.where(id: id)
        if !new_category.empty?
          @product.categories << new_category
        end
      end
    end
    @product.user_id = session[:user_id]
    
    if @product.save
      if @current_user.merchant_name.nil?
        flash[:success] = "Product #{@product.name} has been added successfully"
        flash[:message] = "You merchant name is currently empty. Please add a merchant name to list your fruit stand with Fruitsy Merchants."
        return redirect_to edit_user_path
      else
        flash[:success] = "Product #{@product.name} has been added successfully"
        redirect_to product_path(@product.id)
        return
      end
    elsif !@product.errors.empty?
      flash.now[:error] = "New product was not added. Fix required fields before adding!"
      render :new
      return
    else
      flash.now[:error] = "Something went wrong! Product was not added."
      render :new
      return
    end
  end
  
  def edit
    if @product.nil?
      redirect_to root_path
      return
    end
  end
  
  def update
    if @product.update(product_params)
      flash[:success] = "Product #{@product.name} has been updated successfully"
    else
      flash[:error] = "Something went wrong! Product can not be edited."
      flash[:errors] = @product.errors.messages
    end
    redirect_to current_user_path
    return
  end
  
  private
  
  def find_product
    @product = Product.find_by(id: params[:id])
  end
  
  def product_params
    return params.require(:product).permit(:name, :price, :stock, :img_url, :description, :active, category_ids: [])
  end
end
