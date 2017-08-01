# Emissions Scenario Portal a project for [WRI](http://www.wri.org)

## Prerequisites

- PostgreSQL
- Redis

## Setting up the db

To reset the database & reseed: `bundle exec rake db:drop db:create db:migrate db:seed`.

There are rake tasks that allow to clear individual tables:

`rake clear:time_series_values`

`rake clear:scenarios`

`rake clear:indicators`

`rake clear:models`

`rake clear:locations`

Some of them are dependent, so e.g. clearing models clears scenarios, indicators and time series values.

## Installing dependencies

`bundle install`

## Configuring the application

`.env` file

## Running the application

To run the application:

`redis-server`

`bundle exec sidekiq`

`rails s`
