//
//  Resources.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 08-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import SWXMLHash

class AndroidToIos{
    static func writeXmlToLocalizableStrings(resourceURLs: [URL]) throws {
        
        let xmlParser = SWXMLHash.config { config in
            config.shouldProcessLazily = false
            config.shouldProcessNamespaces = false
            config.caseInsensitive = false
            config.encoding = String.Encoding.utf8
            config.userInfo = [:]
            config.detectParsingErrors = true
        }
        
        try resourceURLs
            .filter { $0.pathExtension == "xml" }
            .forEach { url in
                print("======== URL: \(url)")
                let fileContent = try String(contentsOf: url)
                
                let parsed = xmlParser.parse(fileContent)
                
                let stringDict = Dictionary(uniqueKeysWithValues:
                    parsed["resources"]["string"].all.map {
                        ($0.element!.attribute(by: "name")!.text, $0.element!.text)
                })
                
                let folderPath = url.deletingLastPathComponent().path
                let localizableFileUrl = URL(fileURLWithPath: folderPath + "/Localizable.strings")
                
                var result: String = ""
                stringDict.forEach { result += "\"\($0.key)\"=\"\($0.value)\";\n" }
                
                try Data(result.utf8).write(to: localizableFileUrl, options: .atomic)
                print("======== DONE")
        }
    }

}
