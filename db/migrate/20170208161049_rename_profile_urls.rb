class RenameProfileUrls < ActiveRecord::Migration[5.0]
  def change
    rename_column :providers, :profile_url, :profile
  end
end
