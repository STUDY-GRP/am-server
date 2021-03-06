express       = require 'express'
LogicFactory  = require '../logics/cli-logics/logic-factory'
router        = express.Router()

# 認証ルート(POST Request)
#
router.post "/access_token/", (req, res) ->
  
  logger = module.parent.exports.set("Logger")

  logger.info '[router - auth] called /access_token'

  logicfactory =  new LogicFactory(logger)

  # ロジックの作成
  myLogic = logicfactory.makeLogic 'auth-logic'
  # ロジックの実行
  myLogic.logicExecute req, (httpStatus, resData) ->
    logger.debug "[auth] httpStatus: #{httpStatus}, response: #{resData}"
    myLogic.dispose()
    return res.status(httpStatus).send resData
module.exports = router