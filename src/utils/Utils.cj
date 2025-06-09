package project.utils

import std.console.*

public func readLine(prompt: String): String {
    Console.stdOut.write(prompt)
    Console.stdOut.flush()
    return Console.stdIn.readln() ?? ""
}

public func colorize(text!: String, colorCode!: String): String {
    let reset = "\u{1B}[0m" // ANSI重置代码，恢复默认颜色
    return "${colorCode}${text}${reset}"
}