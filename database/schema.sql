-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admin (
  user_id text NOT NULL,
  job_number text,
  CONSTRAINT admin_pkey PRIMARY KEY (user_id),
  CONSTRAINT admin_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id)
);
CREATE TABLE public.customer (
  user_id text NOT NULL,
  username text UNIQUE,
  CONSTRAINT customer_pkey PRIMARY KEY (user_id),
  CONSTRAINT customer_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id)
);
CREATE TABLE public.historical_station_metrics (
  metrics_id bigint NOT NULL DEFAULT nextval('historical_station_metrics_metrics_id_seq'::regclass),
  station_id text NOT NULL,
  city text,
  station_type text,
  area_m2 numeric,
  competitors_within_3km integer,
  nearby_services_density numeric,
  has_convenience_store boolean,
  has_cafe boolean,
  has_atm boolean,
  has_car_wash boolean,
  date date NOT NULL,
  year integer,
  month integer,
  day integer,
  time_slot text,
  is_weekend boolean,
  is_holiday boolean,
  pumps_total integer,
  pumps_working integer,
  staff_count integer,
  power_status text,
  generator_available boolean,
  pos_uptime_pct numeric,
  network_uptime_pct numeric,
  downtime_minutes integer,
  incidents_reported integer,
  event_type text,
  event_severity integer,
  event_duration_minutes integer,
  is_shutdown boolean,
  shutdown_type text,
  shutdown_reason text,
  transactions integer,
  fuel_volume_91 numeric,
  fuel_volume_95 numeric,
  fuel_volume_diesel numeric,
  fuel_volume numeric,
  total_sales numeric,
  avg_ticket_value numeric,
  fuel_type text,
  traffic_index numeric,
  queue_time_avg numeric,
  complaints_count integer,
  complaint_type text,
  avg_rating numeric,
  inventory_stockout integer,
  inventory_days_of_cover numeric,
  actual_inventory_usage numeric,
  day_of_week integer,
  customer_flow_index numeric,
  performance_score numeric,
  CONSTRAINT historical_station_metrics_pkey PRIMARY KEY (metrics_id),
  CONSTRAINT historical_station_metrics_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.station(station_id)
);
CREATE TABLE public.loyalty_account (
  account_id text NOT NULL,
  current_points integer DEFAULT 0,
  user_id text UNIQUE,
  CONSTRAINT loyalty_account_pkey PRIMARY KEY (account_id),
  CONSTRAINT loyalty_account_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id)
);
CREATE TABLE public.loyalty_program (
  program_id text NOT NULL,
  type text NOT NULL,
  description text,
  CONSTRAINT loyalty_program_pkey PRIMARY KEY (program_id)
);
CREATE TABLE public.membership (
  membership_id text NOT NULL,
  status text,
  started_at timestamp without time zone,
  ended_at timestamp without time zone,
  tier text,
  program_id text,
  account_id text,
  user_id text,
  CONSTRAINT membership_pkey PRIMARY KEY (membership_id),
  CONSTRAINT membership_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.loyalty_program(program_id),
  CONSTRAINT membership_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id),
  CONSTRAINT membership_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.loyalty_account(account_id)
);
CREATE TABLE public.offer (
  offer_id text NOT NULL,
  offer_type text,
  earn_points integer DEFAULT 0,
  redeem_points integer DEFAULT 0,
  user_id text,
  earn_qr_code text UNIQUE,
  redeem_qr_code text UNIQUE,
  min_tier text DEFAULT 'Bronze'::text,
  category text,
  status text DEFAULT 'Active'::text,
  name text,
  is_used boolean DEFAULT false,
  CONSTRAINT offer_pkey PRIMARY KEY (offer_id),
  CONSTRAINT offer_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id)
);
CREATE TABLE public.report (
  report_id text NOT NULL,
  station_id text,
  model_name text,
  summary text,
  metric text,
  detail text,
  recommendation text,
  generation_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT report_pkey PRIMARY KEY (report_id),
  CONSTRAINT report_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.station(station_id)
);
CREATE TABLE public.station (
  station_id text NOT NULL,
  station_name text NOT NULL,
  side_code text UNIQUE,
  city text,
  street text,
  address text,
  status text,
  latitude double precision,
  longitude double precision,
  CONSTRAINT station_pkey PRIMARY KEY (station_id)
);
CREATE TABLE public.transactions (
  transaction_id text NOT NULL,
  date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  amount numeric,
  points integer DEFAULT 0,
  type text,
  offer_id text,
  station_id text,
  account_id text,
  CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id),
  CONSTRAINT transactions_offer_id_fkey FOREIGN KEY (offer_id) REFERENCES public.offer(offer_id),
  CONSTRAINT transactions_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.station(station_id),
  CONSTRAINT transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.loyalty_account(account_id)
);
CREATE TABLE public.users (
  user_id text NOT NULL,
  email text NOT NULL UNIQUE,
  fname text NOT NULL,
  lname text NOT NULL,
  phone text,
  password text NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (user_id)
);