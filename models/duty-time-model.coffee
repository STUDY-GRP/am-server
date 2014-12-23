# 勤務表モデルクラス
# 勤務表トランザクションテーブルへの操作を提供する
#
class DutyTimeModel

  # DutyTimeModel生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor:(@_db, @_logger) ->
    @_logger.debug 'DutyTimeModel#constractor'

  # 現在の日付データを取得する。
  # 引数のユーザーIDで現在日の勤務情報（作業日）を取得する
  #
  # @param [String] userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 作業日
  #
  _getTodayData = (userid, callback) ->
    @_logger.debug 'DutyTimeModel#_getTodayData'
    sql = "SELECT "
    sql += "  user_id as userid"
    sql += ", work_day as workday"
    sql += ", start_time as starttime"
    sql += ", end_time as endtime "
    sql += "FROM t_duty_time "
    sql += "WHERE "
    sql += "user_id = $1 "
    sql += "AND work_day = CURRENT_DATE "
    sql += "AND delete_flg = '0'"
    @_logger.debug "sql: #{sql}"
    @_logger.debug "userid: #{userid}"
    @_db.execute sql, [userid], (err, result) =>
      if err
        # エラーの場合
        return callback err, null
      if result.rowCount <= 0
        return callback null, null
      return callback null, result.rows[0].workday

  # 出社時間を更新する
  # 
  # @param [String] userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  _updateAttendanceTime = (userid, callback) ->
    @_logger.debug 'DutyTimeModel#_updateAttendanceTime'
    sql = "UPDATE t_duty_time "
    sql += "SET "
    sql += "  start_time = CURRENT_TIMESTAMP "
    sql += ", update_user_id = $1 "
    sql += ", update_datetime = CURRENT_TIMESTAMP "
    sql += "WHERE "
    sql += "user_id = $2 "
    sql += "AND work_day = CURRENT_DATE"
    @_logger.debug "sql: #{sql}"
    @_logger.debug "userid: #{userid}"
    @_db.execute sql, [userid, userid], (err, result) ->
      return callback err

  # 出勤情報（出社時間）を登録する
  # 
  # @param [String] userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  _insertAttendanceTime = (userid, callback) ->
    @_logger.debug 'DutyTimeModel#_insertAttendanceTime'
    sql = "INSERT INTO t_duty_time("
    sql += "  user_id "
    sql += ", work_day "
    sql += ", start_time"
    sql += ", create_user_id"
    sql += ", update_user_id"
    sql += ") VALUES ("
    sql += "  $1"
    sql += ", CURRENT_DATE"
    sql += ", CURRENT_TIMESTAMP"
    sql += ", $1"
    sql += ", $1"
    sql += ")"
    @_logger.debug "sql: #{sql}"
    @_logger.debug "userid: #{userid}"
    @_db.execute sql, [userid], (err, result) ->
      return callback err

  # 退社時間を更新する
  # 
  # @param [String] userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  _updateQuittingTime = (userid, callback) ->
    @_logger.debug 'DutyTimeModel#_updateQuittingTime'
    sql = "UPDATE t_duty_time "
    sql += "SET "
    sql += "  end_time = CURRENT_TIMESTAMP "
    sql += ", update_user_id = $1 "
    sql += ", update_datetime = CURRENT_TIMESTAMP "
    sql += "WHERE "
    sql += "user_id = $2 "
    sql += "AND work_day = CURRENT_DATE"
    @_logger.debug "sql: #{sql}"
    @_logger.debug "userid: #{userid}"
    @_db.execute sql, [userid, userid], (err, result) ->
      return callback err

  # 出勤情報（出社時間）を登録する
  # 
  # @param [String] userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  _insertQuittingTime = (userid, callback) ->
    @_logger.debug 'DutyTimeModel#_insertQuittingTime'
    sql = "INSERT INTO t_duty_time("
    sql += "  user_id "
    sql += ", work_day "
    sql += ", end_time"
    sql += ", create_user_id"
    sql += ", update_user_id"
    sql += ") VALUES ("
    sql += "  $1"
    sql += ", CURRENT_DATE"
    sql += ", CURRENT_TIMESTAMP"
    sql += ", $1"
    sql += ", $1"
    sql += ")"
    @_logger.debug "sql: #{sql}"
    @_logger.debug "userid: #{userid}"
    @_db.execute sql, [userid], (err, result) ->
      return callback err

  # 出社時間を設定する
  #
  # @param [String] userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  setAttendanceTime: (userid, callback) ->
    @_logger.debug 'DutyTimeModel#setAttendanceTime'
    _getTodayData.call @, userid, (err, workDay) =>
      if err
        @_logger.debug "DutyTimeModel#setAttendanceTime err: #{err}"
        return callback err
      if workDay
        # データがある場合、開始時間を更新する
        _updateAttendanceTime.call @, userid, (err) =>
          @_logger.debug "DutyTimeModel#setAttendanceTime err: #{err}"
          return callback err
      else
        # データがない場合、新規に開始時間を登録する
        _insertAttendanceTime.call @, userid, (err) =>
          @_logger.debug "DutyTimeModel#setAttendanceTime err: #{err}"
          return callback err

  # 退社時間を設定する
  #
  # @param [String] userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  setQuittingTime: (userid, callback) ->
    @_logger.debug 'DutyTimeModel#setQuittingTime'
    _getTodayData.call @, userid, (err, workDay) =>
      if err
        @_logger.debug "DutyTimeModel#setQuittingTime err: #{err}"
        return callback err
      if workDay
        # データがある場合、開始時間を更新する
        _updateQuittingTime.call @, userid, (err) =>
          @_logger.debug "DutyTimeModel#setQuittingTime err: #{err}"
          return callback err
      else
        # データがない場合、新規に開始時間を登録する
        _insertQuittingTime.call @, userid, (err) =>
          @_logger.debug "DutyTimeModel#setQuittingTime err: #{err}"
          return callback err

  # 勤務情報を検索する
  #
  # @param [String] userid ユーザーID
  # @param [String] fromDate 開始日
  # @param [String] endDate 終了日
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 エラーの場合、null
  #          エラーでない場合、検索結果
  #
  search: (userid, fromDate, endDate, callback) ->
    @_logger.debug 'DutyTimeModel#search'
    sql = "SELECT "
    sql += "  TO_CHAR(work_day, 'yyyy-MM-dd') as workday"
    sql += ", TO_CHAR(start_time, 'hh24:mi') as starttime"
    sql += ", TO_CHAR(end_time, 'hh24:mi') as endtime "
    sql += "FROM t_duty_time "
    sql += "WHERE "
    sql += "user_id = $1 "
    sql += "AND work_day >= $2 "
    sql += "AND work_day < $3 "
    sql += "AND delete_flg = '0'"
    @_logger.debug "sql: #{sql}"
    @_logger.debug "userid: #{userid}"
    @_logger.debug "fromDate: #{fromDate}"
    @_logger.debug "endDate: #{endDate}"
    @_db.execute sql, [userid, fromDate, endDate], (err, result) =>
      if err
        # エラーの場合
        return callback err, null
      if result.rowCount <= 0
        return callback null, null
      return callback null, result.rows

module.exports = DutyTimeModel