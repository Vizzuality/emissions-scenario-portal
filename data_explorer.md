# Data Explorer JSON API & CSV download (in Climate Watch)

## Emission Pathways

### Parameters
- location_ids[]
- model_ids[]
- scenario_ids[]
- category_ids[]
- indicator_ids[]
- start_year
- end_year

### CSV download endpoint

`/api/v1/data/emission_pathways/download.csv`


File format:

ID | Iso code 2 | Location | Model | Scenario | Category | Subategory | Indicator| Unit | Definition | year 1 | year 2 | ...

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
      ],
      "columns":[
         {"name":"string", "sortable":boolean, "current":"string"}
      ]
   }
}
```

Response is paginated. Pagination headers are in place. Meta section is to inform the rendering of data in a tabular form: it lists available years of data (useful when used as headers) and all available data columns together with information on whether they are sortable or not. Column which is currently used for sorting will additionaly have the "current" property set to either "ASC" or "DESC".

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
         "id":1,
         "name":"Africa",
         "iso_code":null,
         "region":true
      },
      {
         "id":2,
         "name":"Annex-1",
         "iso_code":null,
         "region":true
      },
      {
         "id":19,
         "name":"Afghanistan",
         "iso_code":"AF",
         "region":false
      }
   ]
}
```

### Models

`/api/v1/data/emission_pathways/models`

```
{
   "data":[
      {
         "id":3,
         "full_name":"Global Change Assessment Model",
         "description":"GCAM is an integrated assessment tool for exploring consequences and responses to global change",
         "citation":"",
         "key_usage":"This model is used to examine the effect of technology and policy on economy, energy systems, agriculture and land use, and climate",
         "abbreviation":"GCAM",
         "current_version":"4",
         "programming_language":"Java, Visual C++/Xcode, R \u0026 Rstudio",
         "maintainer_institute":"Pacific Northwest National Laboratory (PNNL)",
         "license":"Free and Open Source",
         "expertise":null,
         "base_year":2010,
         "time_step":"5",
         "time_horizon":"2100",
         "platform":"",
         "sectoral_coverage":[
            "buildings (residential and commercial)",
            "electricity",
            "land-use, land-use change, and forestry (LULUCF)",
            "transportation",
            "industry and industrial processes"
         ],
         "geographic_coverage":[
            "International"
         ],
         "url":"http://www.globalchange.umd.edu/gcam/",
         "policy_coverage":[

         ],
         "scenario_coverage":[

         ],
         "gas_and_pollutant_coverage":[
            "CO2",
            "CH4",
            "F-gases (HFC, PFC, SF6)",
            "N2O",
            "SO2"
         ],
         "technology_coverage":[

         ],
         "energy_resource_coverage":[

         ],
         "equilibrium_type":null,
         "population_assumptions":"Exogenously specified; Population does not change in response to policy, technology, etc ",
         "gdp_assumptions":"Exogenously specified assumption about labour productivity growth; GDP does not change in response to policy, technology, etc ",
         "other_assumptions":"",
         "input_data":"",
         "publications_and_notable_projects":"",
         "point_of_contact":"",
         "concept":"",
         "solution_method":"",
         "anticipation":[

         ],
         "behaviour":"",
         "land_use":"",
         "technology_choice":null,
         "global_warming_potentials":null,
         "technology_constraints":null,
         "trade_restrictions":null,
         "solar_power_supply":null,
         "wind_power_supply":null,
         "bioenergy_supply":null,
         "co2_storage_supply":null,
         "logo":null,
         "scenario_ids":[
            38, ...
         ],
         "indicator_ids":[
            106, ...
         ]
      }
   ]
}
```

### Scenarios

`/api/v1/data/emission_pathways/scenarios`

```
{
   "data":[
      {
         "id":38,
         "model_abbreviation":"GCAM",
         "name":"Low policy",
         "year":null,
         "category":"not specified",
         "purpose_or_objective":"",
         "description":"",
         "reference":"",
         "url":null,
         "policy_coverage":[

         ],
         "technology_coverage":[

         ],
         "socioeconomics":null,
         "climate_target":"",
         "other_target":"",
         "burden_sharing":"",
         "discount_rates":"",
         "model":{
            "id":3,
            "name":"Global Change Assessment Model"
         },
         "indicator_ids":[
            360, ...
         ]
      }, ...
   ]
}
```

### Indicators

`/api/v1/data/emission_pathways/indicators`

```
{
   "data":[
      {
         "id":408,
         "name":"Agriculture",
         "definition":null,
         "unit":"EJ/yr",
         "composite_name":"Energy|Energy use by sector|Agriculture",
         "stackable":false,
         "category":{
            "id":1,
            "name":"Energy"
         },
         "subcategory":{
            "id":36,
            "name":"Energy use by sector",
            "parent_id":1
         }
      }
   ]
}
```

### Categories

`/api/v1/data/emission_pathways/categories`

```
{
   "data":[
      {
         "id":1,
         "name":"Energy",
         "parent_id":null
      },
      {
         "id":11,
         "name":"Primary Energy Use",
         "parent_id":1
      }
   ]
}
```
