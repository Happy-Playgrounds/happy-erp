require "test_helper"

class HappyInstallSitesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
  end

  #index
  test "should get index page for all install sites" do
    install_sites = HappyInstallSite.all
    get happy_install_sites_path
    assert_response :success
    assert_select 'h2', "All Install Sites for Happy Playgrounds"

    install_sites.each do |site| 
      assert_select 'td', text: site.site_name
    end
  end

  test "should get index page for specific customer by id" do
    customer = HappyCustomer.second

    get happy_install_sites_path, params: {happy_customer_id: customer.id}
    assert_response :success
    assert_select 'h2', "Happy Install Sites for - #{customer.customer_name}"
    assert_select 'td', text: "Install site for third place"
    assert_select 'td', text: customer.customer_name
  end

  test "should get index page for specific customer by name" do
    customer = HappyCustomer.second

    get happy_install_sites_path, params: {search: customer.customer_name.downcase}
    assert_response :success
    assert_select 'h2', "All Install Sites for Happy Playgrounds"
    assert_select 'td', text: "Install site for third place"
    assert_select 'td', text: customer.customer_name
    assert_select 'td', text: "Customer 1", count: 0
  end

  #show
  test "should show page for specific install site" do
    install_site = HappyInstallSite.first
    get happy_install_site_path(install_site)
    assert_response :success
    assert_select 'h2', text: "Happy Install Site - #{install_site.site_name}"
  end

  #new
  test "should get new page for install site for specific customer" do
    customer = HappyCustomer.first
    silence_stream(STDOUT) do 
      get new_happy_install_site_path, params: {happy_customer_id: customer.id}
    end
    assert_response :success
    assert_select 'h2', "Create and Installation Site for - #{customer.customer_name}"
  end

  #create
  test "should create new happy install site" do
    install_sites = HappyInstallSite.all
    silence_stream(STDOUT) do
      assert_changes -> {install_sites.reload.count} do
        post happy_install_sites_path, params: {happy_install_site: {
            id: 4,
            happy_customer_id: 1,
            site_name: "Install site for fourth place",
            description: "This is an install site again",
            street1: "643643 S. fdsaf St",
            city: "Tulsa",
            state: "OK",
            postal_code: 74135,
            site_type: "School",
            length: 21.000,
            width: 27.000,
            height: 12.000,
            created_at: Time.zone.now,
            updated_at: Time.zone.now,
        }}
      end
    end
    assert_redirected_to HappyInstallSite.last
    follow_redirect!
    assert_match "Site was successfully created.", response.body
  end
end
