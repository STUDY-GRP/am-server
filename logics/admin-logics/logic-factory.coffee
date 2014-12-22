LoginLogic            = require './login-logic'
LogoutLogic           = require './logout-logic'
UserRegistrationLogic = require './user-registration-logic'
AttendanceLogic       = require './attendance-logic'
UserSearchLogic       = require './user-search-logic'

# 管理機能ロジックファクトリクラス
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
    @_logger.debug 'LogicFactory#makeLogic'
    switch logicname
      when 'login-logic' then new LoginLogic(@_logger)
      when 'logout-logic' then new LogoutLogic(@_logger)
      when 'user-registration-logic' then new UserRegistrationLogic(@_logger)
      when 'attendance-logic' then new AttendanceLogic(@_logger)
      when 'user-search-logic' then new UserSearchLogic(@_logger)

module.exports = LogicFactory