"use client"

import { useState, useCallback, useEffect } from "react"
import { useParams } from "next/navigation"
import Link from "next/link"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetConversation } from "@/lib/api/messaging"
import { useMessagingSocket } from "@/hooks/use-messaging-socket"
import { MessageBubble } from "@/components/chat/message-bubble"
import { ChatInput } from "@/components/chat/chat-input"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { ChevronLeft, CircleInformation } from "nasicon-react/outline"
import type { MessageEvent } from "@/types"

export default function ChatConversationPage() {
  const params = useParams()
  const conversationId = params.id as string
  const { user, accessToken } = useAuthStore()
  const tokenValid = !!accessToken

  const [messages, setMessages] = useState<MessageEvent[]>([])
  const [loading, setLoading] = useState(true)
  const [typingUserId, setTypingUserId] = useState<string | null>(null)

  useEffect(() => {
    if (!conversationId) return
    setLoading(true)
    apiGetConversation(conversationId)
      .then((res) => {
        setMessages(res.data ?? [])
        setLoading(false)
      })
      .catch(() => {
        setMessages([])
        setLoading(false)
      })
  }, [conversationId])

  const onMessageNew = useCallback((msg: MessageEvent) => {
    if (msg.conversationId === conversationId) {
      setMessages((prev) => [...prev, msg])
    }
  }, [conversationId])

  const onMessageUpdated = useCallback((msg: MessageEvent) => {
    setMessages((prev) => prev.map((m) => (m.id === msg.id ? msg : m)))
  }, [])

  const onMessageDeleted = useCallback(({ messageId }: { conversationId: string; messageId: string }) => {
    setMessages((prev) => prev.filter((m) => m.id !== messageId))
  }, [])

  const onTypingStart = useCallback(
    ({ conversationId: convId, userId }: { conversationId: string; userId: string }) => {
      if (convId === conversationId && userId !== user?.id) setTypingUserId(userId)
    },
    [conversationId, user?.id],
  )

  const onTypingStop = useCallback(
    ({ conversationId: convId }: { conversationId: string; userId: string }) => {
      if (convId === conversationId) setTypingUserId(null)
    },
    [conversationId],
  )

  const { sendMessage, sendRead, startTyping, stopTyping } = useMessagingSocket(tokenValid, {
    onMessageNew,
    onMessageUpdated,
    onMessageDeleted,
    onTypingStart,
    onTypingStop,
  })

  useEffect(() => {
    if (conversationId && tokenValid) {
      sendRead(conversationId)
    }
  }, [conversationId, tokenValid, sendRead])

  const handleSend = useCallback(
    (text: string) => {
      sendMessage({ conversationId, body: text })
    },
    [conversationId, sendMessage],
  )

  const handleTypingStart = useCallback(() => {
    startTyping(conversationId)
  }, [conversationId, startTyping])

  const handleTypingStop = useCallback(() => {
    stopTyping(conversationId)
  }, [conversationId, stopTyping])

  const formatTime = (iso: string) => {
    const d = new Date(iso)
    return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
  }

  const otherParticipant = messages.length > 0 ? messages[0].sender : null

  return (
    <div className="flex h-full flex-col overflow-hidden">
      <header className="flex shrink-0 items-center gap-2 border-b border-border px-2 py-2">
        <Link href="/chats" className="p-1 text-foreground">
          <ChevronLeft size={22} />
        </Link>
        <Avatar>
          <AvatarFallback className="bg-primary/20 text-primary font-semibold text-xs">
            {otherParticipant ? otherParticipant.fullName.charAt(0).toUpperCase() : "?"}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <p className="text-sm font-semibold leading-tight">{otherParticipant?.fullName ?? "Conversation"}</p>
          <div className="flex items-center gap-1">
            <div className="size-1.5 rounded-full bg-green-500" />
            <p className="text-[11px] text-muted-foreground">Active now</p>
          </div>
        </div>
        <button type="button" className="flex size-7 items-center justify-center rounded-full bg-primary text-primary-foreground">
          <CircleInformation size={16} />
        </button>
      </header>

      <div className="flex-1 overflow-y-auto px-3 py-4 space-y-3">
        {loading && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-muted-foreground">Loading messages...</p>
          </div>
        )}

        {!loading && messages.length === 0 && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-muted-foreground">No messages yet. Start a conversation!</p>
          </div>
        )}

        {messages.map((msg) => (
          <MessageBubble
            key={msg.id}
            text={msg.body}
            time={formatTime(msg.createdAt)}
            from={msg.senderId === user?.id ? "me" : "them"}
            isRead={msg.isRead}
          />
        ))}

        {typingUserId && (
          <div className="flex items-start">
            <div className="rounded-2xl rounded-bl-sm bg-muted px-3.5 py-2.5 text-sm text-muted-foreground">
              <span className="animate-pulse">typing...</span>
            </div>
          </div>
        )}
      </div>

      <ChatInput
        onSend={handleSend}
        onTypingStart={handleTypingStart}
        onTypingStop={handleTypingStop}
      />
    </div>
  )
}
