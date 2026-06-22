"use client"

import { useState, useCallback, useRef } from "react"
import { Send, FaceSmile, Paperclip, Loader } from "nasicon-react/outline"
import type { RefObject } from "react"

interface ChatInputProps {
  onSend: (text: string) => void
  onTypingStart?: () => void
  onTypingStop?: () => void
  placeholder?: string
  onEmojiToggle?: () => void
  showEmoji?: boolean
  onFileSelect?: (e: React.ChangeEvent<HTMLInputElement>) => void
  uploading?: boolean
  fileInputRef?: RefObject<HTMLInputElement | null>
  inputValue?: string
  setInputValue?: (val: string) => void
}

export function ChatInput({
  onSend,
  onTypingStart,
  onTypingStop,
  placeholder = "Type a message...",
  onEmojiToggle,
  showEmoji,
  onFileSelect,
  uploading,
  fileInputRef: externalFileRef,
  inputValue: externalValue,
  setInputValue: externalSetValue,
}: ChatInputProps) {
  const internalInput = useState("")
  const [internalValue, setInternalValue] = internalInput
  const inputValue = externalValue !== undefined ? externalValue : internalValue
  const setInputValue = externalSetValue || setInternalValue
  const internalFileRef = useRef<HTMLInputElement>(null)
  const fileRef = externalFileRef || internalFileRef
  const typingTimer = useRef<ReturnType<typeof setTimeout> | null>(null)

  const handleSend = useCallback(() => {
    if (!inputValue.trim()) return
    onSend(inputValue.trim())
    setInputValue("")
    onTypingStop?.()
  }, [inputValue, onSend, onTypingStop, setInputValue])

  const handleKey = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === "Enter") handleSend()
    },
    [handleSend],
  )

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setInputValue(e.target.value)
      onTypingStart?.()
      if (typingTimer.current) clearTimeout(typingTimer.current)
      typingTimer.current = setTimeout(() => onTypingStop?.(), 2000)
    },
    [onTypingStart, onTypingStop, setInputValue],
  )

  return (
    <div className="flex shrink-0 items-center gap-2 border-t border-border px-3 py-2">
      <input
        type="file"
        ref={fileRef as RefObject<HTMLInputElement | null>}
        onChange={onFileSelect}
        className="hidden"
        accept="image/*,video/*,.pdf,.doc,.docx"
      />
      <button
        type="button"
        onClick={() => fileRef.current?.click()}
        className="text-muted-foreground hover:text-foreground transition-colors"
        disabled={uploading}
      >
        {uploading ? <Loader size={22} className="animate-spin" /> : <Paperclip size={22} />}
      </button>
      <button
        type="button"
        onClick={onEmojiToggle}
        className={`transition-colors ${showEmoji ? "text-primary" : "text-muted-foreground hover:text-foreground"}`}
      >
        <FaceSmile size={22} />
      </button>
      <input
        type="text"
        value={inputValue}
        onChange={handleChange}
        onKeyDown={handleKey}
        placeholder={placeholder}
        className="flex-1 rounded-full border border-border bg-muted px-4 py-2 text-sm outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
      />
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
