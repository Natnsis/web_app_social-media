"use client"

import { useQuery } from "@tanstack/react-query"
import { apiGetLiveStreams, apiGetLiveStream } from "@/lib/api/livestream"

export function useLiveStreams(enabled = true) {
  return useQuery({
    queryKey: ["livestreams"],
    queryFn: apiGetLiveStreams,
    enabled,
  })
}

export function useLiveStream(id: string | null) {
  return useQuery({
    queryKey: ["livestream", id],
    queryFn: () => apiGetLiveStream(id!),
    enabled: !!id,
  })
}
