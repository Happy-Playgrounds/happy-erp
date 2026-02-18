ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

sql = <<-SQL
  DROP TRIGGER IF EXISTS quote_stamp ON happy_quotes;
  DROP FUNCTION IF EXISTS quote_stamp;

  CREATE FUNCTION quote_stamp() RETURNS trigger AS $quote_stamp$
  BEGIN
    IF NEW.number IS NULL THEN
      NEW.number := NEW.id;
      NEW.sub := 0;
    END IF;
    RETURN NEW;
  END;
  $quote_stamp$ LANGUAGE plpgsql;

  CREATE TRIGGER quote_stamp
  BEFORE INSERT ON happy_quotes
  FOR EACH ROW
  EXECUTE PROCEDURE quote_stamp();
SQL

ActiveRecord::Base.connection.execute(sql)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    
    #Includes
    include Devise::Test::IntegrationHelpers
    include ActiveSupport::Testing::Stream

  end
end
