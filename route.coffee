
Group = require('./controllers').Group

module.exports = (app, APIClient) ->

  app.get('/', (req, res) ->
    res.send('this is qqqun api.')
  )

  app.get('/qqqun', (req, res) ->

    errorPage = app.get('errorPage')

    options = {}
    for key, val of req.query
      options[key.toLowerCase()] = val
    if not options.openid or not options.groupopenid
      if errorPage then res.redirect(errorPage)
      else res.json({messgae: 'openid or groupopenid not found.'})

    group = new Group(APIClient, options)
    group.fetch((err, data) ->
      if err and  errorPage then res.redirect(errorPage)
      else res.json(err or data)
    )
  )
