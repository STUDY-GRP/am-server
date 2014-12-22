RESULTCD  = require '../../commonLibs/result-code'
BaseLogic = require '../../commonLibs/base-logic'

# ログアウトロジッククラス
#
class LogoutLogic extends BaseLogic

  # セッションID
  _currentSessionId = null

  # LogoutLogic生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (logger) ->
    logger.debug 'LogoutLogic#constructor'
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
    @_logger.debug 'LogoutLogic#validate'
    # Cookieの取得
    cookie = @getCookie()
    if cookie.length <= 0
      # Cookieがない場合、エラー
      return callback RESULTCD.PE0001, null
    sessionid = cookie['sessionid']
    unless sessionid
      # セッションIDがない場合
      return callback RESULTCD.PE0001, null  
    # セッションIDがある場合
    sessionManager = @getSessionManager()
    sessionManager.hasSession sessionid, (err, hasSession) =>
      if err
        @_logger.error "err: #{err}"
        return callback RESULTCD.FAILED, null
      unless hasSession
        # セッション管理されていない場合
        return callback RESULTCD.PE0001, null
      @_logger.debug "has sessionid."
      @_currentSessionId = sessionid
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
    @_logger.debug 'LogoutLogic#execute'
    sessionManager = @getSessionManager()
    sessionManager.remove @_currentSessionId, (err) ->
      if err
        @_logger.error "err: #{err}"
        return callback RESULTCD.FAILED, null
      return callback RESULTCD.OK, null
module.exports = LogoutLogic
