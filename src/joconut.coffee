class window._History
	@listeners: {} # listeners for change event
	@states: {} # collection of all states
	@loaded: no # WebKit browser fire popstate event on page load
	
	@init: ->
		if window.history.replaceState # detecting support
			window.history.replaceState { url: location.pathname }, document.title, location.pathname
			@states[location.pathname]=
				state:
					url: location.pathname
				title: document.title
			window.onpopstate = =>
				return @emit 'change', @states[location.pathname] if @loaded
				@loaded = yes
		else
			@states[location.hash]=
				state:
					url: location.pathname
				title: document.title
			window.onhashchange = =>
				@emit 'change', @states[location.hash]
	
	@emit: (event, data) ->
		for listener in @listeners[event]
			listener(data)
	
	@on: (event, listener) ->
		@listeners[event] = [] if not @listeners[event]
		@listeners[event].push listener
	
	@push: (state, title, url) ->
		document.title = title if title
		@states[if history.pushState then url else "##{ url }"]=
			state: state
			title: title
		if history.pushState then history.pushState(state, title, url) else location.hash = url

_History.init()

fn = ($) ->
	isLocal = new RegExp "^(#{ location.protocol }\/\/#{ location.host }|\\.|\\/|[A-Z0-9_])", 'i' # dynamically generating regex
	
	$.expr[':'].local = (e) -> # finding local links
		local = no
		href = e.attributes['href'].value
		local = yes if isLocal.test(href)
		local
	
	fill = (response, callback) -> # replacing current page's content with the new one
		$('body').html /<body[^>]*>((.|[\n\r])*)<\/body>/im.exec(response)[1] # fill body
		document.title = /<title>((.|\n\r])*)<\/title>/im.exec(response)[1] # set title
		
		$head = undefined # no need to find <head> now
		
		# load scripts, if needed
		
		loop
			tag = /<script\b[^>]*><\/script>/gm.exec response
			break if not tag
			src = /src\=.?([A-Za-z0-9-_.\/]+).?/.exec tag[0]
			break if not src
			src = src[1]
			if -1 is scripts.indexOf(src) # need to insert
				scripts.push src
				$head = $ 'head' if not $head
				$head.append tag[0]
			response = response.replace tag[0], ''
		
		# load stylesheets, if needed
		
		loop
			tag = /<link\b[^>]*\/?>/gm.exec response
			break if not tag
			if /rel\=.?stylesheet.?/.test tag[0]
				href = /href\=.?([A-Za-z0-9-_.\/]+).?/.exec tag[0]
				break if not href
				href = href[1]
				if -1 is stylesheets.indexOf(href) # need to insert
					stylesheets.push href
					$head = $ 'head' if not $head
					$head.append tag[0]
			response = response.replace tag[0], ''
		
		setTimeout -> # setting up a little timeout, waiting for HTML to get inserted
			$.joconut()
			do callback if callback
		, 50
	
	get = (options, callback) -> # GET
		$.ajax
			url: options.url
			type: 'GET'
			success: (response) ->
				callback false, response
	
	_History.on 'change', (e) ->
		get url: e.state.url, (err, response) -> # just loading URL
			fill response
	
	scripts = []
	$('script').each ->
		scripts.push $(@).attr('src')
	
	stylesheets = []
	$('link').each ->
		stylesheets.push $(@).attr('href')
	
	$.joconut = -> # attach Joconut to links and forms
		$('a:local').each ->
			el = $ @
			el.click (e) ->
				url = el.attr 'href'
				e.preventDefault()
				get url: url, (err, response) ->
					fill response, ->
						_History.push { url: url }, false, url
	
	$ ->
		$.joconut() # auto-initialization
		
fn(jQuery)	