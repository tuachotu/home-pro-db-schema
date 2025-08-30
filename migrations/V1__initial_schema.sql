--
-- PostgreSQL database dump
--

-- Dumped from database version 14.17 (Homebrew)
-- Dumped by pg_dump version 14.17 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: home_item_type; Type: TYPE; Schema: public; Owner: vikrantsingh
--

CREATE TYPE public.home_item_type AS ENUM (
    'room',
    'utility_control',
    'appliance',
    'structural',
    'observation',
    'wiring',
    'sensor',
    'other'
);



--
-- Name: enforce_single_photo_owner(); Type: FUNCTION; Schema: public; Owner: vikrantsingh
--

CREATE FUNCTION public.enforce_single_photo_owner() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (NEW.home_id IS NOT NULL)::int +
     (NEW.home_item_id IS NOT NULL)::int +
     (NEW.user_id IS NOT NULL)::int <> 1 THEN
    RAISE EXCEPTION 'Exactly one of home_id, home_item_id, or user_id must be set on photos';
  END IF;
  RETURN NEW;
END;
$$;



SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: home_items; Type: TABLE; Schema: public; Owner: vikrantsingh
--

CREATE TABLE public.home_items (
    id uuid NOT NULL,
    home_id uuid NOT NULL,
    name text NOT NULL,
    type public.home_item_type NOT NULL,
    is_emergency boolean DEFAULT false,
    data jsonb NOT NULL,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now()
);



--
-- Name: home_owners; Type: TABLE; Schema: public; Owner: vikrantsingh
--

CREATE TABLE public.home_owners (
    home_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text DEFAULT 'owner'::text,
    added_at timestamp without time zone DEFAULT now()
);



--
-- Name: homes; Type: TABLE; Schema: public; Owner: vikrantsingh
--

CREATE TABLE public.homes (
    id uuid NOT NULL,
    address text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_by uuid,
    name text,
    is_primary boolean DEFAULT false,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);



--
-- Name: photos; Type: TABLE; Schema: public; Owner: vikrantsingh
--

CREATE TABLE public.photos (
    id uuid NOT NULL,
    home_id uuid,
    home_item_id uuid,
    user_id uuid,
    s3_key text NOT NULL,
    file_name text,
    content_type text,
    caption text,
    is_primary boolean DEFAULT false,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now()
);



--
-- Name: roles; Type: TABLE; Schema: public; Owner: vikrantsingh
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);



--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: vikrantsingh
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vikrantsingh
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: support_requests; Type: TABLE; Schema: public; Owner: vikrantsingh
--

CREATE TABLE public.support_requests (
    id uuid NOT NULL,
    homeowner_id uuid NOT NULL,
    home_id uuid,
    title text NOT NULL,
    description text,
    status text DEFAULT 'open'::text NOT NULL,
    priority text DEFAULT 'medium'::text NOT NULL,
    assigned_expert_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_by uuid
);



--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: vikrantsingh
--

CREATE TABLE public.user_roles (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    role_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);



--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: vikrantsingh
--

CREATE SEQUENCE public.user_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vikrantsingh
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: vikrantsingh
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    firebase_uid character varying(128) NOT NULL,
    name character varying(500),
    email character varying(150),
    phone_number character varying(15),
    profile jsonb DEFAULT '{}'::jsonb,
    created_by character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_modified_by character varying(100),
    last_modified_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);



--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Name: home_items home_items_pkey; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.home_items
    ADD CONSTRAINT home_items_pkey PRIMARY KEY (id);


--
-- Name: home_owners home_owners_pkey; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.home_owners
    ADD CONSTRAINT home_owners_pkey PRIMARY KEY (home_id, user_id);


--
-- Name: homes homes_pkey; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.homes
    ADD CONSTRAINT homes_pkey PRIMARY KEY (id);


--
-- Name: photos photos_pkey; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: support_requests support_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.support_requests
    ADD CONSTRAINT support_requests_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_user_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_id_key UNIQUE (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_firebase_uid_key; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_firebase_uid_key UNIQUE (firebase_uid);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_active_users; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_active_users ON public.users USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_email; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_email ON public.users USING btree (email);


--
-- Name: idx_firebase_uid; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_firebase_uid ON public.users USING btree (firebase_uid);


--
-- Name: idx_phone_number; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_phone_number ON public.users USING btree (phone_number);


--
-- Name: idx_photos_home_id; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_photos_home_id ON public.photos USING btree (home_id);


--
-- Name: idx_photos_home_item_id; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_photos_home_item_id ON public.photos USING btree (home_item_id);


--
-- Name: idx_photos_is_primary; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_photos_is_primary ON public.photos USING btree (is_primary);


--
-- Name: idx_photos_user_id; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_photos_user_id ON public.photos USING btree (user_id);


--
-- Name: idx_roles_deleted_at; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_roles_deleted_at ON public.roles USING btree (deleted_at);


--
-- Name: idx_roles_name; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_roles_name ON public.roles USING btree (name);


--
-- Name: idx_user_roles_deleted_at; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_user_roles_deleted_at ON public.user_roles USING btree (deleted_at);


--
-- Name: idx_user_roles_role_id; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_user_roles_role_id ON public.user_roles USING btree (role_id);


--
-- Name: idx_user_roles_user_id; Type: INDEX; Schema: public; Owner: vikrantsingh
--

CREATE INDEX idx_user_roles_user_id ON public.user_roles USING btree (user_id);


--
-- Name: photos photos_single_owner_check; Type: TRIGGER; Schema: public; Owner: vikrantsingh
--

CREATE TRIGGER photos_single_owner_check BEFORE INSERT OR UPDATE ON public.photos FOR EACH ROW EXECUTE FUNCTION public.enforce_single_photo_owner();


--
-- Name: user_roles fk_user_roles_role; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_roles fk_user_roles_user; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: home_items home_items_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.home_items
    ADD CONSTRAINT home_items_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: home_items home_items_home_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.home_items
    ADD CONSTRAINT home_items_home_id_fkey FOREIGN KEY (home_id) REFERENCES public.homes(id) ON DELETE CASCADE;


--
-- Name: home_owners home_owners_home_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.home_owners
    ADD CONSTRAINT home_owners_home_id_fkey FOREIGN KEY (home_id) REFERENCES public.homes(id) ON DELETE CASCADE;


--
-- Name: home_owners home_owners_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.home_owners
    ADD CONSTRAINT home_owners_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: homes homes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.homes
    ADD CONSTRAINT homes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: homes homes_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.homes
    ADD CONSTRAINT homes_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: photos photos_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: photos photos_home_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_home_id_fkey FOREIGN KEY (home_id) REFERENCES public.homes(id) ON DELETE CASCADE;


--
-- Name: photos photos_home_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_home_item_id_fkey FOREIGN KEY (home_item_id) REFERENCES public.home_items(id) ON DELETE SET NULL;


--
-- Name: photos photos_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: support_requests support_requests_assigned_expert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.support_requests
    ADD CONSTRAINT support_requests_assigned_expert_id_fkey FOREIGN KEY (assigned_expert_id) REFERENCES public.users(id);


--
-- Name: support_requests support_requests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.support_requests
    ADD CONSTRAINT support_requests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: support_requests support_requests_home_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.support_requests
    ADD CONSTRAINT support_requests_home_id_fkey FOREIGN KEY (home_id) REFERENCES public.homes(id);


--
-- Name: support_requests support_requests_homeowner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.support_requests
    ADD CONSTRAINT support_requests_homeowner_id_fkey FOREIGN KEY (homeowner_id) REFERENCES public.users(id);


--
-- Name: support_requests support_requests_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vikrantsingh
--

ALTER TABLE ONLY public.support_requests
    ADD CONSTRAINT support_requests_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

