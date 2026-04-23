drop table if exists blogs;
drop table if exists discussion_messages;
drop table if exists discussions;
drop table if exists exercises;
drop table if exists quizz_questions;
drop table if exists quizzes;
drop table if exists certificates;
drop table if exists program_completions;
drop table if exists payments;
drop table if exists enrollments;
drop table if exists users;
drop table if exists teaching_groups;
drop table if exists course_modules;
drop table if exists program_modules;
drop table if exists lessons;
drop table if exists courses;
drop table if exists modules;
drop table if exists programs;


-- #1. Creating the main instances of the platform
create table programs (
	id bigint primary key generated always as identity,
	name varchar(255) unique not null,
	price numeric(10, 2) not null check (price >= 0),
	program_type varchar(255) not null,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


create table modules (
	id bigint primary key generated always as identity,
	--program_id bigint references programs (id) not null,
	name varchar(255) unique not null,
	description text not null,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now(),
	deleted_at timestamp default null--bool not null default false   !!!
	--unique (id, program_id)
);


create table courses (
	id bigint primary key generated always as identity,
	--module_id bigint references modules (id) not null,
	name varchar(255) unique not null,
	description text not null,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now(),
	deleted_at timestamp default null -- bool not null default false
	--unique (id, module_id)
);


create table lessons (
	id bigint primary key generated always as identity,
	course_id bigint references courses (id),-- not null,
	name varchar(255) not null unique,
	content text not null,
	video_url varchar(255) unique,-- not null,
	position int check (position > 0),-- not null,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now(),
	deleted_at timestamp default null, --bool not null default false,
	unique (id, course_id)
);


-- the following two tables are required for implementing the multi-to-multi connection type
-- between programs <-> modules and modules <-> courses
create table program_modules (
	--id bigint generated always as identity, 
	program_id bigint references programs (id) on delete cascade not null,
	module_id bigint references modules (id) on delete cascade not null,
	primary key (program_id, module_id)
);


create table course_modules (
	--id bigint generated always as identity,
	module_id bigint references modules (id) on delete cascade not null,
	course_id bigint references courses (id) on delete cascade not null,
	primary key (module_id, course_id)
);


-- #2. Users adding
create table teaching_groups (
	id bigint primary key generated always as identity,
	slug varchar(255) not null unique,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


create table users (
	id bigint primary key generated always as identity,
	teaching_group_id bigint references teaching_groups (id) on delete set null,
	name varchar(255) not null,
	email varchar(255) not null unique,
	password_hash text not null unique,	-- or bytea?..
	role varchar(10) not null default 'student' check (role in ('student', 'teacher', 'admin')),
	created_at timestamp not null default now(),
	updated_at timestamp not null default now(),
	deleted_at timestamp default null,
	unique (id, teaching_group_id)
);
	

-- #3. Implementing the users-platform interaction
create table enrollments (
	id bigint primary key generated always as identity,
	user_id bigint references users (id) not null,
	program_id bigint references programs (id) not null,
	status varchar(10) not null check (status in ('active', 'pending', 'cancelled', 'completed')),
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


create table payments (
	id bigint primary key generated always as identity,
	enrollment_id bigint references enrollments (id) not null,
	amount numeric(10, 2) not null check (amount >= 0), 
	status varchar(10) check (status in ('pending', 'paid', 'failed', 'refunded')),
	paid_at date not null default current_date,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


create table program_completions (
	id bigint primary key generated always as identity,
	user_id bigint references users (id) not null,
	program_id bigint references programs (id) not null,
	status varchar(10) not null check (status in ('active', 'completed', 'pending', 'cancelled')),
	started_at date not null default current_date,
	completed_at date not null default current_date,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


create table certificates (
	id bigint primary key generated always as identity,
	user_id bigint references users (id) not null,
	program_id bigint references programs (id) not null,
	url text not null,
	issued_at date not null default current_date,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


-- #4. Additional content
create table quizzes (
	id bigint primary key generated always as identity,
	lesson_id bigint references lessons (id) on delete set null,
	name varchar(255) not null,
	content text not null,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


/*create extension if not exists ltree;
create table quizz_questions (
	id bigint primary key generated always as identity,
	quizz_id bigint references quizzes (id) on delete set null,
	content text not null,
	path ltree not null unique,	-- for example '1.1' or '1.2.3' 
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);*/


create table exercises (
	id bigint primary key generated always as identity,
	lesson_id bigint references lessons (id) on delete set null,
	name varchar(255) not null,
	url text not null,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


-- #5. users social interaction
create table discussions (
	id bigint primary key generated always as identity,
	lesson_id bigint references lessons (id) on delete set null,
	user_id bigint references users (id) not null,
	text text not null,
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);


/*create table discussion_messages (
	id bigint primary key generated always as identity,
	discussion_id bigint references discussions (id) on delete set null,
	message text not null,
	path ltree not null unique, 
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);*/
	

create table blogs (
	id bigint primary key generated always as identity,
	user_id bigint references users (id) not null,
	name varchar(255) not null,
	content text not null,
	status varchar(15) not null check (status in ('created', 'in moderation', 'published', 'archived')),
	created_at timestamp not null default now(),
	updated_at timestamp not null default now()
);
