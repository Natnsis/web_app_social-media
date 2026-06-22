"use client"

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { apiGetNotifications, apiMarkNotificationRead, apiMarkAllRead, apiGetNotificationPreferences, apiUpdateNotificationPreferences } from "@/lib/api/notifications"
import type { UpdateNotificationPreferencesPayload } from "@/lib/api/notifications"

export function useNotifications(skip = 0, take = 20, enabled = true) {
  return useQuery({
    queryKey: ["notifications", skip, take],
    queryFn: () => apiGetNotifications(skip, take),
    enabled,
  })
}

export function useNotificationPreferences(enabled = true) {
  return useQuery({
    queryKey: ["notification-preferences"],
    queryFn: apiGetNotificationPreferences,
    enabled,
  })
}

export function useMarkNotificationRead() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (notificationId: string) => apiMarkNotificationRead(notificationId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["notifications"] })
    },
  })
}

export function useMarkAllNotificationsRead() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: () => apiMarkAllRead(),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["notifications"] })
    },
  })
}

export function useUpdateNotificationPreferences() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (payload: UpdateNotificationPreferencesPayload) => apiUpdateNotificationPreferences(payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["notification-preferences"] })
    },
  })
}
