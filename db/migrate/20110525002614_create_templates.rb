class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :templates do |t|
      t.string :doc_type
      t.string :name
      t.string :title
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :templates
  end
end
