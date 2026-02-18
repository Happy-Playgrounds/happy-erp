require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "should send reminder email for vendor" do
    reminder = HappyReminder.first
    email = UserMailer.with(reminder: reminder).reminder_email
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ["noreply@happyplaygrounds.com"], email.from
    assert_equal ["test@example.com"], email.to
    assert_equal "Today's Happy Reminders", email.subject
    assert_match 'You requested the following Happy Vendor reminder today:', email.body.to_s
    assert_match 'Test Reminder 3', email.body.to_s
  end

  test "should send reminder email for customer" do
    reminder = HappyReminder.second
    email = UserMailer.with(reminder: reminder).reminder_email
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ["noreply@happyplaygrounds.com"], email.from
    assert_equal ["test@example.com"], email.to
    assert_equal "Today's Happy Reminders", email.subject
    assert_match 'You requested the following Happy Customer reminder today:', email.body.to_s
    assert_match 'Test Reminder 2', email.body.to_s
  end

    test "should send reminder email for quote" do
    reminder = HappyReminder.last
    email = UserMailer.with(reminder: reminder).reminder_email
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ["noreply@happyplaygrounds.com"], email.from
    assert_equal ["test@example.com"], email.to
    assert_equal "Today's Happy Reminders", email.subject
    assert_match 'You requested the following Happy Quote reminder today:', email.body.to_s
    assert_match 'Test Reminder 1', email.body.to_s
  end

  test "should send calender email" do
    reminder = HappyReminder.first
    email = UserMailer.with(happyReminder: reminder).calendar_email
    assert_emails 1 do
      email.deliver_now
    end
  end
end