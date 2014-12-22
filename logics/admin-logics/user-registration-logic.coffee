_         = require 'underscore'
RESULTCD  = require '../../commonLibs/result-code'
BaseLogic = require '../../commonLibs/base-logic'
Crypto    = require 'crypto'
UserModel = require '../../models/user-model'
Async     = require 'async'

# ユーザー登録ロジッククラス
#
class UserRegistrationLogic extends BaseLogic

  # ユーザー情報
  _user = null

  # UserRegistrationLogic生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (logger) ->
    logger.debug 'UserRegistrationLogic#constructor'
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
    @_logger.debug 'UserRegistrationLogic#validate'
    #入力パラメータのチェック
    user = request.body

    # ユーザーIDの未入力チェック
    if _.isEmpty user.userid
      @_logger.debug 'userid parameter is empty.'
      return callback RESULTCD.PE0004, null
    # ユーザー名の未入力チェック
    if _.isEmpty user.username
      @_logger.debug 'username parameter is empty.'
      return callback RESULTCD.PE0004, null
    # パスワードの未入力チェック
    if _.isEmpty user.password
      @_logger.debug 'password parameter is empty.'
      return callback RESULTCD.PE0004, null
    # 再入力パスワードの未入力チェック
    if _.isEmpty user.repassword
      @_logger.debug 'password parameter is empty.'
      return callback RESULTCD.PE0004, null

    # ユーザーIDの文字数チェック
    if user.userid.length > 6 
      @_logger.debug 'userid is too large.(userid length = 6)'
      return callback RESULTCD.PE0004, null
    # ユーザー名の文字数チェック
    if user.username.length > 20
      @_logger.debug 'username is too large.(userid length = 20)'
      return callback RESULTCD.PE0004, null
    # パスワードの文字数チェック
    if user.password.length < 8
      @_logger.debug 'password is too samll.(password 8-16)'
      return callback RESULTCD.PE0004, null
    if user.password.length > 16
      @_logger.debug 'password is too large.(password 8-16)'
      return callback RESULTCD.PE0004, null
    # 再入力パスワードの文字数チェック
    if user.repassword.length < 8
      @_logger.debug 'repassword is too samll.(repassword 8-16)'
      return callback RESULTCD.PE0004, null
    if user.repassword.length > 16
      @_logger.debug 'repassword is too large.(repassword 8-16)'
      return callback RESULTCD.PE0004, null

    # ユーザーIDの有効文字チェック
    unless /^[a-zA-Z0-9]+$/.test user.userid
      @_logger.debug 'userid is invalid.'
      return callback RESULTCD.PE0004, null
    # パスワードの有効文字チェック
    unless /^[a-zA-Z0-9]+$/.test user.password
      @_logger.debug 'password is invalid.'
      return callback RESULTCD.PE0004, null
    # 再入力パスワードの有効文字チェック
    unless /^[a-zA-Z0-9]+$/.test user.repassword
      @_logger.debug 'repassword is invalid.'
      return callback RESULTCD.PE0004, null

    # パスワードと再入力パスワードが一致するかチェック
    if user.password isnt user.repassword
      @_logger.debug 'password is unmatch.'
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
    sessionManager.getSessionUser sessionid, (err, data) =>
      if err
        @_logger.debug 'session check is falied.'
        @_logger.error "err: #{err}"
        return callback RESULTCD.FAILED, null
      unless data
        # セッション管理されていない場合
        @_logger.debug 'there is no session.'
        return callback RESULTCD.PE0001, null
      @_logger.debug "has sessionid."
      @_user = 
        userid: user.userid
        username: user.username
        password: user.password
        hashpassword: null
        adminflag: '0'
        createid: data.userid
        updateid: data.userid
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
    @_logger.debug 'UserRegistrationLogic#execute'

    sha512 = Crypto.createHash 'sha512'
    sha512.update @_user.password
    @_user.hashpassword = sha512.digest 'hex'

    db = @getDBManager()
    db.open (err, client) =>
      if err
        @_logger.debug 'db open failed.'
        return callback RESULTCD.DB0001, null
      userModel = new UserModel(db, @_logger)
      Async.waterfall [
        (asyncCallback) =>
          @_logger.debug 'Transaction Begin'
          db.begin (err) ->
            asyncCallback err
        , (asyncCallback) =>
          userModel.exist @_user.userid, (err, data) =>
            asyncCallback err, data
        , (isExist, asyncCallback) =>
          # ユーザーの存在チェック
          if isExist
            # 既にユーザーが存在している場合、エラーとする
            return callback RESULTCD.PE0005, null
          asyncCallback null
        , (asyncCallback) =>
          # ユーザーの登録
          userModel.register @_user, (err) =>
            asyncCallback err
        , (asyncCallback) =>
          @_logger.debug 'Commit'
          db.commit (err) ->
            if err
              asyncCallback err
            return callback RESULTCD.OK, null
        ], (err) =>
          @_logger.debug "err: #{err}"
          @_logger.debug 'Rollback'
          db.rollback (err) =>
            if err
              @_logger.error 'Rollback Failed.'
              @_logger.error "rollback err: #{err}"
            return callback RESULTCD.FAILED, null

module.exports = UserRegistrationLogic
