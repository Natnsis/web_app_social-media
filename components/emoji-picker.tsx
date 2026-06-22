"use client"

import { useState } from "react"

const EMOJIS = [
  "🙏", "❤️", "😢", "😂", "🔥", "👍", "😍", "🙌",
  "🎉", "✨", "💪", "👏", "😊", "🥰", "🕊️", "🌟",
  "💯", "🔥", "😭", "🤍", "💙", "💜", "💚", "🧡",
  "🫂", "🤲", "✝️", "📖", "🕯️", "⛪",
]

const SUGGESTIONS = [
  "Amen", "Hallelujah", "God bless", "🙏",
  "Glory to God", "Thank you Jesus", "Beautiful", "❤️",
]

interface EmojiPickerProps {
  onEmojiSelect: (emoji: string) => void
  onSuggestionSelect: (text: string) => void
}

export function EmojiPicker({ onEmojiSelect, onSuggestionSelect }: EmojiPickerProps) {
  const [tab, setTab] = useState<"emoji" | "suggestions">("emoji")

  return (
    <div className="border-t border-border bg-popover px-3 py-2">
      <div className="mb-2 flex gap-2">
        <button
          onClick={() => setTab("emoji")}
          className={`rounded-full px-3 py-1 text-xs font-semibold transition-colors ${
            tab === "emoji"
              ? "bg-primary text-primary-foreground"
              : "bg-muted text-muted-foreground"
          }`}
        >
          Emojis
        </button>
        <button
          onClick={() => setTab("suggestions")}
          className={`rounded-full px-3 py-1 text-xs font-semibold transition-colors ${
            tab === "suggestions"
              ? "bg-primary text-primary-foreground"
              : "bg-muted text-muted-foreground"
          }`}
        >
          Quick replies
        </button>
      </div>

      {tab === "emoji" ? (
        <div className="grid grid-cols-8 gap-1">
          {EMOJIS.map((emoji) => (
            <button
              key={emoji}
              onClick={() => onEmojiSelect(emoji)}
              className="flex aspect-square items-center justify-center rounded-lg text-lg transition-colors hover:bg-muted"
            >
              {emoji}
            </button>
          ))}
        </div>
      ) : (
        <div className="flex flex-wrap gap-1.5">
          {SUGGESTIONS.map((text) => (
            <button
              key={text}
              onClick={() => onSuggestionSelect(text)}
              className="rounded-full bg-muted px-3 py-1.5 text-xs font-medium text-foreground transition-colors hover:bg-primary/20"
            >
              {text}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}
