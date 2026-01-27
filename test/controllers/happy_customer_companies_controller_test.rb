require "test_helper"

class HappyCustomerCompaniesControllerTest < ActionDispatch::IntegrationTest

  setup do
    #get new_user_session_url
    #sign_in users(:one)
    @user = users(:one)
  end

  #index 
  test "Index page shows all companies" do
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    get happy_customer_companies_path
    assert_response :success

    assert response.body.include?("<b>#{HappyCustomerCompany.count}</b> in total") ||
           response.body.include?("<b>all #{HappyCustomerCompany.count}</b> Companies")

  end
  test "Index page shows specific company from search" do
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    First_company_name = HappyCustomerCompany.first.company_name
    get happy_customer_companies_path, params: {search: {
      company_name: First_company_name
    }}
    assert_response :success
    assert_select "td", First_company_name

  end

  #show
  test "should show company page with customers" do
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    company = HappyCustomerCompany.first
    customer = company.happy_customers.first.customer_name
    get happy_customer_company_path(company)
    assert_match "Company ID: #{company.id}", response.body
    assert_match customer, response.body
  end

  #create
  test "should redirect create when not logged in " do
    assert_no_difference "HappyCustomerCompany.count" do
      post happy_customer_companies_path, params: {happy_customer_company: {company_name: "Test Company 51"}}
    end
    assert_redirected_to new_user_session_url
  end

  test "should create valid company when logged in" do
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    assert_difference "HappyCustomerCompany.count", 1 do
      post happy_customer_companies_path, params: {happy_customer_company: {company_name: "Test Company 51"}}
    end
    company = HappyCustomerCompany.last
    assert_redirected_to happy_customer_company_path(company)
  end

    test "do not create company if it already exist" do
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    post happy_customer_companies_path, params: {happy_customer_company: {company_name: "Test 51 Company"}}
    assert_no_difference "HappyCustomerCompany.count" do
      post happy_customer_companies_path, params: {happy_customer_company: {company_name: "Test 51 Company"}}
    end
    assert_response :unprocessable_entity

  end

  #update
  test "should update company with valid data" do
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    company = HappyCustomerCompany.first
    assert_changes -> {company.reload.company_name} do
      patch happy_customer_company_path(company), params: {happy_customer_company: {company_name: "New Company Name"}}
    end
    assert_redirected_to happy_customer_company_path(company)
  end

  #destroy
  test "should redirect destroy when not logged in " do
    company = happy_customer_companies(:company_one)
    
    assert_no_difference "HappyCustomerCompany.count" do
      delete happy_customer_company_path(company)
    end
    assert_redirected_to new_user_session_url
  end

  test "should destroy company when logged in " do
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    company = happy_customer_companies(:company_one)
  
    assert_difference "HappyCustomerCompany.count", -1 do
      delete happy_customer_company_path(company)
    end
    assert_redirected_to happy_customer_companies_path
  end

end
