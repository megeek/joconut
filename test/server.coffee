connect = require 'connect'
router = require 'route66'
fs = require 'fs'

router.get '/', (req, res) ->
	fs.readFile "#{ __dirname }/index.html", (err, source) ->
		res.end source.toString()

router.get '/sub', (req, res) ->
	fs.readFile "#{ __dirname }/sub.html", (err, source) ->
		res.end source.toString()

app = do connect
app.use connect.static "#{ __dirname }/../dist"
app.use connect.static "#{ __dirname }/../libs"
app.use router
app.listen 3000