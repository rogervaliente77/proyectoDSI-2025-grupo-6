module Admin
  class ProductsController < ApplicationController
    before_action :set_current_user
    # before_action :check_admin_access
    before_action :set_product, only: %i[ product_sales edit update destroy]
    layout 'dashboard'
    
    def index
      @products = Product.all
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
    
      if @product.save
        redirect_to admin_productos_path, notice: "Producto creado con éxito."
      else
        flash[:alert] = "Hubo un error al crear el producto"
        render :new, status: :unprocessable_entity
      end
    end

    def product_sales
      @products = @product&.product_sales
    end

    def edit
      # binding.pry
    end

    def update
      respond_to do |format|
        if @product.update(product_params)
          format.html {redirect_to admin_edit_product_path(product_id: @product.id), notice: "Producto actualizado con éxito" }
        else
          format.html { redirect_to admin_edit_product_path(product_id: @product.id), alert: "Ocurrio un error" }
        end
      end
    end

    def mark_as_delivered
      @product_sale = ProductSale.find(params[:product_sale_id])
    
      if @product_sale.update(was_delivered: !@product_sale.was_delivered, delivered_at: Time.now)
        redirect_to admin_product_sales_path(product_id: @product_sale.product.id), notice: "Producto actualizado con éxito.", status: :see_other
      else
        redirect_to admin_product_sales_path(product_id: @product_sale.product.id), alert: "Hubo un problema al actualizar el producto", status: :see_other
      end
    end
    
    def destroy
      # binding.pry
      @product.destroy!
  
      respond_to do |format|
        format.html { redirect_to admin_productos_path, status: :see_other, notice: "Producto eliminado exitosamente" }
        format.json { head :no_content }
      end
    end

    def search
      products = Product.where("name ILIKE ?", "%#{params[:q]}%").limit(10)
      render json: products.select(:id, :name, :description, :price)
    end

    private

    def check_admin_access
      if current_user.is_admin == false
        redirect_to portal_home_path, alert: "No tienes acceso a esta sección"
      end
    end

    def set_product
      @product = Product.find(params[:product_id]) || nil
    end

    def set_current_user
      @current_user = current_user
    end

    def product_params
      params.require(:product).permit(:name, :description, :quantity, :price, :image_url, :category_id)
    end
  end
end