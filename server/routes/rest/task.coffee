wrapper = require('mongo_wrapper')
ObjectID = requre('mongodb').ObjectID

fromJSON = (json) -> json

toJSON = (model) ->
	ret = model
	delete ret._id
	ret

hasAccess = (userId, taskId) ->
	# get all members of all teams user is on
	users = []
	wrapper (db) ->
		collection = db.collection('teams')
		teams = collection.find({ users: userId })

		for team in teams
			for user in team.members
				if users.indexOf(user) < 0
					users.push(user)

	users = users.map((id) -> ObjectID(id))

	# see if any user has access
	access = false
	wrapper (db) ->
		collection = db.collection('users')
		usersWithAccess = collection.find({ _id: { $in: users }, tasks: taskId })
		if usersWithAccess.length > 0
			access = true

	access

module.exports = (app) ->
	app.get '/tasks', (request, response) ->
		response.status(500)

	app.get '/tasks/:id', (request, response) ->
		try
			id = request.params.id

			if hasAccess(request.session.userId, id)
				wrapper (db) ->
					[task] = db.collection('tasks').find({ _id: ObjectID(id) })
					response.send(toJSON(task))
			else
				response.status(403)
		catch e
			response.status(500)

	app.post '/tasks', (request, response) ->
		try
			wrapper (db) ->
				task = fromJSON(request.body)
				collection = db.collection('tasks')
				collection.insert task, { safe: true }, (err, records) ->
					if not err
						response.send(records[0]._id.$oid)
					else
						response.status(500)

		catch e
			response.status(500)

	app.put '/tasks/:id', (request, response) ->
		try
			taskId = request.params.id
			if hasAccess(request.session.id, taskId)
				task = fromJSON(request.body)
				wrapper (db) ->
					db.collection('tasks').update({ _id: ObjectID(taskId) }, task)
					response.status(200)
			else
				response.status(403)

		catch e
			response.status(500)

	app.delete '/tasks/:id', (request, response) ->
		try
			taskId = request.params.id

			if hasAccess(request.session.id, taskId)
				wrapper (db) ->
					db.collection('tasks').remove({ _id: ObjectID(taskId) })
			else
				response.status(403)

		catch e
			response.status(500)