mongoose = require "mongoose"
Schema = mongoose.Schema

configSchema = new Schema(
   {
      startingRoom: { type: Schema.Types.ObjectId, ref: "Room" }
   }
   , { collection: "config" })

configSchema.statics.getConfig = (done) -> Config.findOne {}, done
configSchema.statics.setStartingRoom = (roomId, done) ->
   Config.getConfig (err, configuration) ->
      return done(err) if err
      configuration.startingRoom = roomId
      configuration.save(done)
      
Config = module.exports = mongoose.model("Config", configSchema)
