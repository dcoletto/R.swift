//
//  Resources.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 08-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

enum ResourceParsingError: Error {
  case unsupportedExtension(givenExtension: String?, supportedExtensions: Set<String>)
  case parsingFailed(String)
}

struct Resources {
  let assetFolders: [AssetFolder]
  let images: [Image]
  let fonts: [Font]
  let nibs: [Nib]
  let storyboards: [Storyboard]
  let resourceFiles: [ResourceFile]
  let localizableStrings: [LocalizableStrings]
    
  let reusables: [Reusable]

  init(resourceURLs: [URL], fileManager: FileManager) {
    assetFolders = resourceURLs.compactMap { url in tryResourceParsing { try AssetFolder(url: url, fileManager: fileManager) } }
    images = resourceURLs.compactMap { url in tryResourceParsing { try Image(url: url) } }
    fonts = resourceURLs.compactMap { url in tryResourceParsing { try Font(url: url) } }
    nibs = resourceURLs.compactMap { url in tryResourceParsing { try Nib(url: url) } }
    storyboards = resourceURLs.compactMap { url in tryResourceParsing { try Storyboard(url: url) } }
    resourceFiles = resourceURLs.compactMap { url in tryResourceParsing { try ResourceFile(url: url) } }
    reusables = (nibs.map { $0 as ReusableContainer } + storyboards.map { $0 as ReusableContainer }).flatMap { $0.reusables }
    
    let xmlUrls = resourceURLs.filter { $0.pathExtension == "xml" }
    clearLocalizableFile(xmlUrls: xmlUrls, fm: fileManager)
    
    localizableStrings = resourceURLs.compactMap { url in tryResourceParsing { try LocalizableStrings(url: url) } }
    tmpToLocalizableFile(xmlUrls: xmlUrls, fm: fileManager)
  }
}

private func clearLocalizableFile(xmlUrls: [URL], fm: FileManager) {
    xmlUrls.forEach { xmlUrl in
        let tmpPath = xmlUrl.deletingLastPathComponent()
        let tmpFileUrl = URL(string: "\(tmpPath)\(CallInformation.tmpStringFileName)")!
        if fm.fileExists(atPath: tmpFileUrl.path) {
            do {
                try fm.removeItem(atPath: tmpFileUrl.path)
            } catch {
                print("Error removing [tmp] file \(tmpFileUrl.path)")
            }
        }
        let strFileUrl = URL(string: "\(tmpPath)Localizable.strings")!
        if fm.fileExists(atPath: strFileUrl.path) {
            do {
                print("Removing")
                try fm.removeItem(atPath: strFileUrl.path)
            } catch {
                print("Error removing [strings] file \(strFileUrl.path)")
            }
        }
    }
}

private func tmpToLocalizableFile(xmlUrls: [URL], fm: FileManager) {
    xmlUrls.forEach { xmlUrl in
        let tmpPath = xmlUrl.deletingLastPathComponent()
        let tmpFileUrl = URL(string: "\(tmpPath)\(CallInformation.tmpStringFileName)")!
        let localizableFileUrl = URL(string: "\(tmpPath)Localizable.strings")!
        do {
            print("===== .tmp.strings -> Localizable.strings =====")
            // Read from .tmp.strings
            let content = try Data(contentsOf: tmpFileUrl)
            // write to Localizable.strings
            let result = fm.createFile(atPath: localizableFileUrl.path, contents: content)
            if !result {
                print("Error creating file \(localizableFileUrl)")
            }
        } catch {
            print("Error reading content from file \(xmlUrl)")
        }
    }
}

private func tryResourceParsing<T>(_ parse: () throws -> T) -> T? {
  do {
    return try parse()
  } catch let ResourceParsingError.parsingFailed(humanReadableError) {
    warn(humanReadableError)
    return nil
  } catch ResourceParsingError.unsupportedExtension {
    return nil
  } catch {
    return nil
  }
}
