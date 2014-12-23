_         = require 'underscore'
RESULTCD  = require '../../commonLibs/result-code'
BaseLogic = require '../../commonLibs/base-logic'
Async     = require 'async'
UserModel = require '../../models/user-model'

# ユーザー検索ロジッククラス
#
class UserSearchLogic extends BaseLogic
  # 取得上限件数
  _limit  = 0
  # 取得開始位置
  _offset = 0

  # UserSearchLogic生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (logger) ->
    logger.debug 'UserSearchLogic#constructor'
    super logger

  # 入力パラメータの妥当性をチェックする 。
  # 
  # @param [Object] request HTTPリクエストオブジェクト
  # @param [Function] callback コールバック関数
  # callback関数
  #   第1引数 エラーの場合、RESULTCDオブジェクト
  #          エラーでない場合、null
  # 
  validate: (request, callback) ->
    @_logger.debug 'UserSearchLogic#validate'
    #入力パラメータのチェック
    limit  = request.query.limit
    offset = request.query.offset
    # 上限値の未入力チェック
    if _.isEmpty limit
      @_logger.debug 'limit parameter is empty.'
      return callback RESULTCD.PE0004, null
    # 取得位置の未入力チェック
    if _.isEmpty offset
      @_logger.debug 'offset parameter is empty.'
      return callback RESULTCD.PE0004, null

    # 上限値の数値チェック以外
    unless /^\d+$/.test limit
      @_logger.debug 'limit is not numeric.'
      return callback RESULTCD.PE0004, null

    # 取得位置の数値チェック
    unless /^\d+$/.test offset
      @_logger.debug 'offset is not numeric.'
      return callback RESULTCD.PE0004, null
    
    limit  = Number limit
    offset = Number offset
    # 上限値の入力範囲チェック
    if limit <= 0
      @_logger.debug 'limit is too small.(limit > 0)'
      return callback RESULTCD.PE0004, null
    # 取得位置の数値チェック
    if offset < 0
      @_logger.debug 'offset is too small.(offset >= 0)'
      return callback RESULTCD.PE0004, null
    @_limit  = limit
    @_offset = offset
    # Cookieの取得
    cookie = @getCookie()
    if cookie.length <= 0
      # Cookieがない場合、エラー
      @_logger.debug 'there is no cookie.'
      return callback RESULTCD.PE0001, null
    sessionid = cookie['sessionid']
    unless sessionid
      # セッションIDがない場合
      @_logger.debug 'cookie does not have a session.'
      return callback RESULTCD.PE0001, null  
    # セッションIDがある場合
    sessionManager = @getSessionManager()
    sessionManager.hasSession sessionid, (err, hasSession) =>
      if err
        @_logger.debug 'session check is falied.'
        @_logger.error "err: #{err}"
        return callback RESULTCD.FAILED, null
      unless hasSession
        # セッション管理されていない場合
        @_logger.debug 'there is no session.'
        return callback RESULTCD.PE0001, null
      @_logger.debug "has sessionid."
      return callback null

  # 業務ロジックを実行する
  #
  # @param [Object] request HTTPリクエストオブジェクト
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、RESULTCDオブジェクト
  #          エラーでない場合、null
  #   第2引数 レスポンスに渡すデータ
  #
  execute: (request, callback) ->
    @_logger.debug 'UserSearchLogic#execute'
    db = @getDBManager()
    db.open (err, client) =>
      if err
        @_logger.debug 'db open failed.'
        return callback RESULTCD.DB0001, null
      userModel = new UserModel(db, @_logger)
      Async.parallel [
        (asyncCallback) =>
          userModel.count (err, count) =>
            @_logger.debug "user count: #{count}"
            asyncCallback err, count
        , (asyncCallback) =>
          userModel.searchUsers @_offset, @_limit, (err, users) =>
            @_logger.debug "users: #{users}"
            asyncCallback err, users
      ], (err, asyncResult) =>
        if err
          @_logger.debug "err: #{err}"
          return callback RESULTCD.FAILED, null
        data = 
          count: asyncResult[0]
          result: asyncResult[1]
        return callback RESULTCD.OK, data

module.exports = UserSearchLogic

