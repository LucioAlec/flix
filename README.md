# Movie Catalog App

![CI](https://github.com/LucioAlec/flix/actions/workflows/ci.yml/badge.svg)

A full-stack Ruby on Rails application for browsing, managing and reviewing movies.

This project allows users to sign up, sign in, browse movies, write reviews, favorite movies and explore movies by genre. Admin users can manage movies, genres and users through protected CRUD actions.

## Features

- User authentication with email or username
- Password authentication using `has_secure_password`
- Role-based authorization for admin and regular users
- Public movie catalog with index and show pages
- Movie filtering by released, upcoming, recent, hits and flops
- Movie reviews with star ratings and comments
- Favorite movies system
- Genre management
- User profile pages
- Admin-only management for movies, genres and users
- SEO-friendly URLs using slugs
- Movie poster/image upload validation
- Nested resources for movie reviews and favorites
- Automated test suite with Minitest

## Tech Stack

- Ruby on Rails 8.0.4
- Ruby
- SQLite for development and test
- PostgreSQL for production
- Puma
- Propshaft
- CSS Bundling
- Importmap
- Turbo Rails
- Stimulus Rails
- Active Storage
- AWS SDK for S3
- bcrypt
- Minitest
- Capybara
- Selenium WebDriver
- SimpleCov
- RuboCop Rails Omakase
- Brakeman

## Main Resources

The application is organized around the following main resources:

- `User`: represents registered users, including regular users and admins.
- `Movie`: represents movies in the catalog.
- `Review`: represents user reviews for movies.
- `Favorite`: represents the relationship between users and their favorite movies.
- `Genre`: represents movie categories.
- `Characterization`: connects movies and genres.
- `Session`: handles user sign in and sign out.

## Routes Overview

The application uses RESTful routes for the main resources:

```ruby
resources :genres

root "movies#index"

get "movies/filter/:filter" => "movies#index", as: :filtered_movies

resources :movies do
  resources :reviews
  resources :favorites, only: [ :create, :destroy ]
end

resource :session, only: [ :new, :create, :destroy ]

resources :users

get "signin" => "sessions#new"
get "signup" => "users#new"
```

## Authentication and Authorization

Users can sign in using either email or username.

The application has three access levels:

- Guests can browse movies and view movie details.
- Regular users can write reviews, favorite movies and manage their own account.
- Admin users can manage movies, genres and users.

Protected routes prevent guests and unauthorized users from accessing restricted pages or performing restricted actions.

## Testing

The project includes an automated test suite using Minitest.

The tests cover:

- Model validations
- Model scopes
- Model callbacks
- Authentication flows
- Authorization rules
- CRUD actions
- Strong parameters
- Redirects
- Session handling
- Not found scenarios
- Integration flows for users, movies, reviews, favorites and genres

Current test results:

- 165 tests
- 455 assertions
- 0 failures
- 0 errors
- 0 skips

Run the test suite with:

```bash
bin/rails test
```

## Code Quality and Security

Run RuboCop:

```bash
rubocop
```

Run Brakeman:

```bash
brakeman
```
## Continuous Integration

This project uses GitHub Actions to automatically run:

- Rails test suite
- System tests
- RuboCop linting
- Brakeman security scan
- Importmap audit

The CI workflow runs on pull requests and pushes to the `main` branch.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/LucioAlec/flix.git
cd flix
```

Install dependencies:

```bash
bundle install
```

Set up the database:

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

Start the Rails server:

```bash
bin/rails server
```

Open the application at:

```text
http://localhost:3000
```

## Running Tests

```bash
bin/rails test
```

## Project Status

This project is under active development as a Ruby on Rails portfolio application. It focuses on full-stack Rails development, RESTful architecture, authentication, authorization, model relationships, CRUD workflows and automated testing.
