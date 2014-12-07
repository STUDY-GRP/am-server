http = require 'http'

ResultCode =
  OK:     {status: 200, code: '',        message: ''}
  FAILED: {status: 500, code: 'SYS0001', message: 'システムエラー'}
  DB0001: {status: 500, code: 'SYS1001', message: 'DB接続に失敗しました。'}
  DB0002: {status: 500, code: 'SYS1002', message: 'クエリ発行に失敗しました。'}
  PE0001: {status: 400, code: 'PE00001', message: '不正なリクエストのため、認証できません。'}
  PE0002: {status: 400, code: 'PE00002', message: 'ユーザー名または、パスワードが不適切ですs。'}
module.exports = ResultCode
