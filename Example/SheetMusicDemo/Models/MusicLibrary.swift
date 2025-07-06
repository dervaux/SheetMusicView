//
//  MusicLibrary.swift
//  SheetMusicDemo
//
//  Manages the collection of sample MusicXML files for demonstration purposes.
//

import Foundation

/// Represents a sample music piece with metadata
struct MusicPiece: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let composer: String
    let description: String
    let filename: String // Now stores just the filename without extension
    let xmlContent: String? // Optional for file-based loading

    init(title: String, composer: String, description: String, filename: String, xmlContent: String? = nil) {
        self.title = title
        self.composer = composer
        self.description = description
        self.filename = filename
        self.xmlContent = xmlContent
    }
}

/// Manages the library of sample music pieces
class MusicLibrary: ObservableObject {
    @Published var pieces: [MusicPiece] = []
    @Published var selectedPiece: MusicPiece?
    
    init() {
        loadMusicFiles()
    }

    private func loadMusicFiles() {
        // First, try to load files dynamically from the bundle
        var discoveredPieces: [MusicPiece] = []

        // Get all .musicxml files from the bundle
        let musicXMLPaths = Bundle.main.paths(forResourcesOfType: "musicxml", inDirectory: nil)
        for path in musicXMLPaths {
            let url = URL(fileURLWithPath: path)
            let filenameWithExtension = url.lastPathComponent
            let filename = url.deletingPathExtension().lastPathComponent

            // Create a user-friendly title from the filename
            let title = filename.replacingOccurrences(of: "_", with: " ")
                .capitalized

            // Try to extract metadata from the file
            let (composer, description) = extractMetadata(from: path)

            let piece = MusicPiece(
                title: title,
                composer: composer,
                description: description,
                filename: filename // Store without extension for the new API
            )

            discoveredPieces.append(piece)
        }

        // If no files were found, fall back to hardcoded samples
        if discoveredPieces.isEmpty {
            discoveredPieces = [
                MusicPiece(
                    title: "Simple Scale",
                    composer: "Demo",
                    description: "A basic C major scale for testing basic functionality",
                    filename: "simple_scale",
                    xmlContent: SampleMusicXML.simpleScale
                ),
                MusicPiece(
                    title: "Twinkle, Twinkle, Little Star",
                    composer: "Traditional",
                    description: "Classic children's song with simple melody",
                    filename: "twinkle",
                    xmlContent: SampleMusicXML.twinkleTwinkleLittleStar
                ),
                MusicPiece(
                    title: "Bach Minuet",
                    composer: "J.S. Bach",
                    description: "A short classical piece demonstrating more complex notation",
                    filename: "bach_minuet",
                    xmlContent: SampleMusicXML.bachMinuet
                ),
                MusicPiece(
                    title: "Chord Progression",
                    composer: "Demo",
                    description: "Simple chord progression for testing harmony display",
                    filename: "chord_progression",
                    xmlContent: SampleMusicXML.chordProgression
                )
            ]
        }

        // Sort pieces alphabetically by title
        pieces = discoveredPieces.sorted { $0.title < $1.title }

        // Select the first piece by default
        selectedPiece = pieces.first
    }

    private func extractMetadata(from filePath: String) -> (composer: String, description: String) {
        // Try to extract composer and title from the MusicXML file
        guard let xmlContent = try? String(contentsOfFile: filePath) else {
            return ("Unknown", "MusicXML file")
        }

        var composer = "Unknown"
        var title = ""

        // Simple XML parsing to extract composer and title
        if let composerRange = xmlContent.range(of: #"<creator type="composer">(.*?)</creator>"#, options: .regularExpression) {
            let composerMatch = String(xmlContent[composerRange])
            if let match = composerMatch.range(of: #">(.*?)<"#, options: .regularExpression) {
                composer = String(String(composerMatch[match]).dropFirst().dropLast())
            }
        }

        if let titleRange = xmlContent.range(of: #"<work-title>(.*?)</work-title>"#, options: .regularExpression) {
            let titleMatch = String(xmlContent[titleRange])
            if let match = titleMatch.range(of: #">(.*?)<"#, options: .regularExpression) {
                title = String(String(titleMatch[match]).dropFirst().dropLast())
            }
        }

        let description = title.isEmpty ? "MusicXML file" : title
        return (composer, description)
    }
    
    func selectPiece(_ piece: MusicPiece) {
        selectedPiece = piece
    }
    
    func selectPiece(at index: Int) {
        guard index >= 0 && index < pieces.count else { return }
        selectedPiece = pieces[index]
    }
}
