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

ActiveRecord::Schema.define(version: 20180116131950) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "categories", force: :cascade do |t|
    t.text "name"
    t.boolean "stackable"
    t.bigint "parent_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "csv_uploads", id: :serial, force: :cascade do |t|
    t.text "job_id"
    t.integer "user_id", null: false
    t.integer "model_id"
    t.text "service_type", null: false
    t.datetime "finished_at"
    t.boolean "success"
    t.text "message"
    t.jsonb "errors_and_warnings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "data_file_name"
    t.string "data_content_type"
    t.integer "data_file_size"
    t.datetime "data_updated_at"
    t.index ["model_id"], name: "index_csv_uploads_on_model_id"
    t.index ["user_id"], name: "index_csv_uploads_on_user_id"
  end

  create_table "indicators", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "definition"
    t.text "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "composite_name"
    t.bigint "subcategory_id"
    t.integer "time_series_values_count", default: 0
    t.index "lower(composite_name)", name: "index_indicators_on_LOWER_composite_name", unique: true
    t.index ["subcategory_id"], name: "index_indicators_on_subcategory_id"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.boolean "region", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "iso_code"
    t.index ["iso_code"], name: "index_locations_on_iso_code", unique: true
    t.index ["name"], name: "index_locations_on_name", unique: true
  end

  create_table "models", id: :serial, force: :cascade do |t|
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "abbreviation", null: false
    t.text "full_name", null: false
    t.text "current_version"
    t.integer "development_year"
    t.text "programming_language"
    t.text "maintainer_name"
    t.text "license"
    t.text "availability"
    t.text "expertise"
    t.text "expertise_detailed"
    t.text "platform_detailed"
    t.text "purpose_or_objective"
    t.text "description"
    t.text "key_usage"
    t.text "scenario_coverage_detailed"
    t.text "geographic_coverage"
    t.text "geographic_coverage_country", default: [], array: true
    t.text "sectoral_coverage", default: [], array: true
    t.text "gas_and_pollutant_coverage", default: [], array: true
    t.text "policy_coverage", default: [], array: true
    t.text "technology_coverage", default: [], array: true
    t.text "technology_coverage_detailed"
    t.text "energy_resource_coverage", default: [], array: true
    t.text "time_horizon"
    t.text "time_step"
    t.text "equilibrium_type"
    t.text "spatial_resolution"
    t.text "population_assumptions"
    t.text "gdp_assumptions"
    t.text "other_assumptions"
    t.integer "base_year"
    t.text "input_data"
    t.text "publications_and_notable_projects"
    t.text "citation"
    t.text "url"
    t.text "point_of_contact"
    t.text "parent_model"
    t.text "descendent_models"
    t.text "concept"
    t.text "solution_method"
    t.text "anticipation", default: [], array: true
    t.text "policy_coverage_detailed"
    t.text "behaviour"
    t.text "land_use"
    t.text "scenario_coverage", default: [], array: true
    t.index ["abbreviation"], name: "index_models_on_abbreviation", unique: true
    t.index ["team_id"], name: "index_models_on_team_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "description"
    t.text "unit_of_entry"
    t.decimal "conversion_factor"
    t.bigint "indicator_id", null: false
    t.bigint "model_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["indicator_id", "model_id"], name: "index_notes_on_indicator_id_and_model_id", unique: true
    t.index ["indicator_id"], name: "index_notes_on_indicator_id"
    t.index ["model_id"], name: "index_notes_on_model_id"
  end

  create_table "scenarios", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.integer "model_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "model_abbreviation"
    t.text "category"
    t.text "description"
    t.text "geographic_coverage_country", default: [], array: true
    t.text "sectoral_coverage", default: [], array: true
    t.text "gas_and_pollutant_coverage", default: [], array: true
    t.text "policy_coverage", default: [], array: true
    t.text "policy_coverage_detailed"
    t.text "technology_coverage", default: [], array: true
    t.text "technology_coverage_detailed"
    t.text "energy_resource_coverage", default: [], array: true
    t.text "time_horizon"
    t.text "time_step"
    t.text "climate_target_type"
    t.text "large_scale_bioccs"
    t.text "technology_assumptions"
    t.text "gdp_assumptions"
    t.text "population_assumptions"
    t.text "discount_rates"
    t.text "emission_factors"
    t.text "global_warming_potentials"
    t.text "policy_cut_off_year_for_baseline"
    t.text "literature_reference"
    t.text "purpose_or_objective"
    t.text "key_usage"
    t.text "project"
    t.text "climate_target_detailed"
    t.text "climate_target_date"
    t.text "overshoot"
    t.text "other_target_type"
    t.text "other_target"
    t.text "burden_sharing"
    t.integer "time_series_values_count", default: 0
    t.boolean "published", default: false, null: false
    t.index ["model_id"], name: "index_scenarios_on_model_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "time_series_values", id: :serial, force: :cascade do |t|
    t.integer "scenario_id"
    t.integer "indicator_id"
    t.integer "year"
    t.decimal "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
    t.index ["indicator_id"], name: "index_time_series_values_on_indicator_id"
    t.index ["location_id"], name: "index_time_series_values_on_location_id"
    t.index ["scenario_id"], name: "index_time_series_values_on_scenario_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.text "email", default: "", null: false
    t.text "name"
    t.boolean "admin", default: false
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  add_foreign_key "categories", "categories", column: "parent_id", on_delete: :cascade
  add_foreign_key "csv_uploads", "models", on_delete: :cascade
  add_foreign_key "csv_uploads", "users", on_delete: :cascade
  add_foreign_key "indicators", "categories", column: "subcategory_id"
  add_foreign_key "models", "teams"
  add_foreign_key "notes", "indicators"
  add_foreign_key "notes", "models"
  add_foreign_key "scenarios", "models"
  add_foreign_key "time_series_values", "indicators"
  add_foreign_key "time_series_values", "locations"
  add_foreign_key "time_series_values", "scenarios"
  add_foreign_key "users", "teams"
end
