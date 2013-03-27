class CreateAlignments < ActiveRecord::Migration
  def change
    create_table :alignments do |t|
      t.string :name
      t.string :dir
      t.string :exon_gtf
      t.string :seq_name
      t.boolean :reverse
      t.string :user_changes

      t.timestamps
    end
  end
end
