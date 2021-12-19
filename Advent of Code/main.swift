//
//  main.swift
//  No rights reserved.
//

import Foundation
import RegexHelper

func main() {
    let fileUrl = URL(fileURLWithPath: "./aoc-input")
    guard let inputString = try? String(contentsOf: fileUrl, encoding: .utf8) else { fatalError("Invalid input") }
    
    let lines = inputString.components(separatedBy: "\n")
        .filter { !$0.isEmpty }
    var newString = lines[0]
    for i in 1 ..< lines.count {
        newString = "[\(newString),\(lines[i])]"
        newString = sanitise(newString)
    }

    let result = magnitude(of: newString)
    print(result)
}

func main2() {
    let fileUrl = URL(fileURLWithPath: "./aoc-input")
    guard let inputString = try? String(contentsOf: fileUrl, encoding: .utf8) else { fatalError("Invalid input") }

    let lines = inputString.components(separatedBy: "\n")
        .filter { !$0.isEmpty }

    var maxMagnitude = 0

    for i in 0 ..< lines.count {
        for j in 0 ..< lines.count {
            if i != j {
                let line1 = lines[i]
                let line2 = lines[j]
                var newString = "[\(line1),\(line2)]"
                newString = sanitise(newString)
                let result = magnitude(of: newString)
                maxMagnitude = max(maxMagnitude, result)
            }
        }
    }
    print(maxMagnitude)
}

func magnitude(of num: String) -> Int {
    let helper = RegexHelper(pattern: #"(\[(\d+)\,(\d+)\])"#)
    var newString = num
    var moreToReplace = true

    while moreToReplace {
        let result = helper.parse(newString)
        if result.count == 3 {
            let str = result[0]
            let first = Int(result[1])!
            let second = Int(result[2])!
            let sum = first * 3 + second * 2

            newString = newString.replacingOccurrences(of: str, with: "\(sum)")
        } else {
            moreToReplace = false
        }
    }

    return Int(newString)!
}

func sanitise(_ num: String) -> String {
    var operationNeeded = false
    var newString = num
    repeat {
        if let (openBrace, closeBrace) = explodeNeeded(num: newString) {
            newString = explode(num: newString, openBraceIndex: openBrace, closeBraceIndex: closeBrace)
            operationNeeded = true
        } else if let str = splitNeeded(num: newString) {
            newString = split(num: newString, by: str)
            operationNeeded = true
        } else {
            operationNeeded = false
        }
    } while operationNeeded
    return newString
}

func split(num: String, by n: String) -> String {
    let number = Int(n)!
    let firstN = Int(floor(Double(number) / 2))
    let secondN = Int(ceil(Double(number) / 2))
    return num.stringByReplacingFirstOccurrenceOfString(target: n, withString: "[\(firstN),\(secondN)]")
}

func splitNeeded(num: String) -> String? {
    let helper = RegexHelper(pattern: #"(\d{2})"#)
    let result = helper.parse(num)
    guard !result.isEmpty else { return nil }
    return result[0]
}

func explode(num: String, openBraceIndex: Int, closeBraceIndex: Int) -> String {
    let chars = Array(num).map(String.init)

    var prevNumberIndex: Int?
    var prevNumber: Int?
    var nextNumberIndex: Int?
    var nextNumber: Int?


    for j in (0 ..< openBraceIndex).reversed() { // find a number before
        if let digit = Int(chars[j]) {
            var pos = j
            var number = digit
            var power = 1
            for k in (0 ..< j).reversed() {
                if let digit = Int(chars[k]) {

                    number += 10.pow(power) * digit
                    power += 1
                    pos = k
                } else {
                    break
                }
            }
            prevNumberIndex = pos
            prevNumber = number
            break
        }
    }

    for j in closeBraceIndex + 1 ..< chars.count { // find a number after
        if let digit = Int(chars[j]) {
            var number = digit
            for k in j + 1 ..< chars.count {
                if let digit = Int(chars[k]) {
                    number = 10 * number + digit
                } else {
                    break
                }
            }
            nextNumber = number
            nextNumberIndex = j
            break
        }
    }

    let components = chars[openBraceIndex + 1 ... closeBraceIndex - 1].joined(separator: "").components(separatedBy: ",").map { Int($0)! }
    let firstN = components[0]
    let secondN = components[1]
    var newArray = chars

    if let nextNumber = nextNumber, let nextNumberIndex = nextNumberIndex {
        let next = nextNumber + secondN
        let nextNumberWidth = "\(nextNumber)".count
        newArray = newArray[0 ..< nextNumberIndex] + ["\(next)"] + newArray[nextNumberIndex + nextNumberWidth ..< newArray.count]
    }

    newArray = newArray[0 ..< openBraceIndex] + ["0"] + newArray[closeBraceIndex + 1 ..< newArray.count]

    if let prevNumber = prevNumber, let prevNumberIndex = prevNumberIndex {
        let prev = prevNumber + firstN
        let prevNumberWidth = "\(prevNumber)".count
        newArray = newArray[0 ..< prevNumberIndex] + ["\(prev)"] + newArray[prevNumberIndex + prevNumberWidth ..< newArray.count]
    }

    return newArray.joined(separator: "")
}

func explodeNeeded(num: String) -> (openBrace: Int, closeBrace: Int)? {
    let chars = Array(num).map(String.init)

    var bracketCount = 0
    for i in 0 ..< chars.count {
        if chars[i] == "[" {
            bracketCount += 1
        } else if chars[i] == "]" {
            bracketCount -= 1
        }
        if bracketCount == 5 {
            let openBraceIndex = i
            var closeBraceIndex = 0
            for j in i ..< chars.count {
                if chars[j] == "]" {
                    closeBraceIndex = j
                    break
                }
            }
            guard openBraceIndex < closeBraceIndex else { fatalError() }
            return (openBrace: openBraceIndex, closeBrace: closeBraceIndex)
        }
    }
    return nil
}

main()
main2()


extension Int {
    func pow(_ toPower: Int) -> Int {
        guard toPower > 0 else { return 0 }
        return Array(repeating: self, count: toPower).reduce(1, *)
    }
}

extension String {
    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}
