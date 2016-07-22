//
//  Document.swift
//  Notes
//
//  Created by Christian Roese on 7/20/16.
//  Copyright © 2016 Nothin But Scorpions, LLC. All rights reserved.
//

import Cocoa

/// Names of files/directories in the package
enum NoteDocumentFileNames : String {
  case TextFile = "Text.rtf"
  case AttachmentsDirectory = "Attachments"
}

enum ErrorCode : Int {
  /// We couldn't find the document at all
  case CannotAccessDocument
  
  /// We couldn't access any file wrappers inside this document
  case CannotLoadFileWrappers
  
  /// We couldn't load the Text.rtf file
  case CannotLoadText
  
  /// We couldn't access the Attachments folder
  case CannotAccessAttachments
  
  /// We couldn't save the Text.rtf file
  case CannotSaveText
  
  /// We couldn't save an attachment
  case CannotSaveAttachment
}

let ErrorDomain = "NotesErrorDomain"

func err(code: ErrorCode, _ userInfo: [NSObject:AnyObject]? = nil) -> NSError {
  return NSError(domain: ErrorDomain, code: code.rawValue, userInfo: userInfo)
}

class Document: NSDocument {
  
  var text: NSAttributedString = NSAttributedString()
  var documentFileWrapper = NSFileWrapper(directoryWithFileWrappers: [:])
  
  override init() {
    super.init()
    // Add your subclass-specific initialization here.
    
  }
  
  override class func autosavesInPlace() -> Bool {
    return true
  }
  
  override var windowNibName: String? {
    // Returns the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
    return "Document"
  }
  
  override func fileWrapperOfType(typeName: String) throws -> NSFileWrapper {
    let textRTFData = try self.text.dataFromRange(NSRange(0..<self.text.length), documentAttributes: [
      NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType
      ])
    
    // replace existing text file, if it exists in the wrapper
    if let oldTextFileWrapper = self.documentFileWrapper.fileWrappers?[NoteDocumentFileNames.TextFile.rawValue] {
      self.documentFileWrapper.removeFileWrapper(oldTextFileWrapper)
    }
    
    self.documentFileWrapper.addRegularFileWithContents(textRTFData, preferredFilename: NoteDocumentFileNames.TextFile.rawValue)
    
    return self.documentFileWrapper
  }
  
  override func readFromFileWrapper(fileWrapper: NSFileWrapper, ofType typeName: String) throws {
    guard let fileWrappers = fileWrapper.fileWrappers else {
      throw err(.CannotLoadFileWrappers)
    }
    
    guard let documentTextData = fileWrappers[NoteDocumentFileNames.TextFile.rawValue]?.regularFileContents else {
      throw err(.CannotLoadText)
    }
    
    guard let documentText = NSAttributedString(RTF: documentTextData, documentAttributes: nil) else {
      throw err(.CannotLoadText)
    }
    
    self.documentFileWrapper = fileWrapper
    
    self.text = documentText
  }
  
}

