mongo = require('mongodb')

module.exports = (fn) ->
	mongo.Db.connect process.env.MONGOLAB_URI, (err, db) ->
		if err
			console.log('Error connecting to DB: ' + err)
			throw err

		try
			fn(db)
		catch e
			console.log('Error caught while executing wrapper: ' + e)
			throw e
		finally
			db.close()