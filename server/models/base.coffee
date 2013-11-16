class BaseModel
	constructor: (@id = null) ->
		@properties = {}

	setProperty: (key, value) ->
		@properties[key] = value

	getProperty: (key) -> @properties[key]

	deleteProperty: (key) ->
		delete @properties[key]

	hasProperty: (key) -> @properties[key] isnt null and @properties isnt undefined

module.exports = BaseModel