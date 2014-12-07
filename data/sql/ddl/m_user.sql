drop table if exists m_user CASCADE ;

create table m_user (
	user_id         varchar(6)   not null,
	user_name       varchar(20)  not null default '',
	password        varchar(256) not null,
	admin_flg       char(1)      not null default '0',
	delete_flg      char(1)      not NULL default '0',
  	create_user_id  varchar(10)  not null default '',
	create_datetime timestamp    not null default CURRENT_TIMESTAMP,
  	update_user_id  varchar(10)  not null default '',
  	update_datetime timestamp    not null default CURRENT_TIMESTAMP
);

ALTER TABLE m_user ADD CONSTRAINT m_user_pkey PRIMARY KEY (user_id) ;
