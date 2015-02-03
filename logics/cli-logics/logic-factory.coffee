AuthLogic           = require './auth-logic'
AttendanceTimeLogic = require './attendance-time-logic'
QuittingTimeLogic   = require './quitting-time-logic'
TestLogic           = require './test-logic'

# クライアント機能ロジックファクトリクラス
#
class LogicFactory

  # LogicFactory生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (@_logger) ->
    @_logger.debug 'LogicFactory#constructor'

  # ロジックを生成する
  #
  # @param [String] logicname ロジック名
  # @return ロジッククラスのインスタンス
  #
  makeLogic: (logicname) ->
    @_logger.debug "LogicFactory#makeLogic"
    switch logicname
      when 'auth-logic' then new AuthLogic(@_logger)
      when 'attendance-time-logic' then new AttendanceTimeLogic(@_logger)
      when 'quitting-time-logic' then new QuittingTimeLogic(@_logger)
      when 'test-logic' then new TestLogic(@_logger)
module.exports = LogicFactory
			