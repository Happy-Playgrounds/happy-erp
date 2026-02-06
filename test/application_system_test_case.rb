require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  driven_by :selenium, using: :chrome, screen_size: [1200, 900] do |opt| 
    #opt.add_preference("credentials_enable_service", "false")
    #opt.add_preference("profile.password_manager_enabled", "false")
    #opt.add_preference("profile.password_manager_leak_detection_enabled", "false")
   opt.add_preference("autofill.profile_enabled", false)
  end
  
end
