mongo = require('mongodb')

module.exports = (fn) ->
	mongo.Db.connect process.env.MONGOLAB_URI, (err, db) ->
		throw err if err

		try
			fn(db)
		catch e
			throw e
		finally
			db.close()