class CreateAuthorsBooks < ActiveRecord::Migration
  def change
    # :id => false と書いておくことでid フィールドが生成されなくなる
    create_table :authors_books, :id => false do |t|
      t.references :author
      t.references :book
    end
    add_index :authors_books, :author_id
    add_index :authors_books, :book_id
  end
end
