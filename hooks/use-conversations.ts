"use client"

import { useQuery } from "@tanstack/react-query"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetConversations, apiGetConversation, apiGetUnreadCount } from "@/lib/api/messaging"

export function useConversations() {
  const { isAuthenticated } = useAuthStore()
  
  return useQuery({
    queryKey: ["conversations"],
    queryFn: apiGetConversations,
    enabled: isAuthenticated,
    staleTime: 30000,
    gcTime: 5 * 60 * 1000,
  })
}

export function useConversation(conversationId: string | null) {
  const { isAuthenticated } = useAuthStore()

  return useQuery({
    queryKey: ["conversation", conversationId],
    queryFn: () => apiGetConversation(conversationId!),
    enabled: isAuthenticated && !!conversationId,
    staleTime: 15000,
    gcTime: 5 * 60 * 1000,
  })
}

export function useUnreadCount() {
  const { isAuthenticated } = useAuthStore()
  
  return useQuery({
    queryKey: ["unread-count"],
    queryFn: apiGetUnreadCount,
    enabled: isAuthenticated,
    refetchInterval: 30000,
    staleTime: 10000,
    gcTime: 5 * 60 * 1000,
  })
}
