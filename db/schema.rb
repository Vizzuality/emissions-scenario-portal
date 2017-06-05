# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170605090043) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "indicators", force: :cascade do |t|
    t.text     "category"
    t.text     "name",                                  null: false
    t.text     "definition"
    t.text     "unit"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "model_id"
    t.text     "subcategory"
    t.boolean  "stackable_subcategory", default: false
    t.text     "unit_of_entry"
    t.decimal  "conversion_factor"
    t.integer  "parent_id"
    t.index ["model_id"], name: "index_indicators_on_model_id", using: :btree
    t.index ["parent_id"], name: "index_indicators_on_parent_id", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.text     "name",                                 null: false
    t.string   "iso_code2",  limit: 2
    t.boolean  "region",               default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "models", force: :cascade do |t|
    t.integer  "team_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.text     "abbreviation",                                     null: false
    t.text     "full_name",                                        null: false
    t.text     "current_version"
    t.text     "linkages_and_extensions"
    t.integer  "development_year"
    t.text     "programming_language",                default: [],              array: true
    t.text     "maintainer_type"
    t.text     "maintainer_name"
    t.text     "license"
    t.text     "license_detailed"
    t.text     "availability"
    t.text     "expertise"
    t.text     "expertise_detailed"
    t.text     "platform",                            default: [],              array: true
    t.text     "platform_detailed"
    t.text     "category"
    t.text     "category_detailed"
    t.text     "hybrid_classification"
    t.text     "hybrid_classification_detailed"
    t.text     "purpose_or_objective"
    t.text     "description"
    t.text     "key_usage",                           default: [],              array: true
    t.text     "scenario_coverage"
    t.text     "scenario_coverage_details",           default: [],              array: true
    t.text     "geographic_coverage"
    t.text     "geographic_coverage_region",          default: [],              array: true
    t.text     "geographic_coverage_country",         default: [],              array: true
    t.text     "sectoral_coverage",                   default: [],              array: true
    t.text     "gas_and_pollutant_coverage",          default: [],              array: true
    t.text     "policy_coverage",                     default: [],              array: true
    t.text     "technology_coverage",                 default: [],              array: true
    t.text     "technology_coverage_detailed"
    t.text     "energy_resource_coverage",            default: [],              array: true
    t.text     "time_horizon"
    t.text     "time_step"
    t.text     "equilibrium_type"
    t.text     "foresight"
    t.text     "spatial_resolution"
    t.text     "population_assumptions"
    t.text     "gdp_assumptions"
    t.text     "other_assumptions"
    t.integer  "base_year"
    t.text     "input_data"
    t.text     "calibration_and_validation"
    t.text     "languages",                           default: [],              array: true
    t.text     "tutorial_and_training_opportunities", default: [],              array: true
    t.text     "system_requirements"
    t.text     "run_time"
    t.text     "publications_and_notable_projects"
    t.text     "citation"
    t.text     "url"
    t.text     "point_of_contact"
    t.index ["abbreviation"], name: "index_models_on_abbreviation", unique: true, using: :btree
    t.index ["team_id"], name: "index_models_on_team_id", using: :btree
  end

  create_table "scenarios", force: :cascade do |t|
    t.text     "name",                                          null: false
    t.integer  "model_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "model_abbreviation"
    t.text     "model_version"
    t.text     "provider_type"
    t.text     "provider_name"
    t.date     "release_date"
    t.text     "category"
    t.text     "description"
    t.text     "geographic_coverage_region",       default: [],              array: true
    t.text     "geographic_coverage_country",      default: [],              array: true
    t.text     "sectoral_coverage",                default: [],              array: true
    t.text     "gas_and_pollutant_coverage",       default: [],              array: true
    t.text     "policy_coverage",                  default: [],              array: true
    t.text     "policy_coverage_detailed"
    t.text     "technology_coverage",              default: [],              array: true
    t.text     "technology_coverage_detailed"
    t.text     "energy_resource_coverage",         default: [],              array: true
    t.text     "time_horizon"
    t.text     "time_step"
    t.text     "climate_target"
    t.text     "emissions_target"
    t.text     "large_scale_bioccs"
    t.text     "technology_assumptions"
    t.text     "gdp_assumptions"
    t.text     "population_assumptions"
    t.text     "discount_rates",                   default: [],              array: true
    t.text     "emission_factors"
    t.text     "global_warming_potentials"
    t.text     "policy_cut_off_year_for_baseline"
    t.text     "project_study",                    default: [],              array: true
    t.text     "literature_reference"
    t.text     "point_of_contact"
    t.text     "proposed_portal_name"
    t.text     "climate_policy_instrument"
    t.index ["model_id"], name: "index_scenarios_on_model_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "time_series_values", force: :cascade do |t|
    t.integer  "scenario_id"
    t.integer  "indicator_id"
    t.integer  "year"
    t.decimal  "value"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "location_id"
    t.text     "unit_of_entry"
    t.decimal  "conversion_factor"
    t.index ["indicator_id"], name: "index_time_series_values_on_indicator_id", using: :btree
    t.index ["location_id"], name: "index_time_series_values_on_location_id", using: :btree
    t.index ["scenario_id"], name: "index_time_series_values_on_scenario_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.text     "email",                  default: "",    null: false
    t.text     "name"
    t.boolean  "admin",                  default: false
    t.integer  "team_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",      default: 0
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["team_id"], name: "index_users_on_team_id", using: :btree
  end

  add_foreign_key "indicators", "indicators", column: "parent_id"
  add_foreign_key "indicators", "models"
  add_foreign_key "models", "teams"
  add_foreign_key "scenarios", "models"
  add_foreign_key "time_series_values", "indicators"
  add_foreign_key "time_series_values", "locations"
  add_foreign_key "time_series_values", "scenarios"
  add_foreign_key "users", "teams"
end
