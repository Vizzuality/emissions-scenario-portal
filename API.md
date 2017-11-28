# API docs

The rails server exposes a JSON api that allows ESP data to be used in other contexts.

The API endpoints are always prefixed by `/api/v1`.

## `GET /models`

Lists all models

### Query parameters

* `time_series` - Filters locations by the presence of time_series_values
associated with them.

## `GET /models/:id`

Retrieves the model with the given id along with associated entities

## `GET /scenarios`

Lists all scenarios

### Query parameters

* `model` - Filters scenarios by the model id they belong to

## `GET /scenarios/:id`

Retrieves the scenario with the given id along with associated entities

## `GET /indicators`

Lists all indicators

## `GET /indicators/:id`

Retrieves the indicator with the given id along with associated entities

## `GET /locations`

Lists all locations.

### Query parameters
* `time_series` - Filters locations by the presence of time_series_values
associated with them.


## `GET /time_series_values`

Retrieves ESP time series data, sorted by year

### Query parameters

* `location` - Filter time series values by the location they belong to. Accepts several location ids, separated by commas.

* `scenario` - Filter time sereis values by the scenario they belong to. Accepts several scenario ids, separated by commas.
