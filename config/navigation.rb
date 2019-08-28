# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.consider_item_names_as_safe = true

  navigation.items do |primary|
    i = 0
    divider = ->(sub) do
      sub.item :"types-#{i += 1}", "", "#", html: { divider: true, class: 'divider' }, class: 'divider'
    end
    primary.dom_class = 'nav navbar-nav'
    primary.item :key_1, 'Tage', '/', {}
    primary.item :key_3, 'Kategorien', '/kategorien', highlights_on: :subpath
    primary.item :key_4, 'Suche', '/search', {}
    primary.item :key_5, 'Newsletter', '/newsletter', {}
    primary.item :key_6, 'Als App', '/app', {}

    if current_user
      primary.item :key_2, 'Admin', '#', {} do |sub_nav|
        sub_nav.item :key_2_0, 'Dashboard', admin_dashboard_path
        divider.call(sub_nav)
        if can?(:manage, Source)
          sub_nav.item :key_2_1, 'Quellen', admin_sources_path
        end
        if can?(:manage, :twitter)
          divider.call(sub_nav)
          sub_nav.item :key_2_1, 'Twitter', admin_twitter_path
        end
        if can?(:manage, Setting)
          sub_nav.item :key_2_1, 'Settings', admin_settings_path
        end
        if can?(:manage, Category)
          sub_nav.item :key_2_2, 'Kategorien', admin_categories_path
        end
        if can?(:manage, MailSubscription)
          divider.call(sub_nav)
          sub_nav.item :key_2_3, 'Abonnenten', admin_mail_subscriptions_path
        end
        if can?(:manage, User)
          divider.call(sub_nav)
          sub_nav.item :key_2_4, 'Admins', admin_users_path
        end
      end
    end
  end
end
