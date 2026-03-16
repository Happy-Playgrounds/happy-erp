class AddProjectTitleToHappyQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :happy_quotes, :project_title, :string
  end
end
