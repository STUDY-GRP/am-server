class ResponseData

  constructor: (@_logger) ->
    @_logger.debug 'ResponseData#constructor'
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