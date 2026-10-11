# Visual system

## Reference

The approved visual reference is `report/ui/new/`. Keep the existing Tawabti
name. Screens use white cards on a very pale mint canvas, deep green feature
surfaces, and small warm gold accents. Night mode retains a black canvas with
charcoal cards, mint foregrounds and gold highlights.

## Palette

- Day: canvas #F0FCF5, cards #FFFFFF, green #0B5844, mint #E1F4E9.
- Gold accent #FFD85A; gold text #97701A.
- Night: canvas #000000, cards #151A17, mint text #9CD5AD.
- Existing alternate palettes remain selectable.

## Typography

Cairo is the interface family. Preserve the Quran font in the Quran reader.
Headings are confident but compact. Labels and supporting text can wrap.

## Components

Use 16 px page insets and 16–20 px card padding. White surfaces have 16 px
corners and a thin mint border. Nested settings use a quiet mint fill.
Deep green counter/prayer/tawaf panels use white text and gold progress.
Use real database values for statistics and counts.

## Navigation

Five persistent destinations: Home, Prayers, Quran, Dhikr and Tasbih.
Secondary pages can return to a root destination. Root pages are created on
first use and preserve their state. Keep one navigation bar on each screen.

## States and accessibility

Explicit loading, empty, failure and retry states. Minimum 48 px actions.
Validate Arabic, English and Urdu at 390 px, and 320 px with 160% text scaling.
Audio, reminder, search, counter and reading actions must remain functional.

## Reference boundaries

The widget setup page (4.png) describes a separate native home-screen widget
feature and is not implemented as a nonfunctional in-app setup flow.
The reference's illustrative statistics and expanded content catalog must not
be hardcoded into the app. Existing religious texts and sources are reused.
