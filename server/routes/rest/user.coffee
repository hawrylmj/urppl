wrapper = require('./mongo_wrapper')
crypto = require('crypto')
ObjectID = require('mongodb').ObjectID

SHA256 = (text) -> crypto.createHash('sha256').update(text).digest('hex')

fromJSON = (json) -> json

toJSON = (model) ->
	ret = model
	delete ret._id
	delete ret.password_hash
	delete ret.password_salt
	ret

module.exports = (app) ->
	app.get '/login', (request, response) ->
		try
			email = request.query.email
			password = request.query.password

			wrapper (db) ->
				collection = db.collection('users')
				[user] = collection.find({ email: email })
				success = SHA256(password + user.password_salt) is user.password_hash

				if success
					request.session.userId = user._id.$oid
					response.send(toJSON(user))
				else
					response.send(null)
		catch e
			response.status(500)

	app.get '/users', (request, response) ->
		response.status(500)

	app.get '/users/:id', (request, response) ->
		try
			wrapper (db) ->
				id = request.params.id
				collection = db.collection('teams')
				teams = collection.find({ users: { $all: [request.session.userId, id] } })

				if teams.length > 0
					[user] = collection.find({ _id: ObjectID(id) })

					if user
						response.send(toJSON(user))
					else
						response.status(404)

				else
					response.status(403)
		catch e
			response.status(500)

	app.post '/users', (request, response) ->
		try
			wrapper (db) ->
				user = fromJSON(request.body)
				collection = db.collection('users')
				collection.insert user, { safe: true }, (err, records) ->
					if not err
						response.send(records[0]._id.$oid)
					else
						response.status(500)

		catch e
			response.status(500)

	app.put '/users/:id', (request, response) ->
		try
			wrapper (db) ->
				id = request.params.id
				if request.session.id isnt id
					response.status(403)
					return

				user = fromJSON(request.body)
				collection = db.collection('users')
				collection.update { _id: ObjectID(request.session.id) }, user

		catch e
			response.status(500)

	app.delete '/users/:id', (request, response) -> response.status(403)