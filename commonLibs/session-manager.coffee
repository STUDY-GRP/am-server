Crypto       = require 'crypto'
RedisManager = require './redis-manager'
Config       = require 'config'

# セッション管理クラス
#
class SessionManager

  # セッション管理クラスを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (@_logger, @_redis) ->
    @_logger.debug 'SessionManager#constructor'

  # セッションIDを作成する
  #
  # @param [String] userid ユーザーID
  # @return [String] セッションID
  createSessionId: (userid) ->
    @_logger.debug 'SessionManager#createSessionId'
    @_logger.debug "userid: #{userid}"
    baseSid = userid + (new Date).getTime()
    sha512 = Crypto.createHash 'sha512'
    sha512.update baseSid
    sessionId = sha512.digest 'hex'
    return sessionId

  # セッションを持っているか確認する
  # セッションに引数のセッションIDが存在するか確認します。
  #
  # @param [String] sessionid セッションID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 true：セッションIDが存在する
  #          false：セッションIDが存在しない
  #
  hasSession: (sessionid, callback) ->
    @_logger.debug 'SessionManager#hasSession'
    @_redis.open Config.redis.configure, (err) =>
      if err
        @_logger.debug 'redis open failed.'
        return callback err null
      @_redis.exists sessionid, (err, isExist) =>
        if err
          return callback err, null
        return callback null, isExist

  # セッションの持つユーザー情報を取得する
  # 引数のセッションIDに紐つくユーザー情報を取得します。
  #
  # @param [String] sessionid セッションID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 セッションIDに紐つくユーザー情報
  #
  getSessionUser: (sessionid, callback) ->
    @_logger.debug 'SessionManager#getSessionUser'
    @_redis.open Config.redis.configure, (err) =>
      if err
        @_logger.debug 'redis open failed.'
        return callback err null
      @_redis.hgetall sessionid, (err, data) =>
        if err
          return callback err, null
        return callback null, data

  # セッションへ登録する。
  #
  # @param [String] sessionid セッションID
  # @param [Object] sessionData セッションに格納する情報
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  register: (sessionid, sessionData, callback) ->
    @_logger.debug 'SessionManager#register'
    @_logger.debug "sessionid: #{sessionid}"
    @_logger.debug "sessionData: #{sessionData}"

    @_redis.open Config.redis.configure, (err) =>
      if err
        @_logger.debug 'redis open failed.'
        return callback err
      @_redis.hmset sessionid, sessionData, (err, reply) =>
        if err
          @_logger.debug 'can not set session id.'
          return callback err
        return callback null

  # セッションから削除する
  #
  # @param [String] セッションID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  remove: (sessionid, callback) ->
    @_logger.debug 'SessionManager#remove'
    @_logger.debug "sessionid: #{sessionid}"
    @_redis.open Config.redis.configure, (err) =>
      if err
        @_logger.debug 'redis open failed.'
        return callback err null
      @_redis.delete sessionid, (err, reply) =>
        if err
          @_logger.debug 'redis delete failed.'
          return callback err
        return callback null

  # 終了処理を行う
  #
  dispose: ->
    if @_redis
      @_redis.close()

module.exports = SessionManager