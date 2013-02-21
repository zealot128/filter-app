# Rails 3.2 Baseapp

Rails provides a good set of defaults. Even so, we use some different subsets of gems and config, which we compiled into this base-application for new Ruby on Rails apps.

* Rspec + capybara/poltergeist, webmock, timecop
* HAML + SASS + Compass
* SimpleForm (+Bootstrap)
* Twitter Bootstrap + Font Awesome
* Will-paginate with bootstrap
* Chosen select box widget
* sitemap_generator with config/sitemap.rb for easier search-engine sitemap
* Sextant ( /rails/routes) until Rails 4
* Quiet Assets
* Guard with rspec (and spork: note: spork gem is commented out by default)
* Debugging facilities: pry, better\_errors
* opinionated style dir: /web.css and /user.css (for logged-in users) with subdirs in app/assets
* IE9.js for better IE7-9 experience
* Custom webfont (Without google fonts, keeping everything on the server)
* browser classes for <html>-Tag ("ie9", "webkit", etc) for easier ie-Styling
* **Spring** as application preloader for test/spec/rake/generator commands



## Twitter Bootstrap + Fonts

* Twitter Bootstrap Sass
* default haml-layout with navbar and footer
* Font-awesome icons
* font-kit "Lora" and "PTSerif"
  * Download more Font-kits from font-squirrel with "rake font:kit NAME=lora" from fontsquirrel

## Rspec

TestUnit/minitest is dumped in favor for Rspec eco-system.

There are some helpers:

* "be_valid" -> "@record.should be_valid" with better fail message
* ``include MailHelper``
  * provides convenience methods: "mail", "mails" instead of Actionmailer::Base.deliveries
  * Checks all outgoing mails for missing translations
* ``include PoltergeistHelper``
  * screenshot(page) -> Screenshot of current page to localhost:3000/screenshot.jpg
  * uses Poltergeist as capybara adapter
  * Allow webmock connects
  * skip_confirm -> Clicking Delete links with data-confirm

* Rspec-Tags
  * ``it "...", freeze_time: "2012-10-01 12:12"`` uses Timecop to freeze time for that scenario
  * ``it "...", skip: true``, set scenario, describe-groups etc to pending at once
  * ``it "...", caching: true``, enables controller/action caching for that test
* ``include TranslationHelper`` to controller-specs
  * will render views (render_views)
  * will check response-bodys for missing translations



## Install

```
git clone git://github.com/zealot128/rails-baseapp.git
cd rails-baseapp
bundle
rm -rf .git
```
