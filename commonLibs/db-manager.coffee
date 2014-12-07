pg     = require('pg').native
Config = require 'config'

class DBManager
  _done = null
  constructor: (@_logger)->
    @_logger.debug 'DBManager#constructor'

  begin: (client)->
    @_logger.debug 'DBManager#begin'
    client.query 'BEGIN', (err, result) =>
      if err
        # トランザクションの開始に失敗したらfalseを返す
        @_logger.error "Begin is failed. err:#{err}"
        callback false
      else
        # トランザクションの開始に成功したらtrueを返す
        @_logger.debug "Begin is success."
        callback true
  rollback: (client, callback) ->
    @_logger.debug 'DBManager#rollback'
    client.query 'ROLLBACK', (err, result) =>
      if err
        # ロールバックに失敗したらfalseを返す
        @_logger.error "Rollback is failed. err:#{err}"
        callback false
      else
        # ロールバックに成功したらtrueを返す
        @_logger.debug "Rollback is success."
        callback true
  commit: (client, callback) ->
    @_logger.debug 'DBManager#commit'
    client.query 'COMMIT', (err, result) =>
      if err
        # コミットに失敗したらfalseを返す
        @_logger.error "Commit is failed. err:#{err}"
        callback false
      else
        # コミットに成功したらtrueを返す
        @_logger.debug "Commit is success."
        callback true
  open: (callback) ->
    @_logger.debug 'DBManager#open'
    pg.connect Config.db.configure, (err, client, done) ->
      @_done = done
      callback err, client
  execute: (client, sql, paramaters, callback) ->
    client.query sql, paramaters, (err, result) ->
      callback err, result
  close: () ->
    @_logger.debug 'DBManager#close'
    @_done() if @_done
    @_done = null
module.exports = DBManager