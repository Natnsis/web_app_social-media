"use client"

import { useEffect, useRef, useCallback } from "react"
import { Socket } from "socket.io-client"
import { connectNamespace, disconnectNamespace } from "@/lib/socket"
import type { NotificationEvent } from "@/types"

interface UseNotificationSocketOptions {
  onNotificationNew?: (n: NotificationEvent) => void
  onMarkedRead?: (event: { notificationId: string }) => void
  onAllMarkedRead?: () => void
}

export function useNotificationSocket(enabled: boolean, options: UseNotificationSocketOptions) {
  const socketRef = useRef<Socket | null>(null)
  const optionsRef = useRef(options)
  optionsRef.current = options

  useEffect(() => {
    if (!enabled) return

    const socket = connectNamespace("/notifications")
    if (!socket) return
    socketRef.current = socket

    const onNew = (n: NotificationEvent) => optionsRef.current.onNotificationNew?.(n)
    const onMarked = (event: { notificationId: string }) => optionsRef.current.onMarkedRead?.(event)
    const onAllMarked = () => optionsRef.current.onAllMarkedRead?.()

    socket.on("notification:new", onNew)
    socket.on("notification:marked-read", onMarked)
    socket.on("notification:all-marked-read", onAllMarked)

    return () => {
      socket.off("notification:new", onNew)
      socket.off("notification:marked-read", onMarked)
      socket.off("notification:all-marked-read", onAllMarked)
      disconnectNamespace("/notifications")
      socketRef.current = null
    }
  }, [enabled])

  const markRead = useCallback((notificationId: string) => {
    socketRef.current?.emit("notification:mark-read", { notificationId })
  }, [])

  const markAllRead = useCallback(() => {
    socketRef.current?.emit("notification:mark-all-read")
  }, [])

  return { markRead, markAllRead }
}
