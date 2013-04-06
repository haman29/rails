class CreateArtists < ActiveRecord::Migration
  def change
    create_table :artists do |t|
      t.string :name
      t.date :created_at
      t.date :updated_at
      t.date :deleted_at
      t.boolean :del_flg

      t.timestamps
    end
  end
end
