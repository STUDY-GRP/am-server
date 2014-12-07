
LoginLogic            = require './login-logic'
LogoutLogic           = require './logout-logic'
UserRegistrationLogic = require './uer-registration-logic'
AttendanceLogic       = require './attendance-logic'

class LogicFactory
  
	constructor: (@logger) ->

	makeLogic: (logicname) ->
		logger.debug "called LogicFactory#makeLogic."
		switch logicname
			when 'login-logic' then new AuthLogic(@logger)
			when 'logout-logic' then new LogoutLogic(@logger)
			when 'user-registration-logic' then new UserRegistrationLogic(@logger)
			when 'attendance-logic' then new AttendanceLogic(@logger)

module.exports = LogicFactory