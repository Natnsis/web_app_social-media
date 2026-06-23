"use client"

import { useState, useCallback, useEffect } from "react"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetConversation, apiDeleteMessage, apiSendGroupComment } from "@/lib/api/messaging"
import { apiGetGroupComments, apiGetGroupMembers, apiJoinGroup, apiJoinGroupRequest } from "@/lib/api/groups"
import { useMessagingSocket } from "@/hooks/use-messaging-socket"
import { useGroupSocket } from "@/hooks/use-group-socket"
import { ChatConversation } from "@/components/chat/chat-conversation"
import { Users } from "nasicon-react/outline"
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

function normalizeGroupComments(value: unknown): GroupComment[] {
  if (Array.isArray(value)) return value

  if (value && typeof value === "object" && "data" in value) {
    const nested = (value as { data?: unknown }).data
    return Array.isArray(nested) ? nested : []
  }

  return []
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
  const [isMember, setIsMember] = useState<boolean | null>(null)
  const [joining, setJoining] = useState(false)
  const [requestSent, setRequestSent] = useState(false)
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
    setIsMember(null)

    if (isGroup) {
      apiGetGroupMembers(id)
        .then((res) => {
          const member = res.data.some((m) => m.userId === user?.id)
          setIsMember(member)
          if (member) {
            return apiGetGroupComments(id).then((res2) => {
              setGroupMessages(normalizeGroupComments(res2.data.data) || [])
              setDmMessages([])
              setLoading(false)
            })
          }
          setDmMessages([])
          setLoading(false)
        })
        .catch(() => {
          setIsMember(false)
          setDmMessages([])
          setLoading(false)
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
      if (msg.conversationId === id) {
        setDmMessages((prev) => (prev.some((m) => m.id === msg.id) ? prev : [...prev, msg]))
      }
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
      if (comment.groupId === id) {
        setGroupMessages((prev) => (prev.some((m) => m.id === comment.id) ? prev : [...prev, comment]))
      }
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

  const handleJoinGroup = useCallback(async () => {
    setJoining(true)
    try {
      await apiJoinGroup(id)
      setIsMember(true)
      setLoading(true)
      const res = await apiGetGroupComments(id)
      setGroupMessages(normalizeGroupComments(res.data.data) || [])
      setDmMessages([])
      setLoading(false)
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : ""
      if (msg.toLowerCase().includes("private group") || msg.includes("join-requests")) {
        try {
          await apiJoinGroupRequest(id)
          setRequestSent(true)
        } catch {
          // request failed silently
        }
      }
      setJoining(false)
    }
  }, [id])

  useEffect(() => {
    if (id && tokenValid && !isGroup) sendRead(id)
  }, [id, tokenValid, isGroup, sendRead])

  const handleSend = useCallback(
    async (text: string, mediaUrl?: string) => {
      if (isGroup) {
        if (mediaUrl) {
          sendGroupMessage?.({ groupId: id, body: text, mediaUrl })
          return
        }
        try {
          sendGroupMessage?.({ groupId: id, body: text })
        } catch {
          await apiSendGroupComment(id, text)
        }
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
    ? normalizeGroupComments(groupMessages).map((m) => ({
        id: m.id,
        body: m.body,
        createdAt: m.createdAt,
        senderId: m.senderId,
        isRead: false,
        mediaUrl: m.mediaUrl,
      }))
    : dmMessages

  if (isGroup && isMember === false) {
    return (
      <div className="flex h-full min-w-0 flex-1 flex-col items-center justify-center gap-4 p-6">
        <div className="flex size-16 items-center justify-center rounded-full bg-primary/10">
          <Users size={32} className="text-primary" />
        </div>
        <div className="text-center">
          <p className="text-lg font-semibold">{initialHeaderName || "Group"}</p>
          {requestSent ? (
            <>
              <p className="mt-1 text-sm text-muted-foreground">Join request sent</p>
              <p className="mt-0.5 text-xs text-muted-foreground/60">An admin will review your request</p>
            </>
          ) : (
            <p className="mt-1 text-sm text-muted-foreground">You're not a member of this group</p>
          )}
        </div>
        {!requestSent && (
          <button
            onClick={handleJoinGroup}
            disabled={joining}
            className="inline-flex items-center gap-2 rounded-xl bg-primary px-6 py-2.5 text-sm font-semibold text-primary-foreground transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            {joining ? "Joining..." : "Join Group"}
          </button>
        )}
      </div>
    )
  }

  return (
    <div className="h-full min-w-0 flex-1 overflow-hidden">
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
        chatId={id}
        otherUserId={otherUserId}
        currentUserId={user?.id}
        onDeleteMessage={handleDeleteMessage}
      />
    </div>
  )
}
