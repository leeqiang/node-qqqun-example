###
Module dependencies.
###

express = require('express')
http = require('http')

APIV3 = require('openapiv3')
config = require('./config')

# new APIV3(app_id, app_key, api_server)
QQAPI = new APIV3(config.appId, config.appKey, config.serverIp)


app = express()
server = http.createServer(app)

app.configure(->
  app.set('port', process.env.PORT or 3000)
  app.use(express.cookieParser())
  app.use(app.router)
  app.use(express.logger('dev'))
  app.set('errorPage', process.env.ERROR_PAGE or config.errorPage)
)

require('./route')(app, QQAPI)
server.listen(app.get('port'))
console.log("Server listening on port ", app.get('port'))
