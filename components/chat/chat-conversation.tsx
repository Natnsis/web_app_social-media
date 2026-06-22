"use client"

import { useState, useCallback, useRef, useEffect } from "react"
import Link from "next/link"
import { MessageBubble } from "@/components/chat/message-bubble"
import { ChatInput } from "@/components/chat/chat-input"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { ChevronLeft } from "nasicon-react/outline"
import dynamic from "next/dynamic"

const EmojiPicker = dynamic(() => import("emoji-picker-react"), { ssr: false })

interface ChatConversationProps {
  messages: Array<{
    id: string
    body: string
    createdAt: string
    senderId: string
    isRead?: boolean
    mediaUrl?: string | null
  }>
  loading: boolean
  error: boolean
  onSend: (text: string, mediaUrl?: string) => void
  onTypingStart?: () => void
  onTypingStop?: () => void
  typingUserId?: string | null
  headerName?: string
  headerInitials?: string
  headerOnline?: boolean
  headerStatusText?: string
  isGroup?: boolean
  onBack?: () => void
  conversationId?: string
  otherUserId?: string
  currentUserId?: string
  onDeleteMessage?: (messageId: string) => void
}

export function ChatConversation({
  messages,
  loading,
  error,
  onSend,
  onTypingStart,
  onTypingStop,
  typingUserId,
  headerName,
  headerInitials,
  headerOnline,
  headerStatusText,
  isGroup,
  onBack,
  conversationId,
  otherUserId,
  currentUserId,
  onDeleteMessage,
}: ChatConversationProps) {
  const [showEmoji, setShowEmoji] = useState(false)
  const [inputValue, setInputValue] = useState("")
  const [uploading, setUploading] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }, [messages])

  const handleEmojiClick = useCallback((emojiObject: { emoji: string }) => {
    setInputValue((prev) => prev + emojiObject.emoji)
  }, [])

  const handleFileSelect = useCallback(async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    setUploading(true)
    try {
      const { apiUploadMedia } = await import("@/lib/api/messaging")
      const res = await apiUploadMedia(file)
      const mediaUrl = res.data?.url ?? ""
      if (mediaUrl) {
        onSend("", mediaUrl)
      }
    } catch {
      console.error("Upload failed")
    } finally {
      setUploading(false)
      if (fileInputRef.current) fileInputRef.current.value = ""
    }
  }, [onSend])

  const handleSend = useCallback((text: string) => {
    onSend(text)
  }, [onSend])

  const formatTime = (iso: string) =>
    new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })

  return (
    <div className="flex h-full flex-col overflow-hidden">
      <header className="flex shrink-0 items-center gap-2 border-b border-border px-2 py-2">
        {onBack && (
          <button onClick={onBack} className="p-1 text-foreground">
            <ChevronLeft size={22} />
          </button>
        )}
        <Avatar>
          <AvatarFallback className="bg-primary/20 text-primary font-semibold text-xs">
            {headerInitials || (isGroup ? "G" : "?")}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <p className="truncate text-sm font-semibold leading-tight">
            {headerName || (isGroup ? "Group" : "Conversation")}
          </p>
          <div className="flex items-center gap-1">
            <div className={`size-1.5 rounded-full ${headerOnline ? "bg-green-500" : "bg-muted-foreground/30"}`} />
            <p className="text-[11px] text-muted-foreground">
              {headerStatusText ?? (isGroup ? "Group" : "Offline")}
            </p>
          </div>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto px-3 py-4 space-y-3">
        {loading && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-muted-foreground">Loading messages...</p>
          </div>
        )}

        {error && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-destructive">Failed to load messages</p>
          </div>
        )}

        {!loading && !error && messages.length === 0 && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-muted-foreground">No messages yet. Start the conversation!</p>
          </div>
        )}

        {messages.map((msg) => (
          <MessageBubble
            key={msg.id}
            text={msg.body}
            time={formatTime(msg.createdAt)}
            from={msg.senderId === currentUserId ? "me" : "them"}
            isRead={msg.isRead}
            mediaUrl={msg.mediaUrl}
            onDelete={onDeleteMessage ? () => onDeleteMessage(msg.id) : undefined}
          />
        ))}

        {typingUserId && (
          <div className="flex items-start">
            <div className="rounded-2xl rounded-bl-sm bg-muted px-3.5 py-2.5 text-sm text-muted-foreground">
              <span className="animate-pulse">typing...</span>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {showEmoji && (
        <div className="absolute bottom-16 left-0 right-0 z-50 mx-auto max-w-sm">
          <EmojiPicker onEmojiClick={handleEmojiClick} />
        </div>
      )}

      <ChatInput
        onSend={handleSend}
        onTypingStart={onTypingStart}
        onTypingStop={onTypingStop}
        placeholder={isGroup ? "Type a group message..." : "Type a message..."}
        onEmojiToggle={() => setShowEmoji((p) => !p)}
        showEmoji={showEmoji}
        onFileSelect={handleFileSelect}
        uploading={uploading}
        fileInputRef={fileInputRef}
        inputValue={inputValue}
        setInputValue={setInputValue}
      />
    </div>
  )
}
