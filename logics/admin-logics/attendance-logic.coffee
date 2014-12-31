_             = require 'underscore'
RESULTCD      = require '../../commonLibs/result-code'
BaseLogic     = require '../../commonLibs/base-logic'
DutyTimeModel = require '../../models/duty-time-model'
Async         = require 'async'
xDate         = require 'xdate'

# 勤務表取得ロジッククラス
#
class AttendanceLogic extends BaseLogic

  # ユーザーID
  _userid = null
  # 年
  _year = null
  # 月
  _month = null

  # AttendanceLogic生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (logger) ->
    logger.debug 'AttendanceLogic#constructor'
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
    @_logger.debug 'AttendanceLogic#validate'
    #入力パラメータのチェック
    userid  = request.params.id
    year    = request.params.year
    month   = request.params.month
    # ユーザーIDの未入力チェック
    if _.isEmpty userid
      @_logger.debug 'id parameter is empty.'
      return callback RESULTCD.PE0004, null
    # 年の未入力チェック
    if _.isEmpty year
      @_logger.debug 'year parameter is empty.'
      return callback RESULTCD.PE0004, null
    # 月の未入力チェック
    if _.isEmpty month
      @_logger.debug 'month parameter is empty.'
      return callback RESULTCD.PE0004, null

    # ユーザーIDの有効文字チェック
    unless /^[a-zA-Z0-9]+$/.test userid
      @_logger.debug 'userid is invalid.'
      return callback RESULTCD.PE0004, null
    # 西暦年の有効文字チェック
    unless /^\d{4}$/.test year
      @_logger.debug 'year is invalid.'
      return callback RESULTCD.PE0004, null
    # 月の有効文字チェック
    unless /^(0[1-9]|1[0-2])$/.test month
      @_logger.debug 'month is invalid.'
      return callback RESULTCD.PE0004, null

    @_userid = userid
    @_year  = Number year
    @_month = Number month

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
    @_logger.debug 'AttendanceLogic#execute'

    fromdate = xDate @_year, @_month - 1, 1
    enddate  = xDate @_year, @_month, 1

    fromYmd = fromdate.toString 'yyyy-MM-dd'
    endYmd  = enddate.toString 'yyyy-MM-dd'

    db = @getDBManager()
    db.open (err, client) =>
      if err
        @_logger.debug 'db open failed.'
        return callback RESULTCD.DB0001, null
      dutyTimeModel = new DutyTimeModel(db, @_logger)
      
      dutyTimeModel.search @_userid, fromYmd, endYmd, (err, dutyTimelist) =>
        if err
          @_logger.debug "err: #{err}"
          return callback RESULTCD.FAILED, null
        data =
          year: @_year
          month: @_month
          list: dutyTimelist
        return callback RESULTCD.OK, data

module.exports = AttendanceLogic

