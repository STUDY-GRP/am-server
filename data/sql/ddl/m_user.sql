drop table if exists m_user CASCADE ;

-- ユーザーマスタ
create table m_user (
	user_id         varchar(6)   not null,								-- ユーザID
	user_name       varchar(20)  not null default '',					-- ユーザー名
	password        varchar(256) not null,								-- パスワード
	access_token    varchar(256) default null,							-- アクセストークン
	admin_flg       char(1)      not null default '0',					-- 管理者フラグ（0:一般 / 1:管理者）
	delete_flg      char(1)      not NULL default '0',					-- 削除フラグ（0:未削除 / 1:削除済み）
  	create_user_id  varchar(10)  not null default '',					-- 作成ユーザーID
	create_datetime timestamp    not null default CURRENT_TIMESTAMP,	-- 作成日時
  	update_user_id  varchar(10)  not null default '',					-- 更新ユーザーID
  	update_datetime timestamp    not null default CURRENT_TIMESTAMP		-- 更新日時
);

ALTER TABLE m_user ADD CONSTRAINT m_user_pkey PRIMARY KEY (user_id) ;
