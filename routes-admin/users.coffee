express = require 'express'
LogicFactory  = require '../logics/admin-logics/logic-factory'
router  = express.Router()

# ユーザー登録ルート(POST Request)
#
router.post "/", (req, res) ->
  logger = module.parent.exports.set("Logger")

  console.log req.body
  
  logger.info '[router - users] called /user'

  logicfactory =  new LogicFactory(logger)

  # ロジックの作成
  myLogic = logicfactory.makeLogic 'user-registration-logic'
  # ロジックの実行
  myLogic.logicExecute req, (httpStatus, resData) ->
    logger.debug "[auth] httpStatus: #{httpStatus}, response: #{resData}"
    myLogic.dispose()
    return res.status(httpStatus).send resData

# ユーザー検索ルート(GET Request)
#
router.get "/search", (req, res) ->
  logger = module.parent.exports.set("Logger")

  logger.info '[router - users] called /user/search'

  logicfactory =  new LogicFactory(logger)

  # ロジックの作成
  myLogic = logicfactory.makeLogic 'user-search-logic'
  # ロジックの実行
  myLogic.logicExecute req, (httpStatus, resData) ->
    logger.debug "[auth] httpStatus: #{httpStatus}, response: #{resData}"
    myLogic.dispose()
    return res.status(httpStatus).send resData
  return

module.exports = router