class AddCheckInAndCheckOutToPatients < ActiveRecord::Migration[7.1]
  def change
    add_column :patients, :check_in, :datetime
    add_column :patients, :check_out, :datetime
  end
end
