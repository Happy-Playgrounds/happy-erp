class HappyCategoriesController < ApplicationController

  def index
    @search = params["search"]
    @active_vendors = HappyVendor.where(id: HappyProduct.select(:happy_vendor_id)).order(:vendor_name)
    @is_admin = current_user.admin? and (current_user.id == 1 or current_user.id == 11)

    @default_vendor = @active_vendors.find_by(vendor_name: "Playworld")&.id
    @happy_categories = HappyCategory.where("happy_categories.happy_vendor_id = ?", @default_vendor)
    .left_joins(:happy_products)
    .select("happy_categories.*, COUNT(happy_products.id) AS product_count")
    .group("happy_categories.id")
    .order(:category).page(params[:page])

    @unassigned_products_count = 0

    if @search.present?
      session[:last_search_url] = request.fullpath
      @name = @search["category_name"]
      if @search["happy_vendor_id"].present?
          @default_vendor = @search["happy_vendor_id"]
      end
      @happy_categories = HappyCategory.where("happy_categories.happy_vendor_id = ? and category ILIKE ?", @default_vendor, "%#{@name}%")
      .left_joins(:happy_products)
      .select("happy_categories.*, COUNT(happy_products.id) AS product_count")
      .group("happy_categories.id")
      .order(:category).page(params[:page])
      @unassigned_products_count = HappyProduct.where(happy_vendor_id: @default_vendor, happy_category_id: nil).count
    end
    
  end


  def show
    if params[:id] == "none"
      @happy_category = "#{HappyVendor.find_by(id:params[:vendor_id]).vendor_name} - No Category"
      @happy_products = HappyProduct.where(happy_vendor_id: params[:vendor_id], happy_category_id: nil).page(params[:page])
    else
      @happy_category = HappyCategory.find(params[:id]).category
      @happy_products = HappyProduct.where("happy_category_id=?", params[:id]).page params[:page]
      @search = params["search"]
      if @search.present?
        @part = @search["part_number_or_description"]
        @happy_products = HappyProduct.where("happy_category_id=? and (description ILIKE ? OR part_number ILIKE ?)", params[:id], "%#{@part}%", "%#{@part}%").order("happy_category_id").page(params[:page])
      end
    end
  end

  def new
    @happy_category = HappyCategory.new
    @vendors = HappyVendor.order(:vendor_name)
  end

  def create
    @happy_category = HappyCategory.new(happy_category_params)
    @happy_category.user_id = current_user.id
    @happy_category.user_id_update = current_user.id
    @happy_category.happy_profit_center_id = 1
    begin
    if @happy_category.save
      flash[:success] = "Product Category Saved!"
      redirect_to @happy_category
    else
      flash.now[:alert] = "Category not saved!"
      render :new, status: :unprocessable_entity
    end
    rescue ActiveRecord::RecordNotUnique
      @happy_category.errors.add(:category, "already exists")
      flash.now[:alert] = "Category not saved!"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @happy_category = HappyCategory.find(params[:id])
    @vendors = HappyVendor.order(:vendor_name)
  end

  def update
    @happy_category = HappyCategory.find(params[:id])
    @happy_category.user_id_update = current_user.id
    if @happy_category.update(happy_category_params)
      flash[:success] = "Happy Category was successfully updated"
      redirect_to @happy_category
    else
      render :action => 'edit'
    end
  end

  def destroy
    @happy_category.destroy
    redirect_to action: "index"
  end

  private
  def happy_category_params
    params.require(:happy_category).permit!
  end

end
