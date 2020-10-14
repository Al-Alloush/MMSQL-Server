

/*
CHECK (upload_type IN('img', 'file', 'video'))


use [master];
ALTER DATABASE StandardDB SET OFFLINE WITH ROLLBACK IMMEDIATE;
ALTER DATABASE StandardDB SET ONLINE;
DROP DATABASE StandardDB;
Create Database StandardDB


use StandardDB

IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'users')) 
BEGIN
    EXEC ('CREATE SCHEMA [users] AUTHORIZATION [dbo]')
END

IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'admins')) 
BEGIN
    EXEC ('CREATE SCHEMA [admins] AUTHORIZATION [dbo]')
END
*/
----------------------------------------------------------------
use StandardDB
/*
Blue Tables (8):
-	users.users
-	admins.table
-	admins.contact_type
-	admins.recipe_category
-	admins.report_category
-	admins.upload_type
-	admins.deleted_user
-	admins.progress_deleting_user
*/

create table users.users
(
	id uniqueidentifier not null default(newid()),
	username varchar(100) not null,
	first_name varchar(100) null,
	last_name varchar(100) null,
	register_date datetime not null default(getdate()),
	login_date datetime null,
	acc_verified bit not null default(0),
	token uniqueidentifier not null  default(newid())
	constraint PK_id_users  primary key (id),
	constraint UC_usernam_users unique (username)
);
create nonclustered index NC_user_user on users.users (username ASC);
GO

create table admins.tables
(
	id int not null identity(1,1),
	schemaa varchar(100) not null,
	name varchar(100) not null
	constraint PK_id_tables  primary key (id),
	constraint UC_name_tables unique (name)
);
insert into admins.tables (schemaa, name ) values 
('users','users'), ('admins','table'), ('admins','contact_type'), ('admins','recipe_category'),('admins','report_category'),
('admins','upload_type'), ('admins','deleted_user'), ('admins','progress_deleting_user'),

('admins','nutrient'), ('admins','ingredient'), ('admins','ingredient_nutrient'),

('users','recipe'),('users','report'),('users','blocked'),('users','followed'),('users','password'),('users','address'),
('users','devise'),('users','contact'),('users','message'),('users','upload'),('users','user_list'),

('users','comment'),('users','like_recipe'),('users','clone_recipe'),('users','user_recipe_list'),
('users','recipe_category_list'),('users','recipe_upload'),('users','stage'),

('users','stage_ingredient'),('users','like_comment'),('users','upload_stage')
GO

create table admins.contact_type
(
	id int not null identity(1,1),
	name varchar(100) not null,
	type_verified bit not null default(0)
	constraint PK_id_con_typ  primary key (id),
	constraint UC_name_con_typ unique (name)
);
insert into admins.contact_type (name, type_verified ) values 
('email', 1),  ('mobile', 1), ('website', 0)
GO

create table admins.recipe_category
(
	id int not null identity(1,1),
	name varchar(100) not null
	constraint PK_id_rec_cat  primary key (id),
	constraint UC_name_rec_cat unique (name)
);
insert into admins.recipe_category (name ) values 
('Soups'),  ('Salads'), ('Appetizers'), ('Beverages'), ('Vegetables'),
('Main Dishes'), ('Breads, Rolls'), ('Desserts'), ('Miscellaneous')
GO

create table admins.report_category
(
	id int not null identity(1,1),
	name varchar(100) not null
	constraint PK_id_rep_cat  primary key (id),
	constraint UC_name_rep_cat unique (name)
);
GO
create table admins.upload_type
(
	id int not null identity(1,1),
	name varchar(100) not null
	constraint PK_id_upl_typ  primary key (id),
	constraint UC_name_upl_typ unique (name)
);
GO
insert into admins.upload_type (name) values
('img'),('img_profile_wall'),('img_profile'),('file'), ('video')
GO

create table admins.deleted_user
(
	id uniqueidentifier not null,
	add_date datetime not null default(getdate())
	constraint PK_id_del_use  primary key (id)
);
GO
create table admins.progress_deleting_user
(
	id uniqueidentifier not null,
	add_date datetime not null default(getdate())
	constraint PK_id_pro_del  primary key (id)
);
GO

--------------

/*
-- this tables copyed from U.S. DEPARTMENT OF AGRICULTURE, for that use int ID
ingredient Tables (3):
-	admins.nutrient
-	admins.ingredient
-	admins.ingredient_nutrient
*/

create table admins.nutrient
(
	id int not null ,
	name varchar(255) not null,
	tagename varchar(100) not null,
	unit varchar(25) not null,
	decimals tinyint  not null
	constraint PK_id_nutrin  primary key (id)
);
GO
create table admins.ingredient
(
	id int not null ,
	name varchar(100) not null
	constraint PK_id_ingred  primary key (id),
	constraint UC_name_ingred unique (name)
);
create nonclustered index NC_name_ingred on admins.ingredient (name ASC);
GO

create table admins.ingredient_nutrient
(
	ingredient_id int not null ,
	nutrient_id int not null,
	value decimal(10,3) not null
	constraint PK_id_ing_nut  primary key (ingredient_id,nutrient_id ),
	constraint FK_ingrid_ing_nut foreign key (ingredient_id) references admins.ingredient(id),
	constraint FK_nitrid_ing_nut foreign key (nutrient_id) references admins.nutrient(id)
);
GO
--==============================================================
/*
Green Tables (11):
-	users.recipe
-	users.report
-	users.blocked
-	users.followed
-	users.password
-	users.address
-	users.devise
-	users.contact
-	users.message
-	users.upload
-	users.user_list
*/
create table users.recipe
(
	id uniqueidentifier not null default(newid()),
	author_id uniqueidentifier not null ,
	user_id uniqueidentifier not null,
	publish bit not null default(0),
	add_date datetime not null default(getdate()),
	title varchar(100) not null, 
	short_desc varchar(255) null,
	description text null
	constraint PK_id_recipe  primary key (id),
	constraint FK_author_recipe foreign key (author_id) references users.users(id),
	constraint FK_userid_recipe foreign key (user_id) references users.users(id)
);
create nonclustered index NC_author_recipe on users.recipe (author_id ASC);
create nonclustered index NC_userid_recipe on users.recipe (user_id ASC);
GO

create table users.report
(
	table_id int not null,
	id_in_table varchar(255) not null,
	user_id uniqueidentifier not null,
	report_catagoty_id int not null,
	add_date datetime not null default(getdate()),
	description text null
	constraint PK_tid_iit_report primary key (table_id, id_in_table),
	constraint FK_tableid foreign key (table_id) references admins.tables(id),
	constraint FK_userid foreign key (user_id) references users.users(id)
);
create nonclustered index NC_rep_cat_id on users.report (id_in_table ASC);
GO

create table users.blocked
(
	user_id uniqueidentifier not null,
	blocked_id uniqueidentifier not null,
	add_date datetime not null default(getdate())
	constraint PK_uid_bid_blocke  primary key (user_id, blocked_id),
	constraint FK_userid_blocke foreign key (user_id) references users.users(id),
	constraint FK_blocid_blocke foreign key (blocked_id) references users.users(id)
);
create nonclustered index NC_userid_blocke on users.blocked (user_id ASC);
create nonclustered index NC_blockid_blocke on users.blocked (blocked_id ASC);
GO
create table users.followed
(
	user_id uniqueidentifier not null,
	followed_id uniqueidentifier not null,
	add_date datetime not null default(getdate())
	constraint PK_uid_bid_follow  primary key (user_id, followed_id),
	constraint FK_userid_follow foreign key (user_id) references users.users(id),
	constraint FK_blocid_follow foreign key (followed_id) references users.users(id)
);
create nonclustered index NC_userid_follow on users.followed (user_id ASC);
create nonclustered index NC_blockid_follow on users.followed (followed_id ASC);
GO

create table users.password
(
	id uniqueidentifier not null default(newid()),
	user_id uniqueidentifier not null,
	password binary(64) not null,	-- 1--encrypted in one-way hashing algorithms SHA2_512 
									-- 2--password contains letters, numbers and special symbols
									-- Chack -1-,-2- by PROCEDURE CreateNewUserAccount
	salt uniqueidentifier not null, -- salt(unique text for each user, use uniqueidentifier for a salt)(uset for seset password)
	add_date datetime not null default(getdate()),
	token varchar(255) null  default(newid()), -- need it like varchar, because we need to sub some string from a random text if the token for mobile
	token_used bit default (1),
	default_pass bit not null default(1)
	constraint PK_id_passwo primary key (id),
	constraint FK_userid_passwo foreign key (user_id) references users.users(id)
);
create nonclustered index NC_userid_passwo on users.password (user_id ASC);
create nonclustered index NC_passwo_passwo on users.password (password ASC);
create nonclustered index NC_salt_passwo on users.password (salt ASC);
GO

create table users.address
(
	id uniqueidentifier not null default(newid()),
	user_id uniqueidentifier not null,
	street_name varchar(100) null,
	building_num  varchar(100) null,
	full_address varchar(255) not null,
	floor varchar(100) null,
	add_date datetime not NULL default(getdate()),
	verify bit not null default(0),
	default_addr bit not null default(1)
	constraint PK_id_addres primary key (id),
	constraint FK_userid_addres foreign key (user_id) references users.users(id)
);
create nonclustered index NC_userid_addres on users.address (user_id ASC);
GO

create table users.device
(
	id uniqueidentifier not null default(newid()),
	user_id uniqueidentifier not null,
	cooky_id varchar(255) unique not null,
	os_name varchar(100) null,
	os_version varchar(100) null,
	browser_name varchar(100) null,
	b_version varchar(100) null,
	location varchar(100) null,
	country varchar(100) null,
	city varchar(100) null,
	add_date datetime not null
	constraint PK_id_device primary key (id , user_id ),
	constraint FK_userid_device foreign key (user_id) references users.users(id)
);
GO

create table users.contact
(
	id uniqueidentifier not null default(newid()),
	contact varchar(255) not null,
	user_id uniqueidentifier not null,
	contact_type_id int not NULL,
	add_date datetime not null default(getdate()),
	token uniqueidentifier not null default(newid()),
	verified bit not null default(0),
	default_con bit not null default(1),
	publish bit not null default(0)
	constraint PK_id_contac primary key (id),
	constraint UC_contac_contac unique (contact, contact_type_id),
	constraint FK_userid_contac foreign key (user_id) references users.users(id),
	constraint FK_cotyid_contac foreign key (contact_type_id) references admins.contact_type(id)
);
create nonclustered index NC_userid_contac on users.contact (user_id ASC);
GO

create table users.message
(
	id uniqueidentifier not null default(newid()),
	sender_id uniqueidentifier not null,
	receiver_id uniqueidentifier not null,
	sent_date datetime not null default(getdate()),
	read_date datetime null,
	subject varchar(100) null,
	message text null,
	sender_deleted bit not null default(0),
	receiver_deleted bit not null default(0)
	constraint PK_id_messag primary key (id),
	constraint FK_sendid_messag foreign key (sender_id) references users.users(id),
	constraint FK_reciid_messag foreign key (receiver_id) references users.users(id)
);
GO

create table users.upload
(
	id uniqueidentifier not null default(newid()),
	user_id uniqueidentifier not null,
	uri varchar(255) not null,
	description varchar(255) null,
	upload_type int not null,
	add_date datetime not null default(getdate()),
	deleted bit not null default(0)
	constraint PK_id_upload  primary key (id)
	constraint FK_useid_upload foreign key (user_id) references users.users(id),
	constraint FK_upltyp_upload foreign key (upload_type) references admins.upload_type(id)
);
create nonclustered index NC_useid_upload on users.upload (user_id ASC);
GO

create table users.user_list
(
	id int not null identity(1,1),
	user_id uniqueidentifier not null,
	name varchar(100) not null
	constraint PK_id_use_lst primary key (id),
	constraint FK_useid_use_lst foreign key (user_id) references users.users(id)
);
create nonclustered index NC_useid_use_lst on users.user_list (user_id ASC);
GO
--==============================================================
/*
yellow Tables (8):
-	users.comment
-	users.recipe_share
-	users.like_recipe
-	users.clone_recipe
-	users.user_recipe_list
-	users.recipe_category_list
-	users.recipe_upload
-	users.stage

*/
create table users.comment
(
	id uniqueidentifier not null default(newid()),
	user_id uniqueidentifier not null,
	recipe_id uniqueidentifier not null,
	comment varchar(255) not null,
	add_date datetime not null default(getdate())
	constraint PK_id_coment primary key (id),
	constraint FK_userid_coment foreign key (user_id) references users.users(id),
	constraint FK_reciid_coment foreign key (recipe_id) references users.recipe(id)
);
create nonclustered index NC_userid_coment on users.comment (user_id ASC);
create nonclustered index NC_reciid_coment on users.comment (recipe_id ASC);
GO

create table users.recipe_share
(
	id uniqueidentifier not null default(newid()),
	user_id uniqueidentifier not null,
	recipe_id uniqueidentifier,
	add_date datetime not null default(getdate())
	constraint FK_id_recshr primary key (id),
	constraint FK_userid_recshr foreign key (user_id) references users.users(id),
	constraint FK_reciid_recshr foreign key (recipe_id) references users.recipe(id)
);
create nonclustered index NC_userid_recshe on users.recipe_share(user_id ASC)
create nonclustered index NC_reciid_recshe on users.recipe_share(recipe_id ASC)
GO

create table users.like_recipe
(
	user_id uniqueidentifier not null,
	recipe_id uniqueidentifier not null
	constraint PK_userid_postid_likpos primary key (user_id, recipe_id),
	constraint FK_userid_likpos foreign key (user_id) references users.users(id),
	constraint FK_postid_likpos foreign key (recipe_id) references users.recipe(id)
);
create nonclustered index NC_userid_likpos  on users.like_recipe (user_id ASC);
create nonclustered index NC_reciid_likpos on users.like_recipe (recipe_id ASC);
GO


create table users.clone_recipe
(
	recipe_id uniqueidentifier not null,
	clone_num int not null
	constraint PK_reciid_clo_rec primary key (recipe_id),
	constraint FK_reciid_clo_rec foreign key (recipe_id) references users.recipe(id)
);
GO

create table users.user_recipe_list
(
	recipe_id uniqueidentifier not null,
	user_id uniqueidentifier not null,
	list_id int not null,
	constraint PK_rulid_usreli primary key (recipe_id,user_id,list_id ),
	constraint FK_reciid_usreli foreign key (recipe_id) references users.recipe(id),
	constraint FK_userid_usreli foreign key (user_id) references users.users(id),
	constraint FK_listid_usreli foreign key (list_id) references users.user_list(id)
);
GO

create table users.recipe_category_list
(
	recipe_id uniqueidentifier not null,
	recipe_category_id uniqueidentifier not null
	constraint PK_reciid_re_ca_li primary key (recipe_id,recipe_category_id ),
	constraint FK_recaid_re_ca_li foreign key (recipe_id) references users.recipe(id)
);
GO

create table users.recipe_upload
(
	id uniqueidentifier not null default(newid()),
	recipe_id uniqueidentifier not null,
	upload_id uniqueidentifier not null
	constraint PK_id_rec_upl primary key (id),
	constraint FK_recaid_rec_upl foreign key (recipe_id) references users.recipe(id),
	constraint FK_uploid_rec_upl foreign key (upload_id) references users.upload(id)
);
GO


create table users.stage
(
	id uniqueidentifier not null default(newid()),
	recipe_id uniqueidentifier not null,
	description varchar(255) null,
	sequence int null,
	constraint PK_id_stage primary key (id),
	constraint FK_recaid_stage foreign key (recipe_id) references users.recipe(id)
);
GO
--==============================================================
/*
red Tables (3):
-	users.stage_ingredient
-	users.like_comment
-	users.upload_stage
*/

create table users.stage_ingredient
(
	id uniqueidentifier not null default(newid()),
	ingredient_id int not null,
	stage_id uniqueidentifier not null,
	value_info varchar(100) null,
	value int not null
	constraint PK_id_sta_ing primary key (id),
	constraint FK_ingrid_sta_ing foreign key (ingredient_id) references admins.ingredient(id),
	constraint FK_stagid_sta_ing foreign key (stage_id) references users.stage(id)
);
GO

create table users.like_comment
(
	user_id uniqueidentifier not null,
	recipe_id uniqueidentifier not null,
	constraint PK_ueerid_lik_com primary key (user_id, recipe_id),
	constraint FK_userid_lik_com foreign key (user_id) references users.users(id),
	constraint FK_reciid_lik_com foreign key (recipe_id) references users.recipe(id)
);
GO

create table users.upload_stage
(
	id uniqueidentifier not null default(newid()),
	stage_id uniqueidentifier not null,
	upload_id uniqueidentifier not null,
	constraint PK_id_upl_sta primary key (id),
	constraint FK_stagid_upl_sta foreign key (stage_id) references users.stage(id),
	constraint FK_uploid_upl_sta foreign key (upload_id) references users.upload(id)
);
GO


-------------------------------- END Crate User Left Tables
-------------------------------