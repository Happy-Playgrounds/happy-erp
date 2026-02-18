class UserMailer < ApplicationMailer
  default from: "Happy Reminder <noreply@happyplaygrounds.com>"

  def reminder_email
    #@happyUser = User.first
    #@happyUser = params[:user]
    @happyReminder = params[:reminder]
    #puts @happyReminder
    @happyUser = User.find_by("id = ?", @happyReminder.user_id)
    #@quoteNumber = HappyQuote.select('number','sub').find_by("id = ?",quote_reminder.remindable_id)
    #mail_users = User.joins(:happy_reminders).where("Date(reminder_date) = ?",Date.today).distinct
    #puts "User"
    #puts @happyUser.email
    #puts "UserName"
    #puts @happyUser.username
    @Name = @happyUser.username.split('.') 
    @firstName = @Name[0]
    i = rand(14)
    @customerQuote = HappyReminder::CustomerQuotes[i]

    case @happyReminder.remindable_type
      when "HappyQuote"
        @quoteNumber = HappyQuote.select('number','sub').find_by("id = ?",@happyReminder.remindable_id)
        #@happyQuoteReminder = HappyReminder.joins(:user).where("Date(reminder_date) = ? and remindable_type = ? and user_id = ? and remindable_id ",Date.today, "HappyQuote", @happyUser.id)
        @happyQuoteReminder = HappyReminder.joins(:user).where("happy_reminders.id = ? and happy_reminders.user_id = ?", @happyReminder.id, @happyUser.id)

      when "HappyProject"
        #@happyProjectReminder = HappyReminder.joins(:user).where("Date(reminder_date) = ? and remindable_type = ? and user_id = ?",Date.today, "HappyProject", @happyUser.id)
        @happyProjectReminder = HappyReminder.joins(:user).where("happy_reminders.id = ? and happy_reminders.user_id = ?", @happyReminder.id, @happyUser.id)

      when "HappyCustomer"
        #@happyCustomerReminder = HappyReminder.joins(:user).where("Date(reminder_date) = ? and remindable_type = ? and user_id = ?",Date.today, "HappyCustomer", @happyUser.id)
        @happyCustomerReminder = HappyReminder.joins(:user).where("happy_reminders.id = ? and happy_reminders.user_id = ?", @happyReminder.id, @happyUser.id)

      when "HappyVendor"
        #@happyVendorReminder = HappyReminder.joins(:user).where("Date(reminder_date) = ? and remindable_type = ? and user_id = ?",Date.today, "HappyVendor", @happyUser.id)
        @happyVendorReminder = HappyReminder.joins(:user).where("happy_reminders.id = ? and happy_reminders.user_id = ?", @happyReminder.id, @happyUser.id)
      else
        "No type defined for this reminder"
    end

    #@happyReminder = User.joins(:happy_reminder).where("DATE(reminder_date) = ?", Date.today)
    #@happyReminder = User.first.happy_reminders.where("DATE(reminder_date) = ?", Date.today)
    #@happyReminder = User.happy_reminders.where("DATE(reminder_date) = ? and User.id = ?", Date.today, current_user)
    #mail(to: "brian.collins@happyplaygrounds.com", subject: "test")
    #puts "above mail in user_mailer"
    mail(to: @happyUser.email, subject: "Today's Happy Reminders")
    #puts "below mail in user_mailer"
  end

  def calendar_email
    #@happyreminder = HappyReminder.find(params[:reminderID])
    @happyreminder = params[:happyReminder]
    @user = User.find(@happyreminder.user_id)
    #puts "got here"
    #@happyreminder = params[:happyreminder]
    #@user = params[:user]
    #@reminder_url = streaming_sport_reminder_stream_url(sport_slug: @reminder.sport_slug, reminder_slug: @reminder.slug)
    @subject = [@happyreminder.name, @happyreminder.reminder_date].join(', ')
    #puts "got here2"
    #ical = HappyReminderMail::IcalendarEvent.new(reminder: @happyreminder, user: @user).call # generate the ical file
    ical = HappyReminderMail::IcalendarEvent.new(reminder: @happyreminder).call # generate the ical file
    #puts "got here3"

    # attach ICS file
    #mail.attachments["#{@subject}.ics"] = { mime_type: 'application/ics', content: ical.to_ical }
    # mail.attachments["#{@subject}.ics"] = { mime_type: 'text/calendar', content: ical.to_ical }
     mail.attachments["#{@subject}.ics"] = { mime_type: 'text/calendar; method=REQUEST', content: ical }

    mail to: @user.email,
         from: 'Happy Reminder from Happy Playgrounds <admin@happyplaygrounds.com>',
         #cc: Rails.application.config_for(:settings)[:support_email],
         subject: @subject
  end

end
