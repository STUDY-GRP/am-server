AuthLogic           = require './auth-logic'
AttendanceTimeLogic = require './attendance-time-logic'
QuittingTimeLogic   = require './quitting-time-logic'

class LogicFactory
	constructor: (@_logger) ->
		@_logger.debug 'LogicFactory#constructor'
	makeLogic: (logicname) ->
		@_logger.debug "LogicFactory#makeLogic"
		switch logicname
			when 'auth-logic' then new AuthLogic(@_logger)
			when 'attendance-time-logic' then AttendanceTimeLogic(@_logger)
			when 'quitting-time-logic' then QuittingTimeLogic(@_logger)
module.exports = LogicFactory
			