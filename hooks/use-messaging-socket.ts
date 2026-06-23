"use client"

import { useEffect, useRef, useCallback } from "react"
import { Socket } from "socket.io-client"
import { connectNamespace, disconnectNamespace } from "@/lib/socket"
import type {
  MessageEvent,
  MessageDeletedEvent,
  ConvReadEvent,
  TypingDmEvent,
  PresenceOnlineEvent,
  PresenceOfflineEvent,
} from "@/types"

interface UseMessagingSocketOptions {
  onMessageNew?: (message: MessageEvent) => void
  onMessageUpdated?: (message: MessageEvent) => void
  onMessageDeleted?: (event: MessageDeletedEvent) => void
  onConvRead?: (event: ConvReadEvent) => void
  onTypingStart?: (event: TypingDmEvent) => void
  onTypingStop?: (event: TypingDmEvent) => void
  onPresenceOnline?: (event: PresenceOnlineEvent) => void
  onPresenceOffline?: (event: PresenceOfflineEvent) => void
}

export function useMessagingSocket(enabled: boolean, options: UseMessagingSocketOptions) {
  const socketRef = useRef<Socket | null>(null)
  const optionsRef = useRef(options)
  optionsRef.current = options

  useEffect(() => {
    if (!enabled) return

    const socket = connectNamespace("/messaging")
    if (!socket) return
    socketRef.current = socket

    const onMessageNew = (msg: MessageEvent) => optionsRef.current.onMessageNew?.(msg)
    const onMessageUpdated = (msg: MessageEvent) => optionsRef.current.onMessageUpdated?.(msg)
    const onMessageDeleted = (event: MessageDeletedEvent) => optionsRef.current.onMessageDeleted?.(event)
    const onConvRead = (event: ConvReadEvent) => optionsRef.current.onConvRead?.(event)
    const onTypingStart = (event: TypingDmEvent) => optionsRef.current.onTypingStart?.(event)
    const onTypingStop = (event: TypingDmEvent) => optionsRef.current.onTypingStop?.(event)
    const onPresenceOnline = (event: PresenceOnlineEvent) => optionsRef.current.onPresenceOnline?.(event)
    const onPresenceOffline = (event: PresenceOfflineEvent) => optionsRef.current.onPresenceOffline?.(event)

    socket.on("message:new", onMessageNew)
    socket.on("message:updated", onMessageUpdated)
    socket.on("message:deleted", onMessageDeleted)
    socket.on("conv:read", onConvRead)
    socket.on("typing:start", onTypingStart)
    socket.on("typing:stop", onTypingStop)
    socket.on("presence:online", onPresenceOnline)
    socket.on("presence:offline", onPresenceOffline)

    return () => {
      socket.off("message:new", onMessageNew)
      socket.off("message:updated", onMessageUpdated)
      socket.off("message:deleted", onMessageDeleted)
      socket.off("conv:read", onConvRead)
      socket.off("typing:start", onTypingStart)
      socket.off("typing:stop", onTypingStop)
      socket.off("presence:online", onPresenceOnline)
      socket.off("presence:offline", onPresenceOffline)
      disconnectNamespace("/messaging")
      socketRef.current = null
    }
  }, [enabled])

  function emitSafe(event: string, ...args: unknown[]) {
    const socket = socketRef.current
    if (!socket) {
      console.warn(`[useMessagingSocket] Cannot emit "${event}" — socket not connected`)
      return
    }
    if (!socket.connected) {
      console.warn(`[useMessagingSocket] Socket not connected, emit "${event}" may be lost`)
    }
    socket.emit(event, ...args)
  }

  const sendMessage = useCallback((payload: { conversationId?: string; recipientId?: string; body: string; mediaUrl?: string }) => {
    emitSafe("message:send", payload)
  }, [])

  const sendRead = useCallback((conversationId: string) => {
    emitSafe("message:read", { conversationId })
  }, [])

  const startTyping = useCallback((conversationId: string) => {
    emitSafe("typing:start", { conversationId })
  }, [])

  const stopTyping = useCallback((conversationId: string) => {
    emitSafe("typing:stop", { conversationId })
  }, [])

  return { sendMessage, sendRead, startTyping, stopTyping }
}
