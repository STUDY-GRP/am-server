_         = require 'underscore'
RESULTCD  = require '../../commonLibs/result-code'
BaseLogic = require '../../commonLibs/base-logic'
UserModel = require '../../models/user-model'

# ログインロジッククラス
#
class LoginLogic extends BaseLogic

  # ログイン情報
  _loginInfo = null

  # LoginLogic生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (logger) ->
    logger.debug 'LoginLogic#constructor'
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
    @_logger.debug 'LoginLogic#validate'
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
      @_logger.debug 'LoginLogic#validate is success.'
      # エラーがない場合S
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
    @_logger.debug 'LoginLogic#execute'
    # リクエストヘッダにauthorizationが存在する場合、
    # ユーザーIDとパスワードを取得する
    @_logger.debug "user id: #{@_loginInfo.userid}, password: #{@_loginInfo.password}"
    db = @getDBManager()
    db.open (err, client) =>
      if err
        @_logger.debug 'db open failed.'
        return callback RESULTCD.DB0001, null
      @_logger.debug 'DB open Sucess.'
      @_logger.debug 'create UserModel object.'
      userModel = new UserModel(db, @_logger)
      # ユーザー情報の取得
      userModel.getUser @_loginInfo.userid, (err, user) =>
        if err
          # エラーの場合
          @_logger.error "err: #{err}"
          return callback RESULTCD.DB0002, null
        @_logger.debug 'get user success.'
        # ユーザーな存在しない場合、エラー
        return callback RESULTCD.PE0002, null unless user
        authManager = @getAuthManager()
        @_logger.debug 'check password.'
        isSame = authManager.isSamePassword @_loginInfo.password, user.password
        # パスワードが違う場合、エラー
        return callback RESULTCD.PE0002, null unless isSame
        # セッション管理
        sessionManager = @getSessionManager()
        sessionid = sessionManager.createSessionId @_loginInfo.userid
        @_logger.debug "sessionid: #{sessionid}"
        # セッションに格納する情報を作成
        sessionData =
            sessionid: sessionid 
            userid: @_loginInfo.userid
        sessionManager.register sessionid, sessionData, (err) =>
          @_logger.debug ">>> sessionid: #{sessionid}"
          if err
            # セッションの登録に失敗した場合、システムエラー
            @_logger.error "err: #{err}"
            return callback RESULTCD.FAILED, null
          # エラーでない場合、セッションIDをクライントへ返す
          @_logger.debug user
          data =
            sessionid: sessionid
            username: user.username
          return callback RESULTCD.OK, data
module.exports = LoginLogic