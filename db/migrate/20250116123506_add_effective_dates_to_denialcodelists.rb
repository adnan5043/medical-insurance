class AddEffectiveDatesToDenialcodelists < ActiveRecord::Migration[7.1]
  def change
    add_column :denialcodelists, :effective_from, :datetime
    add_column :denialcodelists, :effective_to, :datetime
  end
end
