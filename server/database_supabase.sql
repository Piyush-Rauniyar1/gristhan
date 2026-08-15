--
-- PostgreSQL database dump
--


-- Dumped from database version 15.14 (Homebrew)
-- Dumped by pg_dump version 15.14 (Homebrew)

SELECT pg_catalog.set_config('search_path', '', false);

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: piyushrauniyar
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;



--
-- Name: update_bookings_updated_at(); Type: FUNCTION; Schema: public; Owner: piyushrauniyar
--

CREATE FUNCTION public.update_bookings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;



--
-- Name: update_listings_updated_at(); Type: FUNCTION; Schema: public; Owner: piyushrauniyar
--

CREATE FUNCTION public.update_listings_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;





--
-- Name: admin_password_resets; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.admin_password_resets (
    admin_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: admins; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.admins (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    password_hash text NOT NULL,
    role character varying(50) DEFAULT 'admin'::character varying,
    is_active boolean DEFAULT true,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT admins_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'super_admin'::character varying])::text[])))
);



--
-- Name: amenities; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.amenities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    icon_name character varying(100),
    category character varying(100)
);



--
-- Name: bookings; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.bookings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    guest_id uuid NOT NULL,
    listing_id uuid NOT NULL,
    check_in date NOT NULL,
    check_out date NOT NULL,
    num_guests integer DEFAULT 1 NOT NULL,
    price_per_night numeric(10,2) NOT NULL,
    nights integer NOT NULL,
    total_price numeric(10,2) NOT NULL,
    status character varying(50) DEFAULT 'PENDING'::character varying,
    cancellation_reason text,
    cancelled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    host_id uuid,
    price_breakdown jsonb,
    payment_status character varying(50) DEFAULT 'unpaid'::character varying,
    booking_type character varying(50) DEFAULT 'request'::character varying,
    special_requests text,
    CONSTRAINT bookings_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying, 'REJECTED'::character varying, 'CANCELLED'::character varying, 'COMPLETED'::character varying])::text[])))
);



--
-- Name: calendar_blocks; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.calendar_blocks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    listing_id uuid NOT NULL,
    block_date date NOT NULL,
    reason character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: cohosts; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.cohosts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    listing_id uuid NOT NULL,
    cohost_id uuid NOT NULL,
    permissions jsonb DEFAULT '{"can_approve": false, "can_message": true}'::jsonb,
    payout_percentage numeric(5,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: conversations; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    guest_id uuid NOT NULL,
    host_id uuid,
    listing_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    admin_id uuid
);



--
-- Name: disputes; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.disputes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    raised_by uuid NOT NULL,
    reason text NOT NULL,
    status character varying(50) DEFAULT 'OPEN'::character varying,
    resolution_notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: email_verifications; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.email_verifications (
    user_id uuid NOT NULL,
    otp_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: fee_config; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.fee_config (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    model_type character varying(50) DEFAULT 'SPLIT_FEE'::character varying,
    guest_fee_percentage numeric(5,2) DEFAULT 14.00,
    host_fee_percentage numeric(5,2) DEFAULT 3.00,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: host_bank_details; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.host_bank_details (
    host_id uuid NOT NULL,
    account_number character varying(255),
    routing_number character varying(255),
    bank_name character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: host_kyc; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.host_kyc (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid NOT NULL,
    doc_type character varying(50) NOT NULL,
    front_url text NOT NULL,
    back_url text NOT NULL,
    status character varying(50) DEFAULT 'PENDING'::character varying,
    rejection_reason text,
    submission_count integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT host_kyc_doc_type_check CHECK (((doc_type)::text = ANY ((ARRAY['national_id'::character varying, 'passport'::character varying, 'citizenship'::character varying])::text[]))),
    CONSTRAINT host_kyc_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying])::text[])))
);



--
-- Name: kyc_documents; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.kyc_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    document_url text NOT NULL,
    status character varying(50) DEFAULT 'PENDING'::character varying,
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    type character varying(50) DEFAULT 'PERSONAL'::character varying,
    listing_id uuid,
    host_id uuid,
    rejection_reason text,
    ownership_type character varying(255),
    ward_number character varying(50),
    municipality character varying(255),
    province character varying(255),
    district character varying(255),
    property_reg_number character varying(255),
    documents jsonb DEFAULT '{}'::jsonb,
    reviewed_by uuid,
    reviewed_at timestamp with time zone,
    estimated_review_by timestamp with time zone,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT kyc_documents_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'RESUBMITTED'::character varying, 'NOT_SUBMITTED'::character varying, 'under_review'::character varying])::text[])))
);



--
-- Name: listings; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.listings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid NOT NULL,
    title character varying(255),
    description text,
    category character varying(100),
    status character varying(50) DEFAULT 'DRAFT'::character varying,
    address jsonb,
    floor_plan jsonb,
    amenities jsonb DEFAULT '[]'::jsonb,
    photos jsonb DEFAULT '[]'::jsonb,
    price_per_night numeric(10,2),
    minimum_night_stay integer DEFAULT 1,
    maximum_night_stay integer,
    instant_book_enabled boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    published_at timestamp with time zone,
    cleaning_fee numeric(10,2) DEFAULT 0,
    latitude numeric(10,8),
    longitude numeric(11,8),
    lat numeric(10,6),
    lon numeric(10,6),
    average_rating numeric(3,2) DEFAULT 0,
    total_reviews integer DEFAULT 0,
    CONSTRAINT listings_status_check CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'PUBLISHED'::character varying])::text[])))
);



--
-- Name: message_templates; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.message_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: messages; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid NOT NULL,
    sender_id uuid,
    content text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    sender_admin_id uuid
);



--
-- Name: notifications; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    type character varying(50),
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.password_resets (
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: payments; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    user_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    currency character varying(10) DEFAULT 'USD'::character varying,
    provider character varying(50) DEFAULT 'STRIPE'::character varying,
    status character varying(50) DEFAULT 'INITIALIZED'::character varying,
    transaction_ref character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    stripe_payment_intent_id character varying(255),
    amount_npr integer DEFAULT 0,
    amount_usd_cents integer DEFAULT 0,
    gateway character varying(50) DEFAULT 'stripe'::character varying,
    khalti_pidx character varying(255)
);



--
-- Name: payouts; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.payouts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    status character varying(50) DEFAULT 'REQUESTED'::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: promotions; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.promotions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    listing_id uuid NOT NULL,
    code character varying(50),
    discount_percentage numeric(5,2),
    valid_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: properties; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    host_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    property_type character varying(100) NOT NULL,
    city character varying(100) NOT NULL,
    country character varying(100) NOT NULL,
    address text NOT NULL,
    latitude numeric(9,6),
    longitude numeric(9,6),
    price_per_night integer NOT NULL,
    bedrooms integer DEFAULT 1 NOT NULL,
    bathrooms integer DEFAULT 1 NOT NULL,
    max_guests integer DEFAULT 1 NOT NULL,
    amenities text,
    min_nights integer DEFAULT 1 NOT NULL,
    available boolean DEFAULT true NOT NULL,
    rating numeric(3,2),
    review_count integer DEFAULT 0 NOT NULL,
    cloudinary_public_id character varying(255),
    thumbnail_url text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT properties_bathrooms_check CHECK ((bathrooms >= 0)),
    CONSTRAINT properties_bedrooms_check CHECK ((bedrooms >= 0)),
    CONSTRAINT properties_max_guests_check CHECK ((max_guests > 0)),
    CONSTRAINT properties_min_nights_check CHECK ((min_nights > 0)),
    CONSTRAINT properties_price_per_night_check CHECK ((price_per_night > 0)),
    CONSTRAINT properties_rating_check CHECK (((rating >= (0)::numeric) AND (rating <= (5)::numeric)))
);



--
-- Name: property_amenities; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.property_amenities (
    property_id uuid NOT NULL,
    amenity_id uuid NOT NULL
);



--
-- Name: property_images; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.property_images (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    property_id uuid NOT NULL,
    cloudinary_public_id character varying(255),
    image_url text NOT NULL,
    thumbnail_url text,
    is_primary boolean DEFAULT false NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);



--
-- Name: property_verifications; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.property_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    listing_id uuid NOT NULL,
    ownership_type character varying(50) NOT NULL,
    ownership_certificate_url text NOT NULL,
    citizenship_front_url text NOT NULL,
    citizenship_back_url text NOT NULL,
    authorization_letter_url text,
    ward_number character varying(50) NOT NULL,
    municipality character varying(100) NOT NULL,
    province character varying(100) NOT NULL,
    district character varying(100) NOT NULL,
    property_reg_number character varying(100) NOT NULL,
    status character varying(50) DEFAULT 'PENDING'::character varying,
    rejection_reason text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT property_verifications_ownership_type_check CHECK (((ownership_type)::text = ANY ((ARRAY['owner'::character varying, 'agent'::character varying, 'company'::character varying])::text[]))),
    CONSTRAINT property_verifications_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying])::text[])))
);



--
-- Name: reviews; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    property_id uuid NOT NULL,
    reviewer_id uuid NOT NULL,
    rating integer NOT NULL,
    comment text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);



--
-- Name: tax_rules; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.tax_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    region character varying(255) NOT NULL,
    rate_percentage numeric(5,2) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: users; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    avatar_url text,
    phone character varying(50),
    is_superhost boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    is_host boolean DEFAULT false NOT NULL,
    verification_document text,
    fcm_token character varying(255),
    bio text,
    preferred_currency character varying(10) DEFAULT 'NPR'::character varying,
    kyc_status character varying(50) DEFAULT 'NOT_SUBMITTED'::character varying
);



--
-- Name: wishlist_items; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.wishlist_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    wishlist_id uuid NOT NULL,
    listing_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: wishlists; Type: TABLE; Schema: public; Owner: piyushrauniyar
--

CREATE TABLE public.wishlists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Data for Name: admin_password_resets; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.admins (id, email, full_name, password_hash, role, is_active, last_login_at, created_at, updated_at) VALUES ('1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', 'admin@grihastha.com', 'Platform Admin', '$2a$10$uISZvY0lqyse8gTdHaaBHeo0iumEJ.HVELAgP8VBooUkhPIH9.4AG', 'admin', TRUE, '2026-05-25 20:30:54.02164+05:45', '2026-04-25 22:00:35.734847+05:45', '2026-04-25 22:00:35.734847+05:45');


--
-- Data for Name: amenities; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('e70b704b-6380-4031-b947-90a162c6bb8e', '51e17920-40ba-4be7-aa59-b053d32aaca0', '08e4693b-9ab6-4ff5-9e88-c0beab04b236', '2026-06-16', '2026-06-18', 1, 3200.00, 2, 7955.00, 'PENDING', NULL, NULL, '2026-05-15 17:53:57.70982+05:45', '2026-05-15 17:53:57.70982+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 915, "total": 7955, "base_price": 6400, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 640}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('e9113a4b-58b7-4a90-bed8-0689102e7998', '51e17920-40ba-4be7-aa59-b053d32aaca0', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-05-28', '2026-05-30', 1, 4000.00, 2, 9944.00, 'CANCELLED', NULL, NULL, '2026-05-14 10:00:49.052986+05:45', '2026-05-14 11:42:06.280492+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 1144, "total": 9944, "base_price": 8000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 800}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('f6fd6812-430c-4e36-9d41-874a94b8fd25', '51e17920-40ba-4be7-aa59-b053d32aaca0', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-06-30', '2026-07-04', 1, 4000.00, 4, 19888.00, 'CONFIRMED', NULL, NULL, '2026-05-14 11:37:07.316484+05:45', '2026-05-14 12:09:06.625426+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 2288, "total": 19888, "base_price": 16000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 1600}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('443d304f-cbe0-47e6-8701-f087e5454187', '51e17920-40ba-4be7-aa59-b053d32aaca0', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-05-30', '2026-05-31', 1, 4000.00, 1, 4972.00, 'PENDING', NULL, NULL, '2026-05-14 19:17:06.413306+05:45', '2026-05-14 19:17:06.413306+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 572, "total": 4972, "base_price": 4000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 400}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('4d91b3a6-e75f-4598-91b4-4f8cc26de920', '51e17920-40ba-4be7-aa59-b053d32aaca0', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-05-22', '2026-05-27', 1, 4000.00, 5, 24860.00, 'PENDING', NULL, NULL, '2026-05-14 19:18:23.713687+05:45', '2026-05-14 19:18:23.713687+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 2860, "total": 24860, "base_price": 20000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 2000}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('3036e929-db6f-4988-ab92-dd499b2e4995', '51e17920-40ba-4be7-aa59-b053d32aaca0', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-09-22', '2026-09-26', 1, 4000.00, 4, 19888.00, 'PENDING', NULL, NULL, '2026-05-14 19:28:18.589435+05:45', '2026-05-14 19:28:18.589435+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 2288, "total": 19888, "base_price": 16000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 1600}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('895afeca-4760-4e90-b93a-c726ca478ace', '51e17920-40ba-4be7-aa59-b053d32aaca0', '19accd99-2d75-49a3-a56b-60c5b8b12adc', '2026-05-21', '2026-05-24', 1, 8000.00, 3, 29832.00, 'PENDING', NULL, NULL, '2026-05-14 19:30:03.168576+05:45', '2026-05-14 19:30:03.168576+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 3432, "total": 29832, "base_price": 24000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 2400}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('f770ed5e-3fa4-4b80-bb3d-d06e57b6029a', '51e17920-40ba-4be7-aa59-b053d32aaca0', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-06-24', '2026-06-30', 2, 4000.00, 6, 29832.00, 'CONFIRMED', NULL, NULL, '2026-05-14 19:37:15.084764+05:45', '2026-05-14 19:38:05.154099+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 3432, "total": 29832, "base_price": 24000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 2400}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('747342b3-4096-4e0f-8c80-e545e0b881f3', '19db48df-4aa7-4062-a049-4be5ff99fb9c', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-05-29', '2026-05-30', 1, 4000.00, 1, 4972.00, 'PENDING', NULL, NULL, '2026-05-15 13:19:44.293842+05:45', '2026-05-15 13:19:44.293842+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 572, "total": 4972, "base_price": 4000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 400}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('d2a5bdc1-03f5-4850-821f-595bfab9e985', '19db48df-4aa7-4062-a049-4be5ff99fb9c', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-08-18', '2026-08-27', 1, 4000.00, 9, 44748.00, 'PENDING', NULL, NULL, '2026-05-15 13:20:41.331596+05:45', '2026-05-15 13:20:41.331596+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 5148, "total": 44748, "base_price": 36000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 3600}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('ee8f9070-4ade-4887-9d1e-71b042b0ea41', '51e17920-40ba-4be7-aa59-b053d32aaca0', '08e4693b-9ab6-4ff5-9e88-c0beab04b236', '2026-05-28', '2026-05-31', 1, 3200.00, 3, 11933.00, 'PENDING', NULL, NULL, '2026-05-15 17:38:00.603121+05:45', '2026-05-15 17:38:00.603121+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 1373, "total": 11933, "base_price": 9600, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 960}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('cfb68c5e-dbba-419f-b6a1-c6bfc62a5960', '51e17920-40ba-4be7-aa59-b053d32aaca0', '08e4693b-9ab6-4ff5-9e88-c0beab04b236', '2026-05-21', '2026-05-22', 1, 3200.00, 1, 3978.00, 'PENDING', NULL, NULL, '2026-05-15 17:50:32.20827+05:45', '2026-05-15 17:50:32.20827+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 458, "total": 3978, "base_price": 3200, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 320}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('b9c10fef-db56-4df5-bb26-3aa628413da9', '51e17920-40ba-4be7-aa59-b053d32aaca0', '08e4693b-9ab6-4ff5-9e88-c0beab04b236', '2026-05-27', '2026-05-28', 1, 3200.00, 1, 3978.00, 'PENDING', NULL, NULL, '2026-05-15 17:55:23.139204+05:45', '2026-05-15 17:55:23.139204+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 458, "total": 3978, "base_price": 3200, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 320}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('b7c2a9a2-5682-4dd5-8a86-963a98a62e31', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'b9ab79cc-dd24-47a5-b5d2-4ff73f645cd1', '2026-05-21', '2026-05-22', 1, 2888.00, 1, 3590.00, 'PENDING', NULL, NULL, '2026-05-15 17:58:34.305446+05:45', '2026-05-15 17:58:34.305446+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 413, "total": 3590, "base_price": 2888, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 289}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('884553d2-379b-4a2d-a716-d74bd79589a6', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'b9ab79cc-dd24-47a5-b5d2-4ff73f645cd1', '2026-05-30', '2026-05-31', 1, 2888.00, 1, 3590.00, 'PENDING', NULL, NULL, '2026-05-15 20:57:00.990007+05:45', '2026-05-15 20:57:00.990007+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 413, "total": 3590, "base_price": 2888, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 289}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('a793c3f1-9c18-4d15-b91b-9b9a407cff87', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'b9ab79cc-dd24-47a5-b5d2-4ff73f645cd1', '2026-05-19', '2026-05-21', 1, 2888.00, 2, 7180.00, 'PENDING', NULL, NULL, '2026-05-16 11:51:32.290723+05:45', '2026-05-16 11:51:32.290723+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 826, "total": 7180, "base_price": 5776, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 578}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('e7791f8b-976f-44eb-8673-f04eebed0225', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'b9ab79cc-dd24-47a5-b5d2-4ff73f645cd1', '2026-05-28', '2026-05-30', 1, 2888.00, 2, 7180.00, 'PENDING', NULL, NULL, '2026-05-16 12:02:33.936318+05:45', '2026-05-16 12:02:33.936318+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 826, "total": 7180, "base_price": 5776, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 578}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('07d1e9ca-a2c8-4871-93c0-e2d2ab02881a', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'b9ab79cc-dd24-47a5-b5d2-4ff73f645cd1', '2026-08-30', '2026-08-31', 1, 2888.00, 1, 3590.00, 'PENDING', NULL, NULL, '2026-05-16 13:23:04.440696+05:45', '2026-05-16 13:23:04.440696+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 413, "total": 3590, "base_price": 2888, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 289}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('66c921c1-4d33-4dfb-8191-030a1a332312', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'b9ab79cc-dd24-47a5-b5d2-4ff73f645cd1', '2027-03-10', '2027-03-12', 1, 2888.00, 2, 7180.00, 'PENDING', NULL, NULL, '2026-05-17 14:14:00.091942+05:45', '2026-05-17 14:14:00.091942+05:45', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '{"tax": 826, "total": 7180, "base_price": 5776, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 578}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('57fae878-e842-43f0-ba90-0edf930f8ec3', '51e17920-40ba-4be7-aa59-b053d32aaca0', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2027-02-23', '2027-02-27', 1, 4000.00, 4, 19888.00, 'PENDING', NULL, NULL, '2026-05-18 09:02:21.241407+05:45', '2026-05-18 09:02:21.241407+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 2288, "total": 19888, "base_price": 16000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 1600}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('7383643a-97f7-4483-a6e0-1d52ffaeb288', '51e17920-40ba-4be7-aa59-b053d32aaca0', '19accd99-2d75-49a3-a56b-60c5b8b12adc', '2026-08-26', '2026-08-29', 1, 8000.00, 3, 29832.00, 'PENDING', NULL, NULL, '2026-05-18 11:22:08.426474+05:45', '2026-05-18 11:22:08.426474+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 3432, "total": 29832, "base_price": 24000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 2400}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('27a099f2-589e-4056-9ea2-f0d6254dd1c1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'e8d34ddf-f02a-4de3-a650-7974ba172686', '2026-05-30', '2026-05-31', 1, 2000.00, 1, 2486.00, 'CONFIRMED', NULL, NULL, '2026-05-21 21:30:00.953275+05:45', '2026-05-22 08:49:58.941257+05:45', '322cf49c-33ed-4d71-89e8-dc82efe91854', '{"tax": 286, "total": 2486, "base_price": 2000, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 200}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('5a3ac506-04ec-474f-90fb-bb94c0d64a83', '51e17920-40ba-4be7-aa59-b053d32aaca0', '0e093318-3b42-45b5-9a60-1efca79ce10e', '2026-05-26', '2026-05-30', 1, 4999.00, 4, 24855.00, 'CONFIRMED', NULL, NULL, '2026-05-22 10:21:06.344697+05:45', '2026-05-22 10:21:34.316875+05:45', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', '{"tax": 2859, "total": 24855, "base_price": 19996, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 2000}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('25fdeed4-df1f-4f3a-b0ba-04efb92dd550', '51e17920-40ba-4be7-aa59-b053d32aaca0', '0e093318-3b42-45b5-9a60-1efca79ce10e', '2026-09-29', '2026-09-30', 1, 4999.00, 1, 6214.00, 'PENDING', NULL, NULL, '2026-05-23 19:52:15.571355+05:45', '2026-05-23 19:52:15.571355+05:45', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', '{"tax": 715, "total": 6214, "base_price": 4999, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 500}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('bb01d4c9-df97-4ca2-8f04-a0e0d172a9ec', '51e17920-40ba-4be7-aa59-b053d32aaca0', '0e093318-3b42-45b5-9a60-1efca79ce10e', '2027-04-28', '2027-04-30', 1, 4999.00, 2, 12428.00, 'PENDING', NULL, NULL, '2026-05-23 19:53:25.455364+05:45', '2026-05-23 19:53:25.455364+05:45', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', '{"tax": 1430, "total": 12428, "base_price": 9998, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 1000}', 'unpaid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('c6779bbb-2bba-4e9d-bf84-d742f223c6d9', '51e17920-40ba-4be7-aa59-b053d32aaca0', '774d63aa-c3da-4a87-9c1b-af4f1978137e', '2026-05-30', '2026-05-31', 3, 6999.00, 1, 8700.00, 'COMPLETED', NULL, NULL, '2026-05-22 12:42:59.99926+05:45', '2026-05-24 00:45:25.640409+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 1001, "total": 8700, "base_price": 6999, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 700}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('2a17bfd7-86c0-4283-94a4-511fce3278b0', '51e17920-40ba-4be7-aa59-b053d32aaca0', '774d63aa-c3da-4a87-9c1b-af4f1978137e', '2026-05-24', '2026-05-25', 1, 6999.00, 1, 8700.00, 'COMPLETED', NULL, NULL, '2026-05-23 22:33:52.703608+05:45', '2026-05-24 00:45:25.640409+05:45', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '{"tax": 1001, "total": 8700, "base_price": 6999, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 700}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('06755fce-c9f3-4280-947e-59d3a2ae9890', '51e17920-40ba-4be7-aa59-b053d32aaca0', '9d56b127-d2ae-4ed1-91f9-e43ad953ae27', '2026-05-25', '2026-05-27', 2, 4997.00, 2, 12422.00, 'CONFIRMED', NULL, NULL, '2026-05-24 01:41:25.758743+05:45', '2026-05-24 01:42:45.119396+05:45', '6d675123-04cc-4267-a356-4e9bd384b04a', '{"tax": 1429, "total": 12422, "base_price": 9994, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 999}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('5b6abc48-c2b4-4cb5-bd29-efed4c4a61e0', '51e17920-40ba-4be7-aa59-b053d32aaca0', '74f0d8c5-2692-4a5c-a51c-ce71db7d76ed', '2026-05-25', '2026-05-27', 1, 7996.00, 2, 19878.00, 'CONFIRMED', NULL, NULL, '2026-05-24 11:41:39.655845+05:45', '2026-05-24 11:42:10.65473+05:45', '4bcf4e3a-f721-4816-a053-045843bbb68f', '{"tax": 2287, "total": 19878, "base_price": 15992, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 1599}', 'paid', 'request', NULL);
INSERT INTO public.bookings (id, guest_id, listing_id, check_in, check_out, num_guests, price_per_night, nights, total_price, status, cancellation_reason, cancelled_at, created_at, updated_at, host_id, price_breakdown, payment_status, booking_type, special_requests) VALUES ('a5febac9-68ae-437b-840c-74f826875726', '6f9fe2cd-14a3-40a1-9685-77572be3b6bc', '74f0d8c5-2692-4a5c-a51c-ce71db7d76ed', '2026-05-28', '2026-05-30', 1, 7996.00, 2, 19878.00, 'CONFIRMED', NULL, NULL, '2026-05-25 20:15:07.73202+05:45', '2026-05-25 20:18:37.708151+05:45', '4bcf4e3a-f721-4816-a053-045843bbb68f', '{"tax": 2287, "total": 19878, "base_price": 15992, "cleaning_fee": 0, "discount_applied": 0, "platform_service_fee": 1599}', 'paid', 'request', NULL);


--
-- Data for Name: calendar_blocks; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: cohosts; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('dc8220b9-3df8-457e-853d-94d28daeffd8', '51e17920-40ba-4be7-aa59-b053d32aaca0', NULL, NULL, '2026-05-13 01:24:57.327801+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('9dccd57a-143b-4ade-8993-8e32c6ee7b81', '51e17920-40ba-4be7-aa59-b053d32aaca0', '495763ef-3ea6-4540-9bf2-6258d0706f3b', NULL, '2026-04-25 00:59:40.373577+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '7bc35e04-d9c5-4771-a08f-65ff5874c299', '2026-05-14 11:38:52.036718+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('0542273a-04dc-4c04-b2e7-1cab5e4a3d41', '495763ef-3ea6-4540-9bf2-6258d0706f3b', NULL, NULL, '2026-05-14 12:57:58.060616+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('90feecd0-3771-4fae-bdf5-aa773718d5e1', '51e17920-40ba-4be7-aa59-b053d32aaca0', '322cf49c-33ed-4d71-89e8-dc82efe91854', 'e8d34ddf-f02a-4de3-a650-7974ba172686', '2026-05-21 21:31:10.268172+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('97256cfa-d538-41f5-b018-377f8eaac5ca', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'b7d47f46-66ae-444a-9d2a-96d1078372b7', NULL, '2026-05-15 18:03:11.417624+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('35ee084b-a720-44dd-846e-d100bff7f3d1', '51e17920-40ba-4be7-aa59-b053d32aaca0', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', '0e093318-3b42-45b5-9a60-1efca79ce10e', '2026-05-22 10:21:46.493487+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('8cf9c307-33bc-4122-9cbd-97b97eb13be4', '51e17920-40ba-4be7-aa59-b053d32aaca0', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '774d63aa-c3da-4a87-9c1b-af4f1978137e', '2026-05-22 12:43:49.758785+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('a17f2412-c84d-4d58-bc0f-fb5466392132', '51e17920-40ba-4be7-aa59-b053d32aaca0', '6d675123-04cc-4267-a356-4e9bd384b04a', '9d56b127-d2ae-4ed1-91f9-e43ad953ae27', '2026-05-24 01:43:24.10212+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('4a0b0415-ef51-4fa7-abef-90da453e9c25', '51e17920-40ba-4be7-aa59-b053d32aaca0', '4bcf4e3a-f721-4816-a053-045843bbb68f', '74f0d8c5-2692-4a5c-a51c-ce71db7d76ed', '2026-05-24 11:44:08.928988+05:45', NULL);
INSERT INTO public.conversations (id, guest_id, host_id, listing_id, created_at, admin_id) VALUES ('c9686488-6909-48fe-b2af-60133cc4c8c1', '6f9fe2cd-14a3-40a1-9685-77572be3b6bc', '4bcf4e3a-f721-4816-a053-045843bbb68f', '74f0d8c5-2692-4a5c-a51c-ce71db7d76ed', '2026-05-25 20:20:40.778993+05:45', NULL);


--
-- Data for Name: disputes; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: email_verifications; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('44e679a8-5258-473a-b814-ed353106a16e', '3a798f0994abab0248498fadbfbae093aabf541ffdee057dca44b69120f687fd', '2026-03-27 11:42:02.395+05:45', '2026-03-27 11:27:02.396015+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('6346a42b-c3c1-40df-a564-32e51c576e38', '358f74ce36156327775615a1b20051f9569963c19e38a9944bd794b1a46c731b', '2026-03-28 09:31:52.281+05:45', '2026-03-28 09:16:52.28155+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('88251106-5ccb-4d5b-9e09-e9954add3acc', 'f7c9fe2e83575194ea14eafc67d6495db86fb81d27c51532eb559f536dbcfec0', '2026-03-28 09:35:06.447+05:45', '2026-03-28 09:20:06.447913+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('fd1fd990-8b17-452b-af13-d46b93674379', '1c1e8c3e852489cd1bde02365de77f4b39622d923860dd71996bc080622aca0e', '2026-03-28 09:39:00.017+05:45', '2026-03-28 09:24:00.018095+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('ccebccbd-fb82-4b0a-91d7-fcc0a76fe7c1', '2c6749ece189df69b11e8427b059133d91fe5365179533f81e8cfaea6741570e', '2026-03-28 09:39:39.508+05:45', '2026-03-28 09:24:39.508251+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('9300ba4e-5a75-4db7-92c3-32b7bc01f004', 'ee847280cf8ffeae40e8a99ac230d3f9b203346d8864c87134fad60908c8c796', '2026-03-28 09:39:57.301+05:45', '2026-03-28 09:24:57.301704+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('dcd53311-471c-42dd-b837-f9e40bf3808f', '68d5f580a27d644e69597542268b9d83fd455f5e1761bbb23cfebc56f9596b5a', '2026-03-28 09:45:40.441+05:45', '2026-03-28 09:30:40.441505+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('54db095f-faa3-4944-a1e5-e134b66aecfa', '61c0db27cc4c5b56331a0e528330a4a75b9dc00a26248dd597799c06d9a4d3dc', '2026-03-28 23:39:15.016+05:45', '2026-03-28 23:24:15.01649+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('cc99450f-1a2a-4e6b-977b-7d8a2d1ef07a', 'c481eeb3eae76ea52939691795b344c0675f6cd2177df2791436c9fdd185850b', '2026-03-28 23:40:40.2+05:45', '2026-03-28 23:25:40.200508+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('0177407e-316a-4fc3-9bda-9ce607986aac', 'ca01abc86a89ef395cde6758fc8be386fbba09c0ac7e0cf890adb642da7735c3', '2026-03-28 23:44:03.361+05:45', '2026-03-28 23:29:03.361738+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('151e1edb-5755-4a46-a01b-67305076fccf', '02c3c7cabae654d71c31a7275a9ba9136553aaabaaeba0d275553e020ea6e705', '2026-03-29 13:38:33.599+05:45', '2026-03-29 13:23:33.600152+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('1710d4d4-62a1-41a6-9ff9-0e9758fbebbc', 'c8d1badc510a230ffeaa654fedfeca924d10ac50a074eb17535ffc0f024d303d', '2026-03-29 20:05:46.55+05:45', '2026-03-29 19:50:46.550836+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('d29ecd03-c510-430a-b77e-d966d57d78cb', 'b3d5e6c6079c74205f0964255c3da86f7273a0d4df8d24edfa1152ab390a0b4e', '2026-04-07 10:32:47.362+05:45', '2026-04-07 10:17:47.362454+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('10ba51fa-8939-4933-8fc0-2293ec04a19a', '3ba2fb8686ec5809087e37b02afa82a931194856a954e1bc18c51ab6a091a32d', '2026-04-17 14:33:43.86+05:45', '2026-04-17 14:18:43.860988+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('ca08a722-1ed8-42d0-8831-1bb5fb997373', 'a84d66166fa69fdc621b9b4d92f3f87ab118b46e1016f4a7f0c4cd49953a83f9', '2026-04-17 14:36:07.38+05:45', '2026-04-17 14:21:07.380586+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('e03ffdd3-8803-4ff6-812c-d81cd8c86724', 'b1275d56b3e926d0fceedd9e93ccb058ae865f121762aae4327c8f1e1a4ed04d', '2026-04-17 14:37:20.991+05:45', '2026-04-17 14:22:20.991518+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('d5e767eb-7c5c-4be1-bf2c-7cfe34778d41', '00f5b7d30d50bbee79f99f88e8814f06817c7bb7bacfc9582912182549b857c9', '2026-04-17 14:39:47.265+05:45', '2026-04-17 14:24:47.266038+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('495763ef-3ea6-4540-9bf2-6258d0706f3b', 'e879dc56f670ce1d3b172064203d8685e84ea4032ccaa31487badf4ba026aa30', '2026-04-18 00:39:51.028+05:45', '2026-04-18 00:24:51.029854+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('1b97f51e-164d-41ab-bc04-9fa00fee777f', '197b179d7207e650812b30d1d7163c05fd43e600023f6081eeea94869861f55f', '2026-04-18 19:59:39.347+05:45', '2026-04-18 19:44:39.347232+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('c2714386-f4b3-4108-badf-f955923d9f4e', '3d9d1fb0d71626112fe2f7ac16653fabc0160fbd15d9f9ef04a6664b4b71f216', '2026-05-14 22:11:35.832+05:45', '2026-05-14 21:56:35.832544+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('20bbbfe8-76ad-470b-b55c-7409b09aee9e', 'fa7a7ed1114595b4e42d3c27c1a137e1cc85b9b238a3947eb1a3350622cfebcc', '2026-05-14 22:15:33.182+05:45', '2026-05-14 22:00:33.182808+05:45');
INSERT INTO public.email_verifications (user_id, otp_hash, expires_at, created_at) VALUES ('f41196bb-ecb0-4209-b856-8b6a03ac55ae', '9b4dba4d7fa14af6e5e44e8fac42b7e08004ece344a1b7df6200840cc16160e2', '2026-05-14 22:46:07.224+05:45', '2026-05-14 22:31:07.224369+05:45');


--
-- Data for Name: fee_config; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: host_bank_details; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: host_kyc; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: kyc_documents; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('5d19a8c0-5823-48f5-8bcd-91f0cfa9522d', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', '', 'APPROVED', 'Account Verification', '2026-05-22 10:15:41.032658+05:45', 'PERSONAL', NULL, '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', NULL, 'national_id', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779424240/kyc_documents/fa1rlebu9zqnzmzfum3x.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-22 10:16:06.492881+05:45', '2026-05-25 10:15:41.032658+05:45', '2026-05-22 10:15:41.032658+05:45');
INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('a2ff5061-9cbe-4798-a2c4-0edb24c7a56c', '36ecf3c3-7a77-4ed1-ac67-a908a019e09a', '', 'APPROVED', 'Account Verification', '2026-05-23 22:02:08.188266+05:45', 'PERSONAL', NULL, '36ecf3c3-7a77-4ed1-ac67-a908a019e09a', NULL, 'passport', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779553027/kyc_documents/grxwvagk75rifhg9v5c0.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-23 22:04:17.77177+05:45', '2026-05-26 22:02:08.188266+05:45', '2026-05-23 22:02:08.188266+05:45');
INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('fc6ae3a0-3390-4d55-9a50-53030d892f1a', '495763ef-3ea6-4540-9bf2-6258d0706f3b', '', 'APPROVED', 'Account Verification', '2026-05-13 22:22:40.420422+05:45', 'PERSONAL', NULL, '495763ef-3ea6-4540-9bf2-6258d0706f3b', NULL, 'national_id', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778690259/kyc_documents/lwva5kvytmknjkg8xsg1.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-13 22:22:54.007357+05:45', '2026-05-16 22:22:40.420422+05:45', '2026-05-13 22:22:40.420422+05:45');
INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('e8d06272-f6d0-46d5-aa7d-6572eb0b2bb1', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', '', 'APPROVED', 'Account Verification', '2026-05-15 00:16:50.788296+05:45', 'PERSONAL', NULL, '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', NULL, 'national_id', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778783509/kyc_documents/dldfsjee1ksnguyl2sqr.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-15 00:18:28.257363+05:45', '2026-05-18 00:16:50.788296+05:45', '2026-05-15 00:16:50.788296+05:45');
INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('54da67d8-c1dc-4f96-8a7d-f5b9bffea954', 'b7d47f46-66ae-444a-9d2a-96d1078372b7', '', 'APPROVED', 'Account Verification', '2026-05-15 17:04:46.569022+05:45', 'PERSONAL', NULL, 'b7d47f46-66ae-444a-9d2a-96d1078372b7', NULL, 'passport', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778843985/kyc_documents/fdkbq2dvimjj9panihz8.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-15 17:05:10.395253+05:45', '2026-05-18 17:04:46.569022+05:45', '2026-05-15 17:04:46.569022+05:45');
INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('93942eed-7830-4523-9113-aa61795b4176', '322cf49c-33ed-4d71-89e8-dc82efe91854', '', 'APPROVED', 'Account Verification', '2026-05-21 21:23:18.043053+05:45', 'PERSONAL', NULL, '322cf49c-33ed-4d71-89e8-dc82efe91854', NULL, 'national_id', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779377897/kyc_documents/x90wtp0zibs3farzy5ol.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-21 21:23:58.488414+05:45', '2026-05-24 21:23:18.043053+05:45', '2026-05-21 21:23:18.043053+05:45');
INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('ed3aefc5-adab-4071-8484-73f596087734', '6d675123-04cc-4267-a356-4e9bd384b04a', '', 'APPROVED', 'Account Verification', '2026-05-24 01:34:55.38172+05:45', 'PERSONAL', NULL, '6d675123-04cc-4267-a356-4e9bd384b04a', NULL, 'national_id', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779565794/kyc_documents/tziwqjdvxgfijbgbxood.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-24 01:36:09.953594+05:45', '2026-05-27 01:34:55.38172+05:45', '2026-05-24 01:34:55.38172+05:45');
INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('69c1a676-1d8f-42da-a6f3-22451f1aa6ee', '4bcf4e3a-f721-4816-a053-045843bbb68f', '', 'APPROVED', 'Account Verification', '2026-05-24 11:34:07.39017+05:45', 'PERSONAL', NULL, '4bcf4e3a-f721-4816-a053-045843bbb68f', NULL, 'national_id', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779601746/kyc_documents/qglrq1a9lrsrhvswz9fh.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-24 11:34:57.823998+05:45', '2026-05-27 11:34:07.39017+05:45', '2026-05-24 11:34:07.39017+05:45');
INSERT INTO public.kyc_documents (id, user_id, document_url, status, notes, created_at, type, listing_id, host_id, rejection_reason, ownership_type, ward_number, municipality, province, district, property_reg_number, documents, reviewed_by, reviewed_at, estimated_review_by, updated_at) VALUES ('3387ccb5-3cf7-480e-bce7-de7b095214b8', '27d9d921-46b2-4ee3-901e-31765e9f3dc1', '', 'APPROVED', 'Account Verification', '2026-05-25 20:47:01.193696+05:45', 'PERSONAL', NULL, '27d9d921-46b2-4ee3-901e-31765e9f3dc1', NULL, 'national_id', NULL, NULL, NULL, NULL, NULL, '{"front": {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779721320/kyc_documents/x5omsy1uiqpisfdr9ysc.jpg", "status": "submitted"}}', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b', '2026-05-25 20:47:49.945983+05:45', '2026-05-28 20:47:01.193696+05:45', '2026-05-25 20:47:01.193696+05:45');


--
-- Data for Name: listings; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('e8d34ddf-f02a-4de3-a650-7974ba172686', '322cf49c-33ed-4d71-89e8-dc82efe91854', 'apart in shree aantu', 'njsaNFJKBDSAFXJABDSBXFJKDWNSFJK', NULL, 'PUBLISHED', '{"city": "Biratnagar", "street": "biratnagar", "district": "Morang", "latitude": "26.4623007", "zip_code": "56613", "longitude": "87.2816170", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779378195/grihastha/media/iy71yiydmuxk59bsmdap.webp"}', '{"guests": 5, "bedrooms": 5, "bathrooms": 1}', '["WiFi", "Gym", "Parking", "Balcony", "Garden", "Kitchen", "Hot Water", "Washing Machine"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779378145/grihastha/media/irfiuys6klkw93qplqfn.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779378146/grihastha/media/bo0tar4xujhl4f82mkmn.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779378147/grihastha/media/vabyy5gppdjadxck4aem.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779378149/grihastha/media/hgerobcduvdxu6cvygnd.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779378150/grihastha/media/fodvbpamlu5eioozw0o1.webp"}]', 2000.00, 1, NULL, FALSE, '2026-05-21 21:28:16.160256+05:45', '2026-05-21 21:28:46.452728+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('19accd99-2d75-49a3-a56b-60c5b8b12adc', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'sun city apart', 'dsafncqklwdnfklnwked', 'entire_place', 'PUBLISHED', '{"apt": "sun city apartment", "lat": 27.7166578, "lng": 85.3127015, "city": "kathmandu", "street": "Thamel, Kathmandu-26, Kathmandu Metropolitan City, Kathmandu, Bagamati Province, 25511, Nepal", "province": "Bagmati", "postal_code": "25511"}', '{"beds": 2, "guests": 3, "bedrooms": 2, "bathrooms": 2}', '["wifi", "washer", "kitchen", "air_conditioning", "dryer", "gym", "pool", "workspace", "fire_pit", "fire_extinguisher", "smoke_detector"]', '[]', 8000.00, 1, NULL, FALSE, '2026-04-25 02:02:07.499767+05:45', '2026-05-13 22:42:10.793147+05:45', NULL, 0.00, 27.71665780, 85.31270150, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('0e093318-3b42-45b5-9a60-1efca79ce10e', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', 'Langtang Mountain View Lodge', 'Description\nBeautiful mountain-view apartment located in the peaceful Langtang region near Kyanjin Gompa. The property offers comfortable furnished rooms, free WiFi, hot water, traditional Nepali meals, and stunning Himalayan scenery. Ideal for trekkers, tourists, photographers, and nature lovers seeking a relaxing stay close to Langtang National Park and trekking routes.', NULL, 'PUBLISHED', '{"city": "Kyanjin Gompa", "street": "Kyanjin Gompa", "district": "Rasuwa", "latitude": "28.2123867", "zip_code": "", "longitude": "85.5665851", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779424466/grihastha/media/j5cysyo656pxi9ly0bkd.webp"}', '{"guests": 2, "bedrooms": 1, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Parking", "Kitchen", "Washing Machine", "TV"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779424417/grihastha/media/eqz7axxmgnsteun3wy7v.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779424419/grihastha/media/bxycw3txfx1fp7e2eoai.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779424420/grihastha/media/dpt5bwieufrnsf10nd2z.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779424422/grihastha/media/my7vjxh8uckwwkhbb17q.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779424423/grihastha/media/whibxddr8pzixza6bpnj.webp"}]', 4999.00, 1, NULL, FALSE, '2026-05-22 10:19:27.316536+05:45', '2026-05-22 10:19:50.605444+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('774d63aa-c3da-4a87-9c1b-af4f1978137e', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'Himalayan Retreat — Bandipur Heritage ', 'this is a very good property in kathmadu', NULL, 'PUBLISHED', '{"city": "Kathmandu Metropolitan City", "street": "basantapur  kathmandu ", "district": "Kathmandu", "latitude": "27.7042916", "zip_code": "", "longitude": "85.3065551", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779432903/grihastha/media/z3e0n7bfzvbl9am2pxhl.webp"}', '{"guests": 5, "bedrooms": 3, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Parking", "Kitchen", "Washing Machine", "TV", "Pool", "Gym", "Garden"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779432862/grihastha/media/rltozc4jlghpdggsesub.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779432863/grihastha/media/prcucogcv1zpmlncpact.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779432864/grihastha/media/rrvcjusrtkgrihgyruch.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779432867/grihastha/media/xtsusg1bsawvzyicvwwg.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779432868/grihastha/media/ktuatka5lxlwluym0kbz.webp"}]', 6999.00, 1, NULL, FALSE, '2026-05-22 12:40:07.700413+05:45', '2026-05-22 12:40:51.422733+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('a41df638-dfc0-4fba-8390-3727e58034fd', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'e mfd,qlramgdfmekqd', 'd fv,lwef,d.gmvwefasd;glfme;lfdv', 'entire_place', 'PUBLISHED', '{"apt": "ksadks", "lat": 27.7166578, "lng": 85.3127015, "city": "kathmandu", "street": "Thamel, Kathmandu-26, Kathmandu Metropolitan City, Kathmandu, Bagamati Province, 25511, Nepal", "province": "Bagmati", "postal_code": "25511"}', '{"beds": 2, "guests": 2, "bedrooms": 2, "bathrooms": 2}', '["wifi", "kitchen", "air_conditioning", "heating", "washer", "dryer", "pool", "gym", "fire_pit", "hot_tub", "workspace", "first_aid_kit", "fire_extinguisher", "smoke_detector", "co_detector"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1777062197/grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/fsglecwmxruqzrjjd2k2.webp", "width": 612, "height": 408, "publicId": "grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/fsglecwmxruqzrjjd2k2"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1777062196/grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/rpjlppebxickm3125hve.webp", "width": 275, "height": 183, "publicId": "grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/rpjlppebxickm3125hve"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1777062196/grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/xuo317jw1fwhh99pfnwy.webp", "width": 275, "height": 183, "publicId": "grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/xuo317jw1fwhh99pfnwy"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1777062196/grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/tnmd7rfoh3lrdkdlv39d.webp", "width": 276, "height": 183, "publicId": "grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/tnmd7rfoh3lrdkdlv39d"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1777062197/grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/jtwjldvmvw5gr1vcmspe.webp", "width": 2000, "height": 2800, "publicId": "grihastha/listings/a41df638-dfc0-4fba-8390-3727e58034fd/jtwjldvmvw5gr1vcmspe"}]', 1000.00, 1, NULL, FALSE, '2026-04-25 02:06:54.605322+05:45', '2026-04-25 02:11:41.181766+05:45', '2026-04-25 02:08:22.123167+05:45', 0.00, 27.71665780, 85.31270150, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('9d56b127-d2ae-4ed1-91f9-e43ad953ae27', '6d675123-04cc-4267-a356-4e9bd384b04a', 'Snow Peak Guest House', 'very good property with a pool and mountain view', NULL, 'PUBLISHED', '{"city": "Lantang", "street": "lantang", "district": "Zijin County", "latitude": "23.4162293", "zip_code": "", "longitude": "114.9290435", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779566080/grihastha/media/vjutollecw4hnkyhbxqm.webp"}', '{"guests": 2, "bedrooms": 1, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Parking", "Kitchen", "Washing Machine", "TV", "Pool", "Gym", "Garden", "Balcony"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779566042/grihastha/media/nmjkiczpvffugczpzbmp.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779566044/grihastha/media/lorxint5hl8vzrc2spng.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779566046/grihastha/media/uud62c82itg3yysggr6i.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779566048/grihastha/media/on6aoufktvwo8iyp6sfv.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779566049/grihastha/media/wmpozdu0oduashfaqk1i.webp"}]', 4997.00, 1, NULL, FALSE, '2026-05-24 01:39:41.595462+05:45', '2026-05-24 01:40:10.91886+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('74f0d8c5-2692-4a5c-a51c-ce71db7d76ed', '4bcf4e3a-f721-4816-a053-045843bbb68f', 'Langtang Mountain View Lodge', 'Beautiful mountain-view apartment located in the peaceful Langtang region near Kyanjin Gompa. The property offers comfortable furnished rooms, free WiFi, hot water, traditional Nepali meals, and stunning Himalayan scenery. Ideal for trekkers, tourists, photographers, and nature lovers seeking a relaxing stay close to Langtang National Park and trekking routes.\n', NULL, 'PUBLISHED', '{"city": "Rasuwa", "street": "Rasuwa", "district": "Rasuwa", "latitude": "28.1753591", "zip_code": "45003", "longitude": "85.4776025", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779601966/grihastha/media/zsjan8i2oytdsh45jp2g.webp"}', '{"guests": 2, "bedrooms": 3, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Parking", "Kitchen", "Washing Machine", "TV", "Pool", "Gym", "Garden", "Balcony", "Hot Water"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779601932/grihastha/media/jq5o3svynqxcerikqxma.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779601935/grihastha/media/kmjcrhxmzh6rtlbvdprp.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779601936/grihastha/media/zkpyiriatfdicflr46js.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779601938/grihastha/media/dvcceq3gjfvoo4wjzhvm.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779601939/grihastha/media/w7ucnlibgrht0zh86gsd.webp"}]', 7996.00, 1, NULL, FALSE, '2026-05-24 11:37:47.141834+05:45', '2026-05-24 11:38:23.635183+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('61d3d2bf-e65b-4984-ac88-61a57d9abb17', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'shning apart in duhabi  with sunrise view ', '', NULL, 'PUBLISHED', '{"city": "Kathmandu Metropolitan City", "street": "thamel kathmandu", "district": "Kathmandu", "latitude": "27.7166578", "zip_code": "25511", "longitude": "85.3127015", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691133/grihastha/media/wcernuc9mikxora6robs.webp"}', '{"guests": 2, "bedrooms": 1, "bathrooms": 1}', '["WiFi", "Parking", "Air Conditioning", "Washing Machine", "Kitchen", "Pool"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691096/grihastha/media/wxyqtevvxazrky7obyqi.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691098/grihastha/media/q3epxbufhfgfnzx1ci62.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691099/grihastha/media/bljnbubtevtfgagqbvcd.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691100/grihastha/media/nrqnr3vcp4zbsuyhvomb.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691102/grihastha/media/zl8cpho9qslr5zlrabrk.webp"}]', 5000.00, 1, NULL, FALSE, '2026-05-13 22:37:14.569717+05:45', '2026-05-13 22:41:36.034889+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('388df782-2564-4aef-a025-60fa659d3b1f', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'suncity aprtment ', 'Beautiful mountain-view apartment located in the peaceful Langtang region near Kyanjin Gompa. The property offers comfortable furnished rooms, free WiFi, hot water, traditional Nepali meals, and stunning Himalayan scenery. Ideal for trekkers, tourists, photographers, and nature lovers seeking a relaxing stay close to Langtang National Park and trekking routes.', NULL, 'PUBLISHED', '{"city": "Kathmandu Metropolitan City", "street": "basantapur  kathmandu ", "district": "Kathmandu", "latitude": "27.7042916", "zip_code": "", "longitude": "85.3065551", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779720869/grihastha/media/do9dzbakgw0viwejscba.webp"}', '{"guests": 2, "bedrooms": 5, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Parking", "Kitchen", "Washing Machine", "TV", "Pool", "Gym", "Garden", "Balcony", "Hot Water", "Power Backup"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779720835/grihastha/media/ixqydxkhczeo5zpx4acg.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779720837/grihastha/media/ecrxfawp4poqp8lrcqxw.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779720839/grihastha/media/vkkhjr5hpsp230qmif3b.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779720841/grihastha/media/hwxiwwcq7zbwpdjydztx.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1779720842/grihastha/media/gzhvk48x7yzppd3xri3t.webp"}]', 8004.00, 1, NULL, FALSE, '2026-05-25 20:39:29.899493+05:45', '2026-05-25 20:40:33.874755+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('d449f28d-1c86-4788-b95b-7f5cf1cd7d1b', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'suncity aprtment ', 'looks the seneric view of  basantapur durbar square', 'apartment', 'PUBLISHED', '{"city": "basantapur  kathmandu", "street": "basantapur  kathmandu ", "country": "Nepal", "province": "Bagmati"}', '{"beds": 1, "guests": 2, "bedrooms": 1, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Parking", "Kitchen", "Washing Machine", "Garden", "Hot Water"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1776784712/grihastha/listings/zkmbxcqptkqvx358t3j1.webp", "position": 0, "public_id": "grihastha/listings/zkmbxcqptkqvx358t3j1"}]', 2000.00, 1, NULL, FALSE, '2026-04-21 21:03:29.588931+05:45', '2026-04-21 21:03:33.766924+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('7bc35e04-d9c5-4771-a08f-65ff5874c299', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'crazy apartment in thamel', 'sdkmfckadsfcdlkld', NULL, 'PUBLISHED', '{"city": "Solukhumbu", "street": "everest base camp, Nepal", "district": "Solukhumbu", "latitude": "27.9996646", "zip_code": "", "longitude": "86.8487946", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691571/grihastha/media/hvcbr44kd5zme1iowfxz.webp"}', '{"guests": 2, "bedrooms": 1, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Parking", "Kitchen", "Power Backup", "Washing Machine", "TV", "Gym", "Balcony", "Hot Water"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691484/grihastha/media/pg8nxfsyf5jt72fdg0co.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691504/grihastha/media/u8lyblc4xlg36hyibxto.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691529/grihastha/media/vvd0dirtolfgtloxtrgz.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691531/grihastha/media/egg8duuin5jfjhvddaed.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778691533/grihastha/media/zdef4lgrxyadg2gcsxgv.webp"}]', 4000.00, 1, NULL, FALSE, '2026-05-13 22:44:32.947966+05:45', '2026-05-13 22:45:04.310846+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('b9ab79cc-dd24-47a5-b5d2-4ff73f645cd1', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', 'Himalayan Retreat — Bandipur Heritage ', 'A charming 3-room heritage homestay perched on the hilltop bazaar of Bandipur, one of Nepal''s best-preserved Newari towns. Wake up to panoramic views of the Annapurna and Dhaulagiri ranges. Traditional architecture, home-cooked Newari meals, and walking distance to Bindabasini Temple. Perfect for trekkers and culture travellers.', NULL, 'PUBLISHED', '{"city": "Bandipur", "street": "Bandipur Bazaar", "district": "Tanahun", "latitude": "27.9378408", "zip_code": "33904", "longitude": "84.4070699", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784146/grihastha/media/qsxikbyzu6idfdbkdxmh.webp"}', '{"guests": 5, "bedrooms": 12, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Gym", "Garden", "Parking", "Balcony", "Kitchen", "Hot Water", "Washing Machine", "Power Backup", "TV", "Pool"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784055/grihastha/media/unlucqdlvbiw7hqoncff.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784065/grihastha/media/jtzmiryveaez90p5covc.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784087/grihastha/media/l6lzkochsvffglldjgoe.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784118/grihastha/media/qb8wzzxkframmm7mbdll.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784121/grihastha/media/fpgpk40csy4qv1sb1ul6.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784123/grihastha/media/utiwokylmbfi3w1exmln.webp"}]', 2888.00, 1, NULL, FALSE, '2026-05-15 00:27:27.281396+05:45', '2026-05-15 00:28:00.801471+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);
INSERT INTO public.listings (id, host_id, title, description, category, status, address, floor_plan, amenities, photos, price_per_night, minimum_night_stay, maximum_night_stay, instant_book_enabled, created_at, updated_at, published_at, cleaning_fee, latitude, longitude, lat, lon, average_rating, total_reviews) VALUES ('08e4693b-9ab6-4ff5-9e88-c0beab04b236', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', 'Ilam Tea Garden Cottage — Sunrise Valley Stay', 'A cozy hillside cottage nestled inside a working tea garden in Ilam — Nepal''s tea country in the far east. Guests wake up to misty rolling hills blanketed in green tea bushes with Kanchenjunga visible on clear mornings. Includes a private veranda, fresh-picked tea each morning, and guided walks through the estate. Ideal for nature lovers and slow travellers looking to escape the tourist trail.', NULL, 'PUBLISHED', '{"city": "Suryodaya", "street": "Fikkal–Ilam Road", "district": "Ilam District", "latitude": "26.9336839", "zip_code": "57303", "longitude": "88.0988850", "legal_doc_url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784616/grihastha/media/l2un8nj7ebweyfeazw9p.webp"}', '{"guests": 2, "bedrooms": 1, "bathrooms": 1}', '["WiFi", "Air Conditioning", "Garden", "Parking", "Hot Water", "Kitchen", "Washing Machine", "Power Backup"]', '[{"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784582/grihastha/media/zinq1m1x8pqj0jspw0gz.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784582/grihastha/media/zeajajtw5wfjgl9jgzvl.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784586/grihastha/media/fxjl7oitimuqt94uukgu.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784587/grihastha/media/g2w4zcqs7gsfrh2fswku.webp"}, {"url": "https://res.cloudinary.com/djd9xro7e/image/upload/v1778784589/grihastha/media/pn4gztl2l7uxbsttldbl.webp"}]', 3200.00, 1, NULL, FALSE, '2026-05-15 00:35:17.618493+05:45', '2026-05-15 00:41:55.209538+05:45', NULL, 0.00, NULL, NULL, NULL, NULL, 0.00, 0);


--
-- Data for Name: message_templates; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('71d7c405-3c57-4e8d-af4c-cf3c2fac0cf4', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'hello sir ', TRUE, '2026-04-25 01:07:57.942007+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('90997d3f-4361-4a8e-8f21-038a37ba7bce', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'hello', TRUE, '2026-04-25 01:03:53.081808+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('3ffa14e3-bab1-4342-b78c-699040e9ddd2', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'what mate', TRUE, '2026-04-25 01:05:40.817158+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('ad3cc555-6c07-47bc-849d-155b1a89a178', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'zDAuY6n2zNW39wA1OV6BFPkisylFrSuBVkBZZ9xBgjQr', TRUE, '2026-04-25 01:12:09.204884+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('1ed68fef-d8c3-46ee-8999-a6662ef5c0b3', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'z1w4GsV9DormuExOMwI0/s1H0iRnza65KHHUdLxgq28yA2R2tucG', TRUE, '2026-04-25 01:12:24.136529+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('ce3a0317-b4cf-4c2d-8abf-e938a73a886e', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX19Ycd0NNhCsGILS6jWbYKhAq37IHPb/LwA=', FALSE, '2026-05-13 01:13:03.61341+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('f8bd722a-79e0-4bae-8f57-50560b855bf6', 'dc8220b9-3df8-457e-853d-94d28daeffd8', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1/9xNA3xF3TeBIPdMVsiRrlrGhkdQ/cavs=', FALSE, '2026-05-13 01:25:06.017108+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('cceeafae-8089-4368-91d2-6b194af89cbf', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX19DZzEkJ8sNHNkR/2uOOkqDY1gmFGQ1XJ4=', FALSE, '2026-05-14 17:48:10.746986+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('f1e6ca06-b817-408a-b99e-4c5b25bb6de9', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1+FiPi58EfDKzLbeHW4Zat2hl1yjIEqalM=', FALSE, '2026-05-14 17:48:45.713267+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('32038517-0073-49ee-a83e-f18ab8237587', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX18RPROoWbFjNW43Ry11k6kdk9pMr5+1Vc0=', FALSE, '2026-05-14 18:13:39.120476+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('e51b5495-3beb-42ee-8a18-e258d9c673dc', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX19hLdFu6ZLyyxyLvdbkCF3hhvEbL4bXmEqAoXxijfBfPyIKX3CB/sCf12IavB2BR29TALJn3+8asg==', FALSE, '2026-05-14 18:20:56.105679+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('bf275a5b-22fd-404d-bc08-e8b9c7cb1a99', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1/xFURzZgfl7RHO/mK/SyyI9fp07VPr45Y=', FALSE, '2026-05-14 18:36:45.751524+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('129db84d-8479-46cb-a765-9d0ec7dc249a', '0542273a-04dc-4c04-b2e7-1cab5e4a3d41', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1//JHnKyy4G8pToDzRIwxETpZZkHIFMdko=', FALSE, '2026-05-14 18:56:50.219117+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('764109d0-743a-4302-83d8-a59a2adf56bf', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX18cg6RoGEVoIycodY+Cs3YgukMTMoBY73YZloSm+iFDOgK7SD1CYJ6q', FALSE, '2026-05-14 19:11:52.034826+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('cc68113e-8d65-4ceb-907c-4ca37b4b99f7', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX19C+IjVBJeBTPfR7RTnOgIjS+ZhK0MWgIA=', FALSE, '2026-05-14 19:15:30.946912+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('2bd930de-85cd-4ad3-8db9-cfa46cb44f2f', '0542273a-04dc-4c04-b2e7-1cab5e4a3d41', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1/7zH3IK1GkkWsI6zFiwZPmpX4YRtZ+kYc=', FALSE, '2026-05-14 19:54:07.454249+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('1fb3184a-3ee8-4bc7-be87-f070551db095', '0542273a-04dc-4c04-b2e7-1cab5e4a3d41', NULL, 'hello', FALSE, '2026-05-14 20:08:57.397307+05:45', '1ce74cc1-0eaa-46c7-ae0c-3872b7d9251b');
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('ee66ebd4-282a-4173-aa06-e7baa9b4fd41', '97256cfa-d538-41f5-b018-377f8eaac5ca', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX193EiLF6CjkDMc00PYOxiRs/P6yL3m5/fE=', FALSE, '2026-05-15 18:03:19.355755+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('5eb9a7fc-67b7-468e-ab47-15d8a65186a6', '90feecd0-3771-4fae-bdf5-aa773718d5e1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1/VY9Nk3mRvfMi+kUDwA6dHofIo04PUMF8=', FALSE, '2026-05-21 21:31:43.740945+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('4486811d-6e3f-4163-9fc3-52892af0ae44', '90feecd0-3771-4fae-bdf5-aa773718d5e1', '322cf49c-33ed-4d71-89e8-dc82efe91854', 'U2FsdGVkX19MOtq8p0K3fF6cKC7SNhA8eXfX6U7oiqw=', FALSE, '2026-05-21 21:31:51.751974+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('f86f9d75-8c25-4b32-8c2e-f19652a3d14d', '35ee084b-a720-44dd-846e-d100bff7f3d1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX19be5N/lmMt4fRGvQ+9cc8ZBrUcUxPLtKk=', FALSE, '2026-05-22 10:22:47.408739+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('34257842-3294-4cbd-a942-2360714453ad', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'M2rajeWRAnwEugNkjTJFwbafoqs1TLK3H5BAES0Ow3QU', TRUE, '2026-04-25 01:10:25.798582+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('4aa1d64c-c847-45bd-9b66-64cc45df7379', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'hey', TRUE, '2026-04-25 01:00:39.606124+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('e9e2037b-df57-48a9-be20-4d2b721feaf5', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'hello host', TRUE, '2026-04-25 01:07:47.102687+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('c1142860-7eea-4715-ab2f-c7b51a7d5824', 'a17f2412-c84d-4d58-bc0f-fb5466392132', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1+ZTkiDK0sGN7g207JclSwuCAweq0D88cc=', FALSE, '2026-05-24 01:43:30.442623+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('ac56ebee-b0f0-4e14-a5af-bbd5d0f9c48a', 'a17f2412-c84d-4d58-bc0f-fb5466392132', '6d675123-04cc-4267-a356-4e9bd384b04a', 'U2FsdGVkX18yflBhRhMCwk0508tIZ26tEbJmVWwgSx8=', FALSE, '2026-05-24 01:43:44.834429+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('24248167-b19c-470d-92dd-4426bcc2753a', '4a0b0415-ef51-4fa7-abef-90da453e9c25', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX19yPewy6MfZHOF10IKB9VuKrQaQj/zqjkk=', FALSE, '2026-05-24 11:45:04.188624+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('6f8c186d-534a-486e-b9b5-08bc18f0ed63', 'c9686488-6909-48fe-b2af-60133cc4c8c1', '6f9fe2cd-14a3-40a1-9685-77572be3b6bc', 'U2FsdGVkX18nGffUsaZ9GWAYvlTwpU20UXEy28+jq/8=', FALSE, '2026-05-25 20:20:45.671592+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('55df4ffd-12cf-4aa5-be47-ea6606c5df1b', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'M9v/cKglzHEuA3oZwwuWqPS2/wr+YjhuRFNXR3rJYco=', TRUE, '2026-04-25 01:15:48.543022+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('292d62d3-7387-4106-b2d8-d9c74610a48e', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1/12WQZkiQiSVVwEOWOo0rLjoDuaieQvYk=', FALSE, '2026-05-13 01:20:33.420328+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('31cac8fb-addb-4e91-8ac3-83f117f2ec1a', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1+7DYewpUAmmZs6kauJ24PRvtbe43OgtQE=', FALSE, '2026-05-14 12:55:16.711112+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('96dacc74-819c-4ff6-8a0e-b43e4c10bd97', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX19/XG/bmjYNNOclyjWL9jBwbz+hD+bqU6Q=', FALSE, '2026-05-14 17:50:01.466272+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('f92071f9-801a-49ab-b8af-118f61e482ea', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1/6IVukusChVVHtZ5sMjcD0FRnkoQ352SI=', FALSE, '2026-05-14 17:50:15.824431+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('31fd7d13-b6fd-40dd-981a-8c01248f6179', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX184LCghTcOszjf8qbEK421LxC9zyzWrw1A=', FALSE, '2026-05-14 18:16:43.135939+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('04769682-f2a6-4967-8250-d5beab04a34f', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX19sAPOLqkgH5RF9vtH6FFpW0U3AyObrmi0=', FALSE, '2026-05-14 18:16:51.843495+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('286288b9-c3eb-41e8-9fdc-3e47b45c375f', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX19qwmYmeJp6aTZv+4Q74s26UWUrIClSNxU=', FALSE, '2026-05-14 18:16:55.035934+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('4a4114db-473d-4c49-a94d-bc21e6760db5', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1/gKJ9Gyb9XX1bwAJ1bD17upVN9q2o+6iM=', FALSE, '2026-05-14 18:32:50.891138+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('26fc55b0-1cc4-455c-bb98-dce69259ca78', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX19pX8Qqz2kGYMRruBIHLGcfUXX8rb5+e+U=', FALSE, '2026-05-14 18:32:56.723701+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('883bab0e-b1fe-49e4-a417-cac2ee66c252', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX191JhG903XCnEX9pDOH2Zu02SVH0bP9Lwc=', FALSE, '2026-05-14 18:33:06.064172+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('149f819e-a0ec-42c5-b7ad-9404aa5d6786', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1++m0PEsqlM+Sm57cuIHZWXmI7Zxv3wvu8=', FALSE, '2026-05-14 18:45:05.954338+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('3b24e4d2-eca3-46ca-9719-aa4257b2c2e8', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1/omb0B8yHvCujUBdUN8Urq6OMEoKe4kBs=', FALSE, '2026-05-14 19:11:22.171342+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('39f8ad72-2e10-4253-9a3b-fc3824a3ea6e', 'a93629f6-342c-462a-bae3-04ce228c5fb3', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX196rwecJsW7prVKtdEajP6e3+ZPrjf1ReOwE9v7K+Y/6Jfe0K3tRzl1', FALSE, '2026-05-14 19:14:54.545295+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('0f39b1fb-9f65-47fd-aafe-c4c452cc4728', '0542273a-04dc-4c04-b2e7-1cab5e4a3d41', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1961vyTy5FIj0k4xbwRxRzE3CFl2dvzRlrIxasTu6//hLuCu/NN21AJ', FALSE, '2026-05-14 19:49:12.408665+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('593d0ffa-a725-4ceb-9cf0-b17d3e8b6d56', '0542273a-04dc-4c04-b2e7-1cab5e4a3d41', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1+asD7RZLHv5xr+8GxueacQLk7EEuq1cTI=', FALSE, '2026-05-14 19:57:01.495298+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('8a8a65fe-f1ec-46f5-a773-c2c25a5f6b84', '0542273a-04dc-4c04-b2e7-1cab5e4a3d41', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX19nEv9Ikfp1mKW90j9qdat+BZLrB1nAa5Q=', FALSE, '2026-05-14 20:10:23.146579+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('b4dc0462-2328-46da-ab68-d54f5eee2127', '35ee084b-a720-44dd-846e-d100bff7f3d1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1+bNZL2pbasohseMXfXiN+4EhN0RupPYtE=', FALSE, '2026-05-22 10:22:16.973184+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('8c65daf7-45d9-47f4-aef9-eaafcfe19737', '8cf9c307-33bc-4122-9cbd-97b97eb13be4', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1+T90bm4vF0GTnNikBLxI2oCmrQpgI6iVo=', FALSE, '2026-05-22 12:44:05.872619+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('8f26f4f8-3ec3-41d1-b76c-7bab559f037c', '8cf9c307-33bc-4122-9cbd-97b97eb13be4', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX1/o2bcqBpjUWg35DQeneu5NKmWQBsh9hZo=', FALSE, '2026-05-22 12:44:16.477979+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('de34c88a-1ac8-48ac-b1bc-cfb3252cf0bb', '4a0b0415-ef51-4fa7-abef-90da453e9c25', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1/OFHf9+qUNppwzqovrCHymccfu7nO0bwc=', FALSE, '2026-05-24 11:44:20.815879+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('1f52a849-9a4e-4e8d-a556-cd07820e50bb', '4a0b0415-ef51-4fa7-abef-90da453e9c25', '4bcf4e3a-f721-4816-a053-045843bbb68f', 'U2FsdGVkX1/7hBfKxFH/tJ+VY2/EqBTMOnEBcLGr3Gc=', FALSE, '2026-05-24 11:45:35.29128+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('82a138e1-6710-4350-b8ce-6c0a2b07713d', '8cf9c307-33bc-4122-9cbd-97b97eb13be4', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'U2FsdGVkX197iAAF7lAS6FLRe4wm81IKBPTMTqYNB84grS7kcmFyHOpHrG4uN12T', FALSE, '2026-05-26 10:48:54.664103+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('2d9eb1e4-741f-43b2-aaaa-3c57e1edccf5', '8cf9c307-33bc-4122-9cbd-97b97eb13be4', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'U2FsdGVkX1+ES7aeL+GraAUn7h0ydYeen8umQr97QWoJmELekXhHxdHzNkrVvlF9hFit8rW6VJkEYkRWicBFQg==', FALSE, '2026-05-26 10:49:16.105639+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('01ff85d1-a67c-4aa8-a469-a3babed911b1', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'L77Xw7vNbnzj0ePxk1xfRuidSsnnCmn4J9TpM8Ft84QMwZmKrw==', TRUE, '2026-04-25 01:12:33.81919+05:45', NULL);
INSERT INTO public.messages (id, conversation_id, sender_id, content, is_read, created_at, sender_admin_id) VALUES ('ab8783eb-fb1e-4540-a8e7-e8c433958578', '9dccd57a-143b-4ade-8993-8e32c6ee7b81', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'MrWcWifKjs6xSic7PHfIcAd+D1e/D2GGqIVwLmuLlHA=', TRUE, '2026-04-25 01:15:41.834746+05:45', NULL);


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('9bf98ec5-eb0e-4af7-a88e-9f46042d325c', 'b4492126-c441-4839-8dae-90dc7efc869b', 'Booking Cancelled ❌', 'The booking for dsmxcmldsvx has been cancelled by the guest.', 'booking_cancelled', FALSE, '2026-04-08 09:27:38.544072+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('05bab172-29e1-438b-95d2-d894ac829fa4', '58029367-f35e-48b4-9509-4e02a5fa4f01', 'Trip Cancelled ❌', 'You have cancelled your trip to dsmxcmldsvx.', 'booking_cancelled', FALSE, '2026-04-08 09:27:38.547416+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('4136da83-7eed-4b5c-9019-708922bad948', '46330ab9-f934-4845-83a8-579bb65d5268', 'Booking Cancelled ❌', 'The booking for msandkanfk has been cancelled by the guest. Reason: bnvgfhj', 'booking_cancelled', FALSE, '2026-04-08 11:59:36.493211+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('82c8d6fd-b68a-4dd4-9460-465a6e7e9603', '58029367-f35e-48b4-9509-4e02a5fa4f01', 'Trip Cancelled ❌', 'You have cancelled your trip to msandkanfk. Reason: bnvgfhj', 'booking_cancelled', FALSE, '2026-04-08 11:59:36.494816+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('41736f1b-8229-4c8f-8ccd-899f16d8539c', '46330ab9-f934-4845-83a8-579bb65d5268', 'Booking Cancelled ❌', 'The booking for msandkanfk has been cancelled by the guest. Reason: fgddfgd', 'booking_cancelled', FALSE, '2026-04-08 13:43:34.785452+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('552725dc-4cb1-48e9-931d-4ddabfcbbca1', '58029367-f35e-48b4-9509-4e02a5fa4f01', 'Trip Cancelled ❌', 'You have cancelled your trip to msandkanfk. Reason: fgddfgd', 'booking_cancelled', FALSE, '2026-04-08 13:43:34.7871+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('2cb42d45-e9f1-497c-be02-c94235de0c9a', '46330ab9-f934-4845-83a8-579bb65d5268', 'Booking Cancelled ❌', 'The booking for msandkanfk has been cancelled by the guest. Reason: didnt liked the property\n', 'booking_cancelled', FALSE, '2026-04-11 23:22:26.099614+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('f01c3001-8eef-4f34-8724-20d715d717ca', 'cba03ff7-7ba2-4522-878f-027aee8d85c9', 'Trip Cancelled ❌', 'You have cancelled your trip to msandkanfk. Reason: didnt liked the property\n', 'booking_cancelled', FALSE, '2026-04-11 23:22:26.101433+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('1ceca784-af61-4507-a06c-4a5298c759d1', 'd5e767eb-7c5c-4be1-bf2c-7cfe34778d41', 'Booking Confirmed! 🎉', 'Your stay at msandkanfk has been confirmed.', 'booking_confirmation', FALSE, '2026-04-17 14:36:04.410031+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('640216d2-c5e0-4ca9-8816-d9a39e4ae3e6', '46330ab9-f934-4845-83a8-579bb65d5268', 'New Booking Received! 🥳', 'Verified User just booked msandkanfk.', 'new_booking', FALSE, '2026-04-17 14:36:04.413902+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b91b12c2-5ce1-4ebc-9451-27c066bba205', 'd5e767eb-7c5c-4be1-bf2c-7cfe34778d41', 'Booking Confirmed! 🎉', 'Your stay at msandkanfk has been confirmed.', 'booking_confirmation', FALSE, '2026-04-17 14:36:05.137783+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('e484867b-d49d-4177-b89b-04fabe5e1486', '46330ab9-f934-4845-83a8-579bb65d5268', 'New Booking Received! 🥳', 'Verified User just booked msandkanfk.', 'new_booking', FALSE, '2026-04-17 14:36:05.138878+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('a5f11b01-4577-47ad-bc78-20a862a176c7', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Serene Lakefront Penthouse with Machhapuchhre Views.', 'new_booking', FALSE, '2026-04-18 02:00:07.958405+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('5fda99fa-2d02-4d0c-836f-aa98febdd88b', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Serene Lakefront Penthouse with Machhapuchhre Views.', 'new_booking', FALSE, '2026-04-18 02:00:08.128809+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b8dbaa70-90af-495f-94ee-096dc7d9c55c', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Serene Lakefront Penthouse with Machhapuchhre Views.', 'new_booking', FALSE, '2026-04-18 12:03:02.212825+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('d16a594d-80ba-46a1-b316-20ceb54cc1bf', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Serene Lakefront Penthouse with Machhapuchhre Views.', 'new_booking', FALSE, '2026-04-18 12:03:02.417122+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('35538c76-a74e-4d49-af4f-2bc2e57f774f', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Serene Lakefront Penthouse with Machhapuchhre Views.', 'new_booking', FALSE, '2026-04-19 08:11:08.534424+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('c53cbea0-a188-4b7a-9802-fbc26f7b9afe', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Serene Lakefront Penthouse with Machhapuchhre Views.', 'new_booking', FALSE, '2026-04-19 08:11:08.872709+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('23c92a17-8639-4449-be40-941d39569627', 'e4f69ef6-570e-45cd-a559-fd99612a5849', 'Booking Confirmed', 'Your booking for Serene Lakefront Penthouse with Machhapuchhre Views (4/21/2026 to 4/22/2026) is confirmed!', 'booking', FALSE, '2026-04-20 19:13:06.206736+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('7bc798b5-b7c4-4bdc-95de-ba99516eab6d', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received', 'New booking!\nram bhadur booked Serene Lakefront Penthouse with Machhapuchhre Views for 4/21/2026 to 4/22/2026.', 'booking', FALSE, '2026-04-20 19:13:06.208832+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('1b069c11-67e0-417c-87e9-cc5b3f11258f', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-04-21 21:49:47.608481+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('99460d0d-c645-4586-a1e2-86bb8a1d9851', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-04-21 21:49:48.053772+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('105e8ba1-1a5b-49e5-814a-26d696b14f4c', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-04-22 09:20:21.209895+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('83ebea02-4a8d-4355-8fd2-377d5d6bd26d', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-04-22 09:20:21.393344+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('5dd3a7c6-36b1-4d07-9942-bcba99f85b12', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-04-22 13:18:11.900868+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('a04b7cfb-9975-4a18-85d2-31bb3e8b55c4', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-04-22 13:18:12.034481+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('21465b8f-03c6-4fa1-b3c8-164870fec0cc', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-04-25 00:43:36.849948+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('036d160a-0bc3-4d6f-86ad-772f879db89d', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-04-25 00:43:38.00157+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('d6372e93-135a-48a6-92a3-dd20c0099190', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Message', 'You have a new message: "hey..."', 'NEW_MESSAGE', FALSE, '2026-04-25 01:00:39.608896+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('a0969fd2-dd62-4648-9a77-52be897d69fc', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Message', 'You have a new message: "hello host..."', 'NEW_MESSAGE', FALSE, '2026-04-25 01:07:47.104084+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b684a0ae-3344-4e89-b26f-afd3909cc2a4', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Message', 'You have a new message: "M2rajeWRAnwEugNkjTJFwbafoqs1TLK3H5BAES0Ow3QU..."', 'NEW_MESSAGE', FALSE, '2026-04-25 01:10:25.800319+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('9b2347af-47e7-41ef-9697-f27f6adbb3ab', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Message', 'You have a new message: "L77Xw7vNbnzj0ePxk1xfRuidSsnnCmn4J9TpM8Ft84QMwZmKrw..."', 'NEW_MESSAGE', FALSE, '2026-04-25 01:12:33.820864+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('072214a2-e7ca-44d9-bfd3-cff6f303b6c0', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Message', 'You have a new message: "MrWcWifKjs6xSic7PHfIcAd+D1e/D2GGqIVwLmuLlHA=..."', 'NEW_MESSAGE', FALSE, '2026-04-25 01:15:41.836578+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('8430347c-44a2-41b8-ba49-81eaeabf1cc9', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-05-06 12:35:00.897866+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('3d753259-1118-44af-a283-178726e3ca0d', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Cozy Sunrise Homestay in Sarangkot.', 'new_booking', FALSE, '2026-05-06 12:35:01.846027+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('f08dc5e4-4724-4e11-928f-218bce4d23f0', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-04-22 13:18:11.897309+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('4d1d7aaf-b3b7-45db-996e-6071f9480e4b', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Serene Lakefront Penthouse with Machhapuchhre Views has been confirmed.', 'booking_confirmation', TRUE, '2026-04-18 02:00:07.955026+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('2c42d4d7-2be1-4059-a20d-38e1223a263f', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Serene Lakefront Penthouse with Machhapuchhre Views has been confirmed.', 'booking_confirmation', TRUE, '2026-04-18 02:00:08.127597+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('539f9f84-0539-40c1-b1b9-82c243593b34', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Serene Lakefront Penthouse with Machhapuchhre Views has been confirmed.', 'booking_confirmation', TRUE, '2026-04-18 12:03:02.208924+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('9c37965e-73b0-4c6c-af1c-34263a98e21b', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Serene Lakefront Penthouse with Machhapuchhre Views has been confirmed.', 'booking_confirmation', TRUE, '2026-04-18 12:03:02.415468+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('d1e84d8f-783d-40bc-beb0-2f2bce7ff9e6', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'New Message', 'You have a new message: "hello..."', 'NEW_MESSAGE', TRUE, '2026-04-25 01:03:53.082785+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('14d311fa-176b-4aac-ad2b-041d145383ca', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked e mfd,qlramgdfmekqd.', 'new_booking', FALSE, '2026-05-12 23:22:24.639586+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('da7865ab-c6f5-4002-861d-fe34dea3ae61', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked e mfd,qlramgdfmekqd.', 'new_booking', FALSE, '2026-05-12 23:23:10.70672+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('f44661b2-bbaa-4d01-ae57-0321e8238335', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked e mfd,qlramgdfmekqd.', 'new_booking', FALSE, '2026-05-12 23:24:18.800823+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('719e1ee2-3fbc-44bf-9d18-d0d3e62636de', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked e mfd,qlramgdfmekqd.', 'new_booking', FALSE, '2026-05-12 23:31:10.961892+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('1ce29a3a-704b-4518-88a3-241ff6c33032', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'KYC Rejected', 'Your KYC verification was rejected. Reason: ncxzncjkadsfdkjs', 'alert', FALSE, '2026-05-13 17:04:24.316394+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('53710e5d-4b5c-4485-912f-e0bce51b17bd', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'KYC Rejected', 'Your KYC verification was rejected. Reason: ncxzncjkadsfdkjs', 'alert', FALSE, '2026-05-13 17:04:25.339101+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('4da9f5db-e3e7-4ebe-ae61-f98e45d40c40', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'KYC Rejected', 'Your KYC verification was rejected. Reason: ncxzncjkadsfdkjs', 'alert', FALSE, '2026-05-13 17:04:26.062115+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('05b1e87a-ebb5-442c-96d2-31921d10693c', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'KYC Rejected', 'Your KYC verification was rejected. Reason: ncxzncjkadsfdkjs', 'alert', FALSE, '2026-05-13 17:04:26.978793+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('463f49b4-c0ba-4173-8899-af3e61b4c69d', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'KYC Rejected', 'Your KYC verification was rejected. Reason: ncxzncjkadsfdkjs', 'alert', FALSE, '2026-05-13 17:04:27.178437+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('014dc05b-7bac-45e9-b582-ea5d52a87b57', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'KYC Rejected', 'Your KYC verification was rejected. Reason: ncxzncjkadsfdkjs', 'alert', FALSE, '2026-05-13 17:04:27.345121+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('441c7a43-8be1-47e4-a32f-403ff569f288', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-13 17:06:49.352577+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('4a5d99e2-9da1-4402-860f-69248d8c470f', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-13 22:22:54.02254+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b369e018-a2db-4cd2-af18-c6be8153d896', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked crazy apartment in thamel.', 'new_booking', FALSE, '2026-05-13 23:40:33.639452+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b52b26b0-17d5-44eb-ad45-8efb92b06585', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked shning apart in duhabi  with sunrise view .', 'new_booking', FALSE, '2026-05-14 00:13:08.108548+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('42707f78-82c3-474f-9b11-70e30a76f8e9', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked shning apart in duhabi  with sunrise view .', 'new_booking', FALSE, '2026-05-14 00:37:09.779113+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('387e79f6-6962-4039-a359-c712b6ba18f7', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked shning apart in duhabi  with sunrise view .', 'new_booking', FALSE, '2026-05-14 01:06:22.242771+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('791e64a5-9a6d-4134-8032-7a09362c3fa7', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked crazy apartment in thamel.', 'new_booking', FALSE, '2026-05-14 09:21:16.103954+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('8657058a-2eb3-4bbb-a38c-2c6457ece4dd', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked crazy apartment in thamel.', 'new_booking', FALSE, '2026-05-14 10:01:25.18274+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('557cee1f-8993-4da3-bb31-7c218996732e', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked crazy apartment in thamel.', 'new_booking', FALSE, '2026-05-14 10:02:20.379648+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('c6fd4175-d8d9-4277-94f9-e9520b6f62fe', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Serene Lakefront Penthouse with Machhapuchhre Views has been confirmed.', 'booking_confirmation', TRUE, '2026-04-19 08:11:08.53+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('d281e4c3-86b6-4b9c-bd55-988384a8d4c3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Serene Lakefront Penthouse with Machhapuchhre Views has been confirmed.', 'booking_confirmation', TRUE, '2026-04-19 08:11:08.871091+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('8906abac-878b-4e34-9587-bb34c2df0c5e', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-04-21 21:49:47.603851+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('7b253d81-5e70-4557-9e8f-5bb059b0bd20', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-04-21 21:49:48.052023+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('6e92b6c8-b9fa-4015-a605-0879c7b9f9e0', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-04-22 09:20:21.205578+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('eaa6db74-08b0-41e3-8807-df65dfaff7c0', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-04-22 09:20:21.391506+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b2a4af3c-dfa1-4886-8b5d-bc0cf4dd8b2a', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-04-22 13:18:12.032849+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('055334c7-8f41-45e7-a4a4-2414beeb934d', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-04-25 00:43:36.846631+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('2d6cfccc-3256-4391-baa3-a5a57d74f123', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-04-25 00:43:38.000058+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('e7f92f75-ea3a-4dc7-924c-f1b01dcaa9fb', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'New Message', 'You have a new message: "what mate..."', 'NEW_MESSAGE', TRUE, '2026-04-25 01:05:40.819612+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('2ced905a-080f-4053-bd33-411231c4737b', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'New Message', 'You have a new message: "hello sir ..."', 'NEW_MESSAGE', TRUE, '2026-04-25 01:07:57.943148+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('89cf8216-3333-4d3e-9f72-85f420fdd6dd', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'New Message', 'You have a new message: "zDAuY6n2zNW39wA1OV6BFPkisylFrSuBVkBZZ9xBgjQr..."', 'NEW_MESSAGE', TRUE, '2026-04-25 01:12:09.207264+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('df8cb7bc-c425-4c61-9b72-1ee3167f7d46', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'New Message', 'You have a new message: "z1w4GsV9DormuExOMwI0/s1H0iRnza65KHHUdLxgq28yA2R2tu..."', 'NEW_MESSAGE', TRUE, '2026-04-25 01:12:24.13802+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('33ddee2b-c959-4b39-8a69-5dd209015ce1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'New Message', 'You have a new message: "M9v/cKglzHEuA3oZwwuWqPS2/wr+YjhuRFNXR3rJYco=..."', 'NEW_MESSAGE', TRUE, '2026-04-25 01:15:48.54442+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b3dffe02-9dec-42ed-9854-f7084e0ed719', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-05-06 12:35:00.893784+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('4b05d87b-5b18-43e5-904c-ed947df711e2', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Cozy Sunrise Homestay in Sarangkot has been confirmed.', 'booking_confirmation', TRUE, '2026-05-06 12:35:01.84419+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('c49b86c9-c24d-456c-8207-72ac7a2b1f15', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at e mfd,qlramgdfmekqd has been confirmed.', 'booking_confirmation', TRUE, '2026-05-12 23:22:24.636785+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('7ca15217-c654-4928-b950-3f0fe4e12dbe', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at e mfd,qlramgdfmekqd has been confirmed.', 'booking_confirmation', TRUE, '2026-05-12 23:23:10.704396+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('80d6e5ae-8a33-4b33-af69-ca29f52623f1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at e mfd,qlramgdfmekqd has been confirmed.', 'booking_confirmation', TRUE, '2026-05-12 23:24:18.799119+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('e770fe4b-d61e-4d64-9d1b-9bff3a4b5167', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at e mfd,qlramgdfmekqd has been confirmed.', 'booking_confirmation', TRUE, '2026-05-12 23:31:10.959664+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('98c96f4d-21c9-4b95-8a07-917f584b60fd', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at crazy apartment in thamel has been confirmed.', 'booking_confirmation', TRUE, '2026-05-13 23:40:33.635314+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('0c430377-6718-4e11-9db7-d72f35e3ebcb', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at shning apart in duhabi  with sunrise view  has been confirmed.', 'booking_confirmation', TRUE, '2026-05-14 00:13:08.10424+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('1e6aa6be-ebb1-44e2-91b3-50090802aa2b', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at shning apart in duhabi  with sunrise view  has been confirmed.', 'booking_confirmation', TRUE, '2026-05-14 00:37:09.77598+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('3daf67fa-49ac-4d1d-9d12-e4f7ae40be09', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at shning apart in duhabi  with sunrise view  has been confirmed.', 'booking_confirmation', TRUE, '2026-05-14 01:06:22.237009+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('36aa7633-c93a-4047-a4fd-18a477aee6f4', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at crazy apartment in thamel has been confirmed.', 'booking_confirmation', TRUE, '2026-05-14 09:21:16.099295+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b502fd5f-d73d-439f-a6db-342f5d865ea9', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at crazy apartment in thamel has been confirmed.', 'booking_confirmation', TRUE, '2026-05-14 10:01:25.179117+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('9580b771-4ab5-4abf-9457-b7acf4ae8d94', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at crazy apartment in thamel has been confirmed.', 'booking_confirmation', TRUE, '2026-05-14 10:02:20.377123+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('9ab84854-434f-4974-ac53-03c76325f91f', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at crazy apartment in thamel has been confirmed.', 'booking_confirmation', FALSE, '2026-05-14 11:38:44.073667+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('6f5b07b7-bb89-4cf6-a9c1-345fa3ebdb97', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked crazy apartment in thamel.', 'new_booking', FALSE, '2026-05-14 11:38:44.077763+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('2f42891f-d2bb-464e-825b-4c19393e3c3c', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'Booking Cancelled ❌', 'The booking for crazy apartment in thamel has been cancelled by the guest. Reason: User cancelled', 'booking_cancelled', FALSE, '2026-05-14 11:42:06.284527+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('7d0ba34f-76f9-4c06-857b-4f22c7850112', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Trip Cancelled ❌', 'You have cancelled your trip to crazy apartment in thamel. Reason: User cancelled', 'booking_cancelled', FALSE, '2026-05-14 11:42:06.285295+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('6018b2eb-694f-40d3-98c0-34cc6a64c2cb', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at crazy apartment in thamel has been confirmed.', 'booking_confirmation', FALSE, '2026-05-14 12:09:14.247248+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('c7296f14-19a4-436c-869a-53f18a3c450d', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked crazy apartment in thamel.', 'new_booking', FALSE, '2026-05-14 12:09:14.250547+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('db6bc6e2-c83f-4fa7-9bce-625973c987e1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at crazy apartment in thamel has been confirmed.', 'booking_confirmation', FALSE, '2026-05-14 19:38:14.139322+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('3b4c36bc-5223-4c1a-8ccb-2a096b0ecc0a', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked crazy apartment in thamel.', 'new_booking', FALSE, '2026-05-14 19:38:14.143915+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('78288bb2-df23-4f61-9e11-e1c957334d30', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-15 00:18:28.268933+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('2b31a603-667e-4f8f-a788-3fac36a31fb8', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', 'Property Approved ✅', 'Your property "Himalayan Retreat — Bandipur Heritage " has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-15 00:28:00.805079+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('83b7f852-aea4-46e0-9a9f-255bc3e2d1ed', '7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', 'Property Approved ✅', 'Your property "Ilam Tea Garden Cottage — Sunrise Valley Stay" has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-15 00:41:55.21659+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('3957cde9-4d27-4d98-b10c-1c3e49572929', 'b7d47f46-66ae-444a-9d2a-96d1078372b7', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-15 17:05:08.785771+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('72992ab5-ad8a-4151-ab1f-3b894892ffc7', 'b7d47f46-66ae-444a-9d2a-96d1078372b7', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-15 17:05:10.397583+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('007043f5-91f1-4e75-908e-56ee224b8118', 'b7d47f46-66ae-444a-9d2a-96d1078372b7', 'Property Approved ✅', 'Your property "epstine island" has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-15 17:08:41.597056+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('5e418678-b18e-4cc9-8421-228d3734ba67', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed', 'Your booking for epstine island (5/30/2026 to 5/31/2026) is confirmed!', 'booking', FALSE, '2026-05-15 18:02:30.078172+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('ad2b357d-4d88-4e3e-b7c6-a646826f6961', 'b7d47f46-66ae-444a-9d2a-96d1078372b7', 'New Booking Received', 'New booking!\nadam jampa booked epstine island for 5/30/2026 to 5/31/2026.', 'booking', FALSE, '2026-05-15 18:02:30.080943+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('aa814741-c39a-4772-a57a-ad76d10a82c3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed', 'Your booking for epstine island (5/30/2026 to 5/31/2026) is confirmed!', 'booking', FALSE, '2026-05-15 18:02:47.77+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('4dd25ee1-41fc-42c9-9487-12209c9b9eb1', 'b7d47f46-66ae-444a-9d2a-96d1078372b7', 'New Booking Received', 'New booking!\nadam jampa booked epstine island for 5/30/2026 to 5/31/2026.', 'booking', FALSE, '2026-05-15 18:02:47.7708+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('0098a619-2f6d-4030-beb8-05b48ded9d78', '322cf49c-33ed-4d71-89e8-dc82efe91854', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-21 21:23:58.539085+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('e3047f6d-a896-4c3f-8bf9-c46f042822b7', '322cf49c-33ed-4d71-89e8-dc82efe91854', 'Property Approved ✅', 'Your property "apart in shree aantu" has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-21 21:28:46.455974+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('9f5100ec-28aa-4e13-939e-00d084cbb41c', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at apart in shree aantu has been confirmed.', 'booking_confirmation', FALSE, '2026-05-21 21:30:35.382682+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('3140315a-04a0-41f4-8723-60cd0a143e44', '322cf49c-33ed-4d71-89e8-dc82efe91854', 'New Booking Received! 🥳', 'adam jampa just booked apart in shree aantu.', 'new_booking', FALSE, '2026-05-21 21:30:35.384675+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('ddd3c95c-bd8c-482f-b9fe-aa817a0ee6bd', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at apart in shree aantu has been confirmed.', 'booking_confirmation', FALSE, '2026-05-22 08:50:06.712757+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('25b787e5-16c3-462c-96ac-a96409ec877a', '322cf49c-33ed-4d71-89e8-dc82efe91854', 'New Booking Received! 🥳', 'adam jampa just booked apart in shree aantu.', 'new_booking', FALSE, '2026-05-22 08:50:06.716944+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('dd0ae80f-3010-4d1c-a6fe-0be1f399ef48', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-22 10:16:06.516496+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('f5d55d31-1fc0-48af-b586-2255508d7c64', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', 'Property Approved ✅', 'Your property "Langtang Mountain View Lodge" has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-22 10:19:50.608241+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('f96ff898-94ba-4ee8-9188-f4f44d51e5d5', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Langtang Mountain View Lodge has been confirmed.', 'booking_confirmation', FALSE, '2026-05-22 10:21:40.638023+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('c2b2a11d-a3c3-407f-9bb5-8c66a259973c', '7981c6da-c8b7-438b-9f43-ff3b337a9ce1', 'New Booking Received! 🥳', 'adam jampa just booked Langtang Mountain View Lodge.', 'new_booking', FALSE, '2026-05-22 10:21:40.642121+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('5a73bd4e-84a2-4222-8f9e-da6d12578a3a', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'Property Approved ✅', 'Your property "Himalayan Retreat — Bandipur Heritage " has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-22 12:40:51.425843+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('f749f3e5-12dd-41c3-9337-c698a6e759d0', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Himalayan Retreat — Bandipur Heritage  has been confirmed.', 'booking_confirmation', FALSE, '2026-05-22 12:43:36.108122+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('013bbb35-24b1-46eb-9178-5aefaa611984', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Himalayan Retreat — Bandipur Heritage .', 'new_booking', FALSE, '2026-05-22 12:43:36.110425+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('f940182f-a803-49b9-a196-df2a18f2a096', '36ecf3c3-7a77-4ed1-ac67-a908a019e09a', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-23 22:04:15.378706+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('a9ce1743-8fa4-46ac-834c-7931a18c6873', '36ecf3c3-7a77-4ed1-ac67-a908a019e09a', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-23 22:04:17.77437+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('49432cd9-8d7d-48f6-a941-261c3bde3045', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Himalayan Retreat — Bandipur Heritage  has been confirmed.', 'booking_confirmation', FALSE, '2026-05-23 22:34:29.177587+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('4d96089c-efe3-417d-985a-cf375a8fcde9', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'New Booking Received! 🥳', 'adam jampa just booked Himalayan Retreat — Bandipur Heritage .', 'new_booking', FALSE, '2026-05-23 22:34:29.180339+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('381e9abe-9b14-4898-93d2-9d66e4d64746', '6d675123-04cc-4267-a356-4e9bd384b04a', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-24 01:36:08.123151+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('957b52fa-dea0-4398-a6a5-ae874288279e', '6d675123-04cc-4267-a356-4e9bd384b04a', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-24 01:36:09.956325+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('a4149b31-ff05-48b4-9822-d9cc7c904761', '6d675123-04cc-4267-a356-4e9bd384b04a', 'Property Approved ✅', 'Your property "Snow Peak Guest House" has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-24 01:40:10.921796+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('83586663-f0e7-4fec-972c-4bcd5570f798', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Snow Peak Guest House has been confirmed.', 'booking_confirmation', FALSE, '2026-05-24 01:41:59.215785+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('832dd038-d47c-42ad-90b6-ff5768a7cc7a', '6d675123-04cc-4267-a356-4e9bd384b04a', 'New Booking Received! 🥳', 'adam jampa just booked Snow Peak Guest House.', 'new_booking', FALSE, '2026-05-24 01:41:59.217744+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('6f1954c6-bb50-492e-a448-422ba7b26d34', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Snow Peak Guest House has been confirmed.', 'booking_confirmation', FALSE, '2026-05-24 01:42:52.962807+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('df3985e7-38cc-4bfc-b90b-6d0ea3ca19cb', '6d675123-04cc-4267-a356-4e9bd384b04a', 'New Booking Received! 🥳', 'adam jampa just booked Snow Peak Guest House.', 'new_booking', FALSE, '2026-05-24 01:42:52.96477+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('123a2d53-c903-4b60-8834-0119cab61d1f', '4bcf4e3a-f721-4816-a053-045843bbb68f', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-24 11:34:57.838655+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b55df236-c1b3-4845-b3e4-d60947839edc', '4bcf4e3a-f721-4816-a053-045843bbb68f', 'Property Approved ✅', 'Your property "Langtang Mountain View Lodge" has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-24 11:38:23.637512+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('15f8eaa5-cb45-4941-aeab-8ae3281d1826', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'Booking Confirmed! 🎉', 'Your stay at Langtang Mountain View Lodge has been confirmed.', 'booking_confirmation', FALSE, '2026-05-24 11:42:17.677344+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('697d918d-49c8-4d98-ac28-cd438937acfd', '4bcf4e3a-f721-4816-a053-045843bbb68f', 'New Booking Received! 🥳', 'adam jampa just booked Langtang Mountain View Lodge.', 'new_booking', FALSE, '2026-05-24 11:42:17.680355+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('7926274b-1f1a-4942-8adb-7b140a025cb4', '6f9fe2cd-14a3-40a1-9685-77572be3b6bc', 'Booking Confirmed! 🎉', 'Your stay at Langtang Mountain View Lodge has been confirmed.', 'booking_confirmation', FALSE, '2026-05-25 20:15:49.841011+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('b727aa88-e884-4aea-ac10-2a2348a04bab', '4bcf4e3a-f721-4816-a053-045843bbb68f', 'New Booking Received! 🥳', 'Piyush Rauniyar just booked Langtang Mountain View Lodge.', 'new_booking', FALSE, '2026-05-25 20:15:49.845911+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('c5097042-93bc-4e83-b3b2-254fb0d15b51', '6f9fe2cd-14a3-40a1-9685-77572be3b6bc', 'Booking Confirmed! 🎉', 'Your stay at Langtang Mountain View Lodge has been confirmed.', 'booking_confirmation', FALSE, '2026-05-25 20:18:44.842347+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('f3165779-4d61-4c12-a1a8-27319638a3bb', '4bcf4e3a-f721-4816-a053-045843bbb68f', 'New Booking Received! 🥳', 'Piyush Rauniyar just booked Langtang Mountain View Lodge.', 'new_booking', FALSE, '2026-05-25 20:18:44.845648+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('540b820f-15f0-4f12-b871-7b9d15c19651', '495763ef-3ea6-4540-9bf2-6258d0706f3b', 'Property Approved ✅', 'Your property "suncity aprtment " has been approved and is now visible to guests!', 'listing', FALSE, '2026-05-25 20:40:33.882222+05:45');
INSERT INTO public.notifications (id, user_id, title, message, type, is_read, created_at) VALUES ('2680e1d0-323b-45d9-a3b9-e35a2d681f74', '27d9d921-46b2-4ee3-901e-31765e9f3dc1', 'KYC Approved', 'Your KYC verification has been approved! You are now a verified host.', 'success', FALSE, '2026-05-25 20:47:49.955172+05:45');


--
-- Data for Name: password_resets; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.password_resets (user_id, token_hash, expires_at, created_at) VALUES ('eecec47f-fed1-4039-a03f-5acc2e6b7980', '707d49c00fa1f9c9e1e81d8112a10b37cbb2c0685a543bfe4cbc46c9cd4eb6f2', '2026-03-26 19:34:29.925+05:45', '2026-03-26 19:19:29.925113+05:45');
INSERT INTO public.password_resets (user_id, token_hash, expires_at, created_at) VALUES ('2644e831-bcc6-4407-93fa-35d90afad5ae', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', '2026-03-26 19:35:08.22+05:45', '2026-03-26 19:20:08.221128+05:45');
INSERT INTO public.password_resets (user_id, token_hash, expires_at, created_at) VALUES ('1710d4d4-62a1-41a6-9ff9-0e9758fbebbc', 'b2b8de3b2ba8b344400fa6f932abac465c7dda9411d83f7bbd19657cc08e0788', '2026-03-29 20:08:38.225+05:45', '2026-03-29 19:53:38.225241+05:45');
INSERT INTO public.password_resets (user_id, token_hash, expires_at, created_at) VALUES ('44e679a8-5258-473a-b814-ed353106a16e', '3f3440b131bd38ddae2ac4328111b98614736477cae2a6d24b3ea7fda863b3ad', '2026-04-07 10:29:59.24+05:45', '2026-04-07 10:14:59.241376+05:45');
INSERT INTO public.password_resets (user_id, token_hash, expires_at, created_at) VALUES ('51e17920-40ba-4be7-aa59-b053d32aaca0', '4bf4bd4a377c2bc4b9b1bcce83151dacf2da528a7fddf0f4e01bb8903a938209', '2026-04-18 12:05:19.571+05:45', '2026-04-18 11:50:19.57242+05:45');


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('c7c6fbf7-f3e9-4876-821c-c549b734237b', '589d89ff-ac59-4fc0-a317-5ac1cee6fad3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 37.38, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-04-18 01:47:55.599877+05:45', '2026-04-18 01:47:55.599877+05:45', NULL, 4972, 0, 'khalti', 'EHQyEbiVgQ9AnK7DQhrGJD');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('86acb8d6-b159-4133-b693-1cb3363b5ed2', 'a793c3f1-9c18-4d15-b91b-9b9a407cff87', '51e17920-40ba-4be7-aa59-b053d32aaca0', 53.98, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-16 11:51:32.70621+05:45', '2026-05-16 11:51:32.70621+05:45', NULL, 7180, 0, 'khalti', 'MXKSsEc88DKNELDXLi55mZ');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('b5757763-2c5a-4638-b101-3f61053470bd', '07d1e9ca-a2c8-4871-93c0-e2d2ab02881a', '51e17920-40ba-4be7-aa59-b053d32aaca0', 26.99, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-16 13:23:04.739894+05:45', '2026-05-16 13:23:04.739894+05:45', NULL, 3590, 0, 'khalti', 'cNHJW82cudxp58rnRJALC8');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('34a23a25-7372-4945-9643-8b7d8b5d62c3', 'c80569bb-8f2e-4d87-997f-ac4c95c68f44', '51e17920-40ba-4be7-aa59-b053d32aaca0', 74.77, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-04-18 03:00:05.420773+05:45', '2026-04-18 03:00:05.420773+05:45', 'cs_test_a1dLj86JOeKWZYFG96KDrHDj9iV0BoBkbVOTK6XrulV2Sm85XQQoP1NWXk', 9944, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('e88eaa95-ae60-4b0d-9e5b-c1399a239a3e', '57fae878-e842-43f0-ba90-0edf930f8ec3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 149.53, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-18 09:02:21.544666+05:45', '2026-05-18 09:02:21.544666+05:45', NULL, 19888, 0, 'khalti', 'MGJWLhvRVbdjExdmJPWE7A');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('235ebf90-1b68-4234-8b09-6dc52d45f01a', '7f330891-3371-4e05-876d-efa27973073d', '51e17920-40ba-4be7-aa59-b053d32aaca0', 46.73, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-06 12:34:23.090562+05:45', '2026-05-06 12:34:51.709945+05:45', 'pi_3TTzGpB3zcE3rD2u1ihdSonc', 6215, 4673, 'khalti', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('e5ad7e9c-eb36-4fc4-8c3a-28a1bbd4caec', '2fca1504-255d-44f8-8f8c-e3275a388ae3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 130.84, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-04-19 08:03:19.063238+05:45', '2026-04-19 08:03:19.063238+05:45', NULL, 17402, 0, 'khalti', 'DryjtG6WQpoLRKMDZ4pX2b');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('95aac058-73d9-454a-a5c1-25cdbccf012a', '27a099f2-589e-4056-9ea2-f0d6254dd1c1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 18.69, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-21 21:30:01.363738+05:45', '2026-05-22 08:49:58.958231+05:45', NULL, 2486, 0, 'khalti', 'aAz3zdGJtETkLwbzLw7fQ3');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('1be0d828-4d8f-46a9-aec2-1eb9e2ac57ba', 'b01e6af4-362c-4d02-9389-e4d22ed3dabc', '51e17920-40ba-4be7-aa59-b053d32aaca0', 140.19, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-12 23:13:49.414778+05:45', '2026-05-12 23:31:03.24457+05:45', NULL, 18645, 0, 'khalti', 'JEqiLiDKjmYCpkwdrkTnR4');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('664e5382-3f96-4743-9bfc-ca896d8635bf', '863e6468-374d-49bb-a6a3-d954672f8884', '51e17920-40ba-4be7-aa59-b053d32aaca0', 149.53, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-13 00:07:00.206328+05:45', '2026-05-13 00:07:00.206328+05:45', NULL, 19888, 0, 'khalti', 'LDrtyZPvPiWeCpHFLY6PpK');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('d9ca6a57-c7dc-454f-ad4e-144e0d656ea0', '54000a13-cfd5-4ed6-b6f4-6290fd278511', 'e4f69ef6-570e-45cd-a559-fd99612a5849', 18.69, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-04-20 19:12:55.274986+05:45', '2026-04-20 19:12:55.287461+05:45', 'pi_3TOHrjB3zcE3rD2u0ftn54HB', 2486, 1869, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('80ee19ba-6f38-47af-a260-6da5707fb936', '75d39a82-3028-4706-8e3d-52c26255aa06', '51e17920-40ba-4be7-aa59-b053d32aaca0', 93.46, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-13 00:14:20.130727+05:45', '2026-05-13 00:14:20.130727+05:45', NULL, 12430, 0, 'khalti', 'K2XBY6PCKfU6WMv7dRjnBS');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('6a5a4bf4-b9a1-45cd-abfa-4fb560cb8965', '98d777c6-0a6d-43ab-aeb5-dde933000722', '51e17920-40ba-4be7-aa59-b053d32aaca0', 112.15, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-13 23:14:01.928211+05:45', '2026-05-13 23:14:01.928211+05:45', NULL, 14916, 0, 'khalti', 'muwwT5FotnRBiMs8hGq48B');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('15749b76-9b6e-48b8-bfd6-46d330b1e28b', '376222f1-646c-40ef-b1b1-70b91d6245b3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 140.19, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-14 00:08:24.902112+05:45', '2026-05-14 00:12:59.791028+05:45', NULL, 18645, 0, 'khalti', 'iwenLm54MS6gv9kZnAEEgi');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('d0252726-3807-4c52-b50a-12e9b1fa369e', 'b5f4e183-3d4e-403c-a567-3f6f86de6084', '51e17920-40ba-4be7-aa59-b053d32aaca0', 93.46, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-14 00:35:36.301035+05:45', '2026-05-14 00:37:01.256615+05:45', NULL, 12430, 0, 'khalti', 'A4UZX3TTrVhgcB6qemovRP');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('04075ba5-a48f-481a-b7e9-02699b68f3e7', '9c9e0dc6-14d0-4059-9dd2-87e95b460f71', '51e17920-40ba-4be7-aa59-b053d32aaca0', 112.15, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-14 01:20:38.39724+05:45', '2026-05-14 01:20:38.39724+05:45', NULL, 14916, 0, 'khalti', 'r8iScHkFrqbSGQGykVGqH6');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('83f81fd7-e314-4e85-afaa-13935c217446', '9d4d0572-ac59-4e8f-8139-803e780bdb5b', '51e17920-40ba-4be7-aa59-b053d32aaca0', 1822.44, 'USD', 'STRIPE', 'succeeded', NULL, '2026-04-22 09:19:52.305882+05:45', '2026-04-22 09:20:14.350681+05:45', NULL, 242385, 0, 'khalti', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('4a0bb371-f823-420b-87da-e41f83dc3772', 'e9113a4b-58b7-4a90-bed8-0689102e7998', '51e17920-40ba-4be7-aa59-b053d32aaca0', 74.77, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-14 10:00:49.479206+05:45', '2026-05-14 10:02:13.41204+05:45', NULL, 9944, 0, 'khalti', 'pmpwQU5TLWDVbcLQwaEkZK');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('3447cc27-eb2a-4124-8e85-33306bf9f14f', '443d304f-cbe0-47e6-8701-f087e5454187', '51e17920-40ba-4be7-aa59-b053d32aaca0', 37.38, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-14 19:17:06.924007+05:45', '2026-05-14 19:17:06.924007+05:45', NULL, 4972, 0, 'khalti', 'SFm8UvjAjJmJR5ww52DAzc');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('b3de8be8-3d44-49a8-9c0a-2aaf2733a8ae', '3036e929-db6f-4988-ab92-dd499b2e4995', '51e17920-40ba-4be7-aa59-b053d32aaca0', 149.53, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-14 19:28:19.517597+05:45', '2026-05-14 19:28:19.517597+05:45', 'cs_test_a1U0WXVaGCsIx3kAHSEDsoEN1SEwmFfiGTUnCXnAtIsxVTs0mpJbZrfy9o', 19888, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('d1dbd94d-6f52-4a2c-9223-f195fd835fcc', 'f770ed5e-3fa4-4b80-bb3d-d06e57b6029a', '51e17920-40ba-4be7-aa59-b053d32aaca0', 224.30, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-14 19:37:15.965202+05:45', '2026-05-14 19:38:05.168245+05:45', NULL, 29832, 0, 'khalti', 'VC3YnfMtZPToo54K8KqaRT');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('17baabfb-b86e-4329-9ca8-4bb3bab660d4', 'd2a5bdc1-03f5-4850-821f-595bfab9e985', '19db48df-4aa7-4062-a049-4be5ff99fb9c', 336.45, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 13:20:41.653673+05:45', '2026-05-15 13:20:41.653673+05:45', NULL, 44748, 0, 'khalti', 'gPnziQbgacHafacz3BUgQ6');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('2a4ea54a-2c42-4d73-9075-b272ebcb1c04', 'c59f85af-e348-4e97-822e-c08fdb5003e1', 'd73e9d2f-a858-4b32-b6cf-fb5bb053be16', 65.75, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:13:06.493291+05:45', '2026-05-15 17:13:06.493291+05:45', NULL, 8745, 0, 'khalti', '3ToGRwW8acgjJSrTJXZjr8');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('2f15a648-82a3-480a-bb38-5cefba4d1278', '4a79e712-87a3-4ee5-82d7-5a3c0318d628', 'd73e9d2f-a858-4b32-b6cf-fb5bb053be16', 43.83, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:21:22.716638+05:45', '2026-05-15 17:21:22.716638+05:45', NULL, 5830, 0, 'khalti', 'LTXVRuC52w47EXe4NJJdJo');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('b13cc937-d69d-48fd-80cc-5767659ec6bc', '3880db60-74b8-44ef-a06d-537c8ad7911e', '51e17920-40ba-4be7-aa59-b053d32aaca0', 2827.17, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:34:30.257735+05:45', '2026-05-15 17:34:30.257735+05:45', 'cs_test_a1Kb9uIDn1lMRdDwkqKeBj2RpdgQn3YJNJNk5GlxIptxmMRExsyx3WugYt', 376014, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('4057856a-5fdf-4228-bdbe-d3b9e88e811c', 'cfb68c5e-dbba-419f-b6a1-c6bfc62a5960', '51e17920-40ba-4be7-aa59-b053d32aaca0', 29.91, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:50:33.144524+05:45', '2026-05-15 17:50:33.144524+05:45', 'cs_test_a1F9Ukzb9kL15YaE8Bg1L6xs9vPbAOvZBoL0DKaxty2qCNqxbLMZzCDh5x', 3978, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('c219f387-2fc3-4afb-b2f1-b6003d437b5f', 'b9c10fef-db56-4df5-bb26-3aa628413da9', '51e17920-40ba-4be7-aa59-b053d32aaca0', 29.91, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:55:24.066882+05:45', '2026-05-15 17:55:24.066882+05:45', 'cs_test_a1sotFbHeSwT8exHYErv8aM7W4xxG9aoEe82GZPyotCrc3524fhjGwyzvT', 3978, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('394e4f14-b4e4-406c-b876-79be9176ec8c', 'c6779bbb-2bba-4e9d-bf84-d742f223c6d9', '51e17920-40ba-4be7-aa59-b053d32aaca0', 65.41, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-22 12:43:00.298078+05:45', '2026-05-22 12:43:28.185204+05:45', NULL, 8700, 0, 'khalti', 'LanoCCQxToHohTVxLFm2v3');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('b0bfc437-9380-4929-8b43-e1f119990eaa', 'fffc70ea-b8c2-4310-ba89-37dbab3603ee', '51e17920-40ba-4be7-aa59-b053d32aaca0', 21.92, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-15 18:01:41.516798+05:45', '2026-05-15 18:02:47.767883+05:45', 'pi_3TXKgEB3zcE3rD2u0XqgypNx', 2915, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('76732673-550f-4345-b688-ed1b44f676d1', 'bb01d4c9-df97-4ca2-8f04-a0e0d172a9ec', '51e17920-40ba-4be7-aa59-b053d32aaca0', 93.44, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-23 19:53:26.25309+05:45', '2026-05-23 19:53:26.25309+05:45', 'cs_test_a1dM1f9jbdpyIbolgHonZ83TQKzEp4w2OeUACwMnajE2YNLViwlXWyPUrB', 12428, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('c9129b37-08c8-4987-b848-8df51a0a2ab4', '766a1c10-148b-4adf-b083-0b38505ccaf3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 9.35, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-04-28 13:54:45.476684+05:45', '2026-04-28 14:12:58.419664+05:45', 'pi_3TR6zqB3zcE3rD2u1jWbqePm', 1243, 935, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('73e15a79-6176-4f3c-a076-024882184aef', '06755fce-c9f3-4280-947e-59d3a2ae9890', '51e17920-40ba-4be7-aa59-b053d32aaca0', 93.40, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-24 01:41:26.058334+05:45', '2026-05-24 01:42:45.121026+05:45', NULL, 12422, 0, 'khalti', 'aMcrWWictcPGJoh74jkGQE');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('b3306d1b-32d6-486e-b65d-7e8166cd4381', 'a5febac9-68ae-437b-840c-74f826875726', '6f9fe2cd-14a3-40a1-9685-77572be3b6bc', 149.46, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-25 20:15:08.164922+05:45', '2026-05-25 20:18:37.717772+05:45', NULL, 19878, 0, 'khalti', 'YXxnJyF7hbRvPwFAkL7ezc');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('82487def-caea-419b-9569-10a8dce094cd', '0a705b90-0213-49d0-a908-c80af64a41a6', '51e17920-40ba-4be7-aa59-b053d32aaca0', 37.38, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-12 23:06:00.166933+05:45', '2026-05-12 23:06:00.166933+05:45', NULL, 4972, 0, 'khalti', 'EhMuFCmWFGvyg5JFGugQMC');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('13afa8d0-ded0-45ce-84b0-3e2b569c3b7b', '1509b046-d40b-47db-afda-c5077216c2af', '51e17920-40ba-4be7-aa59-b053d32aaca0', 74.77, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-12 23:31:42.575373+05:45', '2026-05-12 23:31:42.575373+05:45', NULL, 9944, 0, 'khalti', 'B3PziQwbpVfmevNRzQxDEL');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('73d576c8-360a-44d2-9fec-2866080fcd15', 'e522be2f-3281-424a-9da8-1b9f74803d97', '51e17920-40ba-4be7-aa59-b053d32aaca0', 971.97, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-13 00:07:17.555649+05:45', '2026-05-13 00:07:17.555649+05:45', NULL, 129272, 0, 'khalti', 'QNeULXqLN88rTqC3nmkqhJ');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('9bc5c8e2-a9da-4cb7-beed-f22bd77bbb94', '743b997e-95cd-4a6f-abdb-495e0a6969f9', '51e17920-40ba-4be7-aa59-b053d32aaca0', 56.08, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-13 00:18:27.601372+05:45', '2026-05-13 00:18:27.601372+05:45', NULL, 7458, 0, 'khalti', 'j3yj5igPzguPHmDUpvxVn9');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('f01ba395-4e86-4298-bf8f-0016cda54183', '7bc66078-a339-41ef-ae60-153c7a67d0f3', '51e17920-40ba-4be7-aa59-b053d32aaca0', 224.30, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-13 23:29:45.740416+05:45', '2026-05-13 23:40:24.863052+05:45', NULL, 29832, 0, 'khalti', 'xDuF36MFku5xLNYDB4TbSE');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('700f2e7d-1471-486c-be76-662fc01ec4ee', '3419f6e8-80cb-489f-a3c8-2a95a989cad0', 'd5e767eb-7c5c-4be1-bf2c-7cfe34778d41', 224.30, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-14 00:21:04.60899+05:45', '2026-05-14 00:21:04.60899+05:45', NULL, 29832, 0, 'khalti', 'WZwum3DiB8aRpbKWK6ewpM');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('06157d9d-e0ec-4886-b271-c663b842cc3d', '4c2fcc1b-9ebd-4768-adac-abf8e31edce1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 327.11, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-14 00:59:21.115037+05:45', '2026-05-14 01:06:12.319263+05:45', NULL, 43505, 0, 'khalti', 'iGjzA6iw6CjyDBjMRV5rrX');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('fe994a68-f822-4ede-bcf2-c8cbb9f6e7cd', 'f51c657f-cc01-412e-ba6d-098c2dc4dec6', '51e17920-40ba-4be7-aa59-b053d32aaca0', 560.75, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-14 09:14:07.51277+05:45', '2026-05-14 09:21:08.24907+05:45', NULL, 74580, 0, 'khalti', '25PR7SedS9DEbSGE72gUYa');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('c6aba46e-366a-41ec-9f39-89a3b49cda65', 'b7f9c226-46b6-478c-9831-56bfe8b2bf3b', '51e17920-40ba-4be7-aa59-b053d32aaca0', 355.14, 'USD', 'STRIPE', 'succeeded', NULL, '2026-04-18 01:59:28.088481+05:45', '2026-04-18 01:59:59.654916+05:45', NULL, 47234, 0, 'khalti', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('c8bfa05a-6040-445b-ab19-b1b5104a6ecc', 'b9cf096e-d94f-45cb-979c-717aeadab771', '51e17920-40ba-4be7-aa59-b053d32aaca0', 130.84, 'USD', 'STRIPE', 'succeeded', NULL, '2026-04-18 12:02:20.580411+05:45', '2026-04-18 12:02:54.634226+05:45', NULL, 17402, 0, 'khalti', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('ad52de25-fbcf-4f84-b1e5-53ff9b0e791c', '8d660b66-50db-4b97-acb0-5596eaea6189', '51e17920-40ba-4be7-aa59-b053d32aaca0', 130.84, 'USD', 'STRIPE', 'succeeded', NULL, '2026-04-19 08:10:30.700195+05:45', '2026-04-19 08:11:00.230553+05:45', NULL, 17402, 0, 'khalti', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('b59beb38-ec2a-4618-bd1e-727f328a4694', 'f6fd6812-430c-4e36-9d41-874a94b8fd25', '51e17920-40ba-4be7-aa59-b053d32aaca0', 149.53, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-14 11:37:07.884552+05:45', '2026-05-14 12:09:06.636968+05:45', NULL, 19888, 0, 'khalti', 'ZaGk6o7ssaZSD5p45xSau9');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('2ce4ec6c-5e82-436a-a966-37d59aa139f9', '4f9f03ab-2d6b-455a-92e7-07940cbd8d9d', '51e17920-40ba-4be7-aa59-b053d32aaca0', 280.38, 'USD', 'STRIPE', 'succeeded', NULL, '2026-04-21 21:48:56.944018+05:45', '2026-04-21 21:49:40.623773+05:45', NULL, 37290, 0, 'khalti', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('7ae3b40b-a4d2-4dae-b732-3fba5b616595', '4d91b3a6-e75f-4598-91b4-4f8cc26de920', '51e17920-40ba-4be7-aa59-b053d32aaca0', 186.92, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-14 19:18:24.010562+05:45', '2026-05-14 19:18:24.010562+05:45', NULL, 24860, 0, 'khalti', 'SZviGtqYc5ggyvcaHTL87B');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('7603ba1a-3d02-4dcb-9b14-73247d369ee3', 'db94343a-3d2c-47a9-8953-d0a721d3f295', '51e17920-40ba-4be7-aa59-b053d32aaca0', 4345.83, 'USD', 'STRIPE', 'succeeded', NULL, '2026-04-22 13:17:31.12335+05:45', '2026-04-22 13:18:04.716878+05:45', NULL, 577995, 0, 'khalti', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('5c924c79-6d07-414c-b1ab-30eee3898e58', '895afeca-4760-4e90-b93a-c726ca478ace', '51e17920-40ba-4be7-aa59-b053d32aaca0', 224.30, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-14 19:30:04.057726+05:45', '2026-05-14 19:30:04.057726+05:45', 'cs_test_a1zvDmONlssnEr8xTvWL167GpWrnI8K2YxlQJVfmuSnmwTKBTlzeUnCEhF', 29832, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('63612463-9058-432b-8d2a-3d01cee0bb2f', '747342b3-4096-4e0f-8c80-e545e0b881f3', '19db48df-4aa7-4062-a049-4be5ff99fb9c', 37.38, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 13:19:44.701429+05:45', '2026-05-15 13:19:44.701429+05:45', NULL, 4972, 0, 'khalti', 'WJ6aPy66rjoTf4wwfJVL6F');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('72dfacbc-79f0-48d5-b3d2-80b52819aeea', '17a0b955-5a3a-4f4b-bee0-3f188d369199', 'd73e9d2f-a858-4b32-b6cf-fb5bb053be16', 65.75, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:17:39.234565+05:45', '2026-05-15 17:17:39.234565+05:45', 'cs_test_a1UupU8FuqS4ukQqsbGnHpPxxSePQiMv1b4XpIOF08Ds26krzUktArZxY2', 8745, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('a264a923-887e-4411-9c4c-cc925ce69c24', 'b9436903-ccb0-40ae-a79d-30947bfa4be1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 241.08, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:29:33.288538+05:45', '2026-05-15 17:29:33.288538+05:45', NULL, 32064, 0, 'khalti', 'VvLcBVgjc3fKKjiTu4ex9P');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('b1301c6f-5a95-4f56-bdec-e94a79b399cc', 'ee8f9070-4ade-4887-9d1e-71b042b0ea41', '51e17920-40ba-4be7-aa59-b053d32aaca0', 89.72, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:38:01.074645+05:45', '2026-05-15 17:38:01.074645+05:45', NULL, 11933, 0, 'khalti', 'Rz4P4f4TtLzEgCmuX6myLi');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('b0e620d4-9302-4f48-9c4e-ca328c94228e', 'e70b704b-6380-4031-b947-90a162c6bb8e', '51e17920-40ba-4be7-aa59-b053d32aaca0', 59.81, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:53:58.078775+05:45', '2026-05-15 17:53:58.078775+05:45', NULL, 7955, 0, 'khalti', '4wLNZwGjymxUrTm8tAFY7R');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('6c810fca-cf75-4fc8-aed8-b985d88a3f99', 'af5fb239-1675-43ab-8d81-33065ea6e1f1', '51e17920-40ba-4be7-aa59-b053d32aaca0', 46.73, 'USD', 'STRIPE', 'succeeded', NULL, '2026-04-25 00:43:05.6536+05:45', '2026-04-25 00:43:29.1848+05:45', 'pi_3TPovRB3zcE3rD2u0LhfCr1r', 6215, 4673, 'khalti', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('9e3cc0fc-c759-4ee8-b8ca-cbf05cb7482c', 'b7c2a9a2-5682-4dd5-8a86-963a98a62e31', '51e17920-40ba-4be7-aa59-b053d32aaca0', 26.99, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 17:58:35.126443+05:45', '2026-05-15 17:58:35.126443+05:45', 'cs_test_a1atcdZntUMXBFZ079KxVChUuhEFrpVAHggAON1EBnxiTrXn0P9LJlixaz', 3590, 0, 'stripe', NULL);
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('03c238f8-eb3b-4e2a-bdc1-5bb59f52ae68', '884553d2-379b-4a2d-a716-d74bd79589a6', '51e17920-40ba-4be7-aa59-b053d32aaca0', 26.99, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-15 20:57:01.268333+05:45', '2026-05-15 20:57:01.268333+05:45', NULL, 3590, 0, 'khalti', 'wJDVjNg6Ko3ELfoW358RSj');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('52798d56-ac89-4f9a-ac21-b2dabd095435', 'e7791f8b-976f-44eb-8673-f04eebed0225', '51e17920-40ba-4be7-aa59-b053d32aaca0', 53.98, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-16 12:02:34.15609+05:45', '2026-05-16 12:02:34.15609+05:45', NULL, 7180, 0, 'khalti', 'bmAc3tR8o9y4d7bxtgzHJa');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('4859b03b-62c9-442b-a601-f4d093171bd8', '66c921c1-4d33-4dfb-8191-030a1a332312', '51e17920-40ba-4be7-aa59-b053d32aaca0', 53.98, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-17 14:14:00.426723+05:45', '2026-05-17 14:14:00.426723+05:45', NULL, 7180, 0, 'khalti', 'FPRWui7J2AQqVGkbedpB3Z');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('193791c9-4eb2-4a1d-a3a9-15550a54bb70', '7383643a-97f7-4483-a6e0-1d52ffaeb288', '51e17920-40ba-4be7-aa59-b053d32aaca0', 224.30, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-18 11:22:08.843747+05:45', '2026-05-18 11:22:08.843747+05:45', NULL, 29832, 0, 'khalti', 'gsC6XNRUbt6fSSpYMsTEPG');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('6e54a616-46ae-48a2-b154-ed6ea63cf9ae', '5a3ac506-04ec-474f-90fb-bb94c0d64a83', '51e17920-40ba-4be7-aa59-b053d32aaca0', 186.88, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-22 10:21:06.716219+05:45', '2026-05-22 10:21:34.323959+05:45', NULL, 24855, 0, 'khalti', 'NLT7n4xNy6mTRFwZ46rmv7');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('659b90f8-c8e3-462c-9b6c-41c2633c2c32', '25fdeed4-df1f-4f3a-b0ba-04efb92dd550', '51e17920-40ba-4be7-aa59-b053d32aaca0', 46.72, 'USD', 'STRIPE', 'INITIALIZED', NULL, '2026-05-23 19:52:15.904689+05:45', '2026-05-23 19:52:15.904689+05:45', NULL, 6214, 0, 'khalti', 'uACH95Fff4BLEiayxLr2TE');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('457dc651-715f-4830-9a60-24190ae12b00', '2a17bfd7-86c0-4283-94a4-511fce3278b0', '51e17920-40ba-4be7-aa59-b053d32aaca0', 65.41, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-23 22:33:52.995636+05:45', '2026-05-23 22:34:20.610661+05:45', NULL, 8700, 0, 'khalti', '2tmGDwdM7FPmehYy4Zgdp8');
INSERT INTO public.payments (id, booking_id, user_id, amount, currency, provider, status, transaction_ref, created_at, updated_at, stripe_payment_intent_id, amount_npr, amount_usd_cents, gateway, khalti_pidx) VALUES ('d1519f71-dac8-49af-b7f6-2242de8a71e4', '5b6abc48-c2b4-4cb5-bd29-efed4c4a61e0', '51e17920-40ba-4be7-aa59-b053d32aaca0', 149.46, 'USD', 'STRIPE', 'succeeded', NULL, '2026-05-24 11:41:40.107655+05:45', '2026-05-24 11:42:10.66197+05:45', NULL, 19878, 0, 'khalti', 'SgYN5A5TKYW98bHszV3twH');


--
-- Data for Name: payouts; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: promotions; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: properties; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: property_amenities; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: property_images; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: property_verifications; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.reviews (id, booking_id, property_id, reviewer_id, rating, comment, created_at) VALUES ('99f6b972-b7ec-4a9f-b3d8-c3eb8630e156', 'c6779bbb-2bba-4e9d-bf84-d742f223c6d9', '774d63aa-c3da-4a87-9c1b-af4f1978137e', '51e17920-40ba-4be7-aa59-b053d32aaca0', 5, 'Excellent stay at Himalayan Retreat — peaceful location, clean rooms, and great hospitality!', '2026-05-24 00:50:59.377098');


--
-- Data for Name: tax_rules; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('2644e831-bcc6-4407-93fa-35d90afad5ae', 'testuser@example.com', '$argon2id$v=19$m=65536,t=3,p=4$IHgM3aEDc3dg4AmxI+Lwyg$Hn1h7xSvoAh1fMiwID4Xv/+JsPtjT4mcHp0kNT9QSZg', 'Test User', NULL, +1234567890, FALSE, FALSE, '2026-03-24 19:01:58.857058', '2026-03-24 19:01:58.857058', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('b84c7b18-286b-4023-a2c8-ebc0c89f96ae', 'newuser@example.com', '$argon2id$v=19$m=65536,t=3,p=4$FxL1Wa8ylOrQJVqCSNjc1A$PTpXQsXAXNKPW5idM/KjnvolJfQ0xcKuwnSlqAGRM/Y', 'New User', NULL, +9876543210, FALSE, FALSE, '2026-03-24 19:12:40.240245', '2026-03-24 19:12:40.240245', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('711fa513-cc76-43bc-8ad1-64e2e5bed236', 'sh@test.com', '$argon2id$v=19$m=65536,t=3,p=4$u71IqjeStkryR1dKD6Cx0A$nLdHjTlhp8Y541JWlWVloA2wWXjnLajN5ANU6Lj7ago', 'Superhost Test', NULL, NULL, FALSE, FALSE, '2026-03-24 19:24:04.280854', '2026-03-24 19:24:04.280854', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('eecec47f-fed1-4039-a03f-5acc2e6b7980', 'piyush@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$ye+2/xe0QZOPnURk0sXOGw$cJ/ChDA4CVTM1ijfRUkOyHkX+PmitWR8ULDy/soMdrs', 'piyush rauniyar', NULL, NULL, FALSE, FALSE, '2026-03-24 20:37:20.448599', '2026-03-24 20:37:20.448599', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('9963ee8e-25a4-4667-bfc4-b92c3fe6cf02', 'test@example.com', '$2a$12$f6R6Sm4WMcZg8VVnr46fx.FgDMgTjbWsYjTf7RCO72gCZw6NLxKZW', 'Test User', NULL, 9800000000, FALSE, FALSE, '2026-03-26 18:54:05.679143', '2026-03-26 18:54:05.679143', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('c83951a8-6ffc-40d4-9ccd-d9c0f198cab1', 'user@example.com', '$2a$12$055xDXeeiANr6g82zDyrSuUNzkwhj9OLM3XKFiDct.futfTgx3s.K', 'John Doe', NULL, +9779800000000, FALSE, FALSE, '2026-03-27 11:10:57.594319', '2026-03-27 11:10:57.594319', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('44e679a8-5258-473a-b814-ed353106a16e', 'piyushrauniyar16@gmail.com', '$2a$12$Vxr70/pTr0lKhxeRBiyFdOLsSmBzIKwtEooTINIRb4ox6.C1hZb9e', 'piyush rauniyar', NULL, +9779800000000, FALSE, FALSE, '2026-03-27 11:27:02.386937', '2026-03-27 11:39:29.283553', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('f5e9e342-8e36-48f8-ac05-9d988ddf0be0', 'piyushrouniyar12@gmail.com', '$2a$12$2JWaCPFxkksOMc9EjmGMw.7oUWqSq.Z0jlP5zJm00hEAFM0phaFYO', 'Piyush Rauniyar', NULL, 9800000000, FALSE, TRUE, '2026-03-27 11:41:36.082107', '2026-03-27 11:46:36.245185', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('6346a42b-c3c1-40df-a564-32e51c576e38', 'piyushtest123@gmail.com', '$2a$12$JK8.xRol3CA8wQlvG1VMNO6KXNqdeo7NwyCoaTYlwptyawuuON18K', 'Piyush Test', NULL, 9876543210, FALSE, FALSE, '2026-03-28 09:16:52.264077', '2026-03-28 09:16:52.264077', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('88251106-5ccb-4d5b-9e09-e9954add3acc', 'veritest@gmail.com', '$2a$12$dWohfkev/srqTZnIvfgmPO6DPhQtNPSVIxcfmTvcse49UY8Im2Jra', 'Veri Test', NULL, 9876543210, FALSE, FALSE, '2026-03-28 09:20:06.44301', '2026-03-28 09:20:06.44301', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('22d1839f-9b47-461c-949a-449caca6d5b8', 'curltest@gmail.com', '$2a$12$ws/pMaANGuGZe.w737S.CuXBBqmSx8TQkkQeb9iuAZJi5qYMfRBJa', 'Curl Test', NULL, 9876543210, FALSE, TRUE, '2026-03-28 09:23:33.551254', '2026-03-28 09:23:54.088455', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('fd1fd990-8b17-452b-af13-d46b93674379', 'lockout@gmail.com', '$2a$12$EfW2CZRvWgf0zvVTkPbyCu1fIl0hIjiIiYahC6HMAxCxGobWswxEO', 'Lockout Test', NULL, 9876543211, FALSE, FALSE, '2026-03-28 09:24:00.013', '2026-03-28 09:24:00.013', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('9300ba4e-5a75-4db7-92c3-32b7bc01f004', 'locktest1774669197@gmail.com', '$2a$12$4JQE6fKqXZkyHOA3MyUMWegBppHoJaiQcOxwWuMs26H6B1O0PBOO.', 'Lock Test', NULL, 9876543213, FALSE, FALSE, '2026-03-28 09:24:57.298208', '2026-03-28 09:24:57.298208', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('dcd53311-471c-42dd-b837-f9e40bf3808f', 'piyushrouniyar4@gmail.com', '$2a$12$foX5lyHzQIPsNuRIgyb9metfjczcZuIYyWEtQ1ZJAxg331KrjeIkW', 'Piyush Rauniyar', NULL, 9861574567, FALSE, FALSE, '2026-03-28 09:30:40.436402', '2026-03-28 09:30:40.436402', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('54db095f-faa3-4944-a1e5-e134b66aecfa', 'uujsahjpfyayvepnzm@fxavaj.com', '$2a$12$nMFhwjOVA1VlpxMENeQDJuNthx1KymK6ujhLUuA0t3J0nVHQofmCK', 'Jane Doe', NULL, 9800000000, FALSE, FALSE, '2026-03-28 23:24:14.992492', '2026-03-28 23:24:14.992492', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('cc99450f-1a2a-4e6b-977b-7d8a2d1ef07a', 'nakobac740@exahut.com', '$2a$12$hEiypWirrLKsL/jZKi1T6OpSDQjQcfl35aOwzwfxzNlqnd924TsKe', 'Jane Doe', NULL, 9800000000, FALSE, FALSE, '2026-03-28 23:25:40.194746', '2026-03-28 23:25:40.194746', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('0177407e-316a-4fc3-9bda-9ce607986aac', 'tagaho4641@smkanba.com', '$2a$12$LN1.sjUaV5C7JfnCjOBdXuxie6wv.WciA.bq1xtRcHNbX2avVNf3i', 'Jane Doe', NULL, 9800000000, FALSE, FALSE, '2026-03-28 23:29:03.35436', '2026-03-28 23:39:31.164223', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('151e1edb-5755-4a46-a01b-67305076fccf', 'cas56136@laoia.com', '$2a$12$jGBME6ehjoMtcLwxOO11luwAqDSLkIVb8YIos7krIe1wsop5CA6cG', 'Piyush Rauniyar', NULL, 9861574567, FALSE, FALSE, '2026-03-29 13:23:33.587416', '2026-03-29 13:23:33.587416', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('1710d4d4-62a1-41a6-9ff9-0e9758fbebbc', 'lojek85852@smkanba.com', '$2a$12$b1htJNKvnaWLblBOXmjGyObqHomWkHtn8jUPCnVUXZMX2F8HkHZOu', 'ram bhadur', NULL, 9861574567, FALSE, FALSE, '2026-03-29 19:50:46.543194', '2026-03-29 19:50:46.543194', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('be148b0c-f3c4-47e8-a59d-dc95211d1f2e', 'rdi48658@laoia.com', '$2a$12$Ev2FEsBMwz6FnODgdC9pR.a6pyZVDdG8e7KoopEtfHbJPCSB.eQSe', 'Piyush Rauniyar', NULL, 9861574567, FALSE, TRUE, '2026-03-29 20:02:04.654843', '2026-03-29 20:03:06.670681', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('b4492126-c441-4839-8dae-90dc7efc869b', 'banewob186@exahut.com', '$2a$12$Swhnm8T.6HHTIuzcNhR7F.jwVd5bHeersTJgVn..h0aZ/.U6NV.vy', 'john', NULL, 9897986765, FALSE, TRUE, '2026-03-30 18:38:56.466701', '2026-03-30 18:39:29.039874', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('688fa55c-62ff-46f2-8cf2-a9d172a658fc', 'cawip80434@fengnu.com', '$2a$12$1xysnIFiZhuJRrVaP9kIU.KZWAnG4AxfWgrdab4DpkFeVkVeFu4fm', 'Piyush Rauniyar', NULL, 9897986765, FALSE, TRUE, '2026-03-30 21:11:29.935633', '2026-03-30 21:12:04.440216', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('46330ab9-f934-4845-83a8-579bb65d5268', 'gjn69615@laoia.com', '$2a$12$euMUHshUfOMHFYupjXDmgeq0952kXiNklgdPe/aogZ6Qy/xsJ3vfO', 'Piyush Rauniyar', NULL, 9861574567, FALSE, TRUE, '2026-03-31 19:03:47.068192', '2026-03-31 19:05:06.489796', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('9c5878d1-cbe8-47cc-8964-18a547347ed0', 'sexaro2715@algarr.com', '$2a$12$XCYPRowSNqJ/KcE7JGUXQOyk6RiaMVveFVKhihvOvQEfqB1WcJk66', 'Piyush Rauniyar', NULL, 9897986765, FALSE, TRUE, '2026-04-01 12:34:14.771452', '2026-04-01 12:34:40.493733', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('90edcd7a-b2b0-4373-a971-d4a8655ed77e', 'boxam36136@algarr.com', '$2a$12$VbwmTdQmkgSq0KW8Vfw7w.WcB7xAqvYmm.69B77nVhMAZvjXfMfS.', 'Piyush Rauniyar', NULL, 9897986765, FALSE, TRUE, '2026-04-01 12:45:11.079849', '2026-04-01 12:45:37.765558', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('6f9fe2cd-14a3-40a1-9685-77572be3b6bc', 'np02cs4a240050@bicnepal.edu.np', '$2a$12$iSDookGZOzM4LunZmupgxejhBFnsqe357OMjw9zX46LnXM7jRs.Zi', 'Piyush Rauniyar', 'https://res.cloudinary.com/djd9xro7e/image/upload/v1779719667/grihastha/media/atz5ojrjstvge5bouz8b.webp', 9897986765, FALSE, TRUE, '2026-04-05 16:33:36.136137', '2026-05-25 20:19:42.932042', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('d29ecd03-c510-430a-b77e-d966d57d78cb', 'piyushrauniyar12@gmail.com', '$2a$12$lgnbykeRuZGBrVDzxHJF1OZdHNp1vs4jS/LDb4r6rDBhDrHJTcCYC', 'Piyush Rauniyar', NULL, 9861574567, FALSE, FALSE, '2026-04-07 10:17:47.341933', '2026-04-07 10:17:47.341933', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('58029367-f35e-48b4-9509-4e02a5fa4f01', 'uzj43143@laoia.com', '$2a$12$S5KRyiMoXPnvBtLKcbPFsOjJF3BJuRzOOMu0zDg.Va4wvoUBbCSr.', 'hari prasad', NULL, 9861574567, FALSE, TRUE, '2026-04-07 10:27:17.800387', '2026-04-07 10:28:01.239313', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('74d31bcd-911d-4c53-9bee-32f21f8c53b4', 'piq03341@laoia.com', '$2a$12$G4He9OCoDUNUzKuVlwdrt.4pkVedfpbBs39oRADbmQrYJJLadVB4O', 'hari prasad', NULL, 9861574567, FALSE, TRUE, '2026-04-08 13:45:10.60794', '2026-04-08 13:46:05.117426', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('cba03ff7-7ba2-4522-878f-027aee8d85c9', 'vulture7635066@mailshan.com', '$2a$12$neraxmJ3iJdrXwW4V8tZtuDpaab/f4EcCzbNfmf12OGwsW737Kvy.', 'hari prasad', NULL, 9861574567, FALSE, TRUE, '2026-04-11 23:16:52.834458', '2026-04-11 23:17:32.420748', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('e4f69ef6-570e-45cd-a559-fd99612a5849', 'falcon2027512@aminating.com', '$2a$12$8V8o.msXfdfGB.XlxCvC9eFiOa.XLcJa33yRwwpxowS1dm7EpRleS', 'ram bhadur', NULL, 987654321, FALSE, TRUE, '2026-04-16 21:55:17.410087', '2026-04-16 21:56:01.816901', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('10ba51fa-8939-4933-8fc0-2293ec04a19a', 'testuser717338@gmail.com', '$2a$12$3uA/rzkfRWqChq.7aTGfmudpcvQ7czIkB9qAdQ8K.Z.hlLWu1GiMq', 'Test User', NULL, 9841321603, FALSE, FALSE, '2026-04-17 14:18:43.832565', '2026-04-17 14:18:43.832565', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('ca08a722-1ed8-42d0-8831-1bb5fb997373', 'testuser_fixed_123@gmail.com', '$2a$12$zj.COtguKVIEXGyYIm0k4egHkiEIYaK8wQeVfBpc9WqSLL3CwrNwW', 'Test User', NULL, 9841000000, FALSE, FALSE, '2026-04-17 14:21:07.377404', '2026-04-17 14:21:07.377404', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('e03ffdd3-8803-4ff6-812c-d81cd8c86724', 'user1776415040712@gmail.com', '$2a$12$b.9osRcavN5NbD.HwxHAKuBwrk31eSh6qVcrV7eZqG30IgGJPVH7K', 'Test User', NULL, 9841278627, FALSE, FALSE, '2026-04-17 14:22:20.986993', '2026-04-17 14:22:20.986993', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('d5e767eb-7c5c-4be1-bf2c-7cfe34778d41', 'verified_user_123@gmail.com', '$2a$12$Q3dv9n8P/ZBhXq/TvEZ3UuAthG5jQZBP.UtADUXPBbAllRyljishW', 'Verified User', NULL, 9841123456, FALSE, FALSE, '2026-04-17 14:24:47.261844', '2026-04-17 14:24:47.261844', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('43804971-6c4f-4132-9dee-03ecc858d811', 'superhost_test@example.com', '$argon2id$v=19$m=65536,t=3,p=4$TNxIelaho9CmbgJGAEeyAg$aNAYwCxjQ7fLMm6OGmg6sXnGhNw33trXz7wCBx2MY60', 'Test Superhost', NULL, NULL, FALSE, FALSE, '2026-03-24 19:23:57.144834', '2026-05-13 13:00:45.709096', FALSE, NULL, NULL, NULL, 'NPR', 'not_submitted');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('1b97f51e-164d-41ab-bc04-9fa00fee777f', 'myq86277@laoia.com', '$2a$12$c8RA29yh5AO8qJf18xDbJu/q8QETwQPc2.ZAD7ULjKczmTZYrKZhm', 'Piyush Rauniyar', NULL, 9861574567, FALSE, FALSE, '2026-04-18 19:44:39.322715', '2026-04-18 19:44:39.322715', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('ccebccbd-fb82-4b0a-91d7-fcc0a76fe7c1', 'curlhost@gmail.com', '$2a$12$U7sJyKxKoNg/BEVEdkABcudcp7Ccnff/dIBZ8Ya54gGXih/wlPKbi', 'Curl Host', NULL, 9876543212, FALSE, FALSE, '2026-03-28 09:24:39.504083', '2026-05-13 13:00:45.713237', TRUE, NULL, NULL, NULL, 'NPR', 'not_submitted');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('da5726cb-0b31-48a4-b1ce-5b90d137fc3c', 'otter77309332@draughtier.com', '$2a$12$3QDKEGvT91LPd5gZhDKiCu/HOC9/HbhbObqWKbJfBTF8uyhMqdGgy', 'aden smith', NULL, NULL, FALSE, FALSE, '2026-04-17 23:55:34.0731', '2026-05-13 13:00:45.713752', FALSE, NULL, NULL, NULL, 'NPR', 'not_submitted');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('7a5dfdb1-b9bb-4a59-bc9a-66eba46706c6', 'seal79313080@pixoledge.net', '$2a$12$2PCDFsoqIO5wWq6b7j7Vo.LKcVwgywmXLnq3YQD.Vq00aJHARWPdS', 'madan bhadur', NULL, 98765043210, FALSE, TRUE, '2026-05-15 00:13:09.278339', '2026-05-15 00:18:28.258932', TRUE, NULL, NULL, NULL, 'NPR', 'approved');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('19db48df-4aa7-4062-a049-4be5ff99fb9c', 'jevofo7098@dardr.com', '$2a$12$ejLy5pHnEugIrEEQacaCROG9KD2GdkT7/smnfv2jx.S4dCHxpNZPe', 'pratik luitel', NULL, 9876543210, FALSE, TRUE, '2026-05-15 13:18:45.665519', '2026-05-15 13:18:45.665519', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('51e17920-40ba-4be7-aa59-b053d32aaca0', 'grihasthaguest@piyushrauniyar.tech', '$2a$12$/GnnuVM3dqtIv9hBZvkRDu8C.vD102.2NFqUcG.Yfhsu5sVzZIRWK', 'adam jampa', 'https://res.cloudinary.com/djd9xro7e/image/upload/v1779562309/grihastha/media/bul2ffslso098arcdxam.webp', 1234567890, FALSE, TRUE, '2026-04-18 01:32:48.976429', '2026-05-24 00:36:52.518348', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('495763ef-3ea6-4540-9bf2-6258d0706f3b', 'grihasthahost@piyushrauniyar.tech', '$2a$12$r3R/8A9axlG3vKDy/isLGuZBgdr2jUPwza9fkfzYZ8ilQS4TzeILy', 'aden smith', 'https://res.cloudinary.com/djd9xro7e/image/upload/v1778760040/grihastha/media/nbft0y5soqsmyahchoih.webp', 1234567890, FALSE, TRUE, '2026-04-18 00:24:51.015104', '2026-05-14 17:45:40.858429', TRUE, 'https://res.cloudinary.com/djd9xro7e/image/upload/v1776451190/grihastha/documents/x7v7gxxv8w41dcebmsee.jpg', NULL, NULL, 'NPR', 'approved');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('5ba7d1e6-7ef6-4f10-a675-2f0ea3addb98', 'testuser_1778774524728@example.com', '$2a$12$AkkAZGTaNWIF8ZI7r2i9bODxto3viwHRqNcRPaRZ1grotV9AFdi8e', 'Test User', NULL, 1234567890, FALSE, FALSE, '2026-05-14 21:47:04.979018', '2026-05-14 21:47:04.979018', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('c2714386-f4b3-4108-badf-f955923d9f4e', 'eb6dd88060899a1b@30minemail.com', '$2a$12$QDH75LckwChrX7EDgmTfr.ZU.QRv.fx.whC6iR1NXlRnheOo/eYmq', 'Harka sampang', NULL, NULL, FALSE, FALSE, '2026-05-14 21:56:35.826623', '2026-05-14 21:56:35.826623', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('20bbbfe8-76ad-470b-b55c-7409b09aee9e', 'c5aa1804f4c1bd5f@30minemail.com', '$2a$12$KITBFHZnJC4hqcxvVQs.guXyci8wd1pImGy0ecgj730kyHh1p1pk6', 'harka haladar', NULL, 9876543210, FALSE, FALSE, '2026-05-14 22:00:33.178026', '2026-05-14 22:00:33.178026', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('93e09740-e820-47f4-ac38-b45df7c490b6', 'gecko600962@pixoledge.net', '$2a$12$XOVIoQbhTlY3REVBJSoTmOM5LYP.wXdmW7/ReGf6TM1pCkm0CL.pe', 'piyush rauniyar', NULL, 9876543210, FALSE, TRUE, '2026-05-14 22:16:35.420617', '2026-05-14 22:16:35.420617', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('c6f292cd-b6c7-4717-9f78-71399f46cfcc', 'squirrel81515@draughtier.com', '$2a$12$OA6WTT8Pj76T3LieMLK4e.HbnrN89mUJBD9dVbhGnAJswoQUSBety', 'harka sampang', NULL, 0987654321, FALSE, TRUE, '2026-05-14 22:20:28.647121', '2026-05-14 22:28:52.692329', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('f41196bb-ecb0-4209-b856-8b6a03ac55ae', 'badger098579@mailshan.com', '$2a$12$qWzkxU1eC9giic5ICguROOnTAtC/FXW26sQl50WHT1EfF1RgIvs4e', 'Piyush Rauniyar', NULL, 9876543210, FALSE, FALSE, '2026-05-14 22:31:07.218754', '2026-05-14 22:31:07.218754', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('b49d2e30-c396-43ce-b5e1-f41c8174fa70', 'chimpanzee05851708@pixoledge.net', '$2a$12$1LdtcTo9GPCRAvsacmRnM.BtdUB6z00Hy3CqPkaTd7.87CTG5aGcK', 'Piyush Rauniyar', NULL, 9876543210, FALSE, FALSE, '2026-05-14 22:37:35.632082', '2026-05-14 22:39:37.23554', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('b7d47f46-66ae-444a-9d2a-96d1078372b7', 'weasel7155629@pixoledge.net', '$2a$12$62n2PnO6Ng9irx5AlWb88uBxeC7ilREccjbNlHkCjV2/n6slbRIV.', 'arbish bantawa rai', NULL, 9876543210, FALSE, TRUE, '2026-05-15 17:01:37.941195', '2026-05-15 17:05:10.396844', TRUE, NULL, NULL, NULL, 'NPR', 'approved');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('3ca32288-2d94-4d82-add5-5bf70e3c842d', 'porpoise91852@mailshan.com', '$2a$12$kuhKSqRrYkBIVsgj8Nqx8.u.0d6DO3ZWyAugEt9.EAqVe3zaDbiZ6', 'belun shah', 'https://res.cloudinary.com/djd9xro7e/image/upload/v1778779492/grihastha/media/erxlnziwrza7uc04f1so.webp', 9876543210, FALSE, TRUE, '2026-05-14 23:03:22.223859', '2026-05-14 23:09:56.857933', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('c6e28a47-5e17-45ef-a844-ee41df695425', 'chimpanzee891260@pixoledge.net', '$2a$12$WWM5lMxUkXQ36N8qXUBsvORI/QXPEDLb305GJuI/Q8ggypjJY9Qdq', 'mahabir pun', NULL, 09876543211, FALSE, FALSE, '2026-05-14 23:13:39.536164', '2026-05-14 23:13:39.536164', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('d73e9d2f-a858-4b32-b6cf-fb5bb053be16', 'vendace97462188@pixoledge.net', '$2a$12$f2DFpEyqvxWIHiF1o7W22uSvPI8nrcLiNcd7vqo.zVja4zBF2tQiW', 'Piyush Rauniyar', NULL, 9861574567, FALSE, TRUE, '2026-05-15 17:12:11.990502', '2026-05-15 17:12:11.990502', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('4d603844-bd15-4789-925a-f3f442cd9580', 'unicorn284993@mailshan.com', '$2a$12$I3IdEDrv/smvyYW4sz5oueZQV92hD.vaUOfQIqQaFzGQgb/Ku3Xeq', 'miraj dhungana', NULL, 09876543210, FALSE, FALSE, '2026-05-14 23:15:32.761076', '2026-05-14 23:15:32.761076', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('d5ed0d2c-c004-435f-a46f-2d35e9d1700a', 'get85812@laoia.com', '$2a$12$DBrdf3/1S0kyKOawXZKuDeYOlHDE6PIDqjEh3OetptI.EoR3eIE3O', 'Piyush Rauniyar', NULL, 1234567891, FALSE, FALSE, '2026-05-14 23:17:53.497688', '2026-05-14 23:17:53.497688', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('b9a53735-0a23-4903-8f58-b34e7d13d94c', 'lyrebird854974@pixoledge.net', '$2a$12$5D19KH/Ions/xjOlpTPVK.XEY.BTr98n63pXkrmWnAO7UECWZMEgu', 'Piyush Rauniyar', NULL, 09876543210, FALSE, FALSE, '2026-05-14 23:22:37.29224', '2026-05-14 23:22:37.29224', TRUE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('ff1d286c-7b05-49e8-a150-11cd873d2166', 'dolphin561893@draughtier.com', '$2a$12$73wKM7qxnQc/mkB4iUJ0NeWXvCR9aTyfgSn5M240X0LHDMekB3U72', 'hari bhadur', 'https://res.cloudinary.com/djd9xro7e/image/upload/v1778782999/grihastha/media/gar3hedmgnyltmpgpynl.webp', 09876543210, FALSE, TRUE, '2026-05-15 00:05:22.960747', '2026-05-15 00:08:23.6145', FALSE, NULL, NULL, NULL, 'NPR', 'NOT_SUBMITTED');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('322cf49c-33ed-4d71-89e8-dc82efe91854', 'duck24281132@draughtier.com', '$2a$12$nTK3lMhNvtbiBPyb3wGmQuCTCor1iK4OxoDnfSjTbpS/fGKLSkhtm', 'harka hawaldar', NULL, 1234567890, FALSE, TRUE, '2026-05-21 21:22:09.157679', '2026-05-21 21:23:58.494495', TRUE, NULL, NULL, NULL, 'NPR', 'approved');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('6d675123-04cc-4267-a356-4e9bd384b04a', 'elk853418@aminating.com', '$2a$12$gjusDuSRt/5cS0s/k7HrbOY8a7WFhbx4Jldm1hsBWqLVclO4C6/jC', 'Piyush Rauniyar', NULL, 9876543210, FALSE, TRUE, '2026-05-24 01:33:54.699501', '2026-05-24 01:36:09.955351', TRUE, NULL, NULL, NULL, 'NPR', 'approved');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('7981c6da-c8b7-438b-9f43-ff3b337a9ce1', 'mockingbird70396716@draughtier.com', '$2a$12$4qAcn4mo.X60hWIRTVO1yOMCzZK9Idwpj30shdEL2wFgQYI9mgmvq', 'Piyush Rauniyar', 'https://res.cloudinary.com/djd9xro7e/image/upload/v1779424687/grihastha/media/fyt0cqehepfm7haqpvvx.webp', 9876543210, FALSE, TRUE, '2026-05-22 10:14:59.065434', '2026-05-22 10:23:07.695852', TRUE, NULL, NULL, NULL, 'NPR', 'approved');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('36ecf3c3-7a77-4ed1-ac67-a908a019e09a', 'impala17823212@pixoledge.net', '$2a$12$TRsee0eCIOz8yevmPRWD.udAQ./8Jz4CTdpbZ3DVK/svEn4s69jlm', 'samay raina', 'https://res.cloudinary.com/djd9xro7e/image/upload/v1779553465/grihastha/media/vqmfuaeoguzsfzggll4l.webp', 9861574567, FALSE, TRUE, '2026-05-23 21:49:56.365633', '2026-05-23 22:09:25.806418', TRUE, NULL, NULL, NULL, 'NPR', 'approved');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('4bcf4e3a-f721-4816-a053-045843bbb68f', 'cormorant038021@mailshan.com', '$2a$12$/b.6MBg2BU8Ldmj378jdu.ng6gopkQkRX/d3YJwIJCRWGa5kuDCRO', 'Piyush Rauniyar', 'https://res.cloudinary.com/djd9xro7e/image/upload/v1779602529/grihastha/media/ei914laljcdhfbpg2tep.webp', 9807654321, FALSE, TRUE, '2026-05-24 11:33:09.44429', '2026-05-24 11:47:09.815339', TRUE, NULL, NULL, NULL, 'NPR', 'approved');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, phone, is_superhost, is_verified, created_at, updated_at, is_host, verification_document, fcm_token, bio, preferred_currency, kyc_status) VALUES ('27d9d921-46b2-4ee3-901e-31765e9f3dc1', 'tapir02750732@draughtier.com', '$2a$12$Ur24g/LZHWsqoJqSp.GhAe/n2QYWPS0/aOR8ShwWogusHVIGwwmtm', 'ram poudel', NULL, 98765432120, FALSE, TRUE, '2026-05-25 20:46:12.128682', '2026-05-25 20:47:49.950149', TRUE, NULL, NULL, NULL, 'NPR', 'approved');


--
-- Data for Name: wishlist_items; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.wishlist_items (id, wishlist_id, listing_id, created_at) VALUES ('94504e31-3dd6-4842-9bf5-70ed3001639c', '840bc9e9-1ff0-44a6-b209-a04d177aadfb', 'd449f28d-1c86-4788-b95b-7f5cf1cd7d1b', '2026-04-25 01:29:37.347175+05:45');


--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: public; Owner: piyushrauniyar
--

INSERT INTO public.wishlists (id, user_id, name, created_at) VALUES ('840bc9e9-1ff0-44a6-b209-a04d177aadfb', '51e17920-40ba-4be7-aa59-b053d32aaca0', 'nepal trip', '2026-04-25 01:25:02.235169+05:45');


--
-- Name: admin_password_resets admin_password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.admin_password_resets
    ADD CONSTRAINT admin_password_resets_pkey PRIMARY KEY (admin_id);


--
-- Name: admins admins_email_key; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_email_key UNIQUE (email);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: amenities amenities_name_key; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT amenities_name_key UNIQUE (name);


--
-- Name: amenities amenities_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: calendar_blocks calendar_blocks_listing_id_block_date_key; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.calendar_blocks
    ADD CONSTRAINT calendar_blocks_listing_id_block_date_key UNIQUE (listing_id, block_date);


--
-- Name: calendar_blocks calendar_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.calendar_blocks
    ADD CONSTRAINT calendar_blocks_pkey PRIMARY KEY (id);


--
-- Name: cohosts cohosts_listing_id_cohost_id_key; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.cohosts
    ADD CONSTRAINT cohosts_listing_id_cohost_id_key UNIQUE (listing_id, cohost_id);


--
-- Name: cohosts cohosts_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.cohosts
    ADD CONSTRAINT cohosts_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: disputes disputes_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.disputes
    ADD CONSTRAINT disputes_pkey PRIMARY KEY (id);


--
-- Name: email_verifications email_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_pkey PRIMARY KEY (user_id);


--
-- Name: fee_config fee_config_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.fee_config
    ADD CONSTRAINT fee_config_pkey PRIMARY KEY (id);


--
-- Name: host_bank_details host_bank_details_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.host_bank_details
    ADD CONSTRAINT host_bank_details_pkey PRIMARY KEY (host_id);


--
-- Name: host_kyc host_kyc_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.host_kyc
    ADD CONSTRAINT host_kyc_pkey PRIMARY KEY (id);


--
-- Name: kyc_documents kyc_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_pkey PRIMARY KEY (id);


--
-- Name: listings listings_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_pkey PRIMARY KEY (id);


--
-- Name: message_templates message_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.message_templates
    ADD CONSTRAINT message_templates_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: password_resets password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_pkey PRIMARY KEY (user_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: payments payments_unique_booking; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_unique_booking UNIQUE (booking_id);


--
-- Name: payouts payouts_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT payouts_pkey PRIMARY KEY (id);


--
-- Name: promotions promotions_code_key; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_code_key UNIQUE (code);


--
-- Name: promotions promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: property_amenities property_amenities_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.property_amenities
    ADD CONSTRAINT property_amenities_pkey PRIMARY KEY (property_id, amenity_id);


--
-- Name: property_images property_images_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.property_images
    ADD CONSTRAINT property_images_pkey PRIMARY KEY (id);


--
-- Name: property_verifications property_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.property_verifications
    ADD CONSTRAINT property_verifications_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_booking_id_key; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_booking_id_key UNIQUE (booking_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: tax_rules tax_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.tax_rules
    ADD CONSTRAINT tax_rules_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wishlist_items wishlist_items_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_pkey PRIMARY KEY (id);


--
-- Name: wishlist_items wishlist_items_wishlist_id_listing_id_key; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_wishlist_id_listing_id_key UNIQUE (wishlist_id, listing_id);


--
-- Name: wishlists wishlists_pkey; Type: CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_pkey PRIMARY KEY (id);


--
-- Name: idx_admins_email; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_admins_email ON public.admins USING btree (email);


--
-- Name: idx_bookings_check_in; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_bookings_check_in ON public.bookings USING btree (check_in);


--
-- Name: idx_bookings_check_out; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_bookings_check_out ON public.bookings USING btree (check_out);


--
-- Name: idx_bookings_created_at; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_bookings_created_at ON public.bookings USING btree (created_at DESC);


--
-- Name: idx_bookings_guest_id; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_bookings_guest_id ON public.bookings USING btree (guest_id);


--
-- Name: idx_bookings_listing_id; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_bookings_listing_id ON public.bookings USING btree (listing_id);


--
-- Name: idx_bookings_status; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_bookings_status ON public.bookings USING btree (status);


--
-- Name: idx_kyc_status; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_kyc_status ON public.kyc_documents USING btree (status);


--
-- Name: idx_listings_category; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_listings_category ON public.listings USING btree (category);


--
-- Name: idx_listings_created_at; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_listings_created_at ON public.listings USING btree (created_at DESC);


--
-- Name: idx_listings_host_id; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_listings_host_id ON public.listings USING btree (host_id);


--
-- Name: idx_listings_status; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_listings_status ON public.listings USING btree (status);


--
-- Name: idx_properties_available; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_properties_available ON public.properties USING btree (available);


--
-- Name: idx_properties_city; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_properties_city ON public.properties USING btree (city);


--
-- Name: idx_properties_country; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_properties_country ON public.properties USING btree (country);


--
-- Name: idx_properties_host_id; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_properties_host_id ON public.properties USING btree (host_id);


--
-- Name: idx_properties_price; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_properties_price ON public.properties USING btree (price_per_night);


--
-- Name: idx_property_amenities_amenity; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_property_amenities_amenity ON public.property_amenities USING btree (amenity_id);


--
-- Name: idx_property_images_primary; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_property_images_primary ON public.property_images USING btree (property_id, is_primary);


--
-- Name: idx_property_images_property; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_property_images_property ON public.property_images USING btree (property_id);


--
-- Name: idx_reviews_property_id; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_reviews_property_id ON public.reviews USING btree (property_id);


--
-- Name: idx_reviews_reviewer_id; Type: INDEX; Schema: public; Owner: piyushrauniyar
--

CREATE INDEX idx_reviews_reviewer_id ON public.reviews USING btree (reviewer_id);


--
-- Name: bookings bookings_update_timestamp; Type: TRIGGER; Schema: public; Owner: piyushrauniyar
--

CREATE TRIGGER bookings_update_timestamp BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.update_bookings_updated_at();


--
-- Name: listings listings_update_timestamp; Type: TRIGGER; Schema: public; Owner: piyushrauniyar
--

CREATE TRIGGER listings_update_timestamp BEFORE UPDATE ON public.listings FOR EACH ROW EXECUTE FUNCTION public.update_listings_updated_at();


--
-- Name: properties trg_properties_updated_at; Type: TRIGGER; Schema: public; Owner: piyushrauniyar
--

CREATE TRIGGER trg_properties_updated_at BEFORE UPDATE ON public.properties FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: users trg_users_updated_at; Type: TRIGGER; Schema: public; Owner: piyushrauniyar
--

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_password_resets admin_password_resets_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.admin_password_resets
    ADD CONSTRAINT admin_password_resets_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id);


--
-- Name: bookings bookings_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: calendar_blocks calendar_blocks_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.calendar_blocks
    ADD CONSTRAINT calendar_blocks_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: cohosts cohosts_cohost_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.cohosts
    ADD CONSTRAINT cohosts_cohost_id_fkey FOREIGN KEY (cohost_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: cohosts cohosts_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.cohosts
    ADD CONSTRAINT cohosts_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- Name: conversations conversations_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE SET NULL;


--
-- Name: disputes disputes_raised_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.disputes
    ADD CONSTRAINT disputes_raised_by_fkey FOREIGN KEY (raised_by) REFERENCES public.users(id);


--
-- Name: email_verifications email_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: host_bank_details host_bank_details_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.host_bank_details
    ADD CONSTRAINT host_bank_details_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: host_kyc host_kyc_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.host_kyc
    ADD CONSTRAINT host_kyc_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: kyc_documents kyc_documents_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: kyc_documents kyc_documents_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: kyc_documents kyc_documents_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.admins(id);


--
-- Name: kyc_documents kyc_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: listings listings_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: message_templates message_templates_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.message_templates
    ADD CONSTRAINT message_templates_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_admin_id_fkey FOREIGN KEY (sender_admin_id) REFERENCES public.admins(id);


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: password_resets password_resets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payouts payouts_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT payouts_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: promotions promotions_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: properties properties_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: property_amenities property_amenities_amenity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.property_amenities
    ADD CONSTRAINT property_amenities_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES public.amenities(id) ON DELETE CASCADE;


--
-- Name: property_amenities property_amenities_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.property_amenities
    ADD CONSTRAINT property_amenities_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: property_images property_images_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.property_images
    ADD CONSTRAINT property_images_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: property_verifications property_verifications_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.property_verifications
    ADD CONSTRAINT property_verifications_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: wishlist_items wishlist_items_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: wishlist_items wishlist_items_wishlist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_wishlist_id_fkey FOREIGN KEY (wishlist_id) REFERENCES public.wishlists(id) ON DELETE CASCADE;


--
-- Name: wishlists wishlists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: piyushrauniyar
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


