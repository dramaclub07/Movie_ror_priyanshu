class FixTables < ActiveRecord::Migration[7.1]
  def up
    # First, try to remove foreign key constraints if they exist
    execute <<-SQL
      DO $$#{' '}
      BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
          ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS fk_rails_user_id;
          ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS fk_rails_movie_id;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movies') THEN
          ALTER TABLE movies DROP CONSTRAINT IF EXISTS fk_rails_genre_id;
        END IF;
      END $$;
    SQL


    drop_table :subscriptions if table_exists?(:subscriptions)
    drop_table :movies if table_exists?(:movies)
    drop_table :genres if table_exists?(:genres)


    create_table :genres do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :genres, :name, unique: true

    create_table :movies do |t|
      t.string :title, null: false
      t.integer :release_year, null: false
      t.float :rating, null: false
      t.references :genre, null: false, foreign_key: true
      t.timestamps
    end
    add_index :movies, :title
    add_index :movies, :release_year

    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.string :plan_type, null: false
      t.string :status, null: false
      t.timestamps
    end
    add_index :subscriptions, %i[user_id movie_id], unique: true
  end

  def down
    execute <<-SQL
      DO $$#{' '}
      BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
          ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS fk_rails_user_id;
          ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS fk_rails_movie_id;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movies') THEN
          ALTER TABLE movies DROP CONSTRAINT IF EXISTS fk_rails_genre_id;
        END IF;
      END $$;
    SQL

    drop_table :subscriptions if table_exists?(:subscriptions)
    drop_table :movies if table_exists?(:movies)
    drop_table :genres if table_exists?(:genres)
  end
end
