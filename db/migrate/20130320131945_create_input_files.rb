class CreateInputFiles < ActiveRecord::Migration
  def change
    create_table :input_files do |t|
      t.string :name
      t.string :file_type
      t.integer :alignment_id

      t.timestamps
    end
  end
end
