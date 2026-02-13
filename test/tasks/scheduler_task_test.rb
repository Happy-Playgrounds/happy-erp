# test/lib/tasks/scheduler_task_test.rb
require "test_helper"
require "rake"

class SchedulerTaskTest < ActiveSupport::TestCase
  # Load rake tasks
  Rake.application.rake_require("tasks/scheduler")
  Rake::Task.define_task(:environment) # stub out environment task

  def setup
    # Clear enqueued or delivered emails before each test
    ActionMailer::Base.deliveries.clear
    
  end

  test "should use send_reminders to send email" do
    # Run the rake task
    silence_stream(STDOUT) do 
      Rake::Task["send_reminders"].invoke
    end

    # Assert email was sent
    assert_equal 3, ActionMailer::Base.deliveries.size
    ActionMailer::Base.deliveries.each do |email|
      assert_equal ["noreply@happyplaygrounds.com"], email.from
      #assert_equal ["test@example.com"], email.to
      assert_equal "Today's Happy Reminders", email.subject
    end
  end

    #NEED TO FIX SCHEDULER.RAKE send_calanders task
    # test "should use send_calendars to send email" do
    # # Run the rake task
    # Rake::Task["send_calendars"].invoke

    # # Assert email was sent
    # assert_equal 1, ActionMailer::Base.deliveries.size
    # ActionMailer::Base.deliveries.each do |email|
    #   puts email.inspect
    #   assert_equal ["admin@happyplaygrounds.com"], email.from
    #   #assert_equal ["test@example.com"], email.to
    #   #assert_equal "Today's Happy Reminders", email.subject
    # end
    #end
end
