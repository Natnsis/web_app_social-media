"use client"

import { useState, useCallback, useRef } from "react"
import { Send, FaceSmile } from "nasicon-react/outline"

interface ChatInputProps {
  onSend: (text: string) => void
  onTypingStart?: () => void
  onTypingStop?: () => void
  placeholder?: string
}

export function ChatInput({ onSend, onTypingStart, onTypingStop, placeholder = "Type a message..." }: ChatInputProps) {
  const [input, setInput] = useState("")
  const typingTimer = useRef<ReturnType<typeof setTimeout> | null>(null)

  const handleSend = useCallback(() => {
    if (!input.trim()) return
    onSend(input.trim())
    setInput("")
    onTypingStop?.()
  }, [input, onSend, onTypingStop])

  const handleKey = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === "Enter") handleSend()
    },
    [handleSend],
  )

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setInput(e.target.value)
      onTypingStart?.()
      if (typingTimer.current) clearTimeout(typingTimer.current)
      typingTimer.current = setTimeout(() => onTypingStop?.(), 2000)
    },
    [onTypingStart, onTypingStop],
  )

  return (
    <div className="flex shrink-0 items-center gap-2 border-t border-border px-3 py-2">
      <input
        type="text"
        value={input}
        onChange={handleChange}
        onKeyDown={handleKey}
        placeholder={placeholder}
        className="flex-1 rounded-full border border-border bg-muted px-4 py-2 text-sm outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
      />
      <button type="button" className="text-muted-foreground">
        <FaceSmile size={22} />
      </button>
      <button
        type="button"
        onClick={handleSend}
        className="flex size-9 items-center justify-center rounded-full bg-primary text-primary-foreground"
      >
        <Send size={16} />
      </button>
    </div>
  )
}
