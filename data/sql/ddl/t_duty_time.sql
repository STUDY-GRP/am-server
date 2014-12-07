drop table if exists t_duty_time CASCADE ;

create table t_duty_time (
	user_id         varchar(6)  not null,
	work_day        date        not null default CURRENT_DATE,
	start_time      time        not null default CURRENT_TIME,
	end_time        time        not null default  CURRENT_TIME,
	delete_flg      char(1)     not NULL default '0',
  	create_user_id  varchar(10) not null default '',
	create_datetime timestamp   not null default CURRENT_TIMESTAMP,
  	update_user_id  varchar(10) not null default '',
  	update_datetime timestamp   not null default CURRENT_TIMESTAMP
);

ALTER TABLE t_duty_time ADD CONSTRAINT t_duty_time_pkey PRIMARY KEY (user_id, work_day);