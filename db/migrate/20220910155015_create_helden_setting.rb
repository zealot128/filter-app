class CreateHeldenSetting < ActiveRecord::Migration[6.0]
  def change
    if Setting.key == 'fahrrad-filter'
      Setting.set('helden', "https://helden.de/bike/?src=swie&presetVoucher=SWIE2&utm_source=ner&utm_medium=li&utm_campaign=de.po.ro.sa")
    end
  end
end
