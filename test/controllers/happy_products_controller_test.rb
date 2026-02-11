require "test_helper"

class HappyProductsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
  end

  #index
  test "should show index page for products" do
    products = HappyProduct.all
    get happy_products_path
    assert_response :success
    assert_select "h2", "Happy Products"
    assert_select "b", "all #{products.count.to_s}"
    assert_select "td", products.first.part_number
    assert_select "td", products.first.description
  end

  test "should show index page by part number" do
    product_search_for = HappyProduct.first
    get happy_products_path, params: {search: {part_number: product_search_for.part_number, description: " "}}
    assert_response :success
    assert_select "h2", "Happy Products"
    assert_select "td", product_search_for.part_number
  end

  test "should show index page by description" do
    product_search_for = HappyProduct.first
    get happy_products_path, params: {search: {part_number: "", description: product_search_for.description}}
    assert_response :success
    assert_select "h2", "Happy Products"
    assert_select "td", product_search_for.description
  end

  #show
  test "should show page for product" do
    product = HappyProduct.first
    get happy_product_path(product)
    assert_response :success
    assert_select "h2", text: "Happy Product - #{product.part_number}"
    assert_select ".col-sm-5", text: "Description: #{product.description}"
  end

  #productinfo
  test "should get product info from part number" do
    product = HappyProduct.first
    silence_stream(STDOUT) do 
      get happy_products_productinfo_path, params: {productid: product.part_number, format: 'json'}
    end
    assert_response :success
    assert_equal "application/json", response.media_type
    json = JSON.parse(response.body)

    assert json.key?("happyproduct")
    assert_equal product.part_number, json["happyproduct"][0]["part_number"]
    assert_equal product.description, json["happyproduct"][0]["description"]
    assert_equal product.list_price.to_s, json["happyproduct"][0]["list_price"]
  end

end
