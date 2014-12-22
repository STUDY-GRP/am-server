express      = require 'express'
LogicFactory = require '../logics/cli-logics/logic-factory'
router       = express.Router()

# 退社時間登録ルート(POST Request)
#
router.post "/", (req, res) ->
  logger = module.parent.exports.set("Logger")

  logger.info '[router - quitting_time] called /quitting_time'

  logicfactory = new LogicFactory(logger)

  # ロジックの作成
  myLogic = logicfactory.makeLogic 'quitting-time-logic'
  # ロジックの実行
  myLogic.logicExecute req, (httpStatus, resData) ->
    logger.debug "[quitting-time] httpStatus: #{httpStatus}, response: #{resData}"
    myLogic.dispose()
    return res.status(httpStatus).send resData

module.exports = router