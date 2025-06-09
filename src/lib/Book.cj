package project.lib

import serialization.serialization.*
import std.collection.*
import encoding.json.stream.* 


public class Book <: Serializable<Book> {
    public var title: String
    public var author: String
    public var isbn: String
    public var publicationYear: Int64
    public var genres: ArrayList<String>
    public var reviews: ArrayList<Review>

    public init(title!: String, author!: String, isbn!: String, year!: Int64, genres!: ArrayList<String>) {
    this.title = title
    this.author = author
    this.isbn = isbn
    this.publicationYear = year
    this.genres = genres
    this.reviews = ArrayList<Review>()
}

    public init() {
        this.title = ""
        this.author = ""
        this.isbn = ""
        this.publicationYear = 0
        this.genres = ArrayList<String>()
        this.reviews = ArrayList<Review>()
    }
    
    public func serialize(): DataModel {
        let dm = DataModelStruct()
        dm.add(field<String>("title", this.title))
        dm.add(field<String>("author", this.author))
        dm.add(field<String>("isbn", this.isbn))
        dm.add(field<Int64>("publicationYear", this.publicationYear))
        dm.add(field<ArrayList<String>>("genres", this.genres))
        dm.add(field<ArrayList<Review>>("reviews", this.reviews))
        return dm
    }

    public static func deserialize(dm: DataModel): Book {
        let dms = dm as DataModelStruct
        let result = Book()
        result.title = String.deserialize(dms.getOrThrow().get("title"))
        result.author = String.deserialize(dms.getOrThrow().get("author"))
        result.isbn = String.deserialize(dms.getOrThrow().get("isbn"))
        result.publicationYear = Int64.deserialize(dms.getOrThrow().get("publicationYear"))
        result.genres = ArrayList<String>.deserialize(dms.getOrThrow().get("genres"))
        result.reviews = ArrayList<Review>.deserialize(dms.getOrThrow().get("reviews"))
        return result
    }

    public static func genresToString(genres: ArrayList<String>): String {
        if (genres.size == 0) {
            return ""
        }
        var result = ""
        for (i in 0..genres.size) {
            result = result + genres[i]
            if (i < genres.size - 1) {
                result = result + ";"
            }
        }
        return result
    }

    public static func stringToGenres(genreStr: String): ArrayList<String> {
        let list = ArrayList<String>()
        if (genreStr.isEmpty()) {
            return list
        }
        let parts = genreStr.split(';')
        for (part in parts) {
            list.append(part)
        }
        return list
    }

    public func display(): Unit {
        println("---------------------------------")
        println("  Title: ${this.title}")
        println("  Author: ${this.author}")
        println("  ISBN: ${this.isbn}")
        println("  Year: ${this.publicationYear}")
        println("  Genres: ${Book.genresToString(this.genres)}")
        println("---------------------------------")
    }


}
