# Data Explorer JSON API & CSV download (in Climate Watch)

## Emission Pathways

### Parameters
- locations[] (ISO code 3)
- model_ids[]
- scenario_ids[]
- category_ids[]
- subcategory_ids[]
- indicator_ids[]
- start_year
- end_year

### CSV download endpoint

`/api/v1/data/emission_pathways/download.csv`


File format:

ID | Iso code 3 | Location | Model | Scenario | Category | Subategory | Indicator| Unit | Definition | year 1 | year 2 | ...

### JSON API endpoint

#### Data

`/api/v1/data/emission_pathways`

```
{
   "data":[
      {
         "id":66319,
         "location":"string",
         "iso_code2":"ISO code 2",
         "model":"string",
         "scenario":"string",
         "category":"string",
         "subcategory":"string",
         "indicator":"string",
         "unit":"string",
         "definition":"string",
         "emissions":[
            {
               "year":integer,
               "value":double
            }
         ]
      }
   ],
   "meta":{
      "years":[
         integer
      ]
   }
}
```

Response is paginated. Pagination headers are in place.

```
Link: <http://localhost:3000/api/v1/data/emission_pathways?page=416>; rel="last", <http://localhost:3000/api/v1/data/emission_pathways?page=2>; rel="next"
Per-Page: 50
Total: 20754
```

#### Metadata

`/api/v1/data/emission_pathways/meta`

Returns a Link header with meta endpoint urls for discovery (can be used with a HEAD request)

```
Link: </api/v1/data/emission_pathways/locations>; rel="meta locations", </api/v1/data/emission_pathways/models>; rel="meta models", </api/v1/data/emission_pathways/scenarios>; rel="meta scenarios", </api/v1/data/emission_pathways/categories>; rel="meta categories", </api/v1/data/emission_pathways/indicators>; rel="meta indicators"
```

### Locations

`/api/v1/data/emission_pathways/locations`

```
{
   "data":[
      {
         "id":number,
         "name":"string e.g. CAIT"
      }
   ]
}
```

### Models

`/api/v1/data/emission_pathways/models`

### Scenarios

`/api/v1/data/emission_pathways/scenarios`

### Categories

`/api/v1/data/emission_pathways/categories`

### Indicators

`/api/v1/data/emission_pathways/indicators`
