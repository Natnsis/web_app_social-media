"use client"

import { useQuery } from "@tanstack/react-query"
import { apiGetConversations, apiGetUnreadCount } from "@/lib/api/messaging"

export function useConversations(enabled = true) {
  return useQuery({
    queryKey: ["conversations"],
    queryFn: apiGetConversations,
    enabled,
  })
}

export function useUnreadCount(enabled = true) {
  return useQuery({
    queryKey: ["unread-count"],
    queryFn: apiGetUnreadCount,
    enabled,
    refetchInterval: 30000,
  })
}
