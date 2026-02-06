require "application_system_test_case"

class QuotesTest < ApplicationSystemTestCase
  def setup 
      @user = users(:one)
    #post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    visit new_user_session_url
    fill_in "Email", with: @user.email
    fill_in "Password", with: "123456"
    click_button "Log in"
    assert_text "Signed in successfully."
  end

  test "should visit new quote page and add line item" do
    customer = HappyCustomer.first
    silence_stream(STDOUT) do 
      visit new_happy_customer_happy_quote_path(customer)
      assert_text "Create a Quote Header"
      select "Due on Receipt", from: "Terms"
      select "Company Truck", from: "Fob"
      check "Same as Billing Address"
      click_link "add line"
      fill_in "Part Number", with: "0713488"
      assert_field "Description", with: "BTM RAIL 12FT RAMP H RAIL"
      assert_field "Unit price", with: "109.52"
      fill_in "Quantity", with: "5"
      
      click_button "Save Quote"
      assert_text "Quote saved!"
      quote = HappyQuote.last
      assert_text "#{quote.number}-#{quote.sub}"
    end
  end
end