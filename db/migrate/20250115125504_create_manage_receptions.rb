class CreateManageReceptions < ActiveRecord::Migration[7.1]
  def change
    create_table :manage_receptions do |t|
      t.timestamps
    end
    add_reference :manage_receptions, :userable, polymorphic: true, index: true
  end
end
