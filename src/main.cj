package project

import std.console.*
import std.convert.*
import std.collection.*
import project.lib.* 
import project.utils.*

/**
 * 显示主菜单给用户。
 * 作为一个独立的私有函数，让主循环更清晰。
 */
private func displayMenu(): Unit {
    let title = "===== Library Management System ====="
    println(colorize(text: title, colorCode: "\u{1B}[1;34m"))
    println("1. Add a new book")
    println("2. Remove a book by ISBN")
    println("4. List all books")
    println("5. Advanced search")
    println("6. Edit a book")
    println("7. Review")
    println("8. Save and Exit")
    println("=====================================")
    Console.stdOut.write("Enter your choice: ") 
    Console.stdOut.flush() 
    // 确保提示信息立即显示
}

/**
 * 处理“添加书籍”的逻辑
 */
private func handleAddBook(library: Library): Unit {
    println("\n--- Add New Book ---")
    let title = readLine("Enter Title: ")
    let author = readLine("Enter Author: ")
    let isbn = readLine("Enter ISBN: ")

    var year: Int64 = 0
    while (true) {
        let yearStr = readLine("Enter Publication Year: ")
        let yearOpt = Int64.tryParse(yearStr)
        match (yearOpt) {
            case Some(y) => 
                // 默认年份在1000到2025之间
                if (y > 1000 && y < 2026) {
                    year = y
                    break // 输入有效，退出循环
                } else {
                    println("Invalid year. Please enter a reasonable year (e.g., between 1000 and 2025).")
                }
            case None => 
                println("Invalid input. Please enter a number.")
        }
    }

    let genresStr = readLine("Enter Genres (separated by ';'): ")
    let genres = Book.stringToGenres(genresStr)
    
    if (isbn.isEmpty()) {
        println("Error: ISBN cannot be empty.")
        return
    }
    library.addBook(title, author, isbn, year, genres) 
}

/**
 * 处理“移除书籍”的逻辑
 */
private func handleRemoveBook(library: Library): Unit {
    println("\n--- Remove Book ---")
    let isbn = readLine("Enter ISBN of the book to remove: ")
    if (isbn.isEmpty()) { return }

    // 先查找这本书，向用户展示将要删除的是什么
    let bookOpt = library.findBook(isbn)
    match (bookOpt) {
        case None => 
            println("Book with ISBN '${isbn}' not found.")
        case Some(book) => 
            println("You are about to delete the following book:")
            book.display()
            
            let confirm = readLine("Are you sure? (Enter yes to confirm): ")
            
            if (confirm == "yes") {
                if (library.removeBook(isbn)) {
                     println("Book successfully deleted.")
                }
            } else {
                println("Deletion cancelled.")
            }
    }
}

/**
 * 处理“查找书籍”的逻辑
 */
private func handleFindBook(library: Library): Unit {
    println("\n--- Find Book ---")
    let isbn = readLine("Enter ISBN of the book to find: ")
    if (isbn.isEmpty()) { return }

    let bookOpt = library.findBook(isbn)
    // 使用 match 表达式来优雅地处理 Option 类型
    match (bookOpt) {
        case Some(book) => 
            println("Book found:")
            book.display()
    
        case None => 
            println("Sorry, a book with ISBN '${isbn}' was not found.")
    }
}

private func handleEditBook(library: Library): Unit {
    println("\n--- Edit Book ---")
    let isbn = readLine("Enter ISBN of the book to edit: ")
    if (isbn.isEmpty()) { 
        println("ISBN cannot be empty.")
        return 
    }

    // 查找书籍，因为 book 是 class（引用类型），我们获取到的 bookOpt 里的对象就是 library 中原始对象的引用
    let bookOpt = library.findBook(isbn)

    match (bookOpt) {
        case None => 
            println("Book with ISBN '${isbn}' not found.")
        case Some(book) => 
            // 找到了书！现在进入一个编辑子循环
            while (true) {
                println("\nEditing book: '${colorize(text: book.title, colorCode: "\u{1B}[33m")}' (ISBN: ${colorize(text: book.isbn, colorCode: "\u{1B}[33m")}')")
                book.display() // 显示当前书籍的完整信息以便参考
                println("--- What do you want to edit? ---")
                println("1. Edit Title")
                println("2. Edit Author")
                println("3. Edit Publication Year")
                println("4. Finish Editing (Back to Main Menu)")
                
                let choiceStr = readLine("Your choice: ")
                let choice = Int64.tryParse(choiceStr) ?? -1

                match (choice) {
                    case 1 => 
                        let newTitle = readLine("Enter new title: ")
                        book.title = newTitle // 直接修改对象的属性，因为它是 var
                        println("Title updated successfully.")
                    case 2 => 
                        let newAuthor = readLine("Enter new author: ")
                        book.author = newAuthor
                        println("Author updated successfully.")
                    case 3 => 
                        let newYearStr = readLine("Enter new publication year: ")
                        // 如果用户输入无效，则保持原样
                        let newYear = Int64.tryParse(newYearStr) ?? book.publicationYear
                        book.publicationYear = newYear
                        println("Publication year updated successfully.")
                    case 4 => 
                        println("Finished editing. Returning to main menu.")
                        break // 退出编辑的 while 循环
                    case _ => 
                        println("Invalid choice. Please enter a number between 1 and 4.")
                }
            }
    }
}

private func displayBookList(books!: ArrayList<Book>, emptyMessage!: String): Unit {
    if (books.size == 0) {
        println(emptyMessage)
        return
    }

    println("\n--- Search Results ---")
    for (book in books) {
        book.display()
    }
    println("--- Found ${books.size} book(s) ---")
}


private func handleAdvancedSearch(library: Library): Unit {
    while (true) {
        println("\n--- Advanced Search Menu ---")
        println("1. Search by Author")
        println("2. Search by Title (contains)")
        println("3. Back to Main Menu")
        
        let choiceStr = readLine("Your choice: ")
        let choice = Int64.tryParse(choiceStr) ?? -1

        match (choice) {
            case 1 => 
                let author = readLine("Enter author's name: ")
                if (!author.isEmpty()) {
                    let results = library.findBooksByAuthor(authorName: author)
                    displayBookList(books: results, emptyMessage: "No books found for author: ${author}")
                }
            case 2 => 
                let query = readLine("Enter title keyword: ")
                if (!query.isEmpty()) {
                    let results = library.findBooksByTitle(query: query)
                    displayBookList(books: results, emptyMessage: "No books found with title containing: ${query}")
                }
            case 3 => 
                break 
            case _ => 
                println("Invalid choice. Please enter a number between 1 and 3.") 
        }
    }
}

private func handleListAndSort(library: Library): Unit {
    println("\n--- List Books ---")
    println("How would you like to sort the books?")
    println("1. Default (by entry order)")
    println("2. By Title (A-Z)")
    println("3. By Author (A-Z)")
    println("4. By Year (Newest First)")
    println("5. By Year (Oldest First)")

    let choiceStr = readLine("Your choice: ")
    let choice = Int64.tryParse(choiceStr) ?? 1

    var sorterOpt: Option<BookSorter> = None

    match (choice) {
        case 2 => 
            sorterOpt = Some({ a, b => a.title.compare(b.title) })
        case 3 => 
            sorterOpt = Some({ a, b => a.author.compare(b.author) })
        case 4 => 
            sorterOpt = Some({ a, b => b.publicationYear.compare(a.publicationYear) })
        case 5 => 
            sorterOpt = Some({ a, b => a.publicationYear.compare(b.publicationYear) })
        case _ => ()
    }

    // 调用我们重构后的 listAllBooks 方法，将闭包或 None 传递过去
    library.listAllBooks(sorter: sorterOpt)
}

private func handleReviewMenu(library: Library): Unit {
    println("\n--- Review Management ---")
    let isbn = readLine("Enter ISBN of the book you want to review/see reviews for: ")
    if (isbn.isEmpty()) { return }

    let bookOpt = library.findBook(isbn)
    match (bookOpt) {
        case None => println("Book with ISBN '${isbn}' not found.")
        case Some(book) => 
            // 找到了书，进入评论子菜单循环
            while (true) {
                println("\nReviewing book: '${colorize(text: book.title, colorCode: "\u{1B}[33m")}'")
                println("1. View all reviews (${book.reviews.size} reviews)")
                println("2. Add a new review")
                println("3. Back to Main Menu")

                let choiceStr = readLine("Your choice: ")
                let choice = Int64.tryParse(choiceStr) ?? -1
                
                match (choice) {
                    case 1 => viewReviews(book: book)
                    case 2 => addReview(library: library, book: book)
                    case 3 => break
                    case _ => println("Invalid choice.")
                }
            }
    }
}

/**
 * 显示一本书的所有评论
 */
private func viewReviews(book!: Book): Unit {
    println("\n--- Reviews for ${book.title} ---")
    if (book.reviews.size == 0) {
        println("This book has no reviews yet.")
        return
    }
    for (review in book.reviews) {
        review.display()
    }
}

/**
 * 为一本书添加新评论的交互流程
 */
private func addReview(library!: Library, book!: Book): Unit {
    println("\n--- Add a new review for ${book.title} ---")
    let reviewer = readLine("Your name: ")
    
    var rating: Int64 = 0
    while (true) {
        let ratingStr = readLine("Rating (1-5): ")
        let ratingOpt = Int64.tryParse(ratingStr)
        match(ratingOpt) {
            case Some(r) => 
                if (r >= 1 && r <= 5) {
                    rating = r
                    break
                } else {
                    println("Rating must be between 1 and 5.")
                }
            case None => println("Please enter a number.")
        }
    }
    
    let text = readLine("Your review: ")
    
    let newReview = Review(rating: rating, text: text, reviewerName: reviewer)
    
    if (library.addReviewToBook(isbn: book.isbn, review: newReview)) {
        println("Review added successfully!")
    } else {
        println("Error: Could not add review.")
    }
}



/**
 * 应用程序的主入口函数
 */
main(): Unit {
    // 1. 初始化
    let library = Library("library.json")
    library.loadFromFile()

    // 2. 主循环
    while (true) {
        displayMenu()
        let choiceStr = Console.stdIn.readln() ?? ""
        let choice = Int64.tryParse(choiceStr) ?? -1 // 默认为无效选项

        // 3. 根据用户选择执行操作
        match (choice) {
            case 1 => handleAddBook(library)
            case 2 => handleRemoveBook(library)
            case 3 => handleFindBook(library)
            case 4 => handleListAndSort(library)
            case 5 => handleAdvancedSearch(library)
            case 6 => handleEditBook(library) 
            case 7 => handleReviewMenu(library)
            case 8 => 
                library.saveToFile()
                println("Goodbye!")
                break // 退出 while 循环
            case _ => 
                println("Invalid choice. Please enter a number between 1 and 5.")
        }
    }
}