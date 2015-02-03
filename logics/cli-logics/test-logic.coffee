BaseLogic = require '../../commonLibs/base-logic'
RESULTCD  = require '../../commonLibs/result-code'

# Testロジッククラス
#
class TestLogic extends BaseLogic

  # TestLogicを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (logger) ->
    logger.debug 'TestLogic#constructor'
    super logger

  # 入力パラメータの妥当性をチェックする 。
  #
  # @param [Object] request HTTPリクエストオブジェクト
  # @param [Function] callback コールバック関数
  # callback関数
  #   第1引数 エラーの場合、RESULTCDオブジェクト
  #          エラーでない場合、null
  # 
  validate: (request, callback) ->
    @_logger.debug 'TestLogic#validate'
    @_logger.debug 'TestLogic#validate is success.'
    return callback null

  # 業務ロジックを実行する
  #
  # @param [Object] request HTTPリクエストオブジェクト
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、RESULTCDオブジェクト
  #          エラーでない場合、null
  #   第2引数 レスポンスに渡すデータ
  #
  execute: (request, callback) ->
    @_logger.debug 'TestLogic#execute'
    data =
      access_token: "f2b8b63dea78d6353116db84bbe6a06a35dfd9a9b21b3684fb63620ba582761a8ea3e05cd07b43d3be118e5ce6009f11f6137bca8e6f7c5e48e3824d2862f44c_"
      message: "This is Test!!!"
    return callback RESULTCD.OK, data
module.exports = TestLogic
