class SplitTaskTag < ActiveRecord::Migration
  def change
    rename_column :tasks, :tag, :tag_name
    add_column :tasks, :tag_color, :string
  end
end
