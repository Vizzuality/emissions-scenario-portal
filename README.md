# Emissions Scenario Portal a project for [WRI](http://www.wri.org)

## Prerequisites

- PostgreSQL
- Redis

## Setting up the db

To reset the database & reseed: `rails db:drop db:setup`.

There are rails tasks that allow to clear individual tables:

`rails clear:time_series_values`

`rails clear:scenarios`

`rails clear:indicators`

`rails clear:models`

`rails clear:locations`

Some of them are dependent, so e.g. clearing models clears scenarios, indicators and time series values.

## Installing dependencies

`bundle install`

## Configuring the application

`.env` file

## Running the application

To run the application:

`redis-server`

`sidekiq`

`rails server`
