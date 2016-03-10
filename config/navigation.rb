# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  navigation.consider_item_names_as_safe = true
  navigation.items do |primary|
    primary.dom_class = 'nav navbar-nav'
    primary.item :key_1, 'Tage', '/', {}
    primary.item :key_3, 'Kategorien', '/categories', {}
    primary.item :key_4, 'Suche', '/search', {}
    primary.item :key_5, 'Newsletter', '/newsletter', {}

    if controller_path.to_s['admin']
      primary.item :key_2, 'Admin', '#', {} do |sub_nav|
        sub_nav.item :key_2_1, 'Twitter', admin_twitter_path
        sub_nav.item :key_2_1, 'Settings', admin_settings_path
        sub_nav.item :key_2_1, 'Quellen', admin_sources_path
        sub_nav.item :key_2_2, 'Kategorien', admin_categories_path
        sub_nav.item :key_2_3, 'Abonnenten', admin_mail_subscriptions_path
      end
    end

  end
end
