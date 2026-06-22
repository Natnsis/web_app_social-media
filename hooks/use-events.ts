"use client"

import { useQuery } from "@tanstack/react-query"
import { apiGetEvents, apiGetEvent } from "@/lib/api/events"

export function useEvents(page = 1, limit = 20, churchId?: string, enabled = true) {
  return useQuery({
    queryKey: ["events", page, limit, churchId],
    queryFn: () => apiGetEvents(page, limit, churchId),
    enabled,
  })
}

export function useEvent(id: string, enabled = true) {
  return useQuery({
    queryKey: ["event", id],
    queryFn: () => apiGetEvent(id),
    enabled,
  })
}
