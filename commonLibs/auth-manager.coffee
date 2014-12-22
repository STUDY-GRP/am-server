Crypto    = require 'crypto'
RESULTCD  = require './result-code'

# 認証管理機能を提供するクラス
#
class AuthManager

  # AuthManagerを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (@_logger) ->
    @_logger.debug 'AuthManager#constructor'

  # ログイン情報を取得する
  #
  # @param [Object]   request HTTPリクエストオブジェクト
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、RESULTCDオブジェクト
  #          エラーでない場合、null
  #   第2引数 ログイン情報
  #          loginInfo {
  #               userid: ユーザーID
  #             , password: パスワード
  #           }
  #
  getLoginInfo: (authorization, callback) ->
    @_logger.debug 'AuthManager#getLoginInfo'
    headers = authorization.split(' ')
    if headers.length isnt 2
      @_logger.debug 'Authorization Error: invalid authorization header.'
      return callback RESULTCD.PE0001, null
    if headers[0] isnt 'Basic'
      @_logger.debug 'Authorization Error: not found Basic'
      return callback RESULTCD.PE0001, null
    ## Basic認証の場合
    buf = new Buffer headers[1], 'base64'
    @_logger.debug "Authorization: #{buf}"
    array = buf.toString().split ':'
    if array.length isnt 2
      @_logger.debug 'Authorization Error: invalid Basic Authorization'
      return callback RESULTCD.PE0001, null
    loginInfo =
      userid: array[0]
      password: array[1]
    @_logger.debug "created logoinInfo object. #{loginInfo}"
    return callback null, loginInfo

  # アクセストークンを取得する
  #
  # @param [String]   authorization HTTPリクエストヘッダのAuthorization
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、RESULTCDオブジェクト
  #          エラーでない場合、null
  #   第2引数 アクセストークン
  #
  getAccessToken: (authorization, callback) ->
    @_logger.debug 'AuthManager#getAccessToken'
    @_logger.debug "Authorization: #{authorization}"
    headers = authorization.split(' ')
    if headers.length isnt 2
      return callback RESULTCD.PE0001, null
    if headers[0] isnt 'Bearer'
      return callback RESULTCD.PE0001, null
    accessToken = headers[1]
    return callback null, accessToken

  # パスワードが同じかチェックする
  #
  # @param [String] rawpassword HTTPリクエストで送信されてきたパスワード1
  # @param [String] DBに保存されているハッシュ化されたパスワード
  # 
  # @return true:同じ / false:同じでない 
  #
  isSamePassword: (rawpassword, password) ->
    @_logger.debug 'AuthManager#comparePassword'
    sha512 = Crypto.createHash 'sha512'
    sha512.update rawpassword
    hash = sha512.digest 'hex'
    @_logger.debug "request password: #{hash}"
    @_logger.debug "stored password : #{password}"
    isSame = false
    if password is hash
      @_logger.debug 'password match.'
      isSame = true
    else
      @_logger.debug 'password unmatch.'
    return isSame

  # アクセストークンを作成する
  #
  # @param [String] userid ユーザーID
  # @param [String] useragent ユーザーエージェント
  # @param [String] ip IPアドレス
  # 
  # @return アクセストークン
  #
  createAccessToken: (userid, useragent, ip) ->
    @_logger.debug 'AuthManager#createAccessToken'
    @_logger.debug "userid: #{userid}, useragent: #{useragent}, ip: #{ip}"
    # 認証キーを生成する。
    baseToken = userid + useragent + ip
    sha512 = Crypto.createHash 'sha512'
    sha512.update baseToken
    accessToken = sha512.digest 'hex'
    return accessToken
module.exports = AuthManager