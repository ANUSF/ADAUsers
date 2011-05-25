class CreateDocTemplates < ActiveRecord::Migration
  def self.up
    create_table :doc_templates do |t|
      t.string :doc_type
      t.string :name
      t.string :title
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :doc_templates
  end
end
