BaseLogic = require '../../commonLibs/base-logic'
RESULTCD  = require '../../commonLibs/result-code'
Crypto    = require 'crypto'

class AuthLogic extends BaseLogic
  constructor: (logger) ->
    logger.debug 'AutLogic#constructor'
    super logger
  validate: (request, callback) ->
    @_logger.debug 'AuthLogic#validate'
    # リクエストにAuthorizationヘッダがあるか確認する
    if request?.headers?.authorization isnt undefined
      # リクエストにAuthorizationヘッダがある場合、
      # ユーザーIDとパスワードを取得する
      buf = new Buffer request?.headers?.authorization?.split(' ')[1], 'base64'
      @_logger.debug "Authorization: #{buf}"
      array = buf.toString().split ':'
      if array.length is 2
        userid = array[0].trim()
        password = array[1].trim()
        @_logger.debug "userid: #{userid}, password: #{password}"
        if userid.length > 0 and password.length > 0
          # エラーがない場合
          return callback null
      # ユーザーID、パスワードが不適切な場合、認証エラー
      @_logger.debug 'Invalid UserID or Password'
      return callback RESULTCD.PE0002
    # Authorizationヘッダがない場合、認証エラー
    @_logger.debug 'Not Found Authorization Header'
    return callback RESULTCD.PE0001
  execute: (request, callback) ->
    @_logger.debug 'AuthLogic#execute'
    # リクエストヘッダにauthorizationが存在する場合、
    # ユーザーIDとパスワードを取得する
    @_logger.debug "authorization : #{request.headers.authorization}"
    buf = new Buffer(request.headers.authorization.split(' ')[1], 'base64')
    array = buf.toString().split ':'
    reqUserId = array[0]
    reqPassword = array[1]
    @_logger.debug "user id: #{reqUserId}, password: #{reqPassword}"
    db = @getDBManager()
    db.open (err, client) =>
      if err
        return callback RESULTCD.DB0001, null
      sql = "SELECT "
      sql += "  user_id as userId"
      sql += ", password as password"
      sql += ", admin_flg as adminFlg "
      sql += "FROM m_user "
      sql += "WHERE "
      sql += "user_id = $1"
      sql += "AND delete_flg = '0'"
      db.execute client, sql, [reqUserId], (err, result) =>
        if err
          return callback RESULTCD.DB0002, null
        if result.rowCount <= 0
          return callback RESULTCD.PE0002, null
        password = result.rows[0].password
        # パスワードが同じかチェッックする
        # 与えられたアルゴリズでハッシュオブジェクトを取得する
        sha512 = Crypto.createHash 'sha512'
        sha512.update reqPassword
        hash = sha512.digest 'hex'
        @_logger.debug "request password: #{hash}"
        @_logger.debug "stored password : #{password}"
        if password isnt hash
          @_logger.debug 'password unmatch.'
          return callback RESULTCD.PE0002, null
        @getSessionManager().register reqUserId, (err, sid) =>
          if err
            @_logger.debug 'session id register failed.'
            return callback RESULTCD.PE0002, null
          @_logger.debug "sid: #{sid}"
          data =
            access_token: sid
          return callback RESULTCD.OK, data
module.exports = AuthLogic
