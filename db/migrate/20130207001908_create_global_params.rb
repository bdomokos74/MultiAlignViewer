class CreateGlobalParams < ActiveRecord::Migration
  def change
    create_table :global_params do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
