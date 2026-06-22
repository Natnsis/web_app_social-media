"use client"

import { useState, useCallback, useEffect } from "react"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetConversation, apiDeleteMessage } from "@/lib/api/messaging"
import { apiGetGroupComments } from "@/lib/api/groups"
import { useMessagingSocket } from "@/hooks/use-messaging-socket"
import { useGroupSocket } from "@/hooks/use-group-socket"
import { ChatConversation } from "@/components/chat/chat-conversation"
import type { MessageEvent, GroupComment } from "@/types"

interface ChatThreadProps {
  id: string
  isGroup?: boolean
  onBack?: () => void
  initialHeaderName?: string
  initialHeaderInitials?: string
  initialHeaderStatusText?: string
  initialHeaderOnline?: boolean
}

export function ChatThread({
  id,
  isGroup = false,
  onBack,
  initialHeaderName,
  initialHeaderInitials,
  initialHeaderStatusText,
  initialHeaderOnline,
}: ChatThreadProps) {
  const { user, accessToken } = useAuthStore()
  const tokenValid = !!accessToken

  const [dmMessages, setDmMessages] = useState<MessageEvent[]>([])
  const [groupMessages, setGroupMessages] = useState<GroupComment[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)
  const [typingUserId, setTypingUserId] = useState<string | null>(null)
  const [conversationName, setConversationName] = useState(initialHeaderName ?? "")
  const [conversationInitials, setConversationInitials] = useState(initialHeaderInitials ?? "?")
  const [otherUserId, setOtherUserId] = useState<string | undefined>()

  useEffect(() => {
    setConversationName(initialHeaderName ?? "")
    setConversationInitials(initialHeaderInitials ?? "?")
  }, [id, initialHeaderName, initialHeaderInitials])

  useEffect(() => {
    if (!id) return
    setLoading(true)
    setError(false)
    setTypingUserId(null)

    if (isGroup) {
      apiGetGroupComments(id)
        .then((res) => {
          setGroupMessages(res.data ?? [])
          setDmMessages([])
          setLoading(false)
        })
        .catch(() => {
          setGroupMessages([])
          setLoading(false)
          setError(true)
        })
      return
    }

    apiGetConversation(id)
      .then((res) => {
        const msgs = res.data?.messages ?? []
        setDmMessages(msgs)
        setGroupMessages([])
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
  }, [id, isGroup, user?.id])

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

  const messages = isGroup
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
    <div className="min-w-0 flex-1 overflow-hidden">
      <ChatConversation
        messages={messages}
        loading={loading}
        error={error}
        onSend={handleSend}
        onTypingStart={handleTypingStart}
        onTypingStop={handleTypingStop}
        typingUserId={typingUserId}
        headerName={conversationName || initialHeaderName || (isGroup ? "Group" : "Conversation")}
        headerInitials={conversationInitials}
        headerOnline={initialHeaderOnline}
        headerStatusText={initialHeaderStatusText ?? (isGroup ? "Group" : undefined)}
        isGroup={isGroup}
        onBack={onBack}
        conversationId={id}
        otherUserId={otherUserId}
        currentUserId={user?.id}
        onDeleteMessage={handleDeleteMessage}
      />
    </div>
  )
}
