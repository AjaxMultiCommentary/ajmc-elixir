--
-- PostgreSQL database dump
--

-- Dumped from database version 14.8
-- Dumped by pg_dump version 14.8

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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


--
-- Name: project_user_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.project_user_type AS ENUM (
    'admin',
    'editor',
    'user'
);


--
-- Name: version_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.version_type AS ENUM (
    'commentary',
    'edition',
    'translation'
);


--
-- Name: normalize_greek(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.normalize_greek() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      new.normalized_text := regexp_replace(normalize(old.text, NFD), '[̀-ͯ]', '', 'g');
      RETURN new;
    END;
  $$;


--
-- Name: oban_jobs_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.oban_jobs_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  channel text;
  notice json;
BEGIN
  IF NEW.state = 'available' THEN
    channel = 'public.oban_insert';
    notice = json_build_object('queue', NEW.queue);

    PERFORM pg_notify(channel, notice::text);
  END IF;

  RETURN NULL;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id bigint NOT NULL,
    repository character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    urn jsonb NOT NULL
);


--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    attributes jsonb,
    content text NOT NULL,
    urn jsonb NOT NULL,
    text_node_id bigint,
    version_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: cover_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cover_images (
    id bigint NOT NULL,
    attribution_name character varying(255) NOT NULL,
    attribution_source character varying(255) NOT NULL,
    attribution_source_url character varying(255) NOT NULL,
    attribution_url character varying(255) NOT NULL,
    image_url character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: cover_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cover_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cover_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cover_images_id_seq OWNED BY public.cover_images.id;


--
-- Name: element_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.element_types (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: element_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.element_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: element_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.element_types_id_seq OWNED BY public.element_types.id;


--
-- Name: exemplar_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exemplar_pages (
    id bigint NOT NULL,
    page_number integer NOT NULL,
    end_location integer[] NOT NULL,
    exemplar_id bigint,
    start_location integer[] NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: exemplar_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exemplar_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exemplar_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exemplar_pages_id_seq OWNED BY public.exemplar_pages.id;


--
-- Name: exemplars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exemplars (
    id bigint NOT NULL,
    description text,
    filemd5hash character varying(255) NOT NULL,
    filename text NOT NULL,
    label character varying(255),
    language_id bigint NOT NULL,
    source text,
    source_link text,
    structure character varying(255),
    title text NOT NULL,
    urn text NOT NULL,
    version_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    tei_header jsonb DEFAULT '{}'::jsonb,
    parsed_at timestamp(0) without time zone
);


--
-- Name: exemplars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exemplars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exemplars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exemplars_id_seq OWNED BY public.exemplars.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.languages (
    id bigint NOT NULL,
    slug character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.languages_id_seq OWNED BY public.languages.id;


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags character varying(255)[] DEFAULT ARRAY[]::character varying[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT priority_range CHECK (((priority >= 0) AND (priority <= 3))),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.oban_jobs IS '11';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: project_cover_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_cover_images (
    id bigint NOT NULL,
    cover_image_id bigint,
    project_id bigint
);


--
-- Name: project_cover_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_cover_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_cover_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_cover_images_id_seq OWNED BY public.project_cover_images.id;


--
-- Name: project_exemplars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_exemplars (
    id bigint NOT NULL,
    exemplar_id bigint NOT NULL,
    project_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: project_exemplars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_exemplars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_exemplars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_exemplars_id_seq OWNED BY public.project_exemplars.id;


--
-- Name: project_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_users (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    project_user_type public.project_user_type NOT NULL
);


--
-- Name: project_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_users_id_seq OWNED BY public.project_users.id;


--
-- Name: project_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_versions (
    id bigint NOT NULL,
    project_id bigint,
    version_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: project_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_versions_id_seq OWNED BY public.project_versions.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    description text,
    domain character varying(255),
    public_at timestamp without time zone,
    title character varying(255) NOT NULL,
    created_by_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    homepage_copy text DEFAULT ''::text
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: refs_declarations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refs_declarations (
    id bigint NOT NULL,
    units character varying(255)[],
    delimiters character varying(255)[],
    match_patterns character varying(255)[],
    replacement_patterns character varying(255)[],
    raw text NOT NULL,
    xml_version_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: refs_declarations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refs_declarations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refs_declarations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refs_declarations_id_seq OWNED BY public.refs_declarations.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
    id bigint NOT NULL,
    url character varying(255),
    collection_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_id_seq OWNED BY public.repositories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: text_element_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.text_element_users (
    id bigint NOT NULL,
    text_element_id bigint,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: text_element_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.text_element_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_element_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.text_element_users_id_seq OWNED BY public.text_element_users.id;


--
-- Name: text_elements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.text_elements (
    id bigint NOT NULL,
    attributes jsonb,
    end_offset integer DEFAULT 0,
    start_offset integer DEFAULT 0,
    element_type_id bigint NOT NULL,
    end_text_node_id bigint NOT NULL,
    start_text_node_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    content text
);


--
-- Name: text_elements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.text_elements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_elements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.text_elements_id_seq OWNED BY public.text_elements.id;


--
-- Name: text_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.text_groups (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    collection_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    _search tsvector GENERATED ALWAYS AS (to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text)) STORED,
    urn jsonb NOT NULL
);


--
-- Name: text_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.text_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.text_groups_id_seq OWNED BY public.text_groups.id;


--
-- Name: text_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.text_nodes (
    id bigint NOT NULL,
    location integer[] NOT NULL,
    normalized_text text,
    text text NOT NULL,
    inserted_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    _search tsvector GENERATED ALWAYS AS (to_tsvector('english'::regconfig, "left"(text, (1024 * 1024)))) STORED,
    version_id bigint,
    urn jsonb
);


--
-- Name: text_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.text_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.text_nodes_id_seq OWNED BY public.text_nodes.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    hashed_password character varying(255) NOT NULL,
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
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
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: version_passages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_passages (
    id bigint NOT NULL,
    passage_number integer NOT NULL,
    end_location integer[] NOT NULL,
    start_location integer[] NOT NULL,
    version_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: version_passages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.version_passages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_passages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.version_passages_id_seq OWNED BY public.version_passages.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    description text,
    label text NOT NULL,
    work_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    version_type public.version_type NOT NULL,
    structure character varying(255)[],
    filemd5hash character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    language_id bigint,
    parsed_at timestamp(0) without time zone,
    source character varying(255),
    source_link character varying(255),
    tei_header jsonb DEFAULT '{}'::jsonb,
    urn jsonb
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: works; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.works (
    id bigint NOT NULL,
    description text,
    english_title text,
    original_title text,
    text_group_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    _search tsvector GENERATED ALWAYS AS (to_tsvector('english'::regconfig, ((COALESCE(english_title, ''::text) || ' '::text) || COALESCE(description, ''::text)))) STORED,
    urn jsonb NOT NULL
);


--
-- Name: works_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.works_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: works_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.works_id_seq OWNED BY public.works.id;


--
-- Name: xml_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.xml_versions (
    id bigint NOT NULL,
    xml_document xml NOT NULL,
    urn character varying(255) NOT NULL,
    version_type public.version_type NOT NULL,
    work_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: xml_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.xml_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: xml_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.xml_versions_id_seq OWNED BY public.xml_versions.id;


--
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: cover_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cover_images ALTER COLUMN id SET DEFAULT nextval('public.cover_images_id_seq'::regclass);


--
-- Name: element_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.element_types ALTER COLUMN id SET DEFAULT nextval('public.element_types_id_seq'::regclass);


--
-- Name: exemplar_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exemplar_pages ALTER COLUMN id SET DEFAULT nextval('public.exemplar_pages_id_seq'::regclass);


--
-- Name: exemplars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exemplars ALTER COLUMN id SET DEFAULT nextval('public.exemplars_id_seq'::regclass);


--
-- Name: languages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages ALTER COLUMN id SET DEFAULT nextval('public.languages_id_seq'::regclass);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: project_cover_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_cover_images ALTER COLUMN id SET DEFAULT nextval('public.project_cover_images_id_seq'::regclass);


--
-- Name: project_exemplars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_exemplars ALTER COLUMN id SET DEFAULT nextval('public.project_exemplars_id_seq'::regclass);


--
-- Name: project_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_users ALTER COLUMN id SET DEFAULT nextval('public.project_users_id_seq'::regclass);


--
-- Name: project_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_versions ALTER COLUMN id SET DEFAULT nextval('public.project_versions_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: refs_declarations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refs_declarations ALTER COLUMN id SET DEFAULT nextval('public.refs_declarations_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: text_element_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_element_users ALTER COLUMN id SET DEFAULT nextval('public.text_element_users_id_seq'::regclass);


--
-- Name: text_elements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_elements ALTER COLUMN id SET DEFAULT nextval('public.text_elements_id_seq'::regclass);


--
-- Name: text_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_groups ALTER COLUMN id SET DEFAULT nextval('public.text_groups_id_seq'::regclass);


--
-- Name: text_nodes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_nodes ALTER COLUMN id SET DEFAULT nextval('public.text_nodes_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Name: version_passages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_passages ALTER COLUMN id SET DEFAULT nextval('public.version_passages_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: works id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works ALTER COLUMN id SET DEFAULT nextval('public.works_id_seq'::regclass);


--
-- Name: xml_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xml_versions ALTER COLUMN id SET DEFAULT nextval('public.xml_versions_id_seq'::regclass);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: cover_images cover_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cover_images
    ADD CONSTRAINT cover_images_pkey PRIMARY KEY (id);


--
-- Name: element_types element_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.element_types
    ADD CONSTRAINT element_types_pkey PRIMARY KEY (id);


--
-- Name: exemplar_pages exemplar_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exemplar_pages
    ADD CONSTRAINT exemplar_pages_pkey PRIMARY KEY (id);


--
-- Name: exemplars exemplars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exemplars
    ADD CONSTRAINT exemplars_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: project_cover_images project_cover_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_cover_images
    ADD CONSTRAINT project_cover_images_pkey PRIMARY KEY (id);


--
-- Name: project_exemplars project_exemplars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_exemplars
    ADD CONSTRAINT project_exemplars_pkey PRIMARY KEY (id);


--
-- Name: project_users project_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_pkey PRIMARY KEY (id);


--
-- Name: project_versions project_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_versions
    ADD CONSTRAINT project_versions_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: refs_declarations refs_declarations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refs_declarations
    ADD CONSTRAINT refs_declarations_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: text_element_users text_element_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_element_users
    ADD CONSTRAINT text_element_users_pkey PRIMARY KEY (id);


--
-- Name: text_elements text_elements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_elements
    ADD CONSTRAINT text_elements_pkey PRIMARY KEY (id);


--
-- Name: text_groups text_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_groups
    ADD CONSTRAINT text_groups_pkey PRIMARY KEY (id);


--
-- Name: text_nodes text_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_nodes
    ADD CONSTRAINT text_nodes_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: version_passages version_passages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_passages
    ADD CONSTRAINT version_passages_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: works works_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT works_pkey PRIMARY KEY (id);


--
-- Name: xml_versions xml_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xml_versions
    ADD CONSTRAINT xml_versions_pkey PRIMARY KEY (id);


--
-- Name: collections_repository_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX collections_repository_index ON public.collections USING btree (repository);


--
-- Name: comments_text_node_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_text_node_id_index ON public.comments USING btree (text_node_id);


--
-- Name: comments_version_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_version_id_index ON public.comments USING btree (version_id);


--
-- Name: cover_images_attribution_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cover_images_attribution_url_index ON public.cover_images USING btree (attribution_url);


--
-- Name: cover_images_image_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cover_images_image_url_index ON public.cover_images USING btree (image_url);


--
-- Name: element_types_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX element_types_name_index ON public.element_types USING btree (name);


--
-- Name: exemplar_pages_exemplar_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exemplar_pages_exemplar_id_index ON public.exemplar_pages USING btree (exemplar_id);


--
-- Name: exemplar_pages_exemplar_id_page_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX exemplar_pages_exemplar_id_page_number_index ON public.exemplar_pages USING btree (exemplar_id, page_number);


--
-- Name: exemplars_filemd5hash_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX exemplars_filemd5hash_index ON public.exemplars USING btree (filemd5hash);


--
-- Name: exemplars_language_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exemplars_language_id_index ON public.exemplars USING btree (language_id);


--
-- Name: exemplars_urn_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX exemplars_urn_index ON public.exemplars USING btree (urn);


--
-- Name: exemplars_version_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX exemplars_version_id_index ON public.exemplars USING btree (version_id);


--
-- Name: languages_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX languages_slug_index ON public.languages USING btree (slug);


--
-- Name: languages_title_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX languages_title_index ON public.languages USING btree (title);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: projects_created_by_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_created_by_id_index ON public.projects USING btree (created_by_id);


--
-- Name: refs_declarations_xml_version_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX refs_declarations_xml_version_id_index ON public.refs_declarations USING btree (xml_version_id);


--
-- Name: repositories_collection_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX repositories_collection_id_index ON public.repositories USING btree (collection_id);


--
-- Name: repositories_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX repositories_url_index ON public.repositories USING btree (url);


--
-- Name: text_element_users_text_element_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX text_element_users_text_element_id_index ON public.text_element_users USING btree (text_element_id);


--
-- Name: text_element_users_text_element_id_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX text_element_users_text_element_id_user_id_index ON public.text_element_users USING btree (text_element_id, user_id);


--
-- Name: text_element_users_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX text_element_users_user_id_index ON public.text_element_users USING btree (user_id);


--
-- Name: text_elements_element_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX text_elements_element_type_id_index ON public.text_elements USING btree (element_type_id);


--
-- Name: text_elements_end_text_node_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX text_elements_end_text_node_id_index ON public.text_elements USING btree (end_text_node_id);


--
-- Name: text_elements_start_text_node_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX text_elements_start_text_node_id_index ON public.text_elements USING btree (start_text_node_id);


--
-- Name: text_groups__search_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX text_groups__search_index ON public.text_groups USING gin (_search);


--
-- Name: text_groups_collection_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX text_groups_collection_id_index ON public.text_groups USING btree (collection_id);


--
-- Name: text_nodes__search_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX text_nodes__search_index ON public.text_nodes USING gin (_search);


--
-- Name: text_nodes_version_id_location_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX text_nodes_version_id_location_index ON public.text_nodes USING btree (version_id, location);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: versions_urn_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX versions_urn_index ON public.versions USING btree (urn);


--
-- Name: versions_work_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_work_id_index ON public.versions USING btree (work_id);


--
-- Name: works__search_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX works__search_index ON public.works USING gin (_search);


--
-- Name: works_text_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX works_text_group_id_index ON public.works USING btree (text_group_id);


--
-- Name: xml_versions_urn_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX xml_versions_urn_index ON public.xml_versions USING btree (urn);


--
-- Name: xml_versions_work_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX xml_versions_work_id_index ON public.xml_versions USING btree (work_id);


--
-- Name: oban_jobs oban_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oban_notify AFTER INSERT ON public.oban_jobs FOR EACH ROW EXECUTE FUNCTION public.oban_jobs_notify();


--
-- Name: text_nodes text_node_normalized_text_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER text_node_normalized_text_trigger BEFORE INSERT OR UPDATE OF text ON public.text_nodes FOR EACH STATEMENT EXECUTE FUNCTION public.normalize_greek();


--
-- Name: comments comments_text_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_text_node_id_fkey FOREIGN KEY (text_node_id) REFERENCES public.text_nodes(id);


--
-- Name: comments comments_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.versions(id);


--
-- Name: exemplar_pages exemplar_pages_exemplar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exemplar_pages
    ADD CONSTRAINT exemplar_pages_exemplar_id_fkey FOREIGN KEY (exemplar_id) REFERENCES public.exemplars(id) ON DELETE CASCADE;


--
-- Name: exemplars exemplars_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exemplars
    ADD CONSTRAINT exemplars_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: exemplars exemplars_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exemplars
    ADD CONSTRAINT exemplars_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.versions(id) ON DELETE RESTRICT;


--
-- Name: project_cover_images project_cover_images_cover_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_cover_images
    ADD CONSTRAINT project_cover_images_cover_image_id_fkey FOREIGN KEY (cover_image_id) REFERENCES public.cover_images(id);


--
-- Name: project_cover_images project_cover_images_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_cover_images
    ADD CONSTRAINT project_cover_images_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_exemplars project_exemplars_exemplar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_exemplars
    ADD CONSTRAINT project_exemplars_exemplar_id_fkey FOREIGN KEY (exemplar_id) REFERENCES public.exemplars(id) ON DELETE CASCADE;


--
-- Name: project_exemplars project_exemplars_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_exemplars
    ADD CONSTRAINT project_exemplars_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_users project_users_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_users project_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: project_versions project_versions_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_versions
    ADD CONSTRAINT project_versions_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_versions project_versions_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_versions
    ADD CONSTRAINT project_versions_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.versions(id) ON DELETE CASCADE;


--
-- Name: projects projects_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: refs_declarations refs_declarations_xml_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refs_declarations
    ADD CONSTRAINT refs_declarations_xml_version_id_fkey FOREIGN KEY (xml_version_id) REFERENCES public.xml_versions(id);


--
-- Name: repositories repositories_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: text_element_users text_element_users_text_element_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_element_users
    ADD CONSTRAINT text_element_users_text_element_id_fkey FOREIGN KEY (text_element_id) REFERENCES public.text_elements(id) ON DELETE CASCADE;


--
-- Name: text_element_users text_element_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_element_users
    ADD CONSTRAINT text_element_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: text_elements text_elements_element_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_elements
    ADD CONSTRAINT text_elements_element_type_id_fkey FOREIGN KEY (element_type_id) REFERENCES public.element_types(id);


--
-- Name: text_elements text_elements_end_text_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_elements
    ADD CONSTRAINT text_elements_end_text_node_id_fkey FOREIGN KEY (end_text_node_id) REFERENCES public.text_nodes(id) ON DELETE CASCADE;


--
-- Name: text_elements text_elements_start_text_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_elements
    ADD CONSTRAINT text_elements_start_text_node_id_fkey FOREIGN KEY (start_text_node_id) REFERENCES public.text_nodes(id) ON DELETE CASCADE;


--
-- Name: text_groups text_groups_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_groups
    ADD CONSTRAINT text_groups_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: text_nodes text_nodes_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_nodes
    ADD CONSTRAINT text_nodes_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.versions(id) ON DELETE CASCADE;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: version_passages version_passages_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_passages
    ADD CONSTRAINT version_passages_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.versions(id) ON DELETE CASCADE;


--
-- Name: versions versions_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE;


--
-- Name: versions versions_work_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_work_id_fkey FOREIGN KEY (work_id) REFERENCES public.works(id);


--
-- Name: works works_text_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT works_text_group_id_fkey FOREIGN KEY (text_group_id) REFERENCES public.text_groups(id);


--
-- Name: xml_versions xml_versions_work_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xml_versions
    ADD CONSTRAINT xml_versions_work_id_fkey FOREIGN KEY (work_id) REFERENCES public.works(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20220528175111);
INSERT INTO public."schema_migrations" (version) VALUES (20220528175213);
INSERT INTO public."schema_migrations" (version) VALUES (20220528175417);
INSERT INTO public."schema_migrations" (version) VALUES (20220528175633);
INSERT INTO public."schema_migrations" (version) VALUES (20220528180000);
INSERT INTO public."schema_migrations" (version) VALUES (20220528181000);
INSERT INTO public."schema_migrations" (version) VALUES (20220528181942);
INSERT INTO public."schema_migrations" (version) VALUES (20220617161741);
INSERT INTO public."schema_migrations" (version) VALUES (20220617165221);
INSERT INTO public."schema_migrations" (version) VALUES (20220617165228);
INSERT INTO public."schema_migrations" (version) VALUES (20220717043631);
INSERT INTO public."schema_migrations" (version) VALUES (20220717045348);
INSERT INTO public."schema_migrations" (version) VALUES (20220728002759);
INSERT INTO public."schema_migrations" (version) VALUES (20220831141622);
INSERT INTO public."schema_migrations" (version) VALUES (20220902194513);
INSERT INTO public."schema_migrations" (version) VALUES (20220902200528);
INSERT INTO public."schema_migrations" (version) VALUES (20220910181524);
INSERT INTO public."schema_migrations" (version) VALUES (20220928192341);
INSERT INTO public."schema_migrations" (version) VALUES (20221023225419);
INSERT INTO public."schema_migrations" (version) VALUES (20221127171226);
INSERT INTO public."schema_migrations" (version) VALUES (20221212162536);
INSERT INTO public."schema_migrations" (version) VALUES (20221228215032);
INSERT INTO public."schema_migrations" (version) VALUES (20230104171704);
INSERT INTO public."schema_migrations" (version) VALUES (20230106210854);
INSERT INTO public."schema_migrations" (version) VALUES (20230106212114);
INSERT INTO public."schema_migrations" (version) VALUES (20230322174029);
INSERT INTO public."schema_migrations" (version) VALUES (20230517035359);
INSERT INTO public."schema_migrations" (version) VALUES (20230519185239);
INSERT INTO public."schema_migrations" (version) VALUES (20230725213301);
INSERT INTO public."schema_migrations" (version) VALUES (20230725230844);
INSERT INTO public."schema_migrations" (version) VALUES (20230726012549);
INSERT INTO public."schema_migrations" (version) VALUES (20230809212743);
INSERT INTO public."schema_migrations" (version) VALUES (20230810131910);
INSERT INTO public."schema_migrations" (version) VALUES (20230810134000);
INSERT INTO public."schema_migrations" (version) VALUES (20230810211846);
INSERT INTO public."schema_migrations" (version) VALUES (20230813191412);
INSERT INTO public."schema_migrations" (version) VALUES (20230813193427);
INSERT INTO public."schema_migrations" (version) VALUES (20230813205952);
INSERT INTO public."schema_migrations" (version) VALUES (20230813212143);
INSERT INTO public."schema_migrations" (version) VALUES (20230813235321);
INSERT INTO public."schema_migrations" (version) VALUES (20230814000356);
