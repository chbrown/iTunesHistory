#!/usr/bin/env swift
import Foundation

/**
 Generic FileHandle wrapper with custom init and write implementations.
 */
class FileAppender {
    private var fileHandle: FileHandle

    /**
     Open file at `path`, creating blank file (with no contents and default attributes) if needed, and seek to EOF.

     - parameter path: path to file, which may or may not already exist
     */
    init(_ path: String) {
        // can't open a non-existent file for writing (um, weird?)
        if !FileManager.default.fileExists(atPath: path) {
            // create it if it doesn't exist
            // FileManager#createFile returns Bool => true if successful or already exists
            // (which might be useful?), but we'll just fail hard at FileHandle constructor step
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        // now open it (failing hard on I/O error, including no file existing at path)
        fileHandle = FileHandle(forWritingAtPath: path)!
        // seek to the end manually (no option to open in append mode?)
        fileHandle.seekToEndOfFile()
    }

    /**
     Append the given string to the opened file.

     - parameter line: native string to write to the file, encoded as UTF-8. Should already include newline.
     */
    func write(_ line: String) {
        // fail hard if line cannot be serialized as UTF-8
        let data = line.data(using: .utf8)!
        fileHandle.write(data)
    }
}
