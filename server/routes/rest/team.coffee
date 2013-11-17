wrapper = require('./mongo_wrapper')
ObjectID = require('mongodb').ObjectID

fromJSON = (json) -> json

toJSON = (model) ->
	ret = model
	delete ret._id
	ret

hasAccess = (userId, teamId) -> true

module.exports = (app) ->
	app.get '/teams', (request, response) ->
		response.send(500, '')

	app.get '/teams/:id', (request, response) ->
		try
			teamId = request.params.id
			if hasAccess(request.session.userId, teamId)
				wrapper (db) ->
					[team] = db.collection('teams').find({ _id: ObjectID(teamId) })
					response.send(toJSON(team))
			else
				response.send(403, '')
		catch e
			response.send(500, '')

	app.post '/teams', (request, response) ->
		try
			wrapper (db) ->
				team = fromJSON(request.body)
				collection = db.collection('teams')
				collection.insert team, { safe: true }, (err, records) ->
					if not err
						response.send(records[0]._id.$oid)
					else
						response.send(500, '')

		catch e
			response.send(500, '')

	app.put '/teams/:id', (request, response) ->
		try
			teamId = request.params.id
			if hasAccess(request.session.userId, teamId)
				wrapper (db) ->
					team = fromJSON(request.body)
					db.collection('teams').update({ _id: ObjectID(teamId) }, team)
					response.send(200, '')
			else
				response.send(403, '')
		catch e
			response.send(500, '')

	app.delete '/users/:id', (request, response) ->
		try
			teamId = request.params.id

			if hasAccess(request.session.id, teamId)
				wrapper (db) ->
					db.collection('teams').remove({ _id: ObjectID(teamId) })
			else
				response.send(403, '')

		catch e
			response.send(500, '')