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
    let filename: String
    let xmlContent: String
    
    init(title: String, composer: String, description: String, filename: String, xmlContent: String) {
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
        loadSampleMusic()
    }
    
    private func loadSampleMusic() {
        pieces = [
            MusicPiece(
                title: "Simple Scale",
                composer: "Demo",
                description: "A basic C major scale for testing basic functionality",
                filename: "simple_scale.xml",
                xmlContent: SampleMusicXML.simpleScale
            ),
            MusicPiece(
                title: "Twinkle, Twinkle, Little Star",
                composer: "Traditional",
                description: "Classic children's song with simple melody",
                filename: "twinkle.xml",
                xmlContent: SampleMusicXML.twinkleTwinkleLittleStar
            ),
            MusicPiece(
                title: "Bach Minuet",
                composer: "J.S. Bach",
                description: "A short classical piece demonstrating more complex notation",
                filename: "bach_minuet.xml",
                xmlContent: SampleMusicXML.bachMinuet
            ),
            MusicPiece(
                title: "Chord Progression",
                composer: "Demo",
                description: "Simple chord progression for testing harmony display",
                filename: "chord_progression.xml",
                xmlContent: SampleMusicXML.chordProgression
            )
        ]
        
        // Select the first piece by default
        selectedPiece = pieces.first
    }
    
    func selectPiece(_ piece: MusicPiece) {
        selectedPiece = piece
    }
    
    func selectPiece(at index: Int) {
        guard index >= 0 && index < pieces.count else { return }
        selectedPiece = pieces[index]
    }
}
