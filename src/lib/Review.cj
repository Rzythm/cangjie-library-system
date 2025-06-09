package project.lib

import serialization.serialization.*
import std.time.DateTime

public class Review <: Serializable<Review> {
    public var rating: Int64
    public var text: String
    public var reviewerName: String
    public var timestamp: DateTime

    public init(rating!: Int64, text!: String, reviewerName!: String) {
        this.rating = rating
        this.text = text
        this.reviewerName = reviewerName
        this.timestamp = DateTime.now()
    }


    public init() {
        this.rating = 0
        this.text = ""
        this.reviewerName = ""
        this.timestamp = DateTime.now()
    }

    public func serialize(): DataModel {
        return DataModelStruct()
            .add(field<Int64>("rating", this.rating))
            .add(field<String>("text", this.text))
            .add(field<String>("reviewerName", this.reviewerName))
            .add(field<String>("timestamp", this.timestamp.toString()))
    }

    public static func deserialize(dm: DataModel): Review {
        let dms = dm as DataModelStruct
        let result = Review()
        result.rating = Int64.deserialize(dms.getOrThrow().get("rating"))
        result.text = String.deserialize(dms.getOrThrow().get("text"))
        result.reviewerName = String.deserialize(dms.getOrThrow().get("reviewerName"))
        result.timestamp =  DateTime.now() 

        return result
    }

    public func display(): Unit {
        println("--------------------")
        println("Rating:      ${this.rating}/5")
        println("Reviewer:    ${this.reviewerName}")
        println("Date:        ${this.timestamp.toString()}")
        println("Review:      ${this.text}")
        println("--------------------")
    }

}