//
//  MusicPickerView.swift
//  SheetMusicDemo
//
//  Sheet view for selecting sample music pieces.
//

import SwiftUI

struct MusicPickerView: View {
    @ObservedObject var musicLibrary: MusicLibrary
    let onSelection: (MusicPiece) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(musicLibrary.pieces) { piece in
                        MusicPieceRow(
                            piece: piece,
                            isSelected: piece.id == musicLibrary.selectedPiece?.id
                        ) {
                            onSelection(piece)
                        }
                    }
                } header: {
                    Text("Sample Music Library")
                } footer: {
                    Text("Select a piece to load it into the sheet music viewer. Each piece demonstrates different aspects of MusicXML notation.")
                }
            }
            .navigationTitle("Choose Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MusicPieceRow: View {
    let piece: MusicPiece
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Music note icon
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                // Music info
                VStack(alignment: .leading, spacing: 4) {
                    Text(piece.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text("by \(piece.composer)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(piece.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct MusicPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPickerView(musicLibrary: MusicLibrary()) { _ in }
    }
}
#endif
