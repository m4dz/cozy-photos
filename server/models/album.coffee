americano = require 'americano-cozy'
async = require 'async'
CozyInstance = require './cozy_instance'
Photo = require './photo'

module.exports = Album = americano.getModel 'Album',
    id            : String
    title         : String
    description   : String
    date          : Date
    orientation   : Number
    coverPicture  : String
    clearance: (x) -> x
    folderid      : String

Album.beforeSave = (next, data) ->
    if data.title?
        data.title = data.title
                        .replace /<br>/g, ""
                        .replace /<div>/g, ""
                        .replace /<\/div>/g, ""

    # Set default date if not set.
    data.date = new Date() unless data.date?

    next()

Album::getPublicURL = (callback) ->
    CozyInstance.getURL (err, domain) =>
        return callback err if err
        url = "#{domain}public/album/#{@id}"
        callback null, url

Album.listWithThumbs = (callback) ->
    async.parallel [
        (cb) -> Album.request 'byTitle', cb
        (cb) -> Photo.albumsThumbs cb
    ], (err, results) ->
        [albums, defaultCovers] = results
        async.map albums, (album, cb) =>
            album = album.toObject()
            if not album.coverPicture and defaultCover = defaultCovers[album.id]
                [album.coverPicture, album.orientation] = defaultCover

            cb null, album

        , callback
