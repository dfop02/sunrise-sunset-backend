class CreateSunHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :sun_histories do |t|
      t.string :city, null: false
      t.datetime :sunrise
      t.datetime :sunset
      t.datetime :golden_hour
      t.date :date, null: false
    end

    add_index :sun_histories, [:city, :date]
  end
end
