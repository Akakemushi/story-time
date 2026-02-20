class AddUserProfileFields < ActiveRecord::Migration[7.1]
  def up
    enable_extension 'citext' unless extension_enabled?('citext')

    add_column :users, :first_name, :citext
    add_column :users, :last_name, :citext
    add_column :users, :middle_name, :citext
    add_column :users, :username, :citext

    # Backfill existing records
    User.reset_column_information
    User.find_each do |user|
      user.update_columns(
        first_name: "Anonymous",
        last_name: "User",
        username: "User#{user.id}"
      )
    end

    # Now enforce NOT NULL and uniqueness
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
    change_column_null :users, :username, false
    add_index :users, :username, unique: true
  end

  def down
    remove_index :users, :username
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :middle_name
    remove_column :users, :username
  end
end
