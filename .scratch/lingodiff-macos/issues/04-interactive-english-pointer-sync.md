# Issue 04: Interactive English Pointer Highlighting & Bidirectional Card Sync

Type: prototype
Status: resolved
Blocked by: 01, 02, 03

## Question

How should the English text view render interactive verbatim substrings (`TextSpan` with gesture recognizers / mouse hover detectors) and synchronize hover/click events bidirectionally with the AI critique cards?

## Answer

Implemented non-overlapping substring positioning via `EnglishPointerMapper` (`lib/core/pointers/english_pointer_mapper.dart`), interactive rich-text rendering via `InteractiveEnglishView` (`lib/ui/widgets/interactive_english_view.dart`), and animated feedback cards via `CritiqueCardWidget` (`lib/ui/widgets/critique_card_widget.dart`). Hovering or clicking on an English pointer highlights and focuses the corresponding critique card, and vice versa. Full test coverage verified.
