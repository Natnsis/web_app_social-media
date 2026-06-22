"use client"

import { useState, useCallback, useEffect } from "react"
import { useParams, useSearchParams } from "next/navigation"
import Link from "next/link"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetConversation } from "@/lib/api/messaging"
import { apiGetGroupComments } from "@/lib/api/groups"
import { useMessagingSocket } from "@/hooks/use-messaging-socket"
import { useGroupSocket } from "@/hooks/use-group-socket"
import { MessageBubble } from "@/components/chat/message-bubble"
import { ChatInput } from "@/components/chat/chat-input"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { ChevronLeft, CircleInformation } from "nasicon-react/outline"
import type { MessageEvent, GroupComment } from "@/types"

export default function ChatConversationPage() {
  const params = useParams()
  const searchParams = useSearchParams()
  const id = params.id as string
  const isGroup = searchParams.get("type") === "group"

  const { user, accessToken } = useAuthStore()
  const tokenValid = !!accessToken

  const [dmMessages, setDmMessages] = useState<MessageEvent[]>([])
  const [groupMessages, setGroupMessages] = useState<GroupComment[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)
  const [typingUserId, setTypingUserId] = useState<string | null>(null)
  const [conversationName, setConversationName] = useState("")
  const [conversationInitials, setConversationInitials] = useState("?")

  // Fetch messages
  useEffect(() => {
    if (!id) return
    setLoading(true)
    setError(false)

    if (isGroup) {
      apiGetGroupComments(id)
        .then((res) => {
          setGroupMessages(res.data ?? [])
          const first = res.data?.[0]
          if (first?.sender) {
            setConversationName(first.sender.fullName || "Group")
            setConversationInitials(first.sender.fullName?.slice(0, 2).toUpperCase() || "G")
          }
          setLoading(false)
        })
        .catch(() => {
          setGroupMessages([])
          setLoading(false)
          setError(true)
        })
    } else {
      apiGetConversation(id)
        .then((res) => {
          const msgs = res.data?.messages ?? []
          setDmMessages(msgs)
          const other = res.data?.participantA?.id === user?.id ? res.data?.participantB : res.data?.participantA
          if (other) {
            setConversationName(other.fullName)
            setConversationInitials(other.initials || other.fullName?.charAt(0).toUpperCase() || "?")
          }
          setLoading(false)
        })
        .catch(() => {
          setDmMessages([])
          setLoading(false)
          setError(true)
        })
    }
  }, [id, isGroup, user?.id])

  // ── DM socket ──
  const onMessageNew = useCallback(
    (msg: MessageEvent) => {
      if (msg.conversationId === id) setDmMessages((prev) => [...prev, msg])
    },
    [id],
  )
  const onMessageUpdated = useCallback((msg: MessageEvent) => {
    setDmMessages((prev) => prev.map((m) => (m.id === msg.id ? msg : m)))
  }, [])
  const onMessageDeleted = useCallback(({ messageId }: { conversationId: string; messageId: string }) => {
    setDmMessages((prev) => prev.filter((m) => m.id !== messageId))
  }, [])
  const onTypingStart = useCallback(
    ({ conversationId, userId }: { conversationId: string; userId: string }) => {
      if (conversationId === id && userId !== user?.id) setTypingUserId(userId)
    },
    [id, user?.id],
  )
  const onTypingStop = useCallback(
    ({ conversationId }: { conversationId: string; userId: string }) => {
      if (conversationId === id) setTypingUserId(null)
    },
    [id],
  )

  const { sendMessage, sendRead, startTyping, stopTyping } = useMessagingSocket(tokenValid && !isGroup, {
    onMessageNew,
    onMessageUpdated,
    onMessageDeleted,
    onTypingStart,
    onTypingStop,
  })

  // ── Group socket ──
  const {
    sendMessage: sendGroupMessage,
    startTyping: startGroupTyping,
    stopTyping: stopGroupTyping,
  } = useGroupSocket(tokenValid && isGroup, {})

  // Mark as read on mount
  useEffect(() => {
    if (id && tokenValid && !isGroup) sendRead(id)
  }, [id, tokenValid, isGroup, sendRead])

  const handleSend = useCallback(
    (text: string) => {
      if (isGroup) {
        sendGroupMessage?.({ groupId: id, body: text })
      } else {
        sendMessage({ conversationId: id, body: text })
      }
    },
    [id, isGroup, sendMessage, sendGroupMessage],
  )

  const handleTypingStart = useCallback(() => {
    if (isGroup) startGroupTyping?.(id)
    else startTyping(id)
  }, [id, isGroup, startTyping, startGroupTyping])

  const handleTypingStop = useCallback(() => {
    if (isGroup) stopGroupTyping?.(id)
    else stopTyping(id)
  }, [id, isGroup, stopTyping, stopGroupTyping])

  const formatTime = (iso: string) =>
    new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })

  const msgs = isGroup
    ? groupMessages.map((m) => ({
        id: m.id,
        body: m.body,
        createdAt: m.createdAt,
        senderId: m.senderId,
        isRead: false,
      }))
    : dmMessages

  return (
    <div className="flex h-full flex-col overflow-hidden">
      <header className="flex shrink-0 items-center gap-2 border-b border-border px-2 py-2">
        <Link href={isGroup ? "/chats" : "/chats"} className="p-1 text-foreground">
          <ChevronLeft size={22} />
        </Link>
        <Avatar>
          <AvatarFallback className="bg-primary/20 text-primary font-semibold text-xs">
            {conversationInitials}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <p className="text-sm font-semibold leading-tight">{conversationName || (isGroup ? "Group" : "Conversation")}</p>
          <div className="flex items-center gap-1">
            <div className="size-1.5 rounded-full bg-green-500" />
            <p className="text-[11px] text-muted-foreground">{isGroup ? "Group" : "Active now"}</p>
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

        {error && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-destructive">Failed to load messages</p>
          </div>
        )}

        {!loading && !error && msgs.length === 0 && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-muted-foreground">No messages yet. Start the conversation!</p>
          </div>
        )}

        {msgs.map((msg) => (
          <MessageBubble
            key={msg.id}
            text={msg.body}
            time={formatTime(msg.createdAt)}
            from={msg.senderId === user?.id ? "me" : "them"}
            isRead={"isRead" in msg ? (msg as any).isRead : undefined}
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
        placeholder={isGroup ? "Type a group message..." : "Type a message..."}
      />
    </div>
  )
}
