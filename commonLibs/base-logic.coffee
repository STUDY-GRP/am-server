DBManager      = require './db-manager'
SessionManager = require './session-manager'
ResponseData   = require './response-data'
RESULTCD       = require './result-code'

# 全てのロジックのための基底クラス
#
# @example サブクラスでの使い方
#   class XxxLogic extends BaseLogic
#     validate: (request, callback) ->
#     execute: (request, callback) ->
#
class BaseLogic
  # DB管理オブジェクト
  _dbManager = null

  # セッション管理オブジェクト
  _sessionManager = null

  # BaseLogicを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (@_logger) ->
    @_logger.debug 'BaseLogic#constructor'

  # DB管理オブジェクトを取得する。
  #
  # @return [Object] DB管理オブジェクト
  #
  getDBManager: () =>
    @_logger.debug 'BaseLogic#getDBManager'
    unless @_dbManager
      @_dbManager = new DBManager(@_logger)
    return @_dbManager

  # セッション管理オブジェクトを取得する。
  #
  # @return [Object] センション管理オブジェクト
  #
  getSessionManager: () =>
    @_logger.debug 'BaseLogic#getSessionManager'
    unless @_sessionManager
      @_sessionManager = new SessionManager(@_logger)
    return @_sessionManager

  # 入力パラメータの妥当性をチェックする 。
  # サブクラスで必要に応じてオーバーライドする。
  # @param [Object] request HTTPリクエストオブジェクト
  # @param [Function] callback コールバック関数
  # callback関数
  #   第1引数 エラーの場合、RESULTCDオブジェクト
  #          エラーでない場合、null
  # 
  validate: (request, callback) =>
    @_logger.debug 'BaseLogic#validate'
    resData.createResponseData RESULTCD.OK.status, null, (httpStatus, data) =>
      return callback httpStatus, data

  # 業務ロジックを実行する
  # サブクラスでオーバーライドする。
  #
  # @param [Object] request HTTPリクエストオブジェクト
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、RESULTCDオブジェクト
  #          エラーでない場合、null
  #   第2引数 レスポンスに渡すデータ
  #
  execute: (request, callback) =>
    @_logger.debug 'BaseLogic#execute'
    resData.createResponseData RESULTCD.OK.status, null, (httpStatus, data) =>
            return callback httpStatus, data
  # 業務ロジックを実行する
  #
  # @param [Object] request HTTPリクエストオブジェクト
  # @param [Function] callback コールバック関数
  # callback関数
  #   第1引数 HTTPステータス
  #   第2引数 HTTPレスポンスに渡すデータ
  #  
  logicExecute: (request, callback) =>
    @_logger.debug 'BaseLogic#logicExecute'
    # レスポンスデータオブジェクトの生成
    resData = new ResponseData(@_logger)
    # 入力パラメータの妥当性チェック
    @validate request, (err) =>
      @_logger.debug err
      if err 
        # 入力パラメータの妥当性チェックでエラーの場合
        @_logger.debug 'Failed Validation!!'
        # レスポンスデータの生成
        resData.createResponseData err, null, (httpStatus, data) =>
          @_logger.debug "HTTP Status: #{httpStatus}, Data: #{data}"
          return callback httpStatus, data
      else
        # 入力パラメータの妥当性チェックでエラーでない場合、
        # 業務ロジックを実行する
        @execute request, (err, data) =>
          @_logger.debug 'passed BaseLogic#execute'
          # レスポンスデータの生成
          resData.createResponseData err, data, (httpStatus, data) =>
            return callback httpStatus, data
module.exports = BaseLogic