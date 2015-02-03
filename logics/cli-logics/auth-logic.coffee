_         = require 'underscore'
BaseLogic = require '../../commonLibs/base-logic'
RESULTCD  = require '../../commonLibs/result-code'
Async     = require 'async'
UserModel = require '../../models/user-model'

# クライント側認証ロジッククラス
# ユーザーIDとパスワードからAccessTokenを取得する
#
class AuthLogic extends BaseLogic

  _loginInfo = null

  # AuthLogicを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (logger) ->
    logger.debug 'AutLogic#constructor'
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
    @_logger.debug 'AuthLogic#validate'
    # リクエストにAuthorizationヘッダがあるか確認する
    if request?.headers?.authorization is undefined
      # Authorizationヘッダがない場合、認証エラー
      @_logger.debug 'Not Found Authorization Header'
      return callback RESULTCD.PE0001
    # リクエストにAuthorizationヘッダがある場合、
    # ユーザーIDとパスワードを取得する
    authorization = request.headers.authorization
    authManager = @getAuthManager()
    authManager.getLoginInfo authorization, (err, loginInfo) =>
      if err
        return callback err
      @_logger.debug "userid: #{loginInfo.userid}, password: #{loginInfo.password}"
      # ユーザーIDの未入力チェック
      if _.isEmpty(loginInfo.userid)
        @_logger.debug 'UserID is empty.'
        return callback RESULTCD.PE0002
      # パスワードの未入力チェック
      if _.isEmpty(loginInfo.password)
        @_logger.debug 'Password is empty.'
        return callback RESULTCD.PE0002
      @_logger.debug 'AuthLogic#validate is success.'
      # エラーがない場合
      @_loginInfo = loginInfo
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
    @_logger.debug 'AuthLogic#execute'
    # リクエストヘッダにauthorizationが存在する場合、
    # ユーザーIDとパスワードを取得する
    @_logger.debug "user id: #{@_loginInfo.userid}, password: #{@_loginInfo.password}"
    db = @getDBManager()
    db.open (err, client) =>
      if err
        return callback RESULTCD.DB0001, null
      @_logger.debug 'DB open Sucess.'
      @_logger.debug 'create UserModel object.'
      userModel = new UserModel(db, @_logger)
      # ユーザー情報の取得
      userModel.getUser @_loginInfo.userid, (err, user) =>
        if err
          # エラーの場合
          return callback RESULTCD.DB0002, null
        @_logger.debug 'get user success.'
        # ユーザーな存在しない場合、エラー
        return callback RESULTCD.PE0002, null unless user
        authManager = @getAuthManager()
        @_logger.debug 'check password.'
        isSame = authManager.isSamePassword @_loginInfo.password, user.password
        # パスワードが違う場合、エラー
        return callback RESULTCD.PE0002, null unless isSame
        @_logger.debug 'create accesstoken.'
        xffField = request?.get 'x-forwarded-for'
        # ユーザーエージェント
        userAgent = request?.get 'User-Agent'
        # IPアドレス
        console.log _.isEmpty(xffField)
        ip = if _.isEmpty(xffField) then request?.ip else request?.get xffField
        # アクセストークンの作成
        accessToken = authManager.createAccessToken @_loginInfo.userid, userAgent, ip
        Async.waterfall [
          (asyncCallback) ->
            # トランザクション開始
            db.begin (err) ->
              asyncCallback err
          (asyncCallback) =>
            @_logger.debug 'update m_user'
            userModel.setAccessToken @_loginInfo.userid, accessToken, (err) ->
              asyncCallback err
          (asyncCallback) ->
            # コミット
            db.commit (err) ->
              if err
                asyncCallback err
              data =
                access_token: accessToken
              return callback RESULTCD.OK, data 
        ], (err) =>
          # ロールバック
          db.rollback (err) =>
            if err
              @_logger.error 'Rollback Failed.'
              @_logger.error "err: #{err}"
            return callback RESULTCD.FAILED, null
module.exports = AuthLogic
