"use client"

import { useQuery } from "@tanstack/react-query"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetGroups, apiGetGroupComments } from "@/lib/api/groups"

export function useGroups() {
  const { isAuthenticated } = useAuthStore()
  
  return useQuery({
    queryKey: ["groups"],
    queryFn: apiGetGroups,
    enabled: isAuthenticated,
    staleTime: 30000,
    gcTime: 5 * 60 * 1000,
  })
}

export function useGroupComments(groupId: string | null) {
  const { isAuthenticated } = useAuthStore()
  
  return useQuery({
    queryKey: ["group-comments", groupId],
    queryFn: () => apiGetGroupComments(groupId!),
    enabled: isAuthenticated && !!groupId,
    staleTime: 15000,
    gcTime: 5 * 60 * 1000,
  })
}
