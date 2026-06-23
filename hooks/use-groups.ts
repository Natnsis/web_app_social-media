"use client"

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { useAuthStore } from "@/lib/store/auth"
import {
  apiGetGroups,
  apiGetGroupComments,
  apiGetGroupMembers,
  apiCreateGroupFormData,
  apiUpdateGroup,
  apiDeleteGroup,
} from "@/lib/api/groups"

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

export function useGroupMembers(groupId: string | null) {
  const { isAuthenticated } = useAuthStore()

  return useQuery({
    queryKey: ["group-members", groupId],
    queryFn: () => apiGetGroupMembers(groupId!),
    enabled: isAuthenticated && !!groupId,
  })
}

export function useCreateGroup() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: (formData: FormData) => apiCreateGroupFormData(formData),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["groups"] })
    },
  })
}

export function useUpdateGroup() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: ({ id, formData }: { id: string; formData: FormData }) =>
      apiUpdateGroup(id, formData),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["groups"] })
    },
  })
}

export function useDeleteGroup() {
  const qc = useQueryClient()

  return useMutation({
    mutationFn: (id: string) => apiDeleteGroup(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["groups"] })
    },
  })
}
