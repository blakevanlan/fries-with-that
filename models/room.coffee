mongoose = require "mongoose"
Schema = mongoose.Schema

roomSchema = new Schema(
   {
      exits: [{
         roomId: { type: Schema.Types.ObjectId, ref: "Room" }
         phrase: { type: String, require: true }
      }]
      objects: [{
         phrase: { type: String, require: true }
         text: [{ type: String }]
      }]
      title: { type: String, require: true }
      text: [{ type: String }]
   }
   , { collection: "rooms" })

module.exports = mongoose.model("Room", roomSchema)