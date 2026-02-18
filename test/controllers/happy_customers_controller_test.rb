require "test_helper"

class HappyCustomersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
  end

  #index
  test "Index page should show all customers" do
    get happy_customers_path
    assert_response :success
    assert response.body.include?("<b>#{HappyCustomer.count}</b> in total") ||
    response.body.include?("<b>#{HappyCustomer.count}</b> happy customers")
  end

  test "Index page shows specific company from search" do
    First_customer = HappyCustomer.first
        get happy_customers_path, params: {search: {
      customer_name: First_customer.customer_name
    }}
    assert_response :success
    assert_select "td", text: First_customer.customer_name
    assert_select "td", text: First_customer.happy_customer_company_id.to_s
  end

  #create
  test "should create valid customer under company" do
    assert_difference "HappyCustomer.count", 1 do
      post happy_customers_path, params: {happy_customer: {customer_name: "Customer 51",
                                                           happy_customer_company_id: 1,
                                                           email: "Test@example.com",
                                                           first_name: "Cust51",
                                                           last_name: "LastName",
                                                           title: "Title",
                                                           business_phone: "555-123-5678",
                                                           mailing_street1: "2345 S. Street Ave",
                                                           mailing_city: "Place",
                                                           mailing_state: "OK",
                                                           mailing_zipcode: "12345"}}
    end
    assert_equal "Customer Contact saved!", flash[:success]
  end

    test "should fail to create invalid customer under company" do
    assert_no_difference "HappyCustomer.count" do
      post happy_customers_path, params: {happy_customer: {customer_name: "Customer 51",
                                                           happy_customer_company_id: 1,
                                                           email: "",
                                                           first_name: "Cust51",
                                                           last_name: "LastName",
                                                           title: "Title",
                                                           business_phone: "555-123-5678",
                                                           mailing_street1: "2345 S. Street Ave",
                                                           mailing_city: "Place",
                                                           mailing_state: "OK",
                                                           mailing_zipcode: "12345"}}
    end
    assert_response :unprocessable_entity
  end

  #show
  test "should show all customer quotes as admin" do
    customer = HappyCustomer.first
    quote_one = happy_quotes(:quote_one)
    quote_two = happy_quotes(:quote_two)
    quote_three = happy_quotes(:quote_three)
    get happy_customer_path(customer)
    assert_response :success
    assert_select 'h2', "Happy Customer - #{customer.customer_name}"
    assert_select "a[href=?]", "/happy_quotes/#{quote_one.id}", text: "#{quote_one.number}-#{quote_one.sub}"
    assert_select "a[href=?]", "/happy_quotes/#{quote_two.id}", text: "#{quote_two.number}-#{quote_two.sub}"
    assert_select "a[href=?]", "/happy_quotes/#{quote_three.id}", text: "#{quote_three.number}-#{quote_three.sub}"
  end

  test "should only user-owned customer quotes as non-admin" do
    delete destroy_user_session_url
    @nonAdmin = users(:two)
    post user_session_url, params: {user: {email: @nonAdmin.email, password: '123456'}}

    customer = HappyCustomer.first
    quote_one = happy_quotes(:quote_one)
    quote_two = happy_quotes(:quote_two)
    quote_three = happy_quotes(:quote_three)

    get happy_customer_path(customer)
    assert_response :success
    assert_select 'h2', "Happy Customer - #{customer.customer_name}"
    assert_select "a[href=?]", "/happy_quotes/#{quote_one.id}", text: "#{quote_one.number}-#{quote_one.sub}", count: 0
    assert_select "a[href=?]", "/happy_quotes/#{quote_two.id}", text: "#{quote_two.number}-#{quote_two.sub}", count: 0
    assert_select "a[href=?]", "/happy_quotes/#{quote_three.id}", text: "#{quote_three.number}-#{quote_three.sub}"
  end

  test "should display customer reminders if they exist" do
    customer = HappyCustomer.first
    get happy_customer_path(customer)
    assert_response :success
    #puts response.body
    assert_select "button", text: "View Customer Reminders"
  end

  #update
  test "should update customer with valid data" do
    customer = HappyCustomer.first
    assert_changes -> {customer.reload.customer_name} do
      patch happy_customer_path(customer), params: {happy_customer: {customer_name: "Test Name"}}
    end
    assert_equal "Happy Customer Contact was successfully updated", flash[:success]
    assert_redirected_to happy_customer_path(customer)
  end

  test "should not update customer with invalid data" do
    customer = HappyCustomer.first
    assert_no_changes -> {customer.reload.customer_name} do
      patch happy_customer_path(customer), params: {happy_customer: {customer_name: ""}}
    end
  end

  #destroy
  # test "should destroy customer" do
  #   customer = HappyCustomer.first
  
  #   assert_difference "HappyCustomer.count", -1 do
  #     delete happy_customer_path(customer)
  #   end
  #   assert_redirected_to happy_customers_path
  # end

  
end
