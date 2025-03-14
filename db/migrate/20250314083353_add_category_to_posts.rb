class AddCategoryToPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :posts, :category, null: false, foreign_key: true
  end
end
