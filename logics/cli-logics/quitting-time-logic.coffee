_             = require 'underscore'
BaseLogic     = require '../../commonLibs/base-logic'
UserModel     = require '../../models/user-model'
RESULTCD      = require '../../commonLibs/result-code'
DutyTimeModel = require '../../models/duty-time-model'
Async         = require 'async'

# クライント側、終了時刻設定ロジッククラス
#
class QuittingTimeLogic extends BaseLogic

  # QuittingTimeLogicを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (logger) ->
    logger.debug 'QuittingTimeLogic#constructor'
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
    @_logger.debug 'QuittingTimeLogic#validate'
    # リクエストにAuthorizationヘッダがあるか確認する
    if request?.headers?.authorization is undefined
      # Authorizationヘッダがない場合、認証エラー
      @_logger.debug 'Not Found Authorization Header'
      return callback RESULTCD.PE0001
    # リクエストにAuthorizationヘッダがある場合、
    authorization = request.headers.authorization
    authManager = @getAuthManager()
    authManager.getAccessToken authorization, (err, accessToken) =>
      if err
        return callback err null
      @_logger.debug "accessToken: #{accessToken}"
      # アクセストークンの未入力チェック
      if _.isEmpty(accessToken)
        @_logger.debug 'AccessToken is empty.'
        return callback RESULTCD.PE0003
      # エラーがない場合
      @_accessToken = accessToken
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
    @_logger.debug 'QuittingTimeLogic#execute'
    db = @getDBManager()
    db.open (err, client) =>
      if err
        return callback RESULTCD.DB0001, null
      userModel = new UserModel(db, @_logger)
      userModel.getUserByAccessToken @_accessToken, (err, user) =>
        if err
          # エラーの場合
          return callback RESULTCD.DB0002, null
        # ユーザーな存在しない場合、エラー
        return callback RESULTCD.PE0002, null unless user
        dutyTimeModel = new DutyTimeModel(db, @_logger)

        Async.waterfall [
          (asyncCallback) =>
            @_logger.debug 'Transaction Begin'
            db.begin (err) ->
              asyncCallback err
          (asyncCallback) =>
            @_logger.debug 'Set SetQuittingTime'
            dutyTimeModel.setQuittingTime user.userid, (err) ->
              asyncCallback err
          (asyncCallback) =>
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

module.exports = QuittingTimeLogic
