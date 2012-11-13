require 'active_record'

silence do
  ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

  ActiveRecord::Migration.create_table :posts do |t|
    t.string :title
    t.string :slug
    t.integer :site_id
    t.timestamps
  end

  ActiveRecord::Migration.create_table :categories do |t|
    t.string :name
    t.string :permalink
    t.integer :site_id
    t.timestamps
  end

  ActiveRecord::Migration.create_table :sites do |t|
    t.string :domain
    t.timestamps
  end
end