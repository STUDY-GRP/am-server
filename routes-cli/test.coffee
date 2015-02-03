express       = require 'express'
LogicFactory  = require '../logics/cli-logics/logic-factory'
router        = express.Router()

# 認証ルート(POST Request)
#
router.post "/post/", (req, res) -> 
  logger = module.parent.exports.set("Logger")

  logger.info '[router - test] called /test/post'

  logicfactory =  new LogicFactory(logger)

  # ロジックの作成
  myLogic = logicfactory.makeLogic 'test-logic'
  # ロジックの実行
  myLogic.logicExecute req, (httpStatus, resData) ->
    logger.debug "[auth] httpStatus: #{httpStatus}, response: #{resData}"
    myLogic.dispose()
    # レスポンスの返却
    return res.status(httpStatus).send resData
module.exports = router