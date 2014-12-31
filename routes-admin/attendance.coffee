express = require 'express'
LogicFactory  = require '../logics/admin-logics/logic-factory'
router  = express.Router()

# 勤務表取得ルート(GET Request)
#
router.get "/:id/:year/:month", (req, res) ->
  logger = module.parent.exports.set("Logger")

  logger.info '[router - attendance] called /attendance'

  logicfactory =  new LogicFactory(logger)

  # ロジックの作成
  myLogic = logicfactory.makeLogic 'attendance-logic'
  # ロジックの実行
  myLogic.logicExecute req, (httpStatus, resData) ->
    logger.debug "[auth] httpStatus: #{httpStatus}, response: #{resData}"
    myLogic.dispose()
    return res.status(httpStatus).send resData

module.exports = router