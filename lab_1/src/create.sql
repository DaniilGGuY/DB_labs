create schema if not exists mservice;

create table if not exists mservice.account (
	login text,
	password text,
	name text,
	surname text,
	patronic text,
	birthdate date,
	subscribe bool,
	phone text,
	mail text
);

create table if not exists mservice.musician (
	login text,
	name text,
	surname text,
	patronic text,
	followers integer,
	about text
);

create table if not exists mservice.producer (
	login text,
	name text,
	surname text,
	patronic text,
	followers integer,
	about text
);

create table if not exists mservice.track (
	id integer,
	count_listening integer,
	duration integer,
	lyrics text,
	year_of_issue integer
);

create table if not exists mservice.mus_prod (
	id_mus text,
	id_prod text
);

create table if not exists mservice.mus_track (
	id_mus text,
	id_track integer
);

create table if not exists mservice.user_mus (
	id_user text,
	id_mus text
);

create table if not exists mservice.user_track (
	id_user text,
	id_track integer
);

create table if not exists mservice.prod_track (
	id_prod text,
	id_track integer
);
