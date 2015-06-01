class AddStoredProc < ActiveRecord::Migration
  def up
    execute <<-EOS
      CREATE OR REPLACE FUNCTION fill_search_vector_for_news_items() RETURNS trigger LANGUAGE plpgsql AS $$
      declare
        source record;
        article_categories record;

      begin
        select name into source from sources where id = new.source_id;
        select string_agg(name, ' ') as categories into article_categories from categories INNER JOIN "categories_news_items" ON "categories"."id" = "categories_news_items"."category_id" where news_item_id = new.id;

        new.search_vector :=
          setweight(to_tsvector('pg_catalog.german', coalesce(new.title, '')), 'A')                  ||
          setweight(to_tsvector('pg_catalog.german', coalesce(new.plaintext, '')), 'B')                ||
          setweight(to_tsvector('pg_catalog.german', coalesce(source.name, '')), 'B') ||
          setweight(to_tsvector('pg_catalog.german', coalesce(article_categories.categories, '')), 'B')
          ;

        return new;
      end
      $$;
    EOS

    execute <<-EOS
      CREATE TRIGGER news_items_search_trigger BEFORE INSERT OR UPDATE
        ON news_items FOR EACH ROW EXECUTE PROCEDURE fill_search_vector_for_news_items();
    EOS

    NewsItem.find_each(&:touch)
  end
  def down
    execute <<-EOS
               DROP FUNCTION fill_search_vector_for_news_items();
               DROP TRIGGER news_items_search_trigger ON news_items;
    EOS
  end
end
