require "test_helper"

class HappyRemindersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
  end
  #create
  test "create new reminder for quote" do
    quote = HappyQuote.second
    reminders = HappyReminder.all
    silence_stream(STDOUT) do 
      assert_changes -> {reminders.reload.count} do
      post happy_reminders_path, params: {happy_reminder: {
          name: "Test Reminder 3",
          content: "This is a new reminder for testing Quotes!",
          remindable_id: quote.id,
          remindable_type: HappyQuote,
          is_sent: false,
          reminder_date: Date.today,
          user_id: 1
      }}
      end
    end
    assert_redirected_to quote
  end

  test "create new reminder for customer" do
    customer = HappyCustomer.second
    reminders = HappyReminder.all
    silence_stream(STDOUT) do 
      assert_changes -> {reminders.reload.count} do
      post happy_reminders_path, params: {happy_reminder: {
          name: "Test Reminder 3",
          content: "This is a new reminder for testing Customers!",
          remindable_id: customer.id,
          remindable_type: HappyCustomer,
          is_sent: false,
          reminder_date: Date.today,
          user_id: 1
      }}
      end
    end
    assert_redirected_to customer
  end

  test "create new reminder for vendors" do
    vendor = HappyVendor.second
    reminders = HappyReminder.all
    silence_stream(STDOUT) do 
      assert_changes -> {reminders.reload.count} do
      post happy_reminders_path, params: {happy_reminder: {
          name: "Test Reminder 3",
          content: "This is a new reminder for testing Vendors",
          remindable_id: vendor.id,
          remindable_type: HappyVendor,
          is_sent: false,
          reminder_date: Date.today,
          user_id: 1
      }}
      end
    end
    assert_redirected_to vendor
  end

end
