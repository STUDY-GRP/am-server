# レスポンスデータの構造を定義するクラス
#
class ResponseData

  # ResponseDataを生成するコンストラクタ
  #
  # @param [Object] _logger Log4jsログオブジェクト
  #
  constructor: (@_logger) ->
    @_logger.debug 'ResponseData#constructor'

  # レスポンスデータを作成sるう
  #
  # @param [Object] エラーオブジェクト※1
  # @param [Object] レスポンスデータ※2
  # @param [Function] コールバック関数
  # callback関数
  #   第1引数 エラーの場合、エラーオブジェクト
  #          エラーでない場合、null
  #
  # ※1 レスポンスデータのヘッダ情報として設定するエラーオブジェクト。
  #    Error {
  #      err.code
  #      err.message
  #    }
  # ※2 HTTPレスポンスのBodyに設定するデータオブジェクト
  #
  createResponseData: (err, data, callback) ->
    @_logger.debug 'ResponseData#createResponseData'
    @_logger.debug data
    resData = 
      header:
        errorcode: err.code
        message: err.message
      body:
        data
    @_logger.debug resData
    callback err.status, resData

module.exports = ResponseData