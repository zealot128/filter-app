# from http://inaka.net/blog/2015/03/25/hot-score-with-ruby-postgresql-and-elastic-part-1/
class AddHotScoreFunction < ActiveRecord::Migration

  def change
    change_table :news_items do |t|
      t.integer :absolute_score_per_halflife, index: true
    end
  end

  # def data
  #   puts "Rescoring #{NewsItem.count} NIs..."
  #   i = 0
  #   NewsItem.find_each do |ni|
  #     if (i += 1) % 1000 == 0
  #       print 'K'
  #     end
  #     ni.rescore!
  #   end
  # end
end
