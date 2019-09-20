class AddInactiveMonthsDefault < ActiveRecord::Migration[6.0]
  def change
  end

  def data
    Setting.set('inactive_months', 6)
  end
end
