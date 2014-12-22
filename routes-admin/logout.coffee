express = require 'express'
LogicFactory  = require '../logics/admin-logics/logic-factory'
router  = express.Router()

# ログアウトルート(GET Request)
#
router.get "/", (req, res) ->
  logger = module.parent.exports.set("Logger")

  logger.info '[router - logout] called /logout'

  logicfactory =  new LogicFactory(logger)

  # ロジックの作成
  myLogic = logicfactory.makeLogic 'logout-logic'
  # ロジックの実行
  myLogic.logicExecute req, (httpStatus, resData) ->
    logger.debug "[auth] httpStatus: #{httpStatus}, response: #{resData}"
    myLogic.dispose()
    return res.status(httpStatus).send resData

module.exports = router