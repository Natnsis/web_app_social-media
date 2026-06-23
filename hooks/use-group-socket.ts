"use client"

import { useEffect, useRef, useCallback } from "react"
import { Socket } from "socket.io-client"
import { connectNamespace, disconnectNamespace } from "@/lib/socket"
import type {
  GroupComment,
  GroupMessageReplyEvent,
  GroupMessageDeletedEvent,
  GroupMessageSeenEvent,
  GroupTypingEvent,
  GroupMemberJoinedEvent,
  GroupMemberLeftEvent,
  PresenceOnlineEvent,
  PresenceOfflineEvent,
} from "@/types"

interface UseGroupSocketOptions {
  onMessageNew?: (comment: GroupComment) => void
  onMessageReply?: (event: GroupMessageReplyEvent) => void
  onMessageUpdated?: (message: GroupComment) => void
  onMessageDeleted?: (event: GroupMessageDeletedEvent) => void
  onMessageSeen?: (event: GroupMessageSeenEvent) => void
  onTypingStart?: (event: GroupTypingEvent) => void
  onTypingStop?: (event: GroupTypingEvent) => void
  onMemberJoined?: (event: GroupMemberJoinedEvent) => void
  onMemberLeft?: (event: GroupMemberLeftEvent) => void
  onPresenceOnline?: (event: PresenceOnlineEvent) => void
  onPresenceOffline?: (event: PresenceOfflineEvent) => void
}

export function useGroupSocket(enabled: boolean, options: UseGroupSocketOptions) {
  const socketRef = useRef<Socket | null>(null)
  const optionsRef = useRef(options)
  optionsRef.current = options

  useEffect(() => {
    if (!enabled) return

    const socket = connectNamespace("/groups")
    if (!socket) return
    socketRef.current = socket

    const onMessageNew = (msg: GroupComment) => optionsRef.current.onMessageNew?.(msg)
    const onMessageReply = (event: GroupMessageReplyEvent) => optionsRef.current.onMessageReply?.(event)
    const onMessageUpdated = (msg: GroupComment) => optionsRef.current.onMessageUpdated?.(msg)
    const onMessageDeleted = (event: GroupMessageDeletedEvent) => optionsRef.current.onMessageDeleted?.(event)
    const onMessageSeen = (event: GroupMessageSeenEvent) => optionsRef.current.onMessageSeen?.(event)
    const onTypingStart = (event: GroupTypingEvent) => optionsRef.current.onTypingStart?.(event)
    const onTypingStop = (event: GroupTypingEvent) => optionsRef.current.onTypingStop?.(event)
    const onMemberJoined = (event: GroupMemberJoinedEvent) => optionsRef.current.onMemberJoined?.(event)
    const onMemberLeft = (event: GroupMemberLeftEvent) => optionsRef.current.onMemberLeft?.(event)
    const onPresenceOnline = (event: PresenceOnlineEvent) => optionsRef.current.onPresenceOnline?.(event)
    const onPresenceOffline = (event: PresenceOfflineEvent) => optionsRef.current.onPresenceOffline?.(event)

    socket.on("connect", () => {
      console.log("[useGroupSocket] Connected to /groups namespace")
    })
    socket.on("disconnect", (reason) => {
      console.warn("[useGroupSocket] Disconnected from /groups namespace:", reason)
    })
    socket.on("connect_error", (err) => {
      console.error("[useGroupSocket] Connection error:", err.message)
    })

    socket.on("group:message:new", onMessageNew)
    socket.on("group:message:reply", onMessageReply)
    socket.on("group:message:updated", onMessageUpdated)
    socket.on("group:message:deleted", onMessageDeleted)
    socket.on("group:message:seen", onMessageSeen)
    socket.on("group:typing:start", onTypingStart)
    socket.on("group:typing:stop", onTypingStop)
    socket.on("group:member:joined", onMemberJoined)
    socket.on("group:member:left", onMemberLeft)
    socket.on("presence:online", onPresenceOnline)
    socket.on("presence:offline", onPresenceOffline)

    return () => {
      socket.off("connect")
      socket.off("disconnect")
      socket.off("connect_error")
      socket.off("group:message:new", onMessageNew)
      socket.off("group:message:reply", onMessageReply)
      socket.off("group:message:updated", onMessageUpdated)
      socket.off("group:message:deleted", onMessageDeleted)
      socket.off("group:message:seen", onMessageSeen)
      socket.off("group:typing:start", onTypingStart)
      socket.off("group:typing:stop", onTypingStop)
      socket.off("group:member:joined", onMemberJoined)
      socket.off("group:member:left", onMemberLeft)
      socket.off("presence:online", onPresenceOnline)
      socket.off("presence:offline", onPresenceOffline)
      disconnectNamespace("/groups")
      socketRef.current = null
    }
  }, [enabled])

  function emitSafe(event: string, ...args: unknown[]) {
    const socket = socketRef.current
    if (!socket) {
      console.warn(`[useGroupSocket] Cannot emit "${event}" — socket not connected`)
      return
    }
    if (!socket.connected) {
      console.warn(`[useGroupSocket] Socket not connected, emit "${event}" may be lost`)
    }
    socket.emit(event, ...args)
  }

  const sendMessage = useCallback((payload: { groupId: string; body: string; mediaUrl?: string }) => {
    emitSafe("group:message:send", payload)
  }, [])

  const sendRead = useCallback((payload: { groupId: string; messageId: string }) => {
    emitSafe("group:message:read", payload)
  }, [])

  const startTyping = useCallback((groupId: string) => {
    emitSafe("group:typing:start", { groupId })
  }, [])

  const stopTyping = useCallback((groupId: string) => {
    emitSafe("group:typing:stop", { groupId })
  }, [])

  return { sendMessage, sendRead, startTyping, stopTyping }
}
