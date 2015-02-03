Config         = require('config');
Log4js         = require('log4js');
express        = require("express")
path           = require("path")
favicon        = require("serve-favicon")
#logger         = require("morgan")
cookieParser   = require("cookie-parser")
bodyParser     = require("body-parser")
methodOverride = require('method-override')
# Routing - Client
routes         = require("./routes-cli/index")
auth           = require("./routes-cli/auth")
attendanceTime = require("./routes-cli/attendance-time")
quiitingTime   = require("./routes-cli/quitting-time")
test           = require("./routes-cli/test")
# Routing - Administrator
login          = require("./routes-admin/login")
logout         = require("./routes-admin/logout")
users          = require("./routes-admin/users")
attendance     = require("./routes-admin/attendance")

Log4js.configure Config.log.configure
logger = Log4js.getLogger 'application'

app = express()

# view engine setup
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.set "Logger", logger

# uncomment after placing your favicon in /public
#app.use(favicon(__dirname + '/public/favicon.ico'));
# app.use express.logger("dev")
# for parsing application/json
#app.use bodyParser()
#app.use bodyParser.json()
# for parsing application/x-www-form-urlencoded
app.use bodyParser.urlencoded {extended: true}
app.use bodyParser.json()
app.use methodOverride()
# cookieを使用する設定
app.use cookieParser()
app.use express.static(path.join(__dirname, "public"))
app.use Log4js.connectLogger(logger)

app.use (req, res, next) ->
  logger.debug "Initialize Request!!"
  res.header "Content-Type", "application/json;charset=UTF-8"
  # キャッシュ関連
  res.header "Pragma", "no-cache"
  res.header "Cache-Control", "no-cache, must-revalidate"
  next()

# Routing
app.use "/", routes
app.use "/api/1.0/auth", auth
app.use "/api/1.0/attendance_time", attendanceTime
app.use "/api/1.0/quitting_time", quiitingTime
app.use "/api/1.0/test", test
app.use "/admin/api/1.0/login", login
app.use "/admin/api/1.0/logout", logout
app.use "/admin/api/1.0/user", users
app.use "/admin/api/1.0/attendance", attendance

# catch 404 and forward to error handler
app.use (req, res, next) ->
  logger.info "404 Not Found"
  err = new Error("Not Found")
  err.status = 404
  next err
  return

# error handlers
# development error handler
# will print stacktrace
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: err
    return


# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error",
    message: err.message
    error: {}
  return

# uncaughtExceptionをログ出力
process.on 'uncaughtException', (err)->
  logger.error "Caught exception:#{err}"
  logger.debug err.stack

module.exports = app
