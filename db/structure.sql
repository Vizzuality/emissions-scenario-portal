SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


--
-- Name: emissions_filter_by_year_range(jsonb, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.emissions_filter_by_year_range(emissions jsonb, start_year integer, end_year integer) RETURNS jsonb
    LANGUAGE sql IMMUTABLE
    AS $$

      SELECT TO_JSONB(ARRAY_AGG(e)) FROM (
        SELECT e FROM (
          SELECT JSONB_ARRAY_ELEMENTS(emissions) e
        ) expanded_emissions
        WHERE (start_year IS NULL OR (e->>'year')::int >= start_year) AND
          (end_year IS NULL OR (e->>'year')::int <= end_year)
      ) ee

      $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name text,
    parent_id bigint
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: csv_uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.csv_uploads (
    id integer NOT NULL,
    job_id text,
    user_id integer NOT NULL,
    model_id integer,
    service_type text NOT NULL,
    finished_at timestamp without time zone,
    success boolean,
    message text,
    errors_and_warnings jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying,
    data_content_type character varying,
    data_file_size integer,
    data_updated_at timestamp without time zone,
    number_of_records_saved integer DEFAULT 0
);


--
-- Name: csv_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.csv_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: csv_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.csv_uploads_id_seq OWNED BY public.csv_uploads.id;


--
-- Name: indicators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.indicators (
    id integer NOT NULL,
    name text,
    definition text,
    unit text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    composite_name text,
    subcategory_id bigint,
    time_series_values_count integer DEFAULT 0,
    stackable boolean DEFAULT false
);


--
-- Name: indicators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.indicators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: indicators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.indicators_id_seq OWNED BY public.indicators.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    name text NOT NULL,
    region boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    iso_code character varying
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.models (
    id integer NOT NULL,
    team_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    abbreviation text NOT NULL,
    full_name text NOT NULL,
    current_version text,
    programming_language text,
    maintainer_institute text,
    license text,
    expertise text,
    platform text,
    description text,
    key_usage text,
    sectoral_coverage text[] DEFAULT '{}'::text[],
    gas_and_pollutant_coverage text[] DEFAULT '{}'::text[],
    policy_coverage text[] DEFAULT '{}'::text[],
    technology_coverage text[] DEFAULT '{}'::text[],
    energy_resource_coverage text[] DEFAULT '{}'::text[],
    time_horizon text,
    time_step text,
    equilibrium_type text,
    population_assumptions text,
    gdp_assumptions text,
    other_assumptions text,
    base_year integer,
    input_data text,
    publications_and_notable_projects text,
    citation text,
    url text,
    point_of_contact text,
    concept text,
    solution_method text,
    anticipation text[] DEFAULT '{}'::text[],
    behaviour text,
    land_use text,
    scenario_coverage text[] DEFAULT '{}'::text[],
    geographic_coverage text[],
    technology_choice text,
    global_warming_potentials text,
    technology_constraints text,
    trade_restrictions text,
    solar_power_supply text,
    wind_power_supply text,
    bioenergy_supply text,
    co2_storage_supply text,
    logo_file_name character varying,
    logo_content_type character varying,
    logo_file_size integer,
    logo_updated_at timestamp without time zone
);


--
-- Name: models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.models_id_seq OWNED BY public.models.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    description text,
    unit_of_entry text,
    conversion_factor numeric DEFAULT 1,
    indicator_id bigint NOT NULL,
    model_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: scenarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scenarios (
    id integer NOT NULL,
    name text NOT NULL,
    model_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    model_abbreviation text,
    category text,
    description text,
    policy_coverage text[] DEFAULT '{}'::text[],
    technology_coverage text[] DEFAULT '{}'::text[],
    climate_target_type text,
    discount_rates text,
    reference text,
    purpose_or_objective text,
    climate_target text,
    other_target text,
    burden_sharing text,
    time_series_values_count integer DEFAULT 0,
    published boolean DEFAULT false NOT NULL,
    year character varying,
    url character varying,
    socioeconomics text
);


--
-- Name: scenarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scenarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scenarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scenarios_id_seq OWNED BY public.scenarios.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: time_series_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_series_values (
    id integer NOT NULL,
    scenario_id integer,
    indicator_id integer,
    year integer,
    value numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    location_id integer
);


--
-- Name: searchable_time_series_values; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.searchable_time_series_values AS
 SELECT row_number() OVER () AS id,
    locations.id AS location_id,
    locations.iso_code AS iso_code2,
    locations.name AS location,
    models.id AS model_id,
    models.full_name AS model,
    scenarios.id AS scenario_id,
    scenarios.name AS scenario,
    categories.id AS category_id,
    categories.name AS category,
    subcategories.id AS subcategory_id,
    subcategories.name AS subcategory,
    indicators.id AS indicator_id,
    indicators.name AS indicator,
    replace(indicators.composite_name, '|'::text, ' | '::text) AS composite_name,
    indicators.unit,
    indicators.definition,
    jsonb_agg(jsonb_build_object('year', time_series_values.year, 'value', round(time_series_values.value, 2))) AS emissions,
    jsonb_object_agg(time_series_values.year, round(time_series_values.value, 2)) AS emissions_dict
   FROM ((((((public.time_series_values
     JOIN public.locations ON ((locations.id = time_series_values.location_id)))
     JOIN public.scenarios ON ((scenarios.id = time_series_values.scenario_id)))
     JOIN public.models ON ((models.id = scenarios.model_id)))
     JOIN public.indicators ON ((indicators.id = time_series_values.indicator_id)))
     LEFT JOIN public.categories subcategories ON ((subcategories.id = indicators.subcategory_id)))
     LEFT JOIN public.categories ON ((categories.id = subcategories.parent_id)))
  GROUP BY locations.id, locations.iso_code, locations.name, models.id, models.full_name, scenarios.id, scenarios.name, categories.id, categories.name, subcategories.id, subcategories.name, indicators.id, indicators.name, (replace(indicators.composite_name, '|'::text, ' | '::text)), indicators.unit, indicators.definition
  ORDER BY locations.name
  WITH NO DATA;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: time_series_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.time_series_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: time_series_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.time_series_values_id_seq OWNED BY public.time_series_values.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email text DEFAULT ''::text NOT NULL,
    name text,
    admin boolean DEFAULT false,
    team_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_type character varying,
    invited_by_id integer,
    invitations_count integer DEFAULT 0
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: csv_uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csv_uploads ALTER COLUMN id SET DEFAULT nextval('public.csv_uploads_id_seq'::regclass);


--
-- Name: indicators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indicators ALTER COLUMN id SET DEFAULT nextval('public.indicators_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: models id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models ALTER COLUMN id SET DEFAULT nextval('public.models_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: scenarios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenarios ALTER COLUMN id SET DEFAULT nextval('public.scenarios_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: time_series_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_series_values ALTER COLUMN id SET DEFAULT nextval('public.time_series_values_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: csv_uploads csv_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csv_uploads
    ADD CONSTRAINT csv_uploads_pkey PRIMARY KEY (id);


--
-- Name: indicators indicators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indicators
    ADD CONSTRAINT indicators_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: models models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: scenarios scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT scenarios_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: time_series_values time_series_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_series_values
    ADD CONSTRAINT time_series_values_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_categories_on_name_and_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_name_and_parent_id ON public.categories USING btree (name, parent_id);


--
-- Name: index_categories_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_parent_id ON public.categories USING btree (parent_id);


--
-- Name: index_csv_uploads_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_csv_uploads_on_model_id ON public.csv_uploads USING btree (model_id);


--
-- Name: index_csv_uploads_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_csv_uploads_on_user_id ON public.csv_uploads USING btree (user_id);


--
-- Name: index_indicators_on_LOWER_composite_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_indicators_on_LOWER_composite_name" ON public.indicators USING btree (lower(composite_name));


--
-- Name: index_indicators_on_subcategory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_indicators_on_subcategory_id ON public.indicators USING btree (subcategory_id);


--
-- Name: index_indicators_on_subcategory_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_indicators_on_subcategory_id_and_name ON public.indicators USING btree (subcategory_id, name);


--
-- Name: index_locations_on_iso_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locations_on_iso_code ON public.locations USING btree (iso_code);


--
-- Name: index_locations_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locations_on_name ON public.locations USING btree (name);


--
-- Name: index_models_on_abbreviation; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_models_on_abbreviation ON public.models USING btree (abbreviation);


--
-- Name: index_models_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_models_on_team_id ON public.models USING btree (team_id);


--
-- Name: index_notes_on_indicator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_indicator_id ON public.notes USING btree (indicator_id);


--
-- Name: index_notes_on_indicator_id_and_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notes_on_indicator_id_and_model_id ON public.notes USING btree (indicator_id, model_id);


--
-- Name: index_notes_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_model_id ON public.notes USING btree (model_id);


--
-- Name: index_scenarios_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scenarios_on_model_id ON public.scenarios USING btree (model_id);


--
-- Name: index_searchable_time_series_values_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_searchable_time_series_values_on_category_id ON public.searchable_time_series_values USING btree (category_id);


--
-- Name: index_searchable_time_series_values_on_indicator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_searchable_time_series_values_on_indicator_id ON public.searchable_time_series_values USING btree (indicator_id);


--
-- Name: index_searchable_time_series_values_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_searchable_time_series_values_on_location_id ON public.searchable_time_series_values USING btree (location_id);


--
-- Name: index_searchable_time_series_values_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_searchable_time_series_values_on_model_id ON public.searchable_time_series_values USING btree (model_id);


--
-- Name: index_searchable_time_series_values_on_scenario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_searchable_time_series_values_on_scenario_id ON public.searchable_time_series_values USING btree (scenario_id);


--
-- Name: index_searchable_time_series_values_on_subcategory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_searchable_time_series_values_on_subcategory_id ON public.searchable_time_series_values USING btree (subcategory_id);


--
-- Name: index_time_series_values_on_indicator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_series_values_on_indicator_id ON public.time_series_values USING btree (indicator_id);


--
-- Name: index_time_series_values_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_series_values_on_location_id ON public.time_series_values USING btree (location_id);


--
-- Name: index_time_series_values_on_scenario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_series_values_on_scenario_id ON public.time_series_values USING btree (scenario_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON public.users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON public.users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON public.users USING btree (invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_team_id ON public.users USING btree (team_id);


--
-- Name: unique_index_time_series_values; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_index_time_series_values ON public.time_series_values USING btree (scenario_id, indicator_id, location_id, year);


--
-- Name: scenarios fk_rails_0f7c25edbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT fk_rails_0f7c25edbe FOREIGN KEY (model_id) REFERENCES public.models(id);


--
-- Name: csv_uploads fk_rails_2ceaf764ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csv_uploads
    ADD CONSTRAINT fk_rails_2ceaf764ed FOREIGN KEY (model_id) REFERENCES public.models(id) ON DELETE CASCADE;


--
-- Name: indicators fk_rails_38f8059621; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indicators
    ADD CONSTRAINT fk_rails_38f8059621 FOREIGN KEY (subcategory_id) REFERENCES public.categories(id);


--
-- Name: time_series_values fk_rails_4dc6a544a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_series_values
    ADD CONSTRAINT fk_rails_4dc6a544a2 FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: notes fk_rails_5164fc6460; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_5164fc6460 FOREIGN KEY (indicator_id) REFERENCES public.indicators(id);


--
-- Name: models fk_rails_51d606b843; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT fk_rails_51d606b843 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: notes fk_rails_6d5cb29ac1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_6d5cb29ac1 FOREIGN KEY (model_id) REFERENCES public.models(id);


--
-- Name: categories fk_rails_82f48f7407; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_rails_82f48f7407 FOREIGN KEY (parent_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: time_series_values fk_rails_835a3be234; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_series_values
    ADD CONSTRAINT fk_rails_835a3be234 FOREIGN KEY (indicator_id) REFERENCES public.indicators(id);


--
-- Name: users fk_rails_b2bbf87303; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_b2bbf87303 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: csv_uploads fk_rails_d1b8fa0c6f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csv_uploads
    ADD CONSTRAINT fk_rails_d1b8fa0c6f FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: time_series_values fk_rails_ec62aefc68; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_series_values
    ADD CONSTRAINT fk_rails_ec62aefc68 FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20170413120412'),
('20170413122057'),
('20170413125715'),
('20170413125811'),
('20170418105621'),
('20170418121003'),
('20170510110451'),
('20170515081107'),
('20170516094925'),
('20170516102241'),
('20170517104211'),
('20170517113111'),
('20170517113250'),
('20170519111124'),
('20170522115509'),
('20170525102655'),
('20170526121637'),
('20170531080924'),
('20170531094603'),
('20170531130049'),
('20170531131329'),
('20170602112554'),
('20170605090043'),
('20170606184056'),
('20170606200847'),
('20170606201909'),
('20170606202613'),
('20170606203840'),
('20170606210454'),
('20170606211856'),
('20170606212331'),
('20170606213228'),
('20170606213930'),
('20170606214411'),
('20170622093515'),
('20170622094456'),
('20170622094723'),
('20170622095056'),
('20170622095911'),
('20170622100838'),
('20170622101535'),
('20170622101634'),
('20170622101820'),
('20170622105248'),
('20170622105532'),
('20170622110438'),
('20170622112751'),
('20170623073453'),
('20170626094831'),
('20170703083250'),
('20170707123455'),
('20170710093733'),
('20170712131315'),
('20170713093230'),
('20170713095925'),
('20170721104917'),
('20170727140241'),
('20170728142419'),
('20170728144124'),
('20171113125155'),
('20171113125206'),
('20171115102106'),
('20171120094334'),
('20171120155547'),
('20171121122421'),
('20171122115611'),
('20171123120735'),
('20171124081031'),
('20171124081353'),
('20171124081722'),
('20171124083126'),
('20171124083731'),
('20171124084348'),
('20171124084629'),
('20171124084751'),
('20171127104927'),
('20171127105349'),
('20171127133148'),
('20171128124113'),
('20171207075438'),
('20171207080607'),
('20171213082751'),
('20171214111442'),
('20180116131950'),
('20180116141701'),
('20180125102252'),
('20180125112616'),
('20180129111200'),
('20180129131049'),
('20180205134212'),
('20180219102119'),
('20180219104539'),
('20180223182949'),
('20180305160903'),
('20180307085137'),
('20180410161015'),
('20181010120829'),
('20181010125231');


