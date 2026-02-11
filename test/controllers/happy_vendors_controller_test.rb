require "test_helper"

class HappyVendorsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
  end

  #index
  test "should show vendor index page" do
    vendors = HappyVendor.all
    get happy_vendors_path
    assert_response :success
    assert_select "h2", text: "Happy Vendors"
    vendors.each do |vendor|
      assert_select "td", text: vendor.id.to_s
      assert_select "td", text: vendor.vendor_name
    end
  end

  test "should show vendor index page with search" do
    vendor = HappyVendor.first
    get happy_vendors_path, params:{search: {vendor_name: vendor.vendor_name}}
    assert_response :success
    assert_select "td", text: vendor.id.to_s
    assert_select "td", text: vendor.vendor_name
  end

  #new
  test "should show new vendor page" do
    get new_happy_vendor_path
    assert_response :success
    assert_select 'h2', text: "Happy Vendors"
    assert_select 'input[type=submit][value=?]', "Create Happy vendor"
  end

  #show
  test "should show specific vendor page" do
    vendor = HappyVendor.first
    pos = HappyQuote.joins("INNER JOIN happy_quote_lines ON happy_quotes.id = happy_quote_lines.happy_quote_id INNER JOIN happy_vendors ON happy_quote_lines.happy_vendor_id = happy_vendors.id").select("happy_quote_lines.happy_vendor_id as happy_vendor_id, happy_quotes.number AS number, happy_quotes.order_date as order_date, happy_quotes.special_instructions as special_instructions,  avg(purchase_discount) as purchase_discount, sum(total_cost_amount) AS po_amount").group("happy_vendor_id,happy_quotes.number,happy_quotes.order_date,happy_quotes.special_instructions").where("happy_vendor_id = ?", vendor.id).order("number DESC")
    get happy_vendor_path(vendor)
    assert_response :success
    assert_select 'h2', text: "Happy Vendor - #{vendor.vendor_name}"

    pos.each do |po|
      assert_select "a[href=?]", happy_quote_pocreate_path(happy_quote_id: po.number, vendor_id: po.happy_vendor_id, format: "html")
    end
  end

  #edit
  test "should show edit page" do
    vendor = HappyVendor.first
    get edit_happy_vendor_path(vendor)
    assert_select "h2", "Edit - Happy Vendors"
    assert_select "input[name=?][value=?]", "happy_vendor[vendor_name]", vendor.vendor_name
    assert_select 'input[type=submit][value=?]', "Update Happy Vendor"
  end

  #update
  test "should edit vendor with valid info" do
    vendor = HappyVendor.first
    assert_changes -> {vendor.reload.mailing_street1} do
      patch happy_vendor_path(vendor), params: {happy_vendor: {
        mailing_street1: "12345 new street"
      }}
    assert_redirected_to happy_vendor_path(vendor)
    assert_equal "Happy Vendor was successfully updated", flash[:success]
    end
  end

  #create
  test "should create new vendor wih valid" do
    post happy_vendors_path, params: {happy_vendor: {
      vendor_name: "New Vendor",
      first_name: "Tim",
      last_name: "Smith",
      title: "Owner",
      mailing_street1: "54321 S Street. Ave",
      mailing_city: "Tulsa",
      mailing_state: "OK",
      mailing_zipcode: "74145",
      business_phone: "1234567890",
      email: "owner@newvendor.com"
    }}
    assert_equal "Vendor saved!", flash[:success]
    newest_vendor = HappyVendor.last
    assert_redirected_to newest_vendor
    assert_equal "New Vendor", newest_vendor.vendor_name
  end

  test "should not create new vendor with invalid info" do
    post happy_vendors_path, params: {happy_vendor: {
      vendor_name: "",
    }}
    assert_equal "Vendor not saved!", flash[:alert]
  end

end
