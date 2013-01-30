class ChangeStatusToString < ActiveRecord::Migration
  def change
    change_column :release_notes, :status, :string, :limit => 12
  end
end
