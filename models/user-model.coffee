# ユーザーモデルクラス
# ユーザーマスタへの操作を提供する
#
class UserModel

  # UserModelを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor:(@_db, @_logger) ->
    @_logger.debug 'UserModel#constractor'

  # アクセストークンからユーザーを取得する
  #
  # @param [String]   accessToken アクセストークン
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 ユーザー情報
  #
  getUserByAccessToken: (accessToken, callback) ->
    @_logger.debug 'UserModel#getUserByAccessToken'
    sql = "SELECT "
    sql += "  user_id as userId"
    sql += ", password as password"
    sql += ", admin_flg as adminFlg "
    sql += "FROM m_user "
    sql += "WHERE "
    sql += "access_token = $1 "
    sql += "AND delete_flg = '0'"
    @_db.execute sql, [accessToken], (err, result) =>
      if err
        # エラーの場合
        return callback err, null
      if result.rowCount <= 0
        return callback null, null
      return callback null, result.rows[0]

  # ユーザーIDからユーザーを取得する
  #
  # @param [String]   userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 ユーザーID
  #
  getUser: (userid, callback) ->
    @_logger.debug 'UserModel#getUser'
    sql = "SELECT "
    sql += "  user_id as userId"
    sql += ", user_name as userName"
    sql += ", password as password"
    sql += ", admin_flg as adminFlg "
    sql += "FROM m_user "
    sql += "WHERE "
    sql += "user_id = $1 "
    sql += "AND delete_flg = '0'"
    @_logger.debug sql
    @_logger.debug "parameter: #{userid}"
    @_db.execute sql, [userid], (err, result) =>
      if err
        # エラーの場合
        @_logger.debug "query error. #{err}"
        return callback err, null
      if result.rowCount <= 0
        @_logger.debug 'query success. but data count is 0.'
        return callback null, null
      return callback null, result.rows[0]

  # 有効なユーザー件数を取得する
  #
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 ユーザー件数
  #
  count: (callback) ->
    @_logger.debug 'UserModel#searchUsers'
    sql = "SELECT "
    sql += " count(0) as count "
    sql += "FROM m_user "
    sql += "WHERE "
    sql += "delete_flg = '0' "
    @_logger.debug sql
    @_db.execute sql, [], (err, result) =>
      if err
        # エラーの場合
        @_logger.debug "query error. #{err}"
        return callback err, null
      return callback null, result.rows[0].count

  # ユーザーが存在するか確認する
  #
  # @param [String] userid ユーザーID
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 true：ユーザーが存在する
  #          false：ユーザーが存在しない
  exist: (userid, callback) ->
    @_logger.debug 'UserModel#searchUsers'
    sql = "SELECT "
    sql += " count(0) as count "
    sql += "FROM m_user "
    sql += "WHERE "
    sql += "user_id = $1 "
    sql += "AND delete_flg = '0' "
    @_logger.debug sql
    @_db.execute sql, [userid], (err, result) =>
      if err
        # エラーの場合
        @_logger.debug "query error. #{err}"
      if result.rows[0].count <= 0
        return callback null, false
      else
        return callback null, true

  # ユーザーを検索する
  #
  # @param [int] limit  取得上限
  # @param [int] offset 取得位置 
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 ユーザー情報
  #
  searchUsers: (limit, offset, callback) ->
    @_logger.debug 'UserModel#searchUsers'
    sql = "SELECT "
    sql += "  user_id as userId"
    sql += ", user_name as userName"
    sql += ", admin_flg as adminFlg "
    sql += "FROM m_user "
    sql += "WHERE "
    sql += "delete_flg = '0' "
    sql += "ORDER BY user_id ASC "
    sql += "LIMIT $1 "
    sql += "OFFSET $2"
    @_logger.debug sql
    @_logger.debug "parameter: #{offset}, #{limit}"
    @_db.execute sql, [offset, limit], (err, result) =>
      if err
        # エラーの場合
        @_logger.debug "query error. #{err}"
        return callback err, null
      if result.rowCount <= 0
        @_logger.debug 'query success. but data count is 0.'
        return callback null, null
      return callback null, result.rows

  # 指定したユーザーのアクセストークンを設定する
  #
  # @param [String]   userid ユーザーID
  # @param [String]   accessToken アクセストークン
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  setAccessToken: (userid, accessToken, callback) ->
    @_logger.debug 'UserModel#setAccessToken'
    sql = "UPDATE m_user "
    sql += "SET "
    sql += "  access_token = $1 "
    sql += ", update_user_id = $2 "
    sql += ", update_datetime = CURRENT_TIMESTAMP "
    sql += "WHERE "
    sql += "user_id = $3"
    @_logger.debug sql
    @_logger.debug "parameter: #{userid}, accessToken: #{accessToken}"
    @_db.execute sql, [accessToken, userid, userid], (err, result) =>
      callback err

  # ユーザーを登録する
  #
  # @param [Object] user ユーザー情報オブジェクト
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  register: (user, callback) ->
    @_logger.debug 'UserModel#getUser'
    sql = "INSERT INTO m_user ("
    sql += "  user_id"
    sql += ", user_name"
    sql += ", password"
    sql += ", admin_flg"
    sql += ", delete_flg"
    sql += ", create_user_id"
    sql += ", create_datetime"
    sql += ", update_user_id"
    sql += ", update_datetime"
    sql += ") VALUES ("
    sql += "  $1"
    sql += ", $2"
    sql += ", $3"
    sql += ", $4"
    sql += ", '0'"
    sql += ", $5"
    sql += ", CURRENT_TIMESTAMP"
    sql += ", $6"
    sql += ", CURRENT_TIMESTAMP"
    sql += ")"
    @_logger.debug sql
    @_logger.debug "parameter: #{user}"

    @_db.execute sql
      , [user.userid, user.username, user.hashpassword, user.adminflag, user.createid, user.updateid]
      , (err, result) =>
        if err
          # エラーの場合
          @_logger.debug "query error. #{err}"
          return callback err
        return callback null
module.exports = UserModel