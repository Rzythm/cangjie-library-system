# 项目情况

## 项目介绍

**个人图书馆管理系统**是一个基于仓颉语言开发的纯命令行应用程序。它为用户提供了一个简洁、高效的方式来管理自己的个人书籍收藏。用户可以通过一个交互式的菜单，轻松地添加新书、编辑书籍信息、为书籍评分和撰写评论、以及通过多种方式查询和排序自己的书库。

项目实现了完整的数据持久化功能，所有书籍和评论信息都会以结构化的 **JSON** 格式保存在本地，确保数据在程序关闭后不会丢失。通过这个项目，我们实践了仓颉语言的面向对象编程、模块化设计、文件I/O、数据序列化以及错误处理等核心特性。

## 项目特性

* **完整的书籍管理 (CRUD)**：支持书籍的添加 (Create)、查找 (Read)、编辑 (Update) 和删除 (Delete)。
* **丰富的交互菜单**：提供一个多层级的命令行菜单，引导用户完成所有操作，用户体验友好。
* **高级搜索与过滤**：除了通过唯一的ISBN精确查找，还支持按作者姓名、书名关键字（模糊搜索）进行查询。
* **评分与评论系统**：可以为每一本书添加多条独立的评分（1-5星）和文字评论，并能查看指定书籍的所有评论。
* **灵活的排序功能**：在列出所有书籍时，可按书名、作者或出版年份（升序/降序）进行动态排序。
* **健壮的数据持久化**：所有数据通过 `Serializable` 接口和 `DataModel` 中间层被序列化为 **JSON** 格式，保证了数据的结构完整性和可扩展性。
* **模块化代码结构**：项目被清晰地划分为 `lib` (核心逻辑)、`utils` (工具函数) 等多个包，结构清晰，易于维护。
* **用户体验优化**：包含删除前的二次确认、输入验证循环、彩色控制台输出等功能，提升了程序的健壮性和美观度。

## 使用说明

1.  **环境要求**
    * 已正确安装仓颉语言工具链，包括 `cjc` 编译器和 `cjpm` 包管理器。

2.  **编译项目**
    * 将项目克隆到本地。
    * 在项目根目录下，打开终端，运行以下命令来编译整个项目：
        ```bash
        cjpm build
        ```

3.  **运行程序**
    * 编译成功后，通过 `cjpm` 运行主程序：
        ```bash
        cjpm run
        ```
    * 程序启动后，会显示主菜单，根据菜单提示输入数字并按回车即可执行相应操作。

## 功能示例

下面是一个典型的用户交互流程：

```
===== Library Management System =====
1. Add a new book
2. Remove a book by ISBN
3. Find a book by ISBN
4. List all books
5. Advanced search
6. Edit a book
7. Manage Reviews
8. Save and Exit
=====================================
Enter your choice: 1

--- Add New Book ---
Enter Title: The C Programming Language
Enter Author: Brian W. Kernighan
Enter ISBN: 978-0131103627
Enter Publication Year: 1988
Enter Genres (separated by ';'): Programming;C;Classic
Book 'The C Programming Language' added successfully.

===== Library Management System =====
...
Enter your choice: 8

Saving library to library.json...
Library saved successfully as JSON.
Goodbye!
```

# API

### `project.lib.Review`

`Review` 类用于表示单条书籍评论。

**公共属性:**
* `rating: Int64`: 评分 (1-5)。
* `text: String`: 评论的文本内容。
* `reviewerName: String`: 评论者的名字。
* `timestamp: DateTime`: 评论创建时的时间戳。

**公共方法:**
* `init(rating!: Int64, text!: String, reviewerName!: String)`: 构造函数，自动生成当前时间戳。
* `display(): Unit`: 在控制台以格式化的方式打印出这条评论的详细信息。
* `serialize(): DataModel`: [Serializable接口] 将`Review`对象转换为`DataModel`，用于数据持久化。
* `static func deserialize(dm: DataModel): Review`: [Serializable接口] 从`DataModel`中恢复`Review`对象。

### `project.lib.Book`

`Book` 类是程序的核心数据模型，用于表示一本书。

**公共属性:**
* `title: var String`: 书名。
* `author: var String`: 作者。
* `isbn: let String`: ISBN号 (唯一标识，不可修改)。
* `publicationYear: var Int64`: 出版年份。
* `genres: var ArrayList<String>`: 书籍的类型标签列表。
* `reviews: var ArrayList<Review>`: 包含本书所有`Review`对象的列表。

**公共方法:**
* `init(title!: ..., author!: ..., isbn!: ..., year!: ..., genres!: ...)`: 用于手动创建新`Book`对象的构造函数。
* `display(): Unit`: 在控制台以格式化的方式打印出本书的详细信息。
* `serialize(): DataModel`: [Serializable接口] 将`Book`对象（包括其所有`Review`对象）转换为`DataModel`。
* `static func deserialize(dm: DataModel): Book`: [Serializable接口] 从`DataModel`中恢复`Book`对象及其所有评论。

### `project.lib.Library`

`Library` 类是项目的主要逻辑控制器，负责管理整个书库。

**公共方法:**
* `init(filename: String)`: 构造函数，指定数据持久化的文件名。
* `saveToFile(): Bool`: 将当前内存中的所有书籍和评论序列化为JSON格式并保存到文件中。
* `loadFromFile(): Bool`: 从文件中加载JSON数据，并反序列化为内存中的对象列表。
* `addBook(title!: ..., author!: ..., ...)`: 向书库中添加一本新书。
* `removeBook(isbn!: String): Bool`: 根据ISBN从书库中删除一本书。
* `findBook(isbn!: String): Option<Book>`: 根据ISBN精确查找一本书，返回一个`Option<Book>`。
* `findBooksByAuthor(authorName!: String): ArrayList<Book>`: 查找指定作者的所有书籍。
* `findBooksByTitle(query!: String): ArrayList<Book>`: 查找标题中包含指定关键字的所有书籍。
* `addReviewToBook(isbn!: String, review!: Review): Bool`: 为指定的书籍添加一条新的评论。
* `listAllBooks(sorter!: Option<BookSorter>)`: 列出所有书籍，并可以根据传入的排序函数进行排序。

### `project.utils.Utils`

`Utils` 包存放了通用的辅助函数。

**公共方法:**
* `readLine(prompt!: String): String`: 向控制台打印提示信息，并安全地读取用户输入的一行文本。
* `colorize(text!: String, colorCode!: String): String`: 为指定的文本添加ANSI颜色代码，用于在终端中显示彩色文本。
