package project.lib

import std.io.*
import std.fs.*
import std.collection.*
import std.convert.*
import std.sort.*
import std.ast.*
import serialization.serialization.*
import encoding.json.JsonValue
import encoding.json.ToJson 
import project.utils.*

public type BookSorter = (Book, Book) -> Ordering

public open class Library {
    // 成员变量
    private var books: ArrayList<Book>
    private let dataFilename: String

    // 构造函数
    public init(filename: String) {
        this.dataFilename = filename
        this.books = ArrayList<Book>()
    }

    // --- 核心公共方法 ---
    public func saveToFile(): Bool {
        let dataModelSeq = DataModelSeq()
        for (book in this.books) {
            dataModelSeq.add(book.serialize())
        }

        try {
            let jsonValue = dataModelSeq.toJson()
            let jsonString = jsonValue.toString()
            let memoryStream = ByteArrayStream()
            let writer = StringWriter(memoryStream)

            writer.write(jsonString)
            writer.flush() 
            File.writeTo(this.dataFilename, memoryStream.readToEnd())

        } catch (e: Exception) {
            println("Error saving file: ${e}")
            return false
        }
        return true
    }

public func loadFromFile(): Bool {
    if (!File.exists(this.dataFilename)) { return true }
    this.books.clear()
    try {
        let jsonString = String.fromUtf8(File.readFrom(this.dataFilename))
        
        let jsonValue = JsonValue.fromStr(jsonString)

        let dataModel = DataModel.fromJson(jsonValue)
        
        this.books = ArrayList<Book>.deserialize(dataModel)

    } catch (e: Exception) {
        println("Error loading file: ${e}")
        return false
    }
    return true
}

    
    /**
     * 添加一本书到图书馆。
     */
    public func addBook(title: String, author: String, isbn: String, year: Int64, genres: ArrayList<String>) {
        // 检查ISBN是否已存在
        for (book in this.books) {
            if (book.isbn == isbn) {
                 println("Error: Book with ISBN ${isbn} already exists.")
                 return
            }
        }
        
        let newGenres = ArrayList<String>(genres)
        let newBook = Book(title: title, author: author, isbn: isbn, year: year, genres: newGenres)
        this.books.append(newBook) 
        println("Book '${title}' added successfully.")
    }

    /**
     * 根据ISBN号移除一本书。
     */
    public func removeBook(isbn: String): Bool {
        var indexToRemove = -1
        for (i in 0..this.books.size) { 
            if (this.books[i].isbn == isbn) {
                indexToRemove = i
                break
            }
        }

        if (indexToRemove >= 0) {
            this.books.remove(indexToRemove)
            println("Book with ISBN ${isbn} removed.")
            return true
        } else {
            println("Book with ISBN ${isbn} not found.")
            return false
        }
    }
    
    /**
     * 根据ISBN查找一本书。返回 Option<Book> 类型。
     */
    public func findBook(isbn: String): Option<Book> {
        for (book in this.books) {
            if (book.isbn == isbn) {
                return Some(book) 
            }
        }
        return None
    }
    
    /**
     * 列出图书馆里所有的书籍。
     */
    public func listAllBooks(sorter!: Option<BookSorter>) {
        if (this.books.size == 0) {
            println("The library is empty.")
            return
        }

       let booksToDisplay = Array<Book>(this.books)

        match (sorter) {
            case Some(doSort) => 
                // 如果传入了排序函数 (Some)，就用它来排序
                stableSort<Book>(booksToDisplay, doSort)
            case None => ()
                // 如果没传入 (None)，则不进行任何排序
        }

        println("\n--- All Books in Library ---")
        for (book in booksToDisplay) {
            book.display()
        }
    }
    
    /**
    * 处理按作者搜索的逻辑。
    */
    public func findBooksByAuthor(authorName!: String): ArrayList<Book> {
        let results = ArrayList<Book>()
        for (book in this.books) {
            if (book.author == authorName) {
                results.append(book)
            }
        }
        return results
    }

    /**
    * 处理按书名模糊搜索的逻辑。
    */
    public func findBooksByTitle(query!: String): ArrayList<Book> {
        let results = ArrayList<Book>()
        if (query.isEmpty()) {
            return results
        }
        for (book in this.books) {
            if (book.title.contains(query)) {
                results.append(book)
            }
        }
        return results
    }

    /**
    * 给已有的书添加评论
    */
    public func addReviewToBook(isbn!: String, review!: Review): Bool {
        let bookOpt = this.findBook(isbn)
        match (bookOpt) {
            case Some(book) => 
                book.reviews.append(review)
                return true
            case None => 
                return false
        }
    }

}