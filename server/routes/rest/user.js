// Generated by CoffeeScript 1.6.3
(function() {
  var ObjectID, SHA256, crypto, fromJSON, toJSON, wrapper;

  wrapper = require('mongo_wrapper');

  crypto = require('crypto');

  ObjectID = requre('mongodb').ObjectID;

  SHA256 = function(text) {
    return crypto.createHash('sha256').update(text).digest('hex');
  };

  fromJSON = function(json) {
    return json;
  };

  toJSON = function(model) {
    var ret;
    ret = model;
    delete ret._id;
    delete ret.password_hash;
    delete ret.password_salt;
    return ret;
  };

  module.exports = function(app) {
    app.get('/login', function(request, response) {
      var e, email, password;
      try {
        email = request.query.email;
        password = request.query.password;
        return wrapper(function(db) {
          var collection, success, user;
          collection = db.collection('users');
          user = collection.find({
            email: email
          })[0];
          success = SHA256(password + user.password_salt) === user.password_hash;
          if (success) {
            request.session.userId = user._id.$oid;
            return response.send(toJSON(user));
          } else {
            return response.send(null);
          }
        });
      } catch (_error) {
        e = _error;
        return response.status(500);
      }
    });
    app.get('/users', function(request, response) {
      return response.status(500);
    });
    app.get('/users/:id', function(request, response) {
      var e;
      try {
        return wrapper(function(db) {
          var collection, id, teams, user;
          id = request.params.id;
          collection = db.collection('users');
          teams = collection.find({
            users: {
              $all: [request.session.userId, id]
            }
          });
          if (teams.length > 0) {
            user = collection.find({
              _id: ObjectID(id)
            })[0];
            if (user) {
              return response.send(toJSON(user));
            } else {
              return response.status(404);
            }
          } else {
            return response.status(403);
          }
        });
      } catch (_error) {
        e = _error;
        return response.status(500);
      }
    });
    app.post('/users', function(request, response) {
      var e;
      try {
        return wrapper(function(db) {
          var collection, user;
          user = fromJSON(request.body);
          collection = db.collection('users');
          return collection.insert(user, {
            safe: true
          }, function(err, records) {
            if (!err) {
              return response.send(records[0]._id.$oid);
            } else {
              return response.status(500);
            }
          });
        });
      } catch (_error) {
        e = _error;
        return response.status(500);
      }
    });
    app.put('/users/:id', function(request, response) {
      var e;
      try {
        return wrapper(function(db) {
          var collection, id, user;
          id = request.params.id;
          if (request.session.id !== id) {
            response.status(403);
            return;
          }
          user = fromJSON(request.body);
          collection = db.collection('users');
          return collection.update({
            _id: ObjectID(request.session.id)
          }, user);
        });
      } catch (_error) {
        e = _error;
        return response.status(500);
      }
    });
    return app["delete"]('/users/:id', function(request, response) {
      return response.status(403);
    });
  };

}).call(this);
