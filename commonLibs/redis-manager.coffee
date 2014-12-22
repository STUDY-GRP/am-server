redis  = require 'redis'

# Redisへの操作をラッピングするクラス
#
class RedisManager

  _client = null

  # RedisManagerを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (@_logger) ->
    @_logger.debug 'RedisManager#constructor'

  # Redisへの接続を開く
  #
  # @param [object] config 設定オブジェクト
  # @oaram [Function] callback コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  # 
  open: (config, callback) ->
    @_logger.debug 'RedisManager#open'
    if @_client
      # 既にRedisクライアントのインスタンスが存在する場合、
      # Redisクライントの生成はキャンセルする
      return callback null 
    @_client = redis.createClient config.port, config.host
    #@_client.on "error", (err) ->
    #  @_logger "err: #{err}"
    #  return callback err
    return callback null

  # Redisへの接続を閉じる
  #
  close: ->
    @_logger.debug 'RedisManager#close'
    if @_client
      @_client.end()
      @_logger.debug 'redis client closed.'

  # キーを用いてオブジェクトを格納する
  #
  # @param [String] key キー
  # @param [Object] obj キーに対応するオブジェクト
  # @param [Function] callback コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 結果
  #
  hmset: (key, obj, callback) ->
    @_logger.debug 'RedisManager#hmset'
    @_logger.debug "key: #{key}"
    @_logger.debug "obj: #{obj}"
    @_client.hmset key, obj, (err, reply) =>
      return callback err, reply

  # キーを用いてオブジェクトを取得する
  #
  # @param [String] key キー
  # @param [Function] callback コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 結果
  #   
  hgetall: (key, callback) ->
    @_logger.debug 'RedisManager#hgetall'
    @_logger.debug "key: #{key}"
    @_client.hgetall key, (err, reply) =>
      return callback err, reply

  # キーが存在しているか確認する
  #
  # @param [String] key キー
  # @param [Function] callback コールバック関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 true；該当するキーが存在する
  #          false：該当するキーが存在しない
  # 
  exists: (key, callback) ->
    @_logger.debug 'RedisManager#exists'
    @_client.exists key, (err, reply) =>
      if err
        return callback err, null
      @_logger.debug "exists count: #{reply}"
      if reply <= 0
        return callback err, false
      else
        return callback err, true

  # キーを削除する
  #
  # @param [String] key キー
  # @param [Function] callback コールバック関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 true；成功
  #          false：失敗
  #
  delete: (key, callback) ->
    @_logger.debug 'RedisManager#delete'
    @_client.del key, (err, reply) =>
      if err
        return callback err, false
      @_logger.debug "delete count: #{reply}"
      return callback err, true

module.exports = RedisManager
