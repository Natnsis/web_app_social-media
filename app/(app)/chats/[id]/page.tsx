"use client"

import { useState, useCallback, useEffect } from "react"
import { useParams, useSearchParams } from "next/navigation"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetConversation, apiDeleteMessage } from "@/lib/api/messaging"
import { apiGetGroupComments } from "@/lib/api/groups"
import { useMessagingSocket } from "@/hooks/use-messaging-socket"
import { useGroupSocket } from "@/hooks/use-group-socket"
import { ChatConversation } from "@/components/chat/chat-conversation"
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

  const [otherUserId, setOtherUserId] = useState<string | undefined>()

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
          const conv = res.data?.conversation
          const other = conv?.participantA?.id === user?.id ? conv?.participantB : conv?.participantA
          if (other) {
            setConversationName(other.fullName)
            setConversationInitials(other.initials || other.fullName?.charAt(0).toUpperCase() || "?")
            setOtherUserId(other.id)
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
  const onGroupMessageNew = useCallback(
    (comment: GroupComment) => {
      if (comment.groupId === id) setGroupMessages((prev) => [...prev, comment])
    },
    [id],
  )
  const onGroupMessageUpdated = useCallback((msg: GroupComment) => {
    setGroupMessages((prev) => prev.map((m) => (m.id === msg.id ? msg : m)))
  }, [])
  const onGroupMessageDeleted = useCallback(({ messageId }: { groupId: string; messageId: string }) => {
    setGroupMessages((prev) => prev.filter((m) => m.id !== messageId))
  }, [])
  const onGroupTypingStart = useCallback(
    ({ groupId, userId }: { groupId: string; userId: string }) => {
      if (groupId === id && userId !== user?.id) setTypingUserId(userId)
    },
    [id, user?.id],
  )
  const onGroupTypingStop = useCallback(
    ({ groupId }: { groupId: string }) => {
      if (groupId === id) setTypingUserId(null)
    },
    [id],
  )

  const {
    sendMessage: sendGroupMessage,
    startTyping: startGroupTyping,
    stopTyping: stopGroupTyping,
  } = useGroupSocket(tokenValid && isGroup, {
    onMessageNew: onGroupMessageNew,
    onMessageUpdated: onGroupMessageUpdated,
    onMessageDeleted: onGroupMessageDeleted,
    onTypingStart: onGroupTypingStart,
    onTypingStop: onGroupTypingStop,
  })

  // Mark as read on mount
  useEffect(() => {
    if (id && tokenValid && !isGroup) sendRead(id)
  }, [id, tokenValid, isGroup, sendRead])

  const handleSend = useCallback(
    (text: string, mediaUrl?: string) => {
      if (isGroup) {
        sendGroupMessage?.({ groupId: id, body: text, mediaUrl })
      } else {
        sendMessage({ conversationId: id, body: text, mediaUrl })
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

  const handleDeleteMessage = useCallback(
    (messageId: string) => {
      apiDeleteMessage(messageId).catch(() => {})
      if (isGroup) {
        setGroupMessages((prev) => prev.filter((m) => m.id !== messageId))
      } else {
        setDmMessages((prev) => prev.filter((m) => m.id !== messageId))
      }
    },
    [isGroup],
  )

  const msgs = isGroup
    ? groupMessages.map((m) => ({
        id: m.id,
        body: m.body,
        createdAt: m.createdAt,
        senderId: m.senderId,
        isRead: false,
        mediaUrl: m.mediaUrl,
      }))
    : dmMessages

  return (
    <ChatConversation
      messages={msgs}
      loading={loading}
      error={error}
      onSend={handleSend}
      onTypingStart={handleTypingStart}
      onTypingStop={handleTypingStop}
      typingUserId={typingUserId}
      headerName={conversationName || (isGroup ? "Group" : "Conversation")}
      headerInitials={conversationInitials}
      headerOnline
      headerStatusText={isGroup ? "Group" : undefined}
      isGroup={isGroup}
      onBack={() => window.history.back()}
      conversationId={id}
      otherUserId={otherUserId}
      currentUserId={user?.id}
      onDeleteMessage={handleDeleteMessage}
    />
  )
}
