express       = require 'express'
LogicFactory  = require '../logics/admin-logics/logic-factory'
router        = express.Router()

# ログインルート(POST Request)
#
router.post "/", (req, res) ->
  logger = module.parent.exports.set("Logger")

  logger.info '[router - login] called /login'

  logicfactory =  new LogicFactory(logger)

  # ロジックの作成
  myLogic = logicfactory.makeLogic 'login-logic'
  # ロジックの実行
  myLogic.logicExecute req, (httpStatus, resData) ->
    logger.debug "[logib] httpStatus: #{httpStatus}, response: #{resData}"
    myLogic.dispose()

    if httpStatus == 200
      # HTTPステータスが200の場合、セッションIDをcookieに設定して返す
      # sessionid = [sessionid]
      res.cookie 'sessionid', resData.body.sessionid, { path: '/', secure: false, httpOnly: true  }
      # セッションIDはcookieをして返すのでbodyの再作成
      resData.body = {username: resData.body.username}
    return res.status(httpStatus).send resData

module.exports = router