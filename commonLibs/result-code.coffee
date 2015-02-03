http = require 'http'

# 結果コード
# status  HTTPステータス
# code    エラーコード
# message エラーメッセージ
ResultCode =
  OK:     {status: 200, code: '',        message: ''}
  FAILED: {status: 500, code: 'SYS0001', message: 'システムエラー'}
  DB0001: {status: 500, code: 'SYS1001', message: 'DB接続に失敗しました。'}
  DB0002: {status: 500, code: 'SYS1002', message: 'クエリ発行に失敗しました。'}
  PE0001: {status: 401, code: 'PE00001', message: '不正なリクエストのため、認証できません。'}
  PE0002: {status: 400, code: 'PE00002', message: 'ユーザー名または、パスワードが不適切です。'}
  PE0003: {status: 401, code: 'PE00003', messsge: 'アクセストークンが不適切です。'}
  PE0004: {status: 400, code: 'PE00004', message: '入力パラメータが不適切です。'}
  PE0005: {status: 200, code: 'PE00005', message: '既に登録されているユーザーです。'}
module.exports = ResultCode
