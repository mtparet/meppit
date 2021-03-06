class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string     :image,  null: false
      t.references :author, null: false, index: true
      t.references :content, polymorphic: true, index: true

      t.timestamps
    end
  end
end
