//
//  TranspositionControlsView.swift
//  SheetMusicDemo
//
//  UI controls for music transposition functionality.
//

import SwiftUI

struct TranspositionControlsView: View {
    @Binding var transposeSteps: Int
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Title
            HStack {
                Image(systemName: "music.note.list")
                    .foregroundColor(.blue)
                Text("Transposition")
                    .font(.headline)
                Spacer()
            }
            
            // Current transposition display
            HStack {
                Text("Current:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(transpositionText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(transposeSteps == 0 ? .secondary : .primary)
            }
            
            // Control buttons
            HStack(spacing: 16) {
                // Transpose down
                Button(action: {
                    transposeSteps = max(transposeSteps - 1, -12)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "minus")
                        Text("Down")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(transposeSteps <= -12)
                
                // Reset
                Button(action: onReset) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(transposeSteps == 0)
                
                // Transpose up
                Button(action: {
                    transposeSteps = min(transposeSteps + 1, 12)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Up")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(transposeSteps >= 12)
            }
            
            // Quick transpose buttons
            VStack(spacing: 8) {
                Text("Quick Transpose:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach([-12, -6, -3, -1, 1, 3, 6, 12], id: \.self) { steps in
                        Button(action: {
                            transposeSteps = steps
                        }) {
                            Text(steps > 0 ? "+\(steps)" : "\(steps)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .disabled(transposeSteps == steps)
                    }
                }
            }
            
            // Help text
            Text("Transpose by semitones (-12 to +12). Positive values transpose up, negative values transpose down.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var transpositionText: String {
        if transposeSteps == 0 {
            return "Original Key"
        } else if transposeSteps > 0 {
            return "+\(transposeSteps) semitone\(transposeSteps == 1 ? "" : "s") up"
        } else {
            return "\(transposeSteps) semitone\(transposeSteps == -1 ? "" : "s") down"
        }
    }
}
