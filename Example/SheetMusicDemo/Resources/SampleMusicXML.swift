//
//  SampleMusicXML.swift
//  SheetMusicDemo
//
//  Contains embedded MusicXML content for demonstration purposes.
//

import Foundation

struct SampleMusicXML {
    
    /// Simple C major scale
    static let simpleScale = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
    <score-partwise version="3.1">
      <work>
        <work-title>Simple Scale</work-title>
      </work>
      <identification>
        <creator type="composer">Demo</creator>
      </identification>
      <part-list>
        <score-part id="P1">
          <part-name>Piano</part-name>
        </score-part>
      </part-list>
      <part id="P1">
        <measure number="1">
          <attributes>
            <divisions>1</divisions>
            <key>
              <fifths>0</fifths>
            </key>
            <time>
              <beats>4</beats>
              <beat-type>4</beat-type>
            </time>
            <clef>
              <sign>G</sign>
              <line>2</line>
            </clef>
          </attributes>
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>D</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>E</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>F</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
        </measure>
        <measure number="2">
          <note>
            <pitch>
              <step>G</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>A</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>B</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>C</step>
              <octave>5</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
        </measure>
      </part>
    </score-partwise>
    """
    
    /// Twinkle, Twinkle, Little Star
    static let twinkleTwinkleLittleStar = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
    <score-partwise version="3.1">
      <work>
        <work-title>Twinkle, Twinkle, Little Star</work-title>
      </work>
      <identification>
        <creator type="composer">Traditional</creator>
      </identification>
      <part-list>
        <score-part id="P1">
          <part-name>Melody</part-name>
        </score-part>
      </part-list>
      <part id="P1">
        <measure number="1">
          <attributes>
            <divisions>2</divisions>
            <key>
              <fifths>0</fifths>
            </key>
            <time>
              <beats>4</beats>
              <beat-type>4</beat-type>
            </time>
            <clef>
              <sign>G</sign>
              <line>2</line>
            </clef>
          </attributes>
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>2</duration>
            <type>half</type>
          </note>
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>2</duration>
            <type>half</type>
          </note>
        </measure>
        <measure number="2">
          <note>
            <pitch>
              <step>G</step>
              <octave>4</octave>
            </pitch>
            <duration>2</duration>
            <type>half</type>
          </note>
          <note>
            <pitch>
              <step>G</step>
              <octave>4</octave>
            </pitch>
            <duration>2</duration>
            <type>half</type>
          </note>
        </measure>
        <measure number="3">
          <note>
            <pitch>
              <step>A</step>
              <octave>4</octave>
            </pitch>
            <duration>2</duration>
            <type>half</type>
          </note>
          <note>
            <pitch>
              <step>A</step>
              <octave>4</octave>
            </pitch>
            <duration>2</duration>
            <type>half</type>
          </note>
        </measure>
        <measure number="4">
          <note>
            <pitch>
              <step>G</step>
              <octave>4</octave>
            </pitch>
            <duration>4</duration>
            <type>whole</type>
          </note>
        </measure>
      </part>
    </score-partwise>
    """

    /// Bach Minuet (simplified)
    static let bachMinuet = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
    <score-partwise version="3.1">
      <work>
        <work-title>Minuet in G Major</work-title>
      </work>
      <identification>
        <creator type="composer">J.S. Bach</creator>
      </identification>
      <part-list>
        <score-part id="P1">
          <part-name>Piano</part-name>
        </score-part>
      </part-list>
      <part id="P1">
        <measure number="1">
          <attributes>
            <divisions>2</divisions>
            <key>
              <fifths>1</fifths>
            </key>
            <time>
              <beats>3</beats>
              <beat-type>4</beat-type>
            </time>
            <clef>
              <sign>G</sign>
              <line>2</line>
            </clef>
          </attributes>
          <note>
            <pitch>
              <step>D</step>
              <octave>5</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>G</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>A</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>B</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
        </measure>
        <measure number="2">
          <note>
            <pitch>
              <step>C</step>
              <octave>5</octave>
            </pitch>
            <duration>2</duration>
            <type>half</type>
          </note>
          <note>
            <pitch>
              <step>B</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
        </measure>
        <measure number="3">
          <note>
            <pitch>
              <step>A</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>B</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
          <note>
            <pitch>
              <step>C</step>
              <octave>5</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
        </measure>
        <measure number="4">
          <note>
            <pitch>
              <step>B</step>
              <octave>4</octave>
            </pitch>
            <duration>2</duration>
            <type>half</type>
          </note>
          <note>
            <pitch>
              <step>A</step>
              <octave>4</octave>
            </pitch>
            <duration>1</duration>
            <type>quarter</type>
          </note>
        </measure>
      </part>
    </score-partwise>
    """

    /// Simple chord progression
    static let chordProgression = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
    <score-partwise version="3.1">
      <work>
        <work-title>Chord Progression</work-title>
      </work>
      <identification>
        <creator type="composer">Demo</creator>
      </identification>
      <part-list>
        <score-part id="P1">
          <part-name>Piano</part-name>
        </score-part>
      </part-list>
      <part id="P1">
        <measure number="1">
          <attributes>
            <divisions>4</divisions>
            <key>
              <fifths>0</fifths>
            </key>
            <time>
              <beats>4</beats>
              <beat-type>4</beat-type>
            </time>
            <clef>
              <sign>G</sign>
              <line>2</line>
            </clef>
          </attributes>
          <note>
            <pitch>
              <step>C</step>
              <octave>4</octave>
            </pitch>
            <duration>4</duration>
            <type>whole</type>
          </note>
          <note>
            <chord/>
            <pitch>
              <step>E</step>
              <octave>4</octave>
            </pitch>
            <duration>4</duration>
            <type>whole</type>
          </note>
          <note>
            <chord/>
            <pitch>
              <step>G</step>
              <octave>4</octave>
            </pitch>
            <duration>4</duration>
            <type>whole</type>
          </note>
        </measure>
        <measure number="2">
          <note>
            <pitch>
              <step>F</step>
              <octave>4</octave>
            </pitch>
            <duration>4</duration>
            <type>whole</type>
          </note>
          <note>
            <chord/>
            <pitch>
              <step>A</step>
              <octave>4</octave>
            </pitch>
            <duration>4</duration>
            <type>whole</type>
          </note>
          <note>
            <chord/>
            <pitch>
              <step>C</step>
              <octave>5</octave>
            </pitch>
            <duration>4</duration>
            <type>whole</type>
          </note>
        </measure>
      </part>
    </score-partwise>
    """
}
