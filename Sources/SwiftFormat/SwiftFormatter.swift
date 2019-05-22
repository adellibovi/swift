//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftFormatConfiguration
import SwiftFormatCore
import SwiftFormatPrettyPrint
import SwiftSyntax

/// Formats Swift source code or syntax trees according to the Swift style guidelines.
public final class SwiftFormatter {

  /// The configuration settings that control the formatter's behavior.
  public let configuration: Configuration

  /// A diagnostic engine to which non-fatal errors will be reported.
  public let diagnosticEngine: DiagnosticEngine?

  /// Advanced options that are useful when debugging the formatter's behavior but are not meant for
  /// general use.
  public var debugOptions: DebugOptions = []

  /// Creates a new Swift code formatter with the given configuration.
  ///
  /// - Parameters:
  ///   - configuration: The configuration settings that control the formatter's behavior.
  ///   - diagnosticEngine: The diagnostic engine to which non-fatal errors will be reported.
  ///     Defaults to nil.
  public init(configuration: Configuration, diagnosticEngine: DiagnosticEngine? = nil) {
    self.configuration = configuration
    self.diagnosticEngine = diagnosticEngine
  }

    public func parse(contentsOf url: URL) throws -> Syntax {
        guard FileManager.default.isReadableFile(atPath: url.path) else {
            throw SwiftFormatError.fileNotReadable
        }
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
            throw SwiftFormatError.isDirectory
        }
        return try SyntaxTreeParser.parse(url)
    }

  /// Formats the given Swift syntax tree and writes the result to an output stream.
  ///
  /// - Parameters:
  ///   - syntax: The Swift syntax tree to be converted to source code and formatted.
  ///   - url: A file URL denoting the filename/path that should be assumed for this syntax tree.
  ///   - outputStream: A value conforming to `TextOutputStream` to which the formatted output will
  ///     be written.
  /// - Throws: If an unrecoverable error occurs when formatting the code.
  public func format<Output: TextOutputStream>(
    syntax: Syntax, assumingFileURL url: URL, to outputStream: inout Output
  ) throws {
    let context
      = Context(configuration: configuration, diagnosticEngine: diagnosticEngine, fileURL: url)
    let pipeline = FormatPipeline(context: context)
    populate(pipeline)

    let transformedSyntax = pipeline.visit(syntax)

    if debugOptions.contains(.disablePrettyPrint) {
      outputStream.write(transformedSyntax.description)
      return
    }

    let printer = PrettyPrinter(
      context: context,
      node: transformedSyntax,
      printTokenStream: debugOptions.contains(.dumpTokenStream))
    outputStream.write(printer.prettyPrint())
  }

  // TODO: Add an overload of `format` that takes the source text directly.
}
