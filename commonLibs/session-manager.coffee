Crypto    = require 'crypto'

class SessionManager
  constructor: (@_logger)->
    @_logger.debug 'SessionManager#constructor'
  hasSession: (sid) ->
    # セッションをもっているかチェックする
  register: (baseValue, callback) ->
    @_logger.debug 'SessionManager#register'
    # セッションIDを生成する。
    # セッションID = 第1引数1 + 日時
    sidBaseValue = baseValue + (new Date).getTime()
    sha512 = Crypto.createHash 'sha512'
    sha512.update sidBaseValue
    sid = sha512.digest('hex')
    callback null, sid
		# セッションの登録
module.exports = SessionManager