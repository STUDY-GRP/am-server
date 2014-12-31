pg     = require('pg').native
Config = require 'config'

# DB管理機能を提供するクラス
#
class DBManager
  # DBクライアント
  _client = null
  # DB終了オブジェクト
  _done = null

  # DB管理オブジェクトを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (@_logger) ->
    @_logger.debug 'DBManager#constructor'

  # トランザクションを開始する
  #
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  begin: (callback)->
    @_logger.debug 'DBManager#begin'
    @_client.query 'BEGIN', (err) ->
      if err 
        @_logger.debug 'begin transaction failed.'
      callback err

  # トランザクションをロールバックする
  #
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  rollback: (callback) ->
    @_logger.debug 'DBManager#rollback'
    @_client.query 'ROLLBACK', (err) ->
      if err
        @_logger.debug 'rollback transaction failed.'
      callback err

  # トランザクションをコミットする
  #
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  commit: (callback) ->
    @_logger.debug 'DBManager#commit'
    @_client.query 'COMMIT', (err) ->
      if err
        @_logger.debug 'commit transction failed.'
      callback err

  # DBをオープンする
  #
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 DBクライアント
  #   第3引数 doneオブジェクト
  #
  open: (callback) ->
    @_logger.debug 'DBManager#open'
    pg.connect Config.db.configure, (err, client, done) =>
      @_client = client
      @_done = done
      callback err, client

  # クエリを実行する
  #
  # @param [String]   実行するSQL
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #   第2引数 クエリ実行結果オブジェクト
  #
  execute: (sql, paramaters, callback) ->
    @_logger.debug 'DBManager#execute'
    # @_logger.debug "#{@_client}"
    @_client.query sql, paramaters, (err, result) =>
      callback err, result

  # DBをクローズをする
  # 実際にはクライアントをプールに返す。
  #
  close: () ->
    @_logger.debug 'DBManager#close'
    @_done() if @_done
    @_done = null
module.exports = DBManager