# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

This is a Rails 7.2 news aggregation platform that powers hrfilter.de (HR news) and fahrrad-filter.de (cycling news). The app fetches content from various sources (RSS feeds, Twitter, Reddit, Podcasts), scores articles based on social media engagement, and categorizes content for users.

## Development Commands

### Testing
```bash
bin/rspec                    # Run all tests
bin/rspec -f d               # Run with detailed output
bundle exec rspec --only-failures  # Re-run failed tests
bin/ci                       # Full CI suite (setup DB, assets, run tests)
```

### Linting and Code Quality
```bash
bin/rubocop -A               # Run RuboCop with auto-fix
bundle exec annotate         # Update model annotations (auto-generated)
```

### Development Servers
```bash
foreman start                # Start all services (web, jobs, vite)
bin/rails server             # Rails server only
bin/vite dev                 # Frontend dev server
bin/jobs                     # Background job worker (SolidQueue)
```

### Database
```bash
bundle exec rake db:create db:migrate    # Setup database
bundle exec rake db:schema:load          # Load schema in test
```

### Assets
```bash
yarn                         # Install JavaScript dependencies
RAILS_ENV=production bundle exec rails assets:precompile  # Build for production
```

## Architecture

### Core Models
- **Source**: RSS feeds, Twitter accounts, Reddit subreddits, Podcasts with scoring multipliers
- **NewsItem**: Aggregated articles with social media scores and categorization
- **Category**: Topic classification system with keyword matching
- **MailSubscription**: Newsletter subscribers with topic preferences
- **Trends**: Keyword trend tracking system

### Key Services
- **Processors** (`app/processors/`): Fetch content from different source types (RSS, Twitter, Reddit, YouTube)
- **Scoring Algorithm** (`app/services/news_item/scoring_algorithm.rb`): Calculates article relevance based on social signals
- **Newsletter System** (`app/services/newsletter/`): Weekly digest generation
- **Trend Analysis** (`app/models/trends/`): Keyword extraction and trending topic detection

### Background Jobs
- Uses SolidQueue for job processing
- **Source::FetchJob**: Regularly fetches new content from sources
- **NewsItem jobs**: Refresh social media stats, analyze trends
- **NewsletterJob**: Weekly email generation

### Frontend
- **Vue.js 2.7** with TypeScript for interactive components
- **Vite** for build tooling, **Sass** for styling
- Key components in `app/javascript/components/` and `app/javascript/front-page/`
- **Highcharts** for trend visualization

### Database Configuration
- **Development/Test**: PostgreSQL
- **Production**: Multi-database setup with PostgreSQL (primary), SQLite for queue/cache
- **Search**: pg_search for full-text search capabilities

### API
- **Grape API** in `app/api/` for mobile/external access
- REST endpoints for news items and subscriptions

## Configuration Notes

- **Locale**: German (`:de`) is the default language
- **Application name**: `Baseapp::Application` (legacy naming)
- **Multi-tenant**: Supports different site configs via `config/application.*.yml`
- **Email**: MJML templates for responsive newsletters
- **File uploads**: Paperclip for source logos and confirmation files
- **Error tracking**: Sentry integration
- **Analytics**: Ahoy for tracking user interactions

## Deployment
- **Docker**: Multi-stage Dockerfile with Thruster web server
- **Process management**: Uses Procfile for development, Thruster for production
- **Asset pipeline**: Vite handles JavaScript/CSS, Rails asset pipeline for images/fonts

## Code Guidelines
- **Rubocop**: 
  - No full `rubocop -A` EVER, only fix files you created/modified in a session