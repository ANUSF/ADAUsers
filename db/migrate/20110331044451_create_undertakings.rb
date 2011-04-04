class CreateUndertakings < ActiveRecord::Migration
  def self.up
    create_table :undertakings do |t|
      t.string :user_user
      t.boolean :is_restricted
      t.string :intended_use_type
      t.string :intended_use_other
      t.text :intended_use_description
      t.string :email_supervisor
      t.text :funding_sources
      t.boolean :agreed
      t.boolean :processed

      t.timestamps
    end

    create_table :access_levels_undertakings, :id => false do |t|
      t.string :datasetID
      t.integer :undertaking_id
    end
  end

  def self.down
    drop_table :access_levels_undertakings
    drop_table :undertakings
  end
end
