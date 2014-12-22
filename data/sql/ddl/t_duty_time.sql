drop table if exists t_duty_time CASCADE ;

-- 勤務表トランザクション
create table t_duty_time (
	user_id         varchar(6)  not null,							-- ユーザーID
	work_day        date        not null default CURRENT_DATE,		-- 作業日
	start_time      time                 default null,				-- 開始時間
	end_time        time                 default null,				-- 終了時間
	delete_flg      char(1)     not NULL default '0',				-- 削除フラグ
  	create_user_id  varchar(10) not null default '',				-- 作成ユーザーID
	create_datetime timestamp   not null default CURRENT_TIMESTAMP,	-- 作成日時
  	update_user_id  varchar(10) not null default '',				-- 更新ユーザーID
  	update_datetime timestamp   not null default CURRENT_TIMESTAMP	-- 更新日時
);

ALTER TABLE t_duty_time ADD CONSTRAINT t_duty_time_pkey PRIMARY KEY (user_id, work_day);