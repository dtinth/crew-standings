###

Crew Standings

by Thai Pangsakulyanont (dtinth)
http://github.com/dtinth/crew-standings

Licensed CC BY 3.0
http://creativecommons.org/licenses/by/3.0/

###

djmaxcrew_xpath = '//table[@width="960"]//table[@width="960"]//table[@width="960" and not(@height)]//table[@width="960"]//td[@width="725"]'
djmaxcrew_base = 'http://djmaxcrew.com'

yql_base_uri = 'http://query.yahooapis.com/v1/public/yql'
yql_cache_time = 1800

crews = []
default_crewgroup = 'thailand'

yql = do ->
	counter = 0
	return (query, callback) ->
		description = 'cb' + (++counter)
		cb_name = 'window.yql_cb.' + description
		if not window.yql_cb?
			window.yql_cb = {}
		window.yql_cb[description] = callback
		url = yql_base_uri + '?q=' + encodeURIComponent(query) + '&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=' + encodeURIComponent(cb_name) + '&_maxage=' + yql_cache_time
		sc = document.createElement 'script'
		sc.src = url
		document.body.appendChild sc

fetch = (url, callback) ->
	query = 'select * from htmlstring where xpath=\'' + djmaxcrew_xpath + '\' and url=\'' + url + '\''
	yql query, callback

$ize = (fn) ->
	return (data) ->
		fn $ data.query.results.result

fetchDoc = (url, callback) ->
	fetch url, $ize callback

parseFileName = (url) ->
	url.replace(/^[\s\S]*\//, '').replace(/.[^.]+$/, '')

parseText = (text) ->
	text.replace(/^\s+/, '').replace(/\s+$/, '').replace(/\s+/g, ' ')

parseNumber = (number) ->
	parseFloat (number + '').replace(/[^0-9\.]/g, '')

parseIntNumber = (number) ->
	parseInt (number + '').replace(/[^0-9]/g, ''), 10

fixx = do ->
	if 'createTouch' of document
		return ->
	list = []
	$(window).scroll ->
		for el in list
			el.css 'margin-top', (-$(window).scrollTop()) + 'px'
	(el) ->
		list.push $ el

class Loader

	constructor: ->
		@totalObjects = 0
		@loadedObjects = 0
		@progress = 0
		@element = $('<div class="progress-bar"></div>').appendTo(@container = $('<div class="progress-bar-container"></div>').appendTo '#main')

	onfinish: ->

	addObject: ->
		@totalObjects++

	addProgress: ->
		if @totalObjects > 0
			@loadedObjects++
			startPosition = if @loadedObjects > 1 then 1 - (1 - @progress) * (@totalObjects / (@totalObjects - @loadedObjects + 1)) else 0
			endPosition = 1
			@progress = startPosition + (@loadedObjects / @totalObjects) * (endPosition - startPosition)
			if @loadedObjects == @totalObjects
				@element.css
					'-moz-transition': 'width 0.3s linear'
					'-webkit-transition': 'width 0.3s linear'
					'-ms-transition': 'width 0.3s linear'
					'-o-transition': 'width 0.3s linear'
					'transition': 'width 0.3s linear'
				@container.delay(1500).fadeOut('slow')
				@onfinish()
			@element.css 'width', Math.pow(@progress, 2) * 100 + '%'

class Fader

	constructor: (@element) ->
		@element = $ @element
		@opacity = parseFloat @element.css 'opacity'
		@interval = 0

	fadeIn: ->
		@direction = 0.003
		@startAnimation()

	fadeOut: ->
		@direction = -0.003
		@startAnimation()
	
	startAnimation: ->
		@stopAnimation()
		@startTime = new Date().getTime()
		@startOpacity = @opacity
		@interval = setInterval =>
			@animationFrame()
		, 1000 / 60
	
	animationFrame: ->
		elapsedTime = new Date().getTime() - @startTime
		opacity = @startOpacity + @direction * elapsedTime
		if opacity < 0
			opacity = 0
		else if opacity > 1
			opacity = 1
		@setOpacity opacity
		if (opacity == 0 and @direction < 0) or (opacity == 1 and @direction > 0)
			@stopAnimation()
		
	stopAnimation: ->
		clearInterval @interval

	setOpacity: (opacity) ->
		@opacity = opacity
		@element.css 'opacity', @opacity
		@element.css 'display', if @opacity == 0 then 'none' else ''

class CrewListItemView
	
	constructor: (@crew) ->
	
	render: (index, container) ->
		container = $ container
		view = $ '''<div class="crew-container"><div class="crew">
			<div class="row row-crew">
				<img src="http://promo.platinumcrew.co.kr/technika2/icon/technika2/emblem_big/pattern/''' + @crew.pattern + '''.png"
					style="background: url(http://promo.platinumcrew.co.kr/technika2/icon/technika2/emblem_big/plate/''' + @crew.plate + '''.png) no-repeat"
					alt="Pattern">
				<a href="?crew=''' + encodeURIComponent(@crew.name) + '''">''' + @crew.name + '''</a>
			</div>
			<div class="row row-rank">
				''' + @crew.rank + '''
				<span class="points">''' + @crew.points + ''' pts</span>
			</div>
			<div class="row row-week">''' + (
				if @crew.weekly?
					'''<div class="weekly-info">
						''' + @crew.weekly.rank + '''
						<span class="points">''' + @crew.weekly.points + ''' pts</span>
					</div>'''
				else
					'<div class="weekly-not-available">N/A</div>'
			) + '''</div>
			''' + (
				if @crew.weekly?
					'''<div class="row row-weekly weekly-data">
						<img src="http://images.djmaxcrew.com/Technika2/EN/icon/technika2/disc_m/''' + @crew.weekly.song1 + '''.png" alt="''' + @crew.weekly.song1 + '''">
						<img src="http://images.djmaxcrew.com/Technika2/EN/icon/technika2/disc_m/''' + @crew.weekly.song2 + '''.png" alt="''' + @crew.weekly.song2 + '''">
						<img src="http://images.djmaxcrew.com/Technika2/EN/icon/technika2/disc_m/''' + @crew.weekly.song3 + '''.png" alt="''' + @crew.weekly.song3 + '''">
					</div>'''
				else
					'''<div class="row row-weekly">
						<div class="weekly-not-available">N/A</div>
					</div>'''
			) + '''
			<div class="row row-members"></div>
		</div></div>'''
		view.css 'left', (150 + index * 333) + 'px'
		memberIndex = 0
		members = view.find '.row-members'
		for member in @crew.members
			@renderMember memberIndex, members, member
			memberIndex++
		view.appendTo container

	renderMember: (index, container, member) ->
		container = $ container
		isProducer = @crew.weekly? and @crew.weekly.producer == member.name
		view = $ '''<div class="member role-''' + member.role + '''">
			<div class="image">
				<img alt="Icon" src="http://images.djmaxcrew.com/Technika2/EN/icon/technika2/icon_big/''' + member.icon + '''.png">
				<div class="plate" style="background-image:url(http://images.djmaxcrew.com/Technika2/EN/icon/technika2/dj_title/usertitleplate/''' + member.plate + '''.png)">
					<div class="pattern" style="background-image:url(http://images.djmaxcrew.com/Technika2/EN/icon/technika2/dj_title/usertitlepattern/''' + member.pattern + '''.png)">
					</div>
				</div>
			</div>
			<div class="info">
				<div class="level">Lv.''' + member.level + '''</div>
				<div class="name"></div>
			</div>
		</div>'''
		view.find('.pattern').text member.title
		view.find('.name').text member.name
		if isProducer
			view.find('.name').append('''<span class="producer" title="This week's course producer">★</span>''')
		info = view.find('.info')
		view.css 'z-index', @crew.members.length - index + 1
		fader = new Fader(info)
		view.hover ->
			view.addClass('hover')
			fader.fadeOut()
		, ->
			view.addClass('hover')
			fader.fadeIn()
		view.appendTo container

class CrewListView
	
	constructor: (@crews) ->
		@container = $ '#main'
		header = $ '''<div class="header-container"><div class="header">
			<div class="row row-crew">Crew</div>
			<div class="row row-rank">Overall Rank</div>
			<div class="row row-week">Weekly Rank</div>
			<div class="row row-weekly">Weekly Course</div>
			<div class="row row-members">Members</div>
		</div></div>'''
		fixx header
		header.appendTo @container
		@load()

	load: (crewList) ->
		index = 0
		for crew in @crews
			view = new CrewListItemView crew
			view.render index, @container
			index++

class CrewListLoader

	constructor: (@crews) ->
		@element = $('<div class="status-bar"></div>').appendTo(@container = $('<div class="status-bar-container"></div>'))

	onfinish: ->

	load: ->
		matches = null
		params = location.search + ''
		params = params.replace /^\?/, ''
		params = params.replace /\/$/, ''
		if matches = params.match /^([a-z]+)$/
			@loadGroup(matches[1])
		else
			options = {}
			for option in ((decodeURIComponent(str) for str in param.split '=') for param in params.split '&')
				if option.length > 1
					options[option[0]] = option.slice(1).join('=')
			if options['crew']?
				@loadCrew(options['crew'])
			else
				@loadGroup(default_crewgroup)

	loadCrew: (crewName) ->
		@crews.push crewName
		@onfinish()

	loadGroup: (groupName) ->
		@container.appendTo '#main'
		@element.text 'Loading crew list from group "' + groupName + '"...'
		$.ajax
			type: 'GET'
			url: 'groups/' + groupName + '.xml'
			dataType: 'xml'
			success: (xml) =>
				@handleXML xml
			error: (xhr, errorType) =>
				@failure 'Unable to load crew group "' + groupName + '".'

	handleXML: (xml) ->
		xml = $ xml
		for crew in xml.find('crew')
			crew = $ crew
			crewName = parseText crew.text()
			@crews.push crewName
		@finish()
		@onfinish()

	finish: ->
		@element.text 'Crew List Loaded'
		@container.fadeOut()

	failure: (message) ->
		@element.text message
		@container.addClass 'error'


class App

	constructor: ->
		@loadCrewList()

	loadCrewList: ->
		loader = new CrewListLoader(crews)
		loader.onfinish = =>
			@loadCrews()
		loader.load()

	loadCrews: ->
		@loader = new Loader()
		@loader.onfinish = =>
			setTimeout =>
				@loaded()
			, 400
		@crews = []
		@weekly = {}
		@loadWeekly 1
		@loadWeekly 2
		@loadWeekly 3, true
		for crewName in crews
			@loadCrew crewName

	loaded: ->
		for crew in @crews
			if @weekly[crew.name]?
				crew.weekly = @weekly[crew.name]
		@crews.sort (a, b) ->
			return a.rank - b.rank
		new CrewListView @crews
		if window.navigator.standalone
			$(document.body).css 'min-height', (150 + 333 * @crews.length) * 3 / 4 + 'px'

	loadWeekly: (page, loadNext = false) ->
		@loader.addObject()
		fetchDoc djmaxcrew_base + '/crewrace/crewrace_ing.asp?page=' + page, (doc) =>
			found = false
			for tr in doc.find 'tr'
				tr = $ tr
				if tr.find('> td[height="40"] + td[width="10"]').length > 0
					info =
						name:       parseText      tr.find('> td[width="170"] .text11_4_b').text()
						points:     parseIntNumber tr.find('> td[width="170"] .text11_gray').text()
						producer:   parseText      tr.find('td[width="134"] .text11_4_b').text()
						song1:      parseFileName  tr.find('td[width="52"] img').eq(0).attr('src')
						song2:      parseFileName  tr.find('td[width="52"] img').eq(1).attr('src')
						song3:      parseFileName  tr.find('td[width="52"] img').eq(2).attr('src')
						rank:       parseNumber    tr.find('> td[width="70"] span.text11_4_b').text()
					if info.name in crews
						@weekly[info.name] = info
					found = true
			if found and loadNext
				@loadWeekly page + 1, true
			@loader.addProgress()

	loadCrew: (crewName) ->
		@loader.addObject()
		fetchDoc djmaxcrew_base + '/ranking/ranking_crew.asp?search_txt=' + encodeURIComponent(crewName), (doc) =>
			for tr in doc.find 'tr[onclick]'
				tr = $ tr
				info =
					id:         parseNumber   tr.attr('onclick')
					name:       parseText     tr.find('span.text11_4_b').text()
					points:     parseNumber   tr.find('span.text11_gray').text()
					plate:      parseFileName tr.find('table[background]').attr('background')
					pattern:    parseFileName tr.find('table[background] img').attr('src')
					rank:       parseNumber   tr.find('td.text12_4_b').text()
				if info.name == crewName
					@crews.push info
					@loadCrewMembers info
			@loader.addProgress()

	loadCrewMembers: (crew) ->
		@loader.addObject()
		ml = (filename) ->
			return if filename == 'icon_leader' then 'leader' else 'member'
		crew.members = []
		fetchDoc djmaxcrew_base + '/ranking/ranking_crew_member.asp?checkval1=' + crew.id, (doc) =>
			for tr in doc.find('table[width="552"] tr')
				tr = $ tr
				if tr.find('td[width="308"]').length > 0
					info =
						name:      parseText      tr.find('span.text18_4_b').text()
						role:   ml parseFileName  tr.find('td[width="80"] img').attr('src')
						icon:      parseFileName  tr.find('td[width="308"] td[width="104"] img').attr('src')
						plate:     parseFileName  tr.find('td[width="308"] td[background]:not([class])').attr('background')
						pattern:   parseFileName  tr.find('td[width="308"] td[background]:not([class]) td[background]').attr('background')
						title:     parseText      tr.find('td[width="308"] td[background]:not([class]) td[background]').text()
						level:     parseIntNumber tr.find('span.text11_4_b').text()
					crew.members.push info
			@loader.addProgress()

	@main = => new @

$ ->
	App.main()
	fixx '.fixx'
	if window.navigator.standalone
		$('#fork').hide()
